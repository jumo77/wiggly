import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Profile, Strategy } from 'passport-kakao';
import { AuthService } from '../auth.service';

@Injectable()
export class KakaoStrategy extends PassportStrategy(Strategy, 'kakao') {
  constructor(private readonly authService: AuthService) {
    super({
      clientID: 'f5696246180c9ea6f8a0333846160842',
      clientSecret: process.env.KAKAO_API_KEY,
      callbackURL: `https://duddlfdlek.rhymeinspace.com/45f732703af8e55bfcc0607aa508d915e681e14390fb98f4d99f458b81292c82/auth/kakao`,
    });
  }

  async validate(
    accessToken: string,
    refreshToken: string,
    profile: Profile,
    done: (error: any, user?: any, info?: any) => void,
  ) {
    try {
      const { _json } = profile;
      const user = { id: _json.id };
      done(null, user);
    } catch (error) {
      done(error);
    }
  }
}
