import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Profile, Strategy } from 'passport-kakao';
import { AuthService } from '../auth.service';

@Injectable()
// google에 대한 passport
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
    // redirect url에 송신하는 데이터
    done(null, { id: profile._json.id });
  }
}
