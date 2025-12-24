import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { OrganizationsService } from '../services/organizations.service';
import { CreateOrganizationDto } from '../dto/create-organization.dto';
import { UpdateOrganizationDto } from '../dto/update-organization.dto';
import { JwtAuthGuard } from '../../../common/guards/jwt-auth.guard';

@ApiTags('crm')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtAuthGuard)
@Controller('crm/organizations')
export class OrganizationsController {
  constructor(private readonly service: OrganizationsService) {}
  @Post() @ApiOperation({ summary: 'Create organization' }) create(@Body() dto: CreateOrganizationDto) { return this.service.create(dto); }
  @Get() @ApiOperation({ summary: 'Get all organizations' }) findAll() { return this.service.findAll(); }
  @Get(':id') @ApiOperation({ summary: 'Get organization' }) findOne(@Param('id') id: string) { return this.service.findOne(id); }
  @Patch(':id') @ApiOperation({ summary: 'Update organization' }) update(@Param('id') id: string, @Body() dto: UpdateOrganizationDto) { return this.service.update(id, dto); }
  @Delete(':id') @ApiOperation({ summary: 'Delete organization' }) remove(@Param('id') id: string) { return this.service.remove(id); }
}
