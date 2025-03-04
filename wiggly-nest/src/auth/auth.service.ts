import {
  HttpException,
  HttpStatus,
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';

import * as bcrypt from 'bcryptjs';

import { UserService } from 'src/user/user.service';

import { User } from 'src/user/entities/user.entity';
import { AuthDto } from 'src/user/dto/auth.dto';
import { JwtPayload } from './strategies/interfaces/jwt-payload.interface';
import { Socket } from 'socket.io';
import { MailService } from '../mail/mail.service';
import { MailDto } from '../user/dto/mail.dto';
import { Response } from 'express';
import { SchedulerRegistry } from '@nestjs/schedule';
import { denyDiv, verifiedDiv } from './html';
import { SignupDto } from '../user/dto/signup.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly userService: UserService,
    private readonly jwtService: JwtService,
    private readonly mailService: MailService,
    private readonly schedulerRegistry: SchedulerRegistry,
  ) {}

  // 회원 중복 확인
  async checkDupl(dto: MailDto) {
    if (!dto.email)
      throw new HttpException('E-mail is invalide', HttpStatus.BAD_REQUEST);
    const candidate = await this.userService.findOneByLoginId(dto.email);
    if (candidate)
      throw new HttpException('E-mail is already using.', HttpStatus.CONFLICT);
  }

  // 회원가입
  async singUp(userDto: SignupDto) {
    // 회원 중복 확인 이후 같은 이메일로 회원가입한 사람 없겠지만 미연에 방지하는 중복 검사
    await this.checkDupl({ email: userDto.loginId });

    const pw = await this.hash(userDto.password);
    console.log(pw);
    // 메일 주소로 인증 메일
    try {
      // 메일 주소 암호화에서 비밀번호를 salt로 해싱
      const hashed = await bcrypt.hash(userDto.loginId, pw);
      await this.mailService.sendMail(userDto.loginId, hashed);
    const user = await this.userService.create({
      loginId: userDto.loginId,
      password: pw,
    });
    await this.userService.createProfile(user.id, userDto.birthday);
      // timeout 설정
      // 어차피 지워야할 복호화값으로 지워야할 timeout 식별
      this.schedulerRegistry.addTimeout(
        user.loginId + hashed,
        setTimeout(async () => {
          await this.userService.deleteUser(user.loginId);
        }, 3 * 24 * 60 * 60 * 1000),
      );
      return this.result('Sent mail');
    } catch (e) {
      console.error(new Date(), e);
      throw new HttpException(e.toString(), 500);
    }
  }

  // 회원의 메일 주소 보유 인증
  async validateMail(mail: string, code: string) {
    const user = await this.userService.findOneByLoginId(mail);
    if (!user)
      throw new NotFoundException('There are no user under this mail!');
    // 복호화된 암호 코드는 timeout queue에 저장되어있으니 식별
    if (this.schedulerRegistry.doesExist('timeout', mail + code)) {
      // 저장된 값이 맞는 것이 확인되면 회원 인증 성공
      await this.userService.updateUser({
        id: user.id,
        validated: true,
      });
      // 시간이 지나고 삭제되는 것을 취소
      this.schedulerRegistry.deleteTimeout(mail + code);

      return verifiedDiv;
    } else {
      throw new UnauthorizedException();
    }
  }

  // 본인의 메일이 아닐 때.
  async deny(mail: string, code: string) {
    if (this.schedulerRegistry.doesExist('timeout', mail + code)) {
      // 저장된 값이 맞는 것이 확인되면 회원 인증 성공
      await this.userService.deleteUser(mail);
      // 시간이 지나고 삭제되는 것을 취소
      this.schedulerRegistry.deleteTimeout(mail + code);
      return denyDiv;
    }
  }

  // 로그인
  async signIn(userDto: AuthDto) {
    const user = await this.validateUser(userDto);
    return this.generateTokens(user.id);
  }

  // 소셜로 로그인
  async socialLogin(req: any, res: Response, social: string) {
    // 소셜에서 회원을 구분하는 내용을 받아온다.
    // strategy에서 정의한 done, cb 등의 함수에서 data를 담아서 보낸다.
    const id = req.user.id;
    // 회원이 우리 서버에 회원가입된 상태인지 판별
    let user = await this.userService.findOne({
      loginId: id.toString(),
      password: social,
    });
    if (!user)
      // 회원가입되지 않은 회원이라면 새로운 회원으로 가입
      user = await this.userService.create({
        loginId: id.toString(),
        // 소셜 로그인 경로 확정
        password: social,
      });
    // 가입한 회원의 id를 담는 token 발급
    const token = await this.generateTokens(user.id);

    res.cookie('access_token', token.accessToken, this.access);
    res.cookie('refresh_token', token.refreshToken, this.refresh);
  }

  // 회원이 입력한 이메일과 비밀번호 검증
  async validateUser(userDto: AuthDto): Promise<User> {
    // 회원이 입력한 이메일 존재 여부 확인
    const user = await this.userService.findOneByLoginId(userDto.loginId);

    // 없으면 없다고 전달
    if (!user) {
      throw new NotFoundException(`There is no user under this username`);
    }

    // 있을 때, 회원이 입력한 비밀번호와 입력한 이메일에 존재하는 계정의 비밀번호 일치 여부 확인
    const passwordEquals = await bcrypt.compare(
      userDto.password,
      user.password,
    );

    // 일치하면 사용자 전달
    if (passwordEquals) return user;

    // 불일치하면 불일치한다고 전달
    throw new UnauthorizedException('Incorrect password');
  }

  // 회원 정보 수정
  async updateUser(dto: any) {
    // 이메일 수정시 메일 인증 취소 처리
    if (dto.loginId) dto.validated = false;
    // 비밀번호 수정시 암호화
    if (dto.password) dto.password = await this.hash(dto.password);
    console.log(dto);
    // 결과 전달
    return this.userService.updateUser(dto);
  }

  async hash(password: string): Promise<string> {
    return bcrypt.hash(password, 7);
  }

  // access token 검증해 jwt 속 데이터 반환
  async verifyAccessToken(accessToken: string) {
    try {
      return this.jwtService.verify<JwtPayload>(accessToken, {
        secret: process.env.ACCESS_SECRET,
      });
    } catch (err) {
      console.error(new Date(), err);
      throw err;
    }
  }

  // refresh token 검증해 jwt 속 데이터 반환
  async verifyRefreshToken(refreshToken: string) {
    return this.jwtService.verify(refreshToken, {
      secret: process.env.REFRESH_SECRET,
    });
  }

  // refresh token의 데이터를 기반으로 새로운 access token 전달
  async updateAccessToken(refreshToken: string) {
    try {
      const refreshPayload = await this.verifyRefreshToken(refreshToken);
      const userId = refreshPayload.id;

      const tokens = await this.generateTokens(userId);

      return tokens.accessToken;
    } catch (e) {
      throw e;
    }
  }

  // 회원의 id값을 담은 access token, refresh token 제작을 통해
  // 로그인을 1달에 한번만 해도 되게끔 만들어 loginId와 password가 노출되지 않도록 함
  private async generateTokens(id: any) {
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

  // socket.io에서 access token에서 회원의 id를 반환
  async fromSocket(client: Socket): Promise<JwtPayload> {
    try{
      const token = client.handshake.headers['access_token'];
      if (Array.isArray(token)) return this.verifyAccessToken(token[0]);
      else return this.verifyAccessToken(token);
    } catch(e){
	    console.log('fromSocket catch');
      throw e;
    }
  }

  // response로 보낼 json 객체로 만들어주는 함수.
  private result(message: string) {
    return { result: message };
  }

  private access = {
    httpOnly: true,
    // 10분 60초 1000ms
    maxAge: 10 * 60 * 1000,
  };
  private refresh = {
    httpOnly: true,
    // 30일 24시간 60분 60초 1000ms
    maxAge: 30 * 24 * 60 * 60 * 1000,
  };
}
