import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Profile, Strategy } from 'passport-facebook';

@Injectable()
// facebook에 대한 passport
export class FacebookStrategy extends PassportStrategy(Strategy, 'facebook') {
  constructor() {
    super({
      clientID: process.env.FACEBOOK_APP_ID,
      clientSecret: process.env.FACEBOOK_APP_SECRET,
      callbackURL: 'https://duddlfdlek.rhymeinspace.com/45f732703af8e55bfcc0607aa508d915e681e14390fb98f4d99f458b81292c82/auth/facebook/redirect',
      scope: ['public_profile'],
    });
  }

  async validate(
    accessToken: string,
    refreshToken: string,
    profile: Profile,
    done: (err: any, user: any, info?: any) => void,
  ) {
    // redirect url에 송신하는 데이터
    done(null, { id: profile.id });
  }
}
