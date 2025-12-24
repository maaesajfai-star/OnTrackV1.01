import { IsString, IsEmail, IsOptional, IsDateString, IsNumber } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateEmployeeDto {
  @ApiProperty() @IsString() employeeId: string;
  @ApiProperty() @IsString() firstName: string;
  @ApiProperty() @IsString() lastName: string;
  @ApiProperty() @IsEmail() email: string;
  @ApiPropertyOptional() @IsString() @IsOptional() phoneNumber?: string;
  @ApiProperty() @IsString() jobTitle: string;
  @ApiProperty() @IsString() department: string;
  @ApiProperty() @IsDateString() startDate: string;
  @ApiPropertyOptional() @IsDateString() @IsOptional() endDate?: string;
  @ApiPropertyOptional() @IsNumber() @IsOptional() salary?: number;
  @ApiPropertyOptional() @IsString() @IsOptional() emergencyContactName?: string;
  @ApiPropertyOptional() @IsString() @IsOptional() emergencyContactPhone?: string;
  @ApiPropertyOptional() @IsString() @IsOptional() address?: string;
  @ApiPropertyOptional() @IsDateString() @IsOptional() dateOfBirth?: string;
  @ApiPropertyOptional() @IsString() @IsOptional() notes?: string;
}
