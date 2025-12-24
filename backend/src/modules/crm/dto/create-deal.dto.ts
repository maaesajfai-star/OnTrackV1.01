import { IsString, IsNumber, IsEnum, IsOptional, IsUUID, IsDateString } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { DealStage } from '../entities/deal.entity';

export class CreateDealDto {
  @ApiProperty() @IsString() title: string;
  @ApiProperty() @IsNumber() value: number;
  @ApiPropertyOptional({ enum: DealStage }) @IsEnum(DealStage) @IsOptional() stage?: DealStage;
  @ApiProperty() @IsUUID() contactId: string;
  @ApiPropertyOptional() @IsUUID() @IsOptional() organizationId?: string;
  @ApiPropertyOptional() @IsDateString() @IsOptional() expectedCloseDate?: string;
  @ApiPropertyOptional() @IsString() @IsOptional() description?: string;
  @ApiPropertyOptional() @IsNumber() @IsOptional() probability?: number;
}
