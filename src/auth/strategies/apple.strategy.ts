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
          'MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgcWNmOmE5DvxWF8Av\n' +
          'DydDm9o2uy7tUx+c21qyC0+LC96gCgYIKoZIzj0DAQehRANCAAQ24aQSAPj71P2U\n' +
          'XySjI0PkIRfJeivOGdkxtOs1RmGOCe7Ss1+O0Go5h/O1BzGP9QYEu3vCLiQ7MxRW\n' +
          'PMYEYvs1\n' +
          '-----END PRIVATE KEY-----',
        passReqToCallback: true,
      },
      async function (req, accessToken, refreshToken, idToken, profile, cb) {
        try {
          const idTokenDecoded = jwtService.decode(idToken);
          console.log(idTokenDecoded);

        } catch (error) {
          console.error(error);
        }
      },
    );
  }
}