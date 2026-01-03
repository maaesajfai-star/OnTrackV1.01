import { ConfigService } from '@nestjs/config';
import { TypeOrmModuleOptions } from '@nestjs/typeorm';
import { DataSource, DataSourceOptions } from 'typeorm';

// Import all entities explicitly to avoid glob pattern issues in Docker
import { User } from '../modules/users/entities/user.entity';
import { Contact } from '../modules/crm/entities/contact.entity';
import { Organization } from '../modules/crm/entities/organization.entity';
import { Deal } from '../modules/crm/entities/deal.entity';
import { Activity } from '../modules/crm/entities/activity.entity';
import { Employee } from '../modules/hrm/entities/employee.entity';
import { JobPosting } from '../modules/hrm/entities/job-posting.entity';
import { Candidate } from '../modules/hrm/entities/candidate.entity';

// Export all entities for use in other modules
export const entities = [
  User,
  Contact,
  Organization,
  Deal,
  Activity,
  Employee,
  JobPosting,
  Candidate,
];

export const typeOrmConfig = (
  configService: ConfigService,
): TypeOrmModuleOptions => {
  const nodeEnv = configService.get('NODE_ENV', 'development');
  const isDevelopment = nodeEnv === 'development';

  console.log('[TypeORM] Configuration:', {
    nodeEnv,
    isDevelopment,
    entitiesCount: entities.length,
    entities: entities.map(e => e.name),
  });

  return {
    type: 'postgres',
    host: configService.get('POSTGRES_HOST', 'localhost'),
    port: configService.get('POSTGRES_PORT', 5432),
    username: configService.get('POSTGRES_USER', 'ontrack_user'),
    password: configService.get('POSTGRES_PASSWORD'),
    database: configService.get('POSTGRES_DB', 'ontrack_db'),
    entities: entities, // Use explicit entity array instead of glob patterns
    synchronize: isDevelopment, // Auto-create tables in development
    migrationsRun: false,
    logging: isDevelopment ? ['error', 'warn', 'migration'] : ['error'],
    ssl: configService.get('NODE_ENV') === 'production' ? { rejectUnauthorized: false } : false,
    extra: {
      max: configService.get('DB_POOL_MAX', 10),
      min: configService.get('DB_POOL_MIN', 2),
      connectionTimeoutMillis: configService.get('DB_CONNECTION_TIMEOUT', 30000),
    },
  };
};

// DataSource for migrations and CLI
export const dataSourceOptions: DataSourceOptions = {
  type: 'postgres',
  host: process.env.POSTGRES_HOST || 'localhost',
  port: parseInt(process.env.POSTGRES_PORT || '5432'),
  username: process.env.POSTGRES_USER || 'ontrack_user',
  password: process.env.POSTGRES_PASSWORD,
  database: process.env.POSTGRES_DB || 'ontrack_db',
  entities: entities,
  migrations: ['src/database/migrations/*.ts'],
  synchronize: false,
};

const dataSource = new DataSource(dataSourceOptions);
export default dataSource;
