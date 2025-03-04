import { Injectable } from '@nestjs/common';
import { PassportStrategy, AuthGuard } from '@nestjs/passport';
import { JwtService } from '@nestjs/jwt';
import { Strategy, Profile } from '@arendajaelu/nestjs-passport-apple';
import { UserService } from '../../user/user.service';

@Injectable()
export class AppleStrategy extends PassportStrategy(Strategy, 'apple') {
  constructor(
	  private readonly jwtService:JwtService
  ) {
    super({
	clientID: process.env.APPLE_CLIENT_ID,
teamID: process.env.APPLE_TEAM_ID,
callbackURL: process.env.APPLE_CALLBACK_URL,
keyID: process.env.APPLE_KEY_ID,
key:
          '-----BEGIN PRIVATE KEY-----\n' +
          'MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgKyewmYD19rUuPhDK\n' +
          'H4NUqu6pWt47Kuz9vAeH2+VcZxGgCgYIKoZIzj0DAQehRANCAAQLkApP77w4PlUv\n' +
          'gy6G49XeoQGD9lClY/NjOCM2YKq9L9K7Y6bxtv1vEQZEO75l8mFhlip9IB569Amp\n' +
          'hqhxU+Zq\n' +
          '-----END PRIVATE KEY-----',
      scope: ['email', 'name'],
      passReqToCallback: false,
    });
  }

  async validate(_accessToken: string, _refreshToken: string, profile: Profile) {
    return {
      emailAddress: profile.email,
      firstName: profile.name?.firstName || '',
      lastName: profile.name?.lastName || '',
    };
  }
}

@Injectable()
export class AppleOAuthGuard extends AuthGuard('apple') {}
