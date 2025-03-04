import {
  ConnectedSocket,
  MessageBody,
  OnGatewayConnection,
  OnGatewayDisconnect,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { AuthService } from '../auth/auth.service';
import { UserService } from '../user/user.service';
import { JwtPayload } from '../auth/strategies/interfaces/jwt-payload.interface';
import { InviteDto } from './dto/invite.dto';
import { AlertDto } from './dto/alert.dto';
import { IgnoreDto } from './dto/ignore.dto';
import { AlertService } from './alert.service';

@WebSocketGateway({
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
  allowEIO3: true,
  transports: ['websocket', 'polling'],
  // 주소/alert에 대한 내용들을 처리한다는 구문
  namespace: '/alert',
})
export class AlertGateway implements OnGatewayConnection, OnGatewayDisconnect {
  constructor(
    private readonly authService: AuthService,
    private readonly userService: UserService,
    private readonly alertService: AlertService,
  ) {}

  // socket.io의 socket
  @WebSocketServer()
  server: Server;
  // 접속 중인 사용자 목록
  connectedUsers: Map<string, number> = new Map();

  // 접속 시작 처리
  async handleConnection(client: Socket) {
    // 접속 시작한 시간, ip 주소 로그
    console.log(new Date(), client.handshake.address, 'connection');
    let payload: JwtPayload;

    // 접속한 사용자의 요청 속 jwt에서 id값 꺼내기
    try {
    payload = await this.authService.fromSocket(client);
    } catch (e) {
      client.emit('alertConnection', 'Not Valid JWT');
      console.error(new Date(), 'invalid jwt', e);
      client.disconnect(true);

      return;
    }

    // 사용자의 요청에 jwt가 없을 때 접속 종료
    if (!payload) {
      client.emit('alertConnection', 'Not Valid Request');
      console.error(new Date(), 'no payload', payload);
      client.disconnect(true);

      return;
    }

    // 꺼낸 id값으로 사용자 불러오기
    const user = await this.userService.findOneById(payload.id);

    // 불러온 사용자가 없을 때 접속 종료
    if (!user) {
      client.emit('alertConnection', 'Not Valid User ID');
      console.error(new Date(), 'no user', user);
      client.disconnect(true);

      return;
    }

    // 사용자를 사용자 id를 이름으로 하는 방에 접속
    client.join('user: ' + user.id.toString());

    // 접속 중인 사용자 목록에 기기의 id와 사용자의 id 저장
    this.connectedUsers.set(client.id, user.id);

    return;
  }

  // 접속 종료 처리
  async handleDisconnect(client: Socket) {
    // 접속 해제한 시간, ip 주소 로그
    console.log(new Date(), client.handshake.address, 'disconnection');

    // 접속한 사용자의 요청 속 jwt에서 id값 꺼내기
    let payload: JwtPayload; 
    try {
      payload = await this.authService.fromSocket(client);
    } catch (e) {
      client.emit('alertConnection', 'Not Valid JWT');
      console.error(new Date(), 'invalid jwt', e);

      return;
    }
    // 사용자의 요청에 jwt가 없을 때 정지
    if (!payload) {
      client.emit('alertConnection', 'Not Valid Request');
      console.error(new Date(), payload);

      return;
    }

    // 사용자를 사용자 id를 이름으로 하는 방에 접속 종료
    client.leave('user: ' + payload.id);

    // 접속 중인 사용자 목록에 기기의 id와 사용자의 id 삭제
    this.connectedUsers.delete(client.id);

    return;
  }

  // 사용자 초대 알림
  @SubscribeMessage('invite')
  async invite(@ConnectedSocket() client: Socket, @MessageBody() data: string) {
    // 접속 목록에서 client의 id값으로 사용자의 id값 꺼내기
    const inviterId = this.connectedUsers.get(client.id);

    // 사용자의 요청 속 초대할 사용자와 초대할 방 꺼내기
    const inviteDto: InviteDto = JSON.parse(data);

    // 사용자의 요청 시간, 초대한 사용자, 초대할 사용자와 초대할 방 로그
    console.log(new Date(), 'invite from', inviterId, 'to', inviteDto);

    // 초대하는 사용자의 profile 데이터 꺼내기
    const { profilePic, nickname } = await this.userService.findProfile(
      inviterId,
    );

    // 초대 메세지에 초대 관련 데이터 모두 담기
    const alert: AlertDto = {
      nickname,
      profilePic,
      roomId: inviteDto.roomId,
    };

    // 초대할 사용자 접속 중 여부 확인
    if (this.server.adapter['rooms'].has('user: ' + inviteDto.userId)) {
      // 접속 중이라면 앱에 알림 전송
      this.server.to('user: ' + inviteDto.userId).emit('invite', { ...alert, inviterId });
    } else {
      // 접속 중이 아니라면 초대할 사용자의 FCM token을 가져와 FCM으로 알림 전송
      // 초대할 사람의 FCM token 가져오기
      const user = await this.userService.findOneById(inviteDto.userId);
      // 초대할 사람의 FCM token이 없다면 알림 X
      if (!user.fcmToken) return;
      // 있다면 초대한 사람의 FCM token으로 roomId를 담아 알림 요청
      await this.alertService.sendPushNotification(
        user.fcmToken,
        'Invite from ' + alert.nickname,
        'invited you to join room!',
        { roomId: alert.roomId.toString() },
      );
    }
  }

  // 기획서에는 없었지만, ignore시 초대한 사용자에게 보내는 알림 추가 구현
  // (이거 무료로 제작해드린 거예요. 마감이 늦어져 정말 죄송합니다.)
  @SubscribeMessage('ignore')
  async ignore(@ConnectedSocket() client: Socket, @MessageBody() data: string) {
    // 사용자의 요청 속 jwt에서 id값 꺼내기
    const ignorerId = this.connectedUsers.get(client.id);

    // 사용자의 요청 속 무시할 초대 꺼내기
    const ignoreDto: IgnoreDto = JSON.parse(data);
    console.log(new Date(), 'ignore from', ignorerId, 'to', IgnoreDto);

    // 초대한 사용자 접속 중 여부 확인
    if (this.server.adapter['rooms'].has('user: ' + ignoreDto.inviterId)) {
      // 접속 중이라면 무시한 사람의 이름, 프로필 사진을 담아 무시 알림 송신
      const { profilePic, nickname } = await this.userService.findProfile(
        ignorerId,
      );

      ignoreDto.nickname = nickname;
      ignoreDto.profilePic = profilePic;

      // 앱에 알림 전송
      this.server.to('user: ' + ignoreDto.inviterId).emit('ignore', ignoreDto);
    } else console.log('nothing happened. it is best for the developers to handle');
    // 접속 중이 아니라면 아무 일도 일어나지 않는다
  }
}
