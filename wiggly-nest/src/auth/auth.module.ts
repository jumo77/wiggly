import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';

import { UserModule } from 'src/user/user.module';

import { AuthController } from './auth.controller';

import { AuthService } from './auth.service';

import { MailModule } from '../mail/mail.module';
import { GoogleStrategy } from './strategies/google.strategy';
import { KakaoStrategy } from './strategies/kakao.strategy';
import { FacebookStrategy } from './strategies/facebook.strategy';
import { AppleStrategy } from './strategies/apple.strategy';

@Module({
  imports: [
    UserModule,
    PassportModule,
    JwtModule.register({
      secret: process.env.ACCESS_SECRET,
      signOptions: { expiresIn: process.env.ACCESS_EXPIRE },
    }),
    MailModule,
  ],
  controllers: [AuthController],
  providers: [AuthService, GoogleStrategy, KakaoStrategy, FacebookStrategy, AppleStrategy],
  exports: [AuthService],
})
export class AuthModule {}
