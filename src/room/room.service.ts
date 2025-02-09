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
    const room = await this.roomRepository.findOne({ where: { id } });

    if (!room) throw new NotFoundException(`There is no room under id ${id}`);

    return room;
  }
}
