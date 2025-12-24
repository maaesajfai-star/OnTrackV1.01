import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Query } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { JobPostingsService } from '../services/job-postings.service';
import { CreateJobPostingDto } from '../dto/create-job-posting.dto';
import { UpdateJobPostingDto } from '../dto/update-job-posting.dto';
import { JwtAuthGuard } from '../../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { Roles, UserRole } from '../../../common/decorators/roles.decorator';

@ApiTags('hrm')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('hrm/job-postings')
export class JobPostingsController {
  constructor(private readonly service: JobPostingsService) {}

  @Post() @Roles(UserRole.ADMIN, UserRole.HR_MANAGER)
  @ApiOperation({ summary: 'Create job posting' })
  create(@Body() dto: CreateJobPostingDto) { return this.service.create(dto); }

  @Get() @ApiOperation({ summary: 'Get all job postings' })
  findAll(@Query('status') status?: string) {
    return status ? this.service.findByStatus(status) : this.service.findAll();
  }

  @Get(':id') @ApiOperation({ summary: 'Get job posting' })
  findOne(@Param('id') id: string) { return this.service.findOne(id); }

  @Patch(':id') @Roles(UserRole.ADMIN, UserRole.HR_MANAGER)
  @ApiOperation({ summary: 'Update job posting' })
  update(@Param('id') id: string, @Body() dto: UpdateJobPostingDto) { return this.service.update(id, dto); }

  @Delete(':id') @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Delete job posting' })
  remove(@Param('id') id: string) { return this.service.remove(id); }
}
