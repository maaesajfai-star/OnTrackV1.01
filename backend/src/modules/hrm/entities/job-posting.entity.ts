import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';

export enum JobStatus {
  DRAFT = 'draft',
  OPEN = 'open',
  CLOSED = 'closed',
  ON_HOLD = 'on_hold',
}

@Entity('job_postings')
@Index(['status'])
export class JobPosting {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 255 })
  title: string;

  @Column({ length: 100 })
  department: string;

  @Column({ length: 100, nullable: true })
  location: string;

  @Column({
    type: 'enum',
    enum: JobStatus,
    default: JobStatus.DRAFT,
  })
  status: JobStatus;

  @Column({ type: 'text' })
  description: string;

  @Column({ type: 'text', nullable: true })
  requirements: string;

  @Column({ type: 'decimal', precision: 12, scale: 2, nullable: true })
  salaryMin: number;

  @Column({ type: 'decimal', precision: 12, scale: 2, nullable: true })
  salaryMax: number;

  @Column({ type: 'date', nullable: true })
  applicationDeadline: Date;

  @Column({ type: 'int', default: 0 })
  numberOfOpenings: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
