import {
  Body,
  Controller,
  Get,
  Headers,
  HttpException,
  HttpStatus,
  Param,
  Patch,
  Post,
  Req,
  Res,
  UseGuards,
} from '@nestjs/common';

import { AuthService } from './auth.service';

import { AuthDto } from 'src/user/dto/auth.dto';
import { UserService } from '../user/user.service';
import { MailDto } from '../user/dto/mail.dto';
import { AuthGuard } from '@nestjs/passport';

// 주소/auth 로 시작하는 모든 요청 수신
@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
    private readonly userService: UserService,
  ) {}

  @Post('/dupl')
  async dupl(@Body() dto: MailDto) {
    return await this.authService.checkDupl(dto);
  }

  @Post('/signUp')
  async signUp(@Body() userDto: AuthDto) {
    const tokens = await this.authService.singUp(userDto);

    if (!tokens) {
      throw new HttpException(
        'User under this username already exists',
        HttpStatus.BAD_REQUEST,
      );
    }

    return tokens;
  }

  // 메일 보내기 요청
  @Get('/mail')
  async mail(@Headers('access_token') token: string) {
    const payload = await this.authService.verifyAccessToken(token);
    const user = await this.userService.findOne(payload.id);
    return await this.authService.checkMail(user);
  }

  // 발급 받은 메일의 토큰을 인증
  @Post('/mail')
  async validateMail(
    @Body() mail: any,
    @Headers('access_token') token: string,
  ) {
    const payload = await this.authService.verifyAccessToken(token);
    const user = await this.userService.findOne(payload.id);
    return await this.authService.validateMail(mail.mail, user);
  }

  @Post('/signIn')
  async signIn(@Body() userDto: AuthDto) {
    return await this.authService.signIn(userDto);
  }

  // 카카오 로그인 및 로그인 성공시 회원 데이터 송신
  @Get('/kakao')
  @UseGuards(AuthGuard('kakao')) // 이걸로 PassportStrategy 상속받은 클래스들 실행
  async kakao(@Req() req: any) {
    return await this.authService.socialLogin(req);
  }

  // 구글 로그인 요청
  @Get('/google')
  @UseGuards(AuthGuard('google')) // 이걸로 PassportStrategy 상속받은 클래스들 실행
  async googleAuth() {}

  // 구글에서 로그인 성공시 회원 데이터 송신
  @Get('/google/redirect')
  @UseGuards(AuthGuard('google')) // 이걸로 PassportStrategy 상속받은 클래스들 실행
  async googleRedirect(@Req() req) {
    return await this.authService.socialLogin(req);
  }

  // 페이스북 로그인 요청
  @Get('/facebook')
  @UseGuards(AuthGuard('facebook')) // 이걸로 PassportStrategy 상속받은 클래스들 실행
  async facebook() {}

  // 페이스북에서 로그인 성공시 회원 데이터 송신
  @Get('/facebook/redirect')
  @UseGuards(AuthGuard('facebook')) // 이걸로 PassportStrategy 상속받은 클래스들 실행
  async facebookRedirect(@Req() req) {
    return await this.authService.socialLogin(req);
  }

  // 애플 로그인 요청
  @Get('/apple')
  @UseGuards(AuthGuard('apple')) // 이걸로 PassportStrategy 상속받은 클래스들 실행
  async apple(@Req() req: Request) {
    console.log(req);
  }

  // 애플 로그인 성공시 회원 데이터 송신
  @Post('/apple/redirect')
  @UseGuards(AuthGuard('apple')) // 이걸로 PassportStrategy 상속받은 클래스들 실행
  async appleRedirect(@Req() req: Request) {
    return await this.authService.socialLogin(req);
  }

  // access token 만료시 header에 refresh token을 담아 request 보낼 주소
  @Get('/update')
  async updateTokens(@Headers('refresh_token') token: string) {
    const accessToken = await this.authService.updateAccessToken(token);

    return { accessToken: accessToken };
  }

  // 사용자의 데이터 수정 (ex: 비밀번호, fcm token 등)
  @Post('/update')
  async update(
    @Headers('access_token') token: string,
    @Body() dto: any,
  ) {
    const payload = await this.authService.verifyAccessToken(token);
    dto.id = payload.id;

    await this.authService.updateUser(dto);

    return {};
  }
}
