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
import { Contact } from './contact.entity';
import { Organization } from './organization.entity';

export enum DealStage {
  NEW = 'new',
  QUALIFIED = 'qualified',
  NEGOTIATION = 'negotiation',
  WON = 'won',
  LOST = 'lost',
}

@Entity('deals')
@Index(['stage'])
@Index(['contactId'])
export class Deal {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 255 })
  title: string;

  @Column({ type: 'decimal', precision: 15, scale: 2, default: 0 })
  value: number;

  @Column({
    type: 'enum',
    enum: DealStage,
    default: DealStage.NEW,
  })
  stage: DealStage;

  @Column({ type: 'uuid' })
  contactId: string;

  @ManyToOne(() => Contact, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'contactId' })
  contact: Contact;

  @Column({ type: 'uuid', nullable: true })
  organizationId: string;

  @ManyToOne(() => Organization, { onDelete: 'SET NULL' })
  @JoinColumn({ name: 'organizationId' })
  organization: Organization;

  @Column({ type: 'date', nullable: true })
  expectedCloseDate: Date;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ type: 'int', default: 0 })
  probability: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
