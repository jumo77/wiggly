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

import { SignupDto } from 'src/user/dto/signup.dto';
import { LoginUserDto } from 'src/user/dto/login-user.dto';
import { UserService } from '../user/user.service';
import { MailDto } from '../user/dto/mail.dto';
import { AuthGuard } from '@nestjs/passport';

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
  async signUp(@Body() userDto: SignupDto) {
    const tokens = await this.authService.singUp(userDto);

    if (!tokens) {
      throw new HttpException(
        'User under this username already exists',
        HttpStatus.BAD_REQUEST,
      );
    }

    return tokens;
  }

  @Get('/mail')
  async mail(@Headers('access_token') token: string) {
    const payload = await this.authService.verifyAccessToken(token);
    const user = await this.userService.findOne(payload.id);
    return await this.authService.checkMail(user);
  }

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
  async signIn(@Body() userDto: LoginUserDto) {
    return await this.authService.signIn(userDto);
  }

  @Get('/kakao')
  @UseGuards(AuthGuard('kakao'))
  async kakao(@Req() req: any) {
    return await this.authService.socialLogin(req);
  }

  @Get('/google')
  @UseGuards(AuthGuard('google'))
  async googleAuth() {}

  @Get('/google/redirect')
  @UseGuards(AuthGuard('google'))
  async googleRedirect(@Req() req) {
    return await this.authService.socialLogin(req);
  }

  @Get('/facebook')
  @UseGuards(AuthGuard('facebook'))
  async facebook() {}

  @Get('/facebook/redirect')
  @UseGuards(AuthGuard('facebook'))
  async facebookRedirect(@Req() req) {
    return await this.authService.socialLogin(req);
  }

  @Get('/apple')
  @UseGuards(AuthGuard('apple'))
  async apple(@Req() req: Request) {
    console.log(req);
  }

  @Get('/apple/redirect')
  @UseGuards(AuthGuard('apple'))
  async appleRedirect(@Req() req: Request) {
    console.log(req);
  }

  @Patch('/fcm_token')
  async updateFcmToken(
    @Headers('access_token') token: string,
    @Body() dto: any,
  ) {
    console.log(token);
    const payload = await this.authService.verifyAccessToken(token);
    dto.id = payload.id;

    await this.userService.updateUser(dto);

    return {};
  }

  @Get('/update')
  async updateTokens(@Headers('refresh_token') token: string) {
    const accessToken = await this.authService.updateAccessToken(token);

    return { accessToken: accessToken };
  }

  @Post('/update')
  async updatePassword(
    @Headers('access_token') token: string,
    @Body() dto: any,
  ) {
    const payload = await this.authService.verifyAccessToken(token);
    dto.id = payload.id;

    await this.userService.updateUser(dto);

    return {};
  }
}
