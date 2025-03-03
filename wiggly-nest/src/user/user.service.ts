import {
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';

import { Repository } from 'typeorm';

import { User } from './entities/user.entity';
import { Profile } from './entities/profile.entity';
import { AuthDto } from './dto/auth.dto';

@Injectable()
export class UserService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(Profile)
    private readonly profileRepository: Repository<Profile>,
  ) {}

  // id를 통해 user 찾기
  async findOneById(id: number): Promise<User> {
    const user = await this.userRepository.findOne({ where: { id } });

    if (!user) {
      throw new UnauthorizedException(`There is no user under id ${id}`);
    }

    return user;
  }

  // loginId를 통해 user 찾기
  async findOneByLoginId(loginId: string) {
    return await this.userRepository.findOne({ where: { loginId } });
  }

  // findOne 그대로 사용
  async findOne(find: any) {
    return await this.userRepository.findOne({ where: find });
  }

  // user를 저장한 뒤 저장한 user의 데이터 반환
  async create(createUserDto: AuthDto) {
    if (createUserDto.password === '')
      return this.userRepository.save({ ...createUserDto, validated: true });
    return this.userRepository.save(createUserDto);
  }

  // user 수정, id에 맞는 user가 있는지 확인
  async updateUser(updateUserDto: any) {
    const user = await this.findOneById(updateUserDto.id);
    if (!user) throw new UnauthorizedException();
    return this.userRepository.update(updateUserDto.id, updateUserDto);
  }

  async deleteUser(loginId: string) {
    const user = await this.findOneByLoginId(loginId);
    if (!user) throw new NotFoundException();
    return this.userRepository.delete(user.id);
  }

  async createProfile(userId: number, birthday: Date): Promise<Profile> {
    return this.profileRepository.save({ userId, birthday });
  }

  // userId를 통해 profile 찾기
  async findProfile(userId: number): Promise<Profile> {
    const profile = await this.profileRepository.findOne({
      where: { userId },
    });

    if (!profile)
      throw new UnauthorizedException(
        'There is no profile under user_id ' + userId.toString(),
      );

    return profile;
  }
}
