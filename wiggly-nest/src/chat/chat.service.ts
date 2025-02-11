import { Injectable } from '@nestjs/common';
import { Repository } from 'typeorm';
import { Chat } from './entities/chat.entity';
import { AddChatDto } from './dto/add-chat.dto';
import { RoomService } from '../room/room.service';
import { UserService } from '../user/user.service';
import { InjectRepository } from '@nestjs/typeorm';

@Injectable()
export class ChatService {
  constructor(
    @InjectRepository(Chat)
    private readonly chatRepository: Repository<Chat>,
    private readonly roomService: RoomService,
    private readonly userService: UserService,
  ) {}

  async addChat(addMessageDto: AddChatDto, userId: number) {
    return this.chatRepository.save({ ...addMessageDto, userId });
  }
}
