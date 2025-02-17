import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { JwtService } from '@nestjs/jwt';
import { Strategy } from 'passport-apple';
import { UserService } from '../../user/user.service';

@Injectable()
export class AppleStrategy extends PassportStrategy(Strategy, 'apple') {
  constructor(
    private readonly jwtService: JwtService,
    private readonly userService: UserService,
  ) {
    super(
      {
        clientID: process.env.APPLE_CLIENT_ID,
        teamID: process.env.APPLE_TEAM_ID,
        callbackURL: process.env.APPLE_CALLBACK_URL,
        keyID: process.env.APPLE_KEY_ID,
        privateKeyString:
          '-----BEGIN PRIVATE KEY-----\n' +
          'MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgZ+YiXfEMoUTHvt7C\n' +
          'ePAqa70RpHiYZw9qPzjhtDECVbegCgYIKoZIzj0DAQehRANCAAQwjua5Hf/vQzOI\n' +
          'i5cRD58gIviFueRGlqVIfLmNTWX8g9SlnO+pAr5vaTGx/IwPB46Vy2cQbdTnsrkn\n' +
          'PHSgmbnU\n' +
          '-----END PRIVATE KEY-----',
        passReqToCallback: true,
      },
      async function(req, accessToken, refreshToken, idToken, profile, cb) {
        try {
          const idTokenDecoded = jwtService.decode(idToken);
          // redirect url에 송신하는 데이터
          cb(null, { id: idTokenDecoded['email'] });
        } catch (error) {
          console.error(error);
        }
      },
    );
  }
}
