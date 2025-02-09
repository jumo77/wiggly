import { Injectable, UnauthorizedException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';

import { Repository } from 'typeorm';

import { User } from './entities/user.entity';
import { SignupDto } from './dto/signup.dto';
import { Profile } from './entities/profile.entity';

@Injectable()
export class UserService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(Profile)
    private readonly profileRepository: Repository<Profile>,
  ) {}

  async findOne(id: number): Promise<User> {
    const user = await this.userRepository.findOne(id);

    if (!user) {
      throw new UnauthorizedException(`There is no user under id ${id}`);
    }

    return user;
  }

  async findOneByLoginId(username: string) {
    return await this.userRepository.findOne({ loginId: username });
  }

  async create(createUserDto: SignupDto) {
    const user = this.userRepository.create({ ...createUserDto });

    return this.userRepository.save(user);
  }

  async updateUser(updateUserDto: any) {
    const user = await this.findOne(updateUserDto.id);
    if (!user) throw new UnauthorizedException();
    return this.userRepository.update(updateUserDto.id, updateUserDto);
  }

  async findProfile(userId: number): Promise<Profile> {
    const profile = await this.profileRepository.findOne({ userId: userId });

    if (!profile)
      throw new UnauthorizedException(
        'There is no profile under user_id ' + userId.toString(),
      );

    return profile;
  }
}
