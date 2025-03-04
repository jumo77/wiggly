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

import { UserService } from 'src/user/user.service';
import { AuthService } from 'src/auth/auth.service';
import { RoomService } from 'src/room/room.service';

import { AddChatDto } from './dto/add-chat.dto';
import { ChatService } from './chat.service';
import { EntranceService } from '../room/entrance.service';
import { EntranceDto } from '../room/dto/entrance.dto';

// @UsePipes(new ValidationPipe({ transform: true }))
@WebSocketGateway({
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
  allowEIO3: true,
  transports: ['websocket', 'polling'],
  namespace: '/chat',
})
export class ChatGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  connectedUsers: Map<string, number> = new Map();

  constructor(
    private readonly userService: UserService,
    private readonly authService: AuthService,
    private readonly chatService: ChatService,
    private readonly entranceService: EntranceService,
  ) {}

  // 접속 시작 처리
  async handleConnection(client: Socket) {
    // 접속 시작한 시간, ip 주소 로그
    console.log(new Date(), client.handshake.address, 'connection');

    // 접속한 사용자의 요청 속 jwt에서 id값 꺼내기
    let payload;

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
      client.emit('chatConnection','Not Valid Request');
      console.error(new Date(), payload);
      client.disconnect(true);

      return;
    }

    // 꺼낸 id값으로 사용자 불러오기
    const user = payload && (await this.userService.findOneById(payload.id));

    // 불러온 사용자가 없을 때 접속 종료
    if (!user) {
      client.emit('chatConnection', 'Not Valid User ID');
      console.error(new Date(), payload);
      client.disconnect(true);

      return;
    }

    // 접속 중인 사용자 목록에 기기의 id와 사용자의 id 저장
    this.connectedUsers.set(client.id, user.id);

    return;
  }

  // 접속 종료 처리
  async handleDisconnect(client: Socket) {
    // 접속 해제한 시간, ip 주소 로그
    console.log(new Date(), client.handshake.address, 'disconnection');

// 접속한 사용자의 요청 속 jwt에서 id값 꺼내기
    let payload;

    try {
    payload = await this.authService.fromSocket(client);
    } catch (e) {
      client.emit('alertConnection', 'Not Valid JWT');
      console.error(new Date(), 'invalid jwt', e);
      client.disconnect(true);

      return;
    }

    // 사용자의 요청에 jwt가 없을 때 정지
    if (!payload) {
      client.emit('chatConnection', 'Not Valid Request');
      console.error(new Date(), payload);

      return;
    }

    // 접속 중인 사용자 목록에 기기의 id와 사용자의 id 삭제
    this.connectedUsers.delete(client.id);

    return;
  }

  // 방 입장
  @SubscribeMessage('chat')
  async onMessage(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: string,
  ) {
    // 접속 목록에서 client의 id값으로 사용자의 id값 꺼내기
    const userId = this.connectedUsers.get(client.id);

    // 사용자의 요청 속 채팅을 보낼 방, 채팅 내용 꺼내기
    const addMessageDto: AddChatDto = JSON.parse(data);

    // 채팅 저장하기
    await this.chatService.addChat(addMessageDto, userId);

    // 채팅을 보낼 방에 채팅 보내기
    this.server.to('room: ' + addMessageDto.roomId.toString())
      .emit('chat', { ...addMessageDto, userId });
  }

  @SubscribeMessage('join')
  async onRoomJoin(
    @ConnectedSocket() client: Socket,
    @MessageBody() joinRoomDto: string,
  ) {
    // 접속 목록에서 client의 id값으로 사용자의 id값 꺼내기
    const userId = this.connectedUsers.get(client.id);

    // 사용자의 요청 속 입장할 방 꺼내기
    const { roomId } = JSON.parse(joinRoomDto);

    // 방 입장 내용 저장하기
    await this.entranceService.save({ userId, roomId });

    // 사용자 입장
    client.join('room: ' + roomId.toString());
    // 사용자에게 입장된 방 보내기
    client.emit('join', { roomId: roomId });

    // 어떤 방에 어떤 사용자가 입장했는지 모든 접속자들에게 모두 알리기
    this.server.emit('join', { userId: userId, roomId: roomId });
  }

  @SubscribeMessage('leave')
  async onRoomLeave(
    @ConnectedSocket() client: Socket,
    @MessageBody() leaveRoomDto: string,
  ) {
    // 접속 목록에서 client의 id값으로 사용자의 id값 꺼내기
    const userId = this.connectedUsers.get(client.id);

    // 사용자의 요청 속 퇴장할 방 꺼내기
    const { roomId } = JSON.parse(leaveRoomDto) as EntranceDto;

    // 방 퇴장 내용 저장하기
    await this.entranceService.save({ userId, roomId, enter: false });

    // 사용자 퇴장
    client.leave('room: ' + roomId.toString());
    // 사용자에게 퇴장된 방 보내기
    client.emit('leave', { roomId: roomId });

    // 어떤 방에 어떤 사용자가 퇴장했는지 모든 접속자들에게 알리기
    this.server.emit('leave', { userId: userId, roomId: roomId });
  }
}
