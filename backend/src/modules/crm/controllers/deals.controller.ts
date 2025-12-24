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
