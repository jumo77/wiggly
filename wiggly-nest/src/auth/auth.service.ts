import {
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

@Injectable()
export class AuthService {
  constructor(
    private readonly userService: UserService,
    private readonly jwtService: JwtService,
    private readonly mailService: MailService,
  ) {}

  // 회원 중복 확인
  async checkDupl(dto: MailDto) {
    if (!dto.email) return this.result('Invalid mail');
    const candidate = await this.userService.findOneByLoginId(dto.email);

    if (candidate) return this.result('E-mail is already using.');
    else return { result: 'You can use this E-mail.' };
  }

  // 회원가입
  async singUp(userDto: AuthDto) {
    // 회원 중복 확인 이후 같은 이메일로 회원가입한 사람 없겠지만 미연에 방지하는 중복 검사
    const result = await this.checkDupl({ email: userDto.loginId });
    if (result.result === 'E-mail is already using.') return null;

    const user = await this.userService.create({
      loginId: userDto.loginId,
      password: await this.hash(userDto.password),
    });

    return await this.generateTokens(user.id);
  }

  // 메일 주소로 인증코드 보내기
  async checkMail(user: User) {
    try {
      // 메일 주소를 암호화하는데, 비밀번호를 salt로 해싱
      const hashed = await bcrypt.hash(user.loginId, user.password);
      await this.mailService.sendMail(user.loginId, hashed);
      return this.result('Sent mail');
    } catch (e) {
      console.error(new Date(), e);
      return this.result(e.toString());
    }
  }

  // 회원의 메일 주소 보유 인증
  async validateMail(value: string, user: User) {
    // 해시 알고리즘은 복호화가 사실상 불가능해 암호화
    const hash = await bcrypt.hash(user.loginId, user.password);
    // 암호화한 데이터와 암호가 같다면 회원이 인증된 회원임을 인증
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

  // 로그인
  async signIn(userDto: AuthDto) {
    const user = await this.validateUser(userDto);

    return await this.generateTokens(user.id);
  }

  // 소셜로 로그인
  async socialLogin(req: any) {
    // 소셜에서 회원을 구분하는 내용을 받아온다.
    // strategy에서 정의한 done, cb 등의 함수에서 data를 담아서 보낸다.
    const id = req.user.id;
    // 회원이 우리 서버에 회원가입된 상태인지 판별
    let user = await this.userService.findOneByLoginId(id.toString());
    if (!user)
      // 회원가입되지 않은 회원이라면 새로운 회원으로 가입
      user = await this.userService.create({
        loginId: id.toString(),
        password: '',
      });
    // 가입한 회원의 id를 담는 token 발급
    return this.generateTokens(user.id);
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
    throw new UnauthorizedException( 'Incorrect password');
  }

  // 회원 정보 수정
  async updateUser(dto: any){
    // 이메일 수정시 메일 인증 취소 처리
    if (dto.loginId) dto.validated = false;
    // 비밀번호 수정시 암호화
    if (dto.password) dto.password = this.hash(dto.password);
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
      throw new UnauthorizedException();
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
      throw new UnauthorizedException();
    }
  }

  // 회원의 id값을 담은 access token, refresh token 제작을 통해
  // 로그인을 1달에 한번만 해도 되게끔 만들어 loginId와 password가 노출되지 않도록 함
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

  // socket.io에서 access token에서 회원의 id를 반환
  async fromSocket(client: Socket): Promise<JwtPayload> {
    const token = client.handshake.headers['access_token'];
    if (Array.isArray(token)) return this.verifyAccessToken(token[0]);
    else return this.verifyAccessToken(token);
  }

  // response로 보낼 json 객체로 만들어주는 함수.
  private result(message: string) {
    return { result: message };
  }
}
