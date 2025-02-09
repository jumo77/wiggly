import { IsString } from 'class-validator';

export class SignupDto {
  @IsString()
  loginId: string;

  @IsString()
  password: string;
}
