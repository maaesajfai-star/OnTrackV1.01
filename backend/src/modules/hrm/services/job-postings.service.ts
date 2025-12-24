import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JobPosting } from '../entities/job-posting.entity';
import { CreateJobPostingDto } from '../dto/create-job-posting.dto';
import { UpdateJobPostingDto } from '../dto/update-job-posting.dto';

@Injectable()
export class JobPostingsService {
  constructor(@InjectRepository(JobPosting) private repo: Repository<JobPosting>) {}

  create(dto: CreateJobPostingDto) { return this.repo.save(this.repo.create(dto)); }
  findAll() { return this.repo.find({ order: { createdAt: 'DESC' } }); }
  async findOne(id: string) {
    const item = await this.repo.findOne({ where: { id } });
    if (!item) throw new NotFoundException(`Job Posting #${id} not found`);
    return item;
  }
  async update(id: string, dto: UpdateJobPostingDto) {
    const item = await this.findOne(id);
    return this.repo.save({ ...item, ...dto });
  }
  async remove(id: string) {
    const item = await this.findOne(id);
    await this.repo.remove(item);
  }
  findByStatus(status: string) {
    return this.repo.find({ where: { status: status as any } });
  }
}
