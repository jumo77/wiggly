import { IsNotEmpty, IsNumber, IsString } from 'class-validator';

export class AlertDto {
  @IsNumber()
  @IsNotEmpty()
  inviterId: number;

  @IsString()
  @IsNotEmpty()
  nickname: string;

  @IsNumber()
  @IsNotEmpty()
  roomId: number;

  @IsString()
  @IsNotEmpty()
  profilePic: string;
}
