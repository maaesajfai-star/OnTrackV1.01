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
