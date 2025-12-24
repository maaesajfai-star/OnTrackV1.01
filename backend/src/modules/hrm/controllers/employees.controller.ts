import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Query } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { EmployeesService } from '../services/employees.service';
import { CreateEmployeeDto } from '../dto/create-employee.dto';
import { UpdateEmployeeDto } from '../dto/update-employee.dto';
import { JwtAuthGuard } from '../../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { Roles, UserRole } from '../../../common/decorators/roles.decorator';

@ApiTags('hrm')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('hrm/employees')
export class EmployeesController {
  constructor(private readonly service: EmployeesService) {}

  @Post() @Roles(UserRole.ADMIN, UserRole.HR_MANAGER)
  @ApiOperation({ summary: 'Create employee' })
  create(@Body() dto: CreateEmployeeDto) { return this.service.create(dto); }

  @Get() @ApiOperation({ summary: 'Get all employees' })
  findAll(@Query('department') department?: string) {
    return department ? this.service.findByDepartment(department) : this.service.findAll();
  }

  @Get(':id') @ApiOperation({ summary: 'Get employee' })
  findOne(@Param('id') id: string) { return this.service.findOne(id); }

  @Patch(':id') @Roles(UserRole.ADMIN, UserRole.HR_MANAGER)
  @ApiOperation({ summary: 'Update employee' })
  update(@Param('id') id: string, @Body() dto: UpdateEmployeeDto) { return this.service.update(id, dto); }

  @Delete(':id') @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Delete employee' })
  remove(@Param('id') id: string) { return this.service.remove(id); }
}
