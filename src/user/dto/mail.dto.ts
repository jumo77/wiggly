import { IsNotEmpty, IsString } from 'class-validator';

export class MailDto {
  @IsString()
  @IsNotEmpty()
  email: string;
}
