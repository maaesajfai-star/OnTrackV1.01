import { IsString, IsEmail, IsOptional, IsUUID, IsEnum, IsNumber, IsDateString } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { CandidateStage } from '../entities/candidate.entity';

export class CreateCandidateDto {
  @ApiProperty() @IsString() firstName: string;
  @ApiProperty() @IsString() lastName: string;
  @ApiProperty() @IsEmail() email: string;
  @ApiPropertyOptional() @IsString() @IsOptional() phoneNumber?: string;
  @ApiProperty() @IsUUID() jobPostingId: string;
  @ApiPropertyOptional({ enum: CandidateStage }) @IsEnum(CandidateStage) @IsOptional() stage?: CandidateStage;
  @ApiPropertyOptional() @IsNumber() @IsOptional() score?: number;
  @ApiPropertyOptional() @IsString() @IsOptional() notes?: string;
  @ApiPropertyOptional() @IsString() @IsOptional() linkedinUrl?: string;
  @ApiPropertyOptional() @IsDateString() @IsOptional() appliedDate?: string;
}
