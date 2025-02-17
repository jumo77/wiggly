import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { UserModule } from 'src/user/user.module';

import { Room } from './entities/room.entity';
import { Chat } from '../chat/entities/chat.entity';

import { RoomService } from './room.service';

@Module({
  imports: [TypeOrmModule.forFeature([Room, Chat]), UserModule],
  controllers: [],
  providers: [RoomService],
  exports: [RoomService],
})
export class RoomModule {}
