import { IsString, IsEnum, IsOptional, IsNumber, IsDateString } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { JobStatus } from '../entities/job-posting.entity';

export class CreateJobPostingDto {
  @ApiProperty() @IsString() title: string;
  @ApiProperty() @IsString() department: string;
  @ApiPropertyOptional() @IsString() @IsOptional() location?: string;
  @ApiPropertyOptional({ enum: JobStatus }) @IsEnum(JobStatus) @IsOptional() status?: JobStatus;
  @ApiProperty() @IsString() description: string;
  @ApiPropertyOptional() @IsString() @IsOptional() requirements?: string;
  @ApiPropertyOptional() @IsNumber() @IsOptional() salaryMin?: number;
  @ApiPropertyOptional() @IsNumber() @IsOptional() salaryMax?: number;
  @ApiPropertyOptional() @IsDateString() @IsOptional() applicationDeadline?: string;
  @ApiPropertyOptional() @IsNumber() @IsOptional() numberOfOpenings?: number;
}
