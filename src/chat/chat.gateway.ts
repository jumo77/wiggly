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
    private readonly roomService: RoomService,
    private readonly chatService: ChatService,
    private readonly entranceService: EntranceService,
  ) {}

  async handleConnection(client: Socket) {
    const payload = await this.authService.fromSocket(client);
    console.log(new Date(), client.handshake.address, 'connection');

    const user = payload && (await this.userService.findOne(payload.id));

    if (!user) {
      client.emit('Not Valid User ID');
      console.error(new Date(), payload);
      client.disconnect(true);

      return;
    }

    this.connectedUsers.set(client.id, user.id);

    return;
  }

  async handleDisconnect(client: Socket) {
    console.log(new Date(), client.handshake.address, 'disconnection');
    this.connectedUsers.delete(client.id);

    return;
  }

  @SubscribeMessage('chat')
  async onMessage(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: string,
  ) {
    const addMessageDto: AddChatDto = JSON.parse(data);
    const userId = this.connectedUsers.get(client.id);
    const user = await this.userService.findOne(userId);

    const roomId = addMessageDto.roomId;
    const room = await this.roomService.findOne(roomId);

    addMessageDto.userId = userId;

    await this.chatService.addChat(addMessageDto);

    this.server.to('room: ' + roomId.toString()).emit('chat', addMessageDto);
  }

  @SubscribeMessage('join')
  async onRoomJoin(
    @ConnectedSocket() client: Socket,
    @MessageBody() joinRoomDto: string,
  ) {
    const { roomId } = JSON.parse(joinRoomDto);
    // const { roomId } = joinRoomDto;
    const userId = this.connectedUsers.get(client.id);
    console.log(new Date(), userId, roomId);

    await this.entranceService.save({ userId, roomId });
    client.join('room: ' + roomId.toString());
    client.emit('join', { roomId: roomId });

    this.server.emit('join', { userId: userId, roomId: roomId });
  }

  @SubscribeMessage('leave')
  async onRoomLeave(
    @ConnectedSocket() client: Socket,
    @MessageBody() leaveRoomDto: string,
  ) {
    const { roomId } = JSON.parse(leaveRoomDto);
    const userId = this.connectedUsers.get(client.id);

    await this.entranceService.save({ userId, roomId, enter: false });
    client.leave('room: ' + roomId.toString());
    client.emit('leave', { roomId: roomId });

    this.server.emit('leave', { userId: userId, roomId: roomId });
  }
}
