import { Module } from '@nestjs/common';

import { ChatGateway } from './chat.gateway';

import { UserModule } from 'src/user/user.module';
import { AuthModule } from 'src/auth/auth.module';
import { RoomModule } from 'src/room/room.module';
import { ChatService } from './chat.service';
import { EntranceService } from '../room/entrance.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Entrance } from '../room/entities/entrance.entity';
import { Chat } from './entities/chat.entity';

@Module({
  imports: [
    UserModule,
    AuthModule,
    RoomModule,
    TypeOrmModule.forFeature([Entrance, Chat]),
  ],
  providers: [ChatGateway, ChatService, EntranceService],
  exports: [ChatService],
})
export class ChatModule {}
