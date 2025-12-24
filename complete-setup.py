#!/usr/bin/env python3
"""
UEMS Project Complete Setup Script
Generates all necessary backend modules, frontend components, and configurations
"""

import os
import json

PROJECT_ROOT = "/home/mahmoud/AI/Projects/claude-Version1"

# File templates
FILES = {
    # CRM Module
    "backend/src/modules/crm/crm.module.ts": """import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Contact } from './entities/contact.entity';
import { Organization } from './entities/organization.entity';
import { Deal } from './entities/deal.entity';
import { Activity } from './entities/activity.entity';
import { ContactsController } from './controllers/contacts.controller';
import { OrganizationsController } from './controllers/organizations.controller';
import { DealsController } from './controllers/deals.controller';
import { ActivitiesController } from './controllers/activities.controller';
import { ContactsService } from './services/contacts.service';
import { OrganizationsService } from './services/organizations.service';
import { DealsService } from './services/deals.service';
import { ActivitiesService } from './services/activities.service';

@Module({
  imports: [TypeOrmModule.forFeature([Contact, Organization, Deal, Activity])],
  controllers: [
    ContactsController,
    OrganizationsController,
    DealsController,
    ActivitiesController,
  ],
  providers: [
    ContactsService,
    OrganizationsService,
    DealsService,
    ActivitiesService,
  ],
  exports: [ContactsService, OrganizationsService, DealsService, ActivitiesService],
})
export class CrmModule {}
""",

    "backend/src/modules/crm/services/contacts.service.ts": """import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Contact } from '../entities/contact.entity';
import { CreateContactDto } from '../dto/create-contact.dto';
import { UpdateContactDto } from '../dto/update-contact.dto';

@Injectable()
export class ContactsService {
  constructor(
    @InjectRepository(Contact)
    private contactRepository: Repository<Contact>,
  ) {}

  async create(createContactDto: CreateContactDto): Promise<Contact> {
    const contact = this.contactRepository.create(createContactDto);
    return this.contactRepository.save(contact);
  }

  async findAll(): Promise<Contact[]> {
    return this.contactRepository.find({
      relations: ['organization'],
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: string): Promise<Contact> {
    const contact = await this.contactRepository.findOne({
      where: { id },
      relations: ['organization'],
    });
    if (!contact) {
      throw new NotFoundException(`Contact #${id} not found`);
    }
    return contact;
  }

  async update(id: string, updateContactDto: UpdateContactDto): Promise<Contact> {
    const contact = await this.findOne(id);
    Object.assign(contact, updateContactDto);
    return this.contactRepository.save(contact);
  }

  async remove(id: string): Promise<void> {
    const contact = await this.findOne(id);
    await this.contactRepository.remove(contact);
  }

  async findByOrganization(organizationId: string): Promise<Contact[]> {
    return this.contactRepository.find({
      where: { organizationId },
      order: { createdAt: 'DESC' },
    });
  }
}
""",

    "backend/src/modules/crm/dto/create-contact.dto.ts": """import { IsString, IsEmail, IsOptional, IsUUID } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateContactDto {
  @ApiProperty()
  @IsString()
  firstName: string;

  @ApiProperty()
  @IsString()
  lastName: string;

  @ApiProperty()
  @IsEmail()
  email: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  phone?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  role?: string;

  @ApiPropertyOptional()
  @IsUUID()
  @IsOptional()
  organizationId?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  notes?: string;
}
""",

    "backend/src/modules/crm/dto/update-contact.dto.ts": """import { PartialType } from '@nestjs/swagger';
import { CreateContactDto } from './create-contact.dto';

export class UpdateContactDto extends PartialType(CreateContactDto) {}
""",

    "backend/src/modules/crm/controllers/contacts.controller.ts": """import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards } from '@nestjs/common';
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
  constructor(private readonly contactsService: ContactsService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new contact' })
  create(@Body() createContactDto: CreateContactDto) {
    return this.contactsService.create(createContactDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all contacts' })
  findAll() {
    return this.contactsService.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get contact by ID' })
  findOne(@Param('id') id: string) {
    return this.contactsService.findOne(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update contact' })
  update(@Param('id') id: string, @Body() updateContactDto: UpdateContactDto) {
    return this.contactsService.update(id, updateContactDto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete contact' })
  remove(@Param('id') id: string) {
    return this.contactsService.remove(id);
  }
}
""",

}

def create_file(path, content):
    """Create a file with given content"""
    full_path = os.path.join(PROJECT_ROOT, path)
    os.makedirs(os.path.dirname(full_path), exist_ok=True)
    with open(full_path, 'w') as f:
        f.write(content)
    print(f"✓ Created: {path}")

def main():
    print("=" * 60)
    print("UEMS Project Setup - Creating Files")
    print("=" * 60)

    for path, content in FILES.items():
        create_file(path, content)

    print("=" * 60)
    print(f"✓ Successfully created {len(FILES)} files!")
    print("=" * 60)

if __name__ == "__main__":
    main()
