import { IsNotEmpty, IsNumber } from 'class-validator';

export class InviteDto {
  @IsNumber()
  @IsNotEmpty()
  userId: number;

  @IsNumber()
  @IsNotEmpty()
  roomId: number;
}
