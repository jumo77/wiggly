import { IsNumber, IsOptional, IsString } from 'class-validator';

export class AddChatDto {
  @IsString()
  chat: string;

  @IsNumber()
  roomId: number;

  @IsOptional()
  @IsNumber()
  userId?: number;
}
