import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Contact } from './entities/contact.entity';
import { Organization } from './entities/organization.entity';
import { Deal } from './entities/deal.entity';
import { Activity } from './entities/activity.entity';
import { ContactsController } from './controllers/contacts.controller';
import { OrganizationsController } from './controllers/organizations.controller';
import { DealsController } from './controllers/deals.controller';
import { ActivitiesController } from './controllers/activities.controller';
import { ContactsService } from './services/contacts.service';
import { OrganizationsService } from './services/organizations.service';
import { DealsService } from './services/deals.service';
import { ActivitiesService } from './services/activities.service';

@Module({
  imports: [TypeOrmModule.forFeature([Contact, Organization, Deal, Activity])],
  controllers: [
    ContactsController,
    OrganizationsController,
    DealsController,
    ActivitiesController,
  ],
  providers: [
    ContactsService,
    OrganizationsService,
    DealsService,
    ActivitiesService,
  ],
  exports: [ContactsService, OrganizationsService, DealsService, ActivitiesService],
})
export class CrmModule {}
