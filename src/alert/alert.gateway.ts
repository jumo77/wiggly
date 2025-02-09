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
  namespace: '/alert',
})
export class AlertGateway implements OnGatewayConnection, OnGatewayDisconnect {
  constructor(
    private readonly authService: AuthService,
    private readonly userService: UserService,
    private readonly alertService: AlertService,
  ) {}

  @WebSocketServer()
  server: Server;
  connectedUsers: Map<string, number> = new Map();

  async handleConnection(client: Socket) {
    console.log(new Date(), client.handshake.address, 'connection');

    const payload: JwtPayload = await this.authService.fromSocket(client);

    if (!payload) {
      console.error(new Date(), payload);
      client.disconnect(true);

      return;
    }

    const user = payload && (await this.userService.findOne(payload.id));

    if (!user) {
      console.error(new Date(), user);
      client.disconnect(true);

      return;
    }

    client.join('user: ' + user.id);
    this.connectedUsers.set(client.id, user.id);

    return;
  }

  async handleDisconnect(client: Socket) {
    console.log(new Date(), client.handshake.address, 'disconnection');

    const payload = await this.authService.fromSocket(client);

    if (!payload) {
      console.error(new Date(), payload);

      return;
    }

    client.leave('user: ' + payload.id);
    this.connectedUsers.delete(client.id);

    return;
  }

  @SubscribeMessage('invite')
  async invite(@ConnectedSocket() client: Socket, @MessageBody() data: string) {
    const inviterId = this.connectedUsers.get(client.id);

    const inviteDto: InviteDto = JSON.parse(data);

    console.log(new Date(), 'invite from', inviterId, 'to', inviteDto);

    const { profilePic, nickname } = await this.userService.findProfile(
      inviterId,
    );

    const alert: AlertDto = {
      nickname,
      profilePic,
      roomId: inviteDto.roomId,
      inviterId,
    };

    if (this.server.adapter['rooms'].has('user: ' + inviteDto.userId)) {
      this.server.to('user: ' + inviteDto.userId).emit('invite', alert);
    } else {
      const user = await this.userService.findOne(inviteDto.userId);
      console.log(user.fcmToken);
      await this.alertService.sendPushNotification(
        user.fcmToken,
        'Invite from ' + alert.nickname,
        'invited you to join room!',
        { roomId: alert.roomId.toString() },
      );
    }
  }

  @SubscribeMessage('ignore')
  async ignore(@ConnectedSocket() client: Socket, @MessageBody() data: string) {
    const ignorereId = this.connectedUsers.get(client.id);

    const ignoreDto: IgnoreDto = JSON.parse(data);
    console.log(new Date(), 'ignore from', ignorereId, 'to', IgnoreDto);

    if (this.server.sockets.adapter.rooms.get('user: ' + ignoreDto.inviterId)) {
      const { profilePic, nickname } = await this.userService.findProfile(
        ignorereId,
      );

      ignoreDto.nickname = nickname;
      ignoreDto.profilePic = profilePic;

      this.server.to('user: ' + ignoreDto.inviterId).emit('ignore', ignoreDto);
    } else
      console.log('nothing happened. it is best for the developers to handle');
  }
}
