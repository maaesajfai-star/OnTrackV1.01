import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { JobPosting } from './job-posting.entity';

export enum CandidateStage {
  APPLIED = 'applied',
  SCREENING = 'screening',
  INTERVIEW = 'interview',
  OFFER = 'offer',
  HIRED = 'hired',
  REJECTED = 'rejected',
}

@Entity('candidates')
@Index(['stage'])
@Index(['jobPostingId'])
@Index(['email'])
export class Candidate {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 100 })
  firstName: string;

  @Column({ length: 100 })
  lastName: string;

  @Column({ length: 255 })
  email: string;

  @Column({ length: 20, nullable: true })
  phoneNumber: string;

  @Column({ type: 'uuid' })
  jobPostingId: string;

  @ManyToOne(() => JobPosting, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'jobPostingId' })
  jobPosting: JobPosting;

  @Column({
    type: 'enum',
    enum: CandidateStage,
    default: CandidateStage.APPLIED,
  })
  stage: CandidateStage;

  @Column({ type: 'int', nullable: true })
  score: number;

  @Column({ type: 'text', nullable: true })
  notes: string;

  @Column({ length: 500, nullable: true })
  cvFilePath: string;

  @Column({ length: 500, nullable: true })
  linkedinUrl: string;

  @Column({ type: 'text', nullable: true })
  parsedCvData: string;

  @Column({ type: 'date', nullable: true })
  appliedDate: Date;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  get fullName(): string {
    return `${this.firstName} ${this.lastName}`;
  }
}
