import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Employee } from './entities/employee.entity';
import { JobPosting } from './entities/job-posting.entity';
import { Candidate } from './entities/candidate.entity';
import { EmployeesController } from './controllers/employees.controller';
import { JobPostingsController } from './controllers/job-postings.controller';
import { CandidatesController } from './controllers/candidates.controller';
import { EmployeesService } from './services/employees.service';
import { JobPostingsService } from './services/job-postings.service';
import { CandidatesService } from './services/candidates.service';
import { CvParserService } from './services/cv-parser.service';

@Module({
  imports: [TypeOrmModule.forFeature([Employee, JobPosting, Candidate])],
  controllers: [EmployeesController, JobPostingsController, CandidatesController],
  providers: [EmployeesService, JobPostingsService, CandidatesService, CvParserService],
  exports: [EmployeesService, JobPostingsService, CandidatesService],
})
export class HrmModule {}
