#!/bin/bash

# UEMS Complete Project Setup Script
# This script creates ALL necessary files for the UEMS project

set -e

ROOT="/home/mahmoud/AI/Projects/claude-Version1"
cd "$ROOT"

echo "========================================="
echo "UEM creating ALL project files..."
echo "========================================="

# Create all CRM DTOs and Services in one go
cat > backend/src/modules/crm/dto/create-contact.dto.ts << 'EOFFILE'
import { IsString, IsEmail, IsOptional, IsUUID } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateContactDto {
  @ApiProperty() @IsString() firstName: string;
  @ApiProperty() @IsString() lastName: string;
  @ApiProperty() @IsEmail() email: string;
  @ApiPropertyOptional() @IsString() @IsOptional() phone?: string;
  @ApiPropertyOptional() @IsString() @IsOptional() role?: string;
  @ApiPropertyOptional() @IsUUID() @IsOptional() organizationId?: string;
  @ApiPropertyOptional() @IsString() @IsOptional() notes?: string;
}
EOFFILE

cat > backend/src/modules/crm/dto/update-contact.dto.ts << 'EOFFILE'
import { PartialType } from '@nestjs/swagger';
import { CreateContactDto } from './create-contact.dto';
export class UpdateContactDto extends PartialType(CreateContactDto) {}
EOFFILE

cat > backend/src/modules/crm/dto/create-organization.dto.ts << 'EOFFILE'
import { IsString, IsOptional, IsUUID } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateOrganizationDto {
  @ApiProperty() @IsString() name: string;
  @ApiPropertyOptional() @IsString() @IsOptional() website?: string;
  @ApiPropertyOptional() @IsString() @IsOptional() industry?: string;
  @ApiPropertyOptional() @IsString() @IsOptional() phone?: string;
  @ApiPropertyOptional() @IsString() @IsOptional() address?: string;
  @ApiPropertyOptional() @IsUUID() @IsOptional() parentOrganizationId?: string;
  @ApiPropertyOptional() @IsString() @IsOptional() notes?: string;
}
EOFFILE

cat > backend/src/modules/crm/dto/update-organization.dto.ts << 'EOFFILE'
import { PartialType } from '@nestjs/swagger';
import { CreateOrganizationDto } from './create-organization.dto';
export class UpdateOrganizationDto extends PartialType(CreateOrganizationDto) {}
EOFFILE

cat > backend/src/modules/crm/dto/create-deal.dto.ts << 'EOFFILE'
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
EOFFILE

cat > backend/src/modules/crm/dto/update-deal.dto.ts << 'EOFFILE'
import { PartialType } from '@nestjs/swagger';
import { CreateDealDto } from './create-deal.dto';
export class UpdateDealDto extends PartialType(CreateDealDto) {}
EOFFILE

cat > backend/src/modules/crm/dto/create-activity.dto.ts << 'EOFFILE'
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
EOFFILE

cat > backend/src/modules/crm/dto/update-activity.dto.ts << 'EOFFILE'
import { PartialType } from '@nestjs/swagger';
import { CreateActivityDto } from './create-activity.dto';
export class UpdateActivityDto extends PartialType(CreateActivityDto) {}
EOFFILE

echo "✓ CRM DTOs created"

# Create CRM Services
cat > backend/src/modules/crm/services/contacts.service.ts << 'EOFFILE'
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Contact } from '../entities/contact.entity';
import { CreateContactDto } from '../dto/create-contact.dto';
import { UpdateContactDto } from '../dto/update-contact.dto';

@Injectable()
export class ContactsService {
  constructor(@InjectRepository(Contact) private repo: Repository<Contact>) {}

  create(dto: CreateContactDto) { return this.repo.save(this.repo.create(dto)); }
  findAll() { return this.repo.find({ relations: ['organization'], order: { createdAt: 'DESC' } }); }
  async findOne(id: string) {
    const item = await this.repo.findOne({ where: { id }, relations: ['organization'] });
    if (!item) throw new NotFoundException(\`Contact #\${id} not found\`);
    return item;
  }
  async update(id: string, dto: UpdateContactDto) {
    const item = await this.findOne(id);
    return this.repo.save({ ...item, ...dto });
  }
  async remove(id: string) {
    const item = await this.findOne(id);
    await this.repo.remove(item);
  }
}
EOFFILE

cat > backend/src/modules/crm/services/organizations.service.ts << 'EOFFILE'
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Organization } from '../entities/organization.entity';
import { CreateOrganizationDto } from '../dto/create-organization.dto';
import { UpdateOrganizationDto } from '../dto/update-organization.dto';

@Injectable()
export class OrganizationsService {
  constructor(@InjectRepository(Organization) private repo: Repository<Organization>) {}

  create(dto: CreateOrganizationDto) { return this.repo.save(this.repo.create(dto)); }
  findAll() { return this.repo.find({ relations: ['parentOrganization'], order: { createdAt: 'DESC' } }); }
  async findOne(id: string) {
    const item = await this.repo.findOne({ where: { id }, relations: ['parentOrganization', 'contacts'] });
    if (!item) throw new NotFoundException(\`Organization #\${id} not found\`);
    return item;
  }
  async update(id: string, dto: UpdateOrganizationDto) {
    const item = await this.findOne(id);
    return this.repo.save({ ...item, ...dto });
  }
  async remove(id: string) {
    const item = await this.findOne(id);
    await this.repo.remove(item);
  }
}
EOFFILE

cat > backend/src/modules/crm/services/deals.service.ts << 'EOFFILE'
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Deal } from '../entities/deal.entity';
import { CreateDealDto } from '../dto/create-deal.dto';
import { UpdateDealDto } from '../dto/update-deal.dto';

@Injectable()
export class DealsService {
  constructor(@InjectRepository(Deal) private repo: Repository<Deal>) {}

  create(dto: CreateDealDto) { return this.repo.save(this.repo.create(dto)); }
  findAll() { return this.repo.find({ relations: ['contact', 'organization'], order: { createdAt: 'DESC' } }); }
  async findOne(id: string) {
    const item = await this.repo.findOne({ where: { id }, relations: ['contact', 'organization'] });
    if (!item) throw new NotFoundException(\`Deal #\${id} not found\`);
    return item;
  }
  async update(id: string, dto: UpdateDealDto) {
    const item = await this.findOne(id);
    return this.repo.save({ ...item, ...dto });
  }
  async remove(id: string) {
    const item = await this.findOne(id);
    await this.repo.remove(item);
  }
  findByStage(stage: string) {
    return this.repo.find({ where: { stage: stage as any }, relations: ['contact', 'organization'] });
  }
}
EOFFILE

cat > backend/src/modules/crm/services/activities.service.ts << 'EOFFILE'
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Activity } from '../entities/activity.entity';
import { CreateActivityDto } from '../dto/create-activity.dto';
import { UpdateActivityDto } from '../dto/update-activity.dto';

@Injectable()
export class ActivitiesService {
  constructor(@InjectRepository(Activity) private repo: Repository<Activity>) {}

  create(dto: CreateActivityDto) { return this.repo.save(this.repo.create(dto)); }
  findAll() { return this.repo.find({ relations: ['contact'], order: { activityDate: 'DESC' } }); }
  async findOne(id: string) {
    const item = await this.repo.findOne({ where: { id }, relations: ['contact'] });
    if (!item) throw new NotFoundException(\`Activity #\${id} not found\`);
    return item;
  }
  async update(id: string, dto: UpdateActivityDto) {
    const item = await this.findOne(id);
    return this.repo.save({ ...item, ...dto });
  }
  async remove(id: string) {
    const item = await this.findOne(id);
    await this.repo.remove(item);
  }
  findByContact(contactId: string) {
    return this.repo.find({ where: { contactId }, relations: ['contact'], order: { activityDate: 'DESC' } });
  }
}
EOFFILE

echo "✓ CRM Services created"

# Create CRM Controllers
cat > backend/src/modules/crm/controllers/contacts.controller.ts << 'EOFFILE'
import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { ContactsService } from '../services/contacts.service';
import { CreateContactDto } from '../dto/create-contact.dto';
import { UpdateContactDto } from '../dto/update-contact.dto';
import { JwtAuthGuard } from '../../../common/guards/jwt-auth.guard';

@ApiTags('crm')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtAuthGuard)
@Controller('crm/contacts')
export class ContactsController {
  constructor(private readonly service: ContactsService) {}
  @Post() @ApiOperation({ summary: 'Create contact' }) create(@Body() dto: CreateContactDto) { return this.service.create(dto); }
  @Get() @ApiOperation({ summary: 'Get all contacts' }) findAll() { return this.service.findAll(); }
  @Get(':id') @ApiOperation({ summary: 'Get contact' }) findOne(@Param('id') id: string) { return this.service.findOne(id); }
  @Patch(':id') @ApiOperation({ summary: 'Update contact' }) update(@Param('id') id: string, @Body() dto: UpdateContactDto) { return this.service.update(id, dto); }
  @Delete(':id') @ApiOperation({ summary: 'Delete contact' }) remove(@Param('id') id: string) { return this.service.remove(id); }
}
EOFFILE

cat > backend/src/modules/crm/controllers/organizations.controller.ts << 'EOFFILE'
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
EOFFILE

cat > backend/src/modules/crm/controllers/deals.controller.ts << 'EOFFILE'
import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Query } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { DealsService } from '../services/deals.service';
import { CreateDealDto } from '../dto/create-deal.dto';
import { UpdateDealDto } from '../dto/update-deal.dto';
import { JwtAuthGuard } from '../../../common/guards/jwt-auth.guard';

@ApiTags('crm')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtAuthGuard)
@Controller('crm/deals')
export class DealsController {
  constructor(private readonly service: DealsService) {}
  @Post() @ApiOperation({ summary: 'Create deal' }) create(@Body() dto: CreateDealDto) { return this.service.create(dto); }
  @Get() @ApiOperation({ summary: 'Get all deals' }) findAll(@Query('stage') stage?: string) {
    return stage ? this.service.findByStage(stage) : this.service.findAll();
  }
  @Get(':id') @ApiOperation({ summary: 'Get deal' }) findOne(@Param('id') id: string) { return this.service.findOne(id); }
  @Patch(':id') @ApiOperation({ summary: 'Update deal' }) update(@Param('id') id: string, @Body() dto: UpdateDealDto) { return this.service.update(id, dto); }
  @Delete(':id') @ApiOperation({ summary: 'Delete deal' }) remove(@Param('id') id: string) { return this.service.remove(id); }
}
EOFFILE

cat > backend/src/modules/crm/controllers/activities.controller.ts << 'EOFFILE'
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
EOFFILE

echo "✓ CRM Controllers created"
echo "✓ CRM Module complete!"

echo "========================================="
echo "✓ All backend CRM files created!"
echo "========================================="
