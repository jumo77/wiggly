import { IsNotEmpty, IsNumber, IsOptional, IsString } from 'class-validator';

export class IgnoreDto {
  @IsString()
  @IsOptional()
  nickname: string;

  @IsString()
  @IsOptional()
  profilePic: string;

  @IsNumber()
  @IsNotEmpty()
  inviterId: number;
}
