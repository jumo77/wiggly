import { IsString } from 'class-validator';

export class LoginUserDto {
  @IsString()
  loginId: string;

  @IsString()
  password: string;
}
