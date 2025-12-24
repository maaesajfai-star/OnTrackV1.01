import { IsString, IsEnum, IsOptional, IsUUID, IsNumber, IsDateString } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { ActivityType } from '../entities/activity.entity';

export class CreateActivityDto {
  @ApiProperty({ enum: ActivityType }) @IsEnum(ActivityType) type: ActivityType;
  @ApiProperty() @IsString() subject: string;
  @ApiPropertyOptional() @IsString() @IsOptional() description?: string;
  @ApiProperty() @IsUUID() contactId: string;
  @ApiPropertyOptional() @IsDateString() @IsOptional() activityDate?: string;
  @ApiPropertyOptional() @IsNumber() @IsOptional() durationMinutes?: number;
}
