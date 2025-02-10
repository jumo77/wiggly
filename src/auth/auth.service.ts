import {
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';

import * as bcrypt from 'bcryptjs';

import { UserService } from 'src/user/user.service';

import { User } from 'src/user/entities/user.entity';
import { SignupDto } from 'src/user/dto/signup.dto';
import { LoginUserDto } from 'src/user/dto/login-user.dto';
import { JwtPayload } from './strategies/interfaces/jwt-payload.interface';
import { Socket } from 'socket.io';
import { MailService } from '../mail/mail.service';
import { MailDto } from '../user/dto/mail.dto';
import axios from 'axios';
import * as qs from 'qs';

@Injectable()
export class AuthService {
  constructor(
    private readonly userService: UserService,
    private readonly jwtService: JwtService,
    private readonly mailService: MailService,
  ) {}

  async hash(password: string): Promise<string> {
    return bcrypt.hash(password, 7);
  }

  async checkDupl(dto: MailDto) {
    if (!dto.email) return this.result('Invalid mail');
    const candidate = await this.userService.findOneByLoginId(dto.email);

    if (candidate) return this.result('E-mail is already using.');
    else return { result: 'You can use this E-mail.' };
  }

  async singUp(userDto: SignupDto) {
    const result = await this.checkDupl({ email: userDto.loginId });
    if (result.result === 'E-mail is already using.') return null;

    const user = await this.userService.create({
      loginId: userDto.loginId,
      password: await this.hash(userDto.password),
    });

    return await this.generateTokens(user.id);
  }

  async checkMail(user: User) {
    try {
      const hashed = await bcrypt.hash(user.loginId, user.password);
      await this.mailService.sendMail(user.loginId, hashed);
      return this.result('Sent mail');
    } catch (e) {
      console.error(new Date(), e);
      return this.result(e.toString());
    }
  }

  async validateMail(value: string, user: User) {
    const hash = await bcrypt.hash(user.loginId, user.password);
    if (value === hash) {
      await this.userService.updateUser({
        id: user.id,
        validated: true,
      });
      return this.result('validated');
    } else {
      throw new UnauthorizedException();
    }
  }

  async signIn(userDto: LoginUserDto) {
    const user = await this.validateUser(userDto);

    return await this.generateTokens(user.id);
  }

  async socialLogin(req: any) {
    const id = req.user.id;
    let user = await this.userService.findOneByLoginId(id.toString());
    if (!user)
      user = await this.userService.create({
        loginId: id.toString(),
        password: '',
      });
    return this.generateTokens(user.id);
  }

  async validateUser(userDto: LoginUserDto): Promise<User> {
    const user = await this.userService.findOneByLoginId(userDto.loginId);

    if (!user) {
      throw new NotFoundException(`There is no user under this username`);
    }

    const passwordEquals = await bcrypt.compare(
      userDto.password,
      user.password,
    );

    if (passwordEquals) return user;

    throw new UnauthorizedException({ message: 'Incorrect password' });
  }

  async verifyAccessToken(accessToken: string) {
    try {
      return this.jwtService.verify<JwtPayload>(accessToken, {
        secret: process.env.ACCESS_SECRET,
      });
    } catch (err) {
      console.error(new Date(), err);
      throw new UnauthorizedException();
    }
  }

  verifyRefreshToken(refreshToken: string) {
    return this.jwtService.verify(refreshToken, {
      secret: process.env.REFRESH_SECRET,
    });
  }

  async updateAccessToken(refreshToken: string) {
    try {
      const refreshPayload = this.verifyRefreshToken(refreshToken);
      const userId = refreshPayload.id;

      const tokens = await this.generateTokens(userId);

      return tokens.accessToken;
    } catch (e) {
      throw new UnauthorizedException();
    }
  }

  async fromSocket(client: Socket): Promise<JwtPayload> {
    const token = client.handshake.headers['access_token'];
    if (Array.isArray(token)) return this.verifyAccessToken(token[0]);
    else return this.verifyAccessToken(token);
  }

  private async generateTokens(id: number) {
    const payload = { id, role: 'web_anon' };

    const accessToken = this.jwtService.sign(payload, {
      secret: process.env.ACCESS_SECRET,
      expiresIn: process.env.ACCESS_EXPIRE,
    });
    const refreshToken = this.jwtService.sign(payload, {
      secret: process.env.REFRESH_SECRET,
      expiresIn: process.env.REFRESH_EXPIRE,
    });

    return { accessToken, refreshToken };
  }

  private result(message: string) {
    return { result: message };
  }
}
