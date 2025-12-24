import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Employee } from '../entities/employee.entity';
import { CreateEmployeeDto } from '../dto/create-employee.dto';
import { UpdateEmployeeDto } from '../dto/update-employee.dto';

@Injectable()
export class EmployeesService {
  constructor(@InjectRepository(Employee) private repo: Repository<Employee>) {}

  create(dto: CreateEmployeeDto) { return this.repo.save(this.repo.create(dto)); }
  findAll() { return this.repo.find({ where: { isActive: true }, order: { createdAt: 'DESC' } }); }
  async findOne(id: string) {
    const item = await this.repo.findOne({ where: { id } });
    if (!item) throw new NotFoundException(`Employee #${id} not found`);
    return item;
  }
  async update(id: string, dto: UpdateEmployeeDto) {
    const item = await this.findOne(id);
    return this.repo.save({ ...item, ...dto });
  }
  async remove(id: string) {
    const item = await this.findOne(id);
    await this.repo.remove(item);
  }
  findByDepartment(department: string) {
    return this.repo.find({ where: { department, isActive: true } });
  }
}
