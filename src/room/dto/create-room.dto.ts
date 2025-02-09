import { IsNumber, IsString } from 'class-validator';

export class CreateRoomDto {
  @IsString()
  readonly description: string;

  @IsNumber()
  ownerId: number;
}
