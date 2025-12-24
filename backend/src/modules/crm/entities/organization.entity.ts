import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
  Index,
} from 'typeorm';
import { Contact } from './contact.entity';

@Entity('organizations')
@Index(['name'])
export class Organization {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 255 })
  name: string;

  @Column({ length: 255, nullable: true })
  website: string;

  @Column({ length: 100, nullable: true })
  industry: string;

  @Column({ length: 20, nullable: true })
  phone: string;

  @Column({ type: 'text', nullable: true })
  address: string;

  @Column({ type: 'uuid', nullable: true })
  parentOrganizationId: string;

  @ManyToOne(() => Organization, (org) => org.childOrganizations, {
    onDelete: 'SET NULL',
  })
  @JoinColumn({ name: 'parentOrganizationId' })
  parentOrganization: Organization;

  @OneToMany(() => Organization, (org) => org.parentOrganization)
  childOrganizations: Organization[];

  @OneToMany(() => Contact, (contact) => contact.organization)
  contacts: Contact[];

  @Column({ type: 'text', nullable: true })
  notes: string;

  @Column({ default: true })
  isActive: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
