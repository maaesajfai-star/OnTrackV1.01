import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Query } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { ActivitiesService } from '../services/activities.service';
import { CreateActivityDto } from '../dto/create-activity.dto';
import { UpdateActivityDto } from '../dto/update-activity.dto';
import { JwtAuthGuard } from '../../../common/guards/jwt-auth.guard';

@ApiTags('crm')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtAuthGuard)
@Controller('crm/activities')
export class ActivitiesController {
  constructor(private readonly service: ActivitiesService) {}
  @Post() @ApiOperation({ summary: 'Create activity' }) create(@Body() dto: CreateActivityDto) { return this.service.create(dto); }
  @Get() @ApiOperation({ summary: 'Get all activities' }) findAll(@Query('contactId') contactId?: string) {
    return contactId ? this.service.findByContact(contactId) : this.service.findAll();
  }
  @Get(':id') @ApiOperation({ summary: 'Get activity' }) findOne(@Param('id') id: string) { return this.service.findOne(id); }
  @Patch(':id') @ApiOperation({ summary: 'Update activity' }) update(@Param('id') id: string, @Body() dto: UpdateActivityDto) { return this.service.update(id, dto); }
  @Delete(':id') @ApiOperation({ summary: 'Delete activity' }) remove(@Param('id') id: string) { return this.service.remove(id); }
}
