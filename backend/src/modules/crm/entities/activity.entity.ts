import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { Contact } from './contact.entity';

export enum ActivityType {
  CALL = 'call',
  EMAIL = 'email',
  MEETING = 'meeting',
  NOTE = 'note',
}

@Entity('activities')
@Index(['type'])
@Index(['contactId'])
@Index(['activityDate'])
export class Activity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({
    type: 'enum',
    enum: ActivityType,
  })
  type: ActivityType;

  @Column({ length: 255 })
  subject: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ type: 'uuid' })
  contactId: string;

  @ManyToOne(() => Contact, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'contactId' })
  contact: Contact;

  @Column({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  activityDate: Date;

  @Column({ type: 'int', nullable: true })
  durationMinutes: number;

  @CreateDateColumn()
  createdAt: Date;
}
