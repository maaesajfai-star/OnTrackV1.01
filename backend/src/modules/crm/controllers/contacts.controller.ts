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
