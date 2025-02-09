import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';

import { Repository } from 'typeorm';

import { Room } from './entities/room.entity';

@Injectable()
export class RoomService {
  constructor(
    @InjectRepository(Room) private readonly roomRepository: Repository<Room>,
  ) {}

  async findOne(id: number): Promise<Room> {
    const room = await this.roomRepository.findOne(id);

    if (!room) throw new NotFoundException(`There is no room under id ${id}`);

    return room;
  }

  async findByUserId(userId: number): Promise<number> {
    const room: Room = await this.roomRepository.findOne({ userId: userId });

    if (!room)
      throw new NotFoundException(
        'There is no room of user under id ' + userId.toString(),
      );

    return room[0].id;
  }
}
