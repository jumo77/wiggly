import { IsBoolean, IsNumber, IsOptional } from 'class-validator';

export class EntranceDto {
  @IsNumber()
  readonly roomId: number;

  @IsNumber()
  readonly userId: number;

  @IsOptional()
  @IsBoolean()
  readonly enter?: boolean;
}
