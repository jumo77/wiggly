import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { UserService } from './user.service';

import { User } from './entities/user.entity';
import { Profile } from "./entities/profile.entity";

@Module({
  imports: [TypeOrmModule.forFeature([User, Profile])],
  providers: [UserService],
  exports: [UserService],
})
export class UserModule {}
