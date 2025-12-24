import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Candidate } from '../entities/candidate.entity';
import { CreateCandidateDto } from '../dto/create-candidate.dto';
import { UpdateCandidateDto } from '../dto/update-candidate.dto';

@Injectable()
export class CandidatesService {
  constructor(@InjectRepository(Candidate) private repo: Repository<Candidate>) {}

  create(dto: CreateCandidateDto) { return this.repo.save(this.repo.create(dto)); }
  findAll() { return this.repo.find({ relations: ['jobPosting'], order: { createdAt: 'DESC' } }); }
  async findOne(id: string) {
    const item = await this.repo.findOne({ where: { id }, relations: ['jobPosting'] });
    if (!item) throw new NotFoundException(`Candidate #${id} not found`);
    return item;
  }
  async update(id: string, dto: UpdateCandidateDto) {
    const item = await this.findOne(id);
    return this.repo.save({ ...item, ...dto });
  }
  async remove(id: string) {
    const item = await this.findOne(id);
    await this.repo.remove(item);
  }
  findByStage(stage: string) {
    return this.repo.find({ where: { stage: stage as any }, relations: ['jobPosting'] });
  }
  findByJobPosting(jobPostingId: string) {
    return this.repo.find({ where: { jobPostingId }, relations: ['jobPosting'] });
  }
}
