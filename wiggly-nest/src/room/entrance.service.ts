import { Injectable } from '@nestjs/common';
import { Repository } from 'typeorm';
import { Entrance } from './entities/entrance.entity';
import { EntranceDto } from './dto/entrance.dto';
import { InjectRepository } from '@nestjs/typeorm';

@Injectable()
export class EntranceService {
  constructor(
    @InjectRepository(Entrance)
    private readonly entranceRepository: Repository<Entrance>,
  ) {}

  async save(entranceDto: any) {
    return this.entranceRepository.save(entranceDto);
  }
}
