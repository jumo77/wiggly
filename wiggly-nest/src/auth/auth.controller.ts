import {
  Body,
  Controller,
  Get,
  Headers,
  Query,
  Post,
  Req,
  Res,
  UseGuards,
} from '@nestjs/common';

import { Response } from 'express';
import { ApiTags } from '@nestjs/swagger';

import { AuthService } from './auth.service';
import { AppleOAuthGuard } from './strategies/apple.strategy';

import { AuthDto } from 'src/user/dto/auth.dto';
import { MailDto } from '../user/dto/mail.dto';
import { AuthGuard } from '@nestjs/passport';
import { confirmDiv, denyDiv, successDiv } from './html';
import { SignupDto } from '../user/dto/signup.dto';

@ApiTags('oauth')
// 주소/auth 로 시작하는 모든 요청 수신
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('/signUp')
  async signUp(@Body() userDto: SignupDto) {
    return this.authService.singUp(userDto);
  }

  // 발급 받은 메일의 토큰을 인증
  @Get('/mail/verify')
  async validateMail(@Query('email') mail: string, @Query('code') code: string){
    return await this.authService.validateMail(mail, code);
  }

  @Get('/mail/confirm')
  async confirmDeny(@Query('email') mail: string, @Query('code') code: string) {
    return confirmDiv(mail, code);
  }

  @Get('/mail/deny')
  async deny(@Query('email') mail: string, @Query('code') code: string) {
    return this.authService.deny(mail, code);
  }

  @Post('/signIn')
  async signIn(@Body() userDto: AuthDto) {
	  console.log(userDto);
    return await this.authService.signIn(userDto);
  }

  // 카카오 로그인 및 로그인 성공시 회원 데이터 송신
  @Get('/kakao')
  // 이걸로 PassportStrategy 상속받은 클래스들 실행
  @UseGuards(AuthGuard('kakao'))
  async kakao(@Req() req: any, @Res() res: Response) {
    await this.authService.socialLogin(req, res, 'kakao');
    res.send(successDiv);
  }

  // 구글 로그인 요청
  @Get('/google')
  // 이걸로 PassportStrategy 상속받은 클래스들 실행
  @UseGuards(AuthGuard('google'))
  async googleAuth() {}

  // 구글에서 로그인 성공시 회원 데이터 송신
  @Get('/google/redirect')
  // 이걸로 PassportStrategy 상속받은 클래스들 실행
  @UseGuards(AuthGuard('google'))
  async googleRedirect(@Req() req: any, @Res() res: Response) {
    await this.authService.socialLogin(req, res, 'google');
    res.send(successDiv);
  }

  // 페이스북 로그인 요청
  @Get('/facebook')
  // 이걸로 PassportStrategy 상속받은 클래스들 실행
  @UseGuards(AuthGuard('facebook'))
  async facebook() {}

  // 페이스북에서 로그인 성공시 회원 데이터 송신
  @Get('/facebook/redirect')
  // 이걸로 PassportStrategy 상속받은 클래스들 실행
  @UseGuards(AuthGuard('facebook'))
  async facebookRedirect(@Req() req: any, @Res() res: Response) {
    await this.authService.socialLogin(req, res, 'facebook');
    res.send(successDiv);
  }

  // 애플 로그인 요청
  @Get('/apple')
  // 이걸로 PassportStrategy 상속받은 클래스들 실행
  @UseGuards(AppleOAuthGuard)
  async apple(@Req() req: Request) {
    console.log(req);
  }

  // 애플 로그인 성공시 회원 데이터 송신
  @Post('/apple/redirect')
  // 이걸로 PassportStrategy 상속받은 클래스들 실행
  @UseGuards(AppleOAuthGuard)
  async appleRedirectGet(@Req() req: any, @Res() res: Response) {
	  return req.user;
//	  console.log('get called');
//	  console.log(Object.keys(req));
//	  console.log(req.user);
//          await this.authService.socialLogin(req, res, 'apple');
//    res.send(successDiv);
  }

  // access token 만료시 header에 refresh token을 담아 request 보낼 주소
  @Get('/update')
  async updateTokens(@Headers('refresh_token') token: string) {
    const accessToken = await this.authService.updateAccessToken(token);

    return { accessToken: accessToken };
  }

  // 사용자의 데이터 수정 (ex: 비밀번호, fcm token 등)
  @Post('/update')
  async update(@Headers('access_token') token: string, @Body() dto: any) {
    const payload = await this.authService.verifyAccessToken(token);
    dto.id = payload.id;

    await this.authService.updateUser(dto);

    return {};
  }
}
