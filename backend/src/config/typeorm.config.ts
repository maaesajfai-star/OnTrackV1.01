import { ConfigService } from '@nestjs/config';
import { TypeOrmModuleOptions } from '@nestjs/typeorm';
import { DataSource, DataSourceOptions } from 'typeorm';
import { join } from 'path';

export const typeOrmConfig = (
  configService: ConfigService,
): TypeOrmModuleOptions => {
  const nodeEnv = configService.get('NODE_ENV', 'development');
  const isDevelopment = nodeEnv === 'development';

  // Use absolute paths from project root
  const srcPath = join(process.cwd(), 'src');
  const distPath = join(process.cwd(), 'dist');

  // Detect if we're running from dist/ (compiled) or src/ (ts-node)
  // Check if the main.js file exists in dist/ to determine runtime mode
  const fs = require('fs');
  const isCompiledRuntime = fs.existsSync(join(distPath, 'main.js'));

  // Use .js from dist/ if compiled, otherwise .ts from src/
  const entitiesPath = isCompiledRuntime
    ? [join(distPath, '**', '*.entity.js')]
    : [join(srcPath, '**', '*.entity.ts')];

  const migrationsPath = isCompiledRuntime
    ? [join(distPath, 'database', 'migrations', '*.js')]
    : [join(srcPath, 'database', 'migrations', '*.ts')];

  console.log('[TypeORM] Configuration:', {
    nodeEnv,
    isDevelopment,
    isCompiledRuntime,
    entitiesPath,
    migrationsPath,
  });

  return {
    type: 'postgres',
    host: configService.get('POSTGRES_HOST', 'localhost'),
    port: configService.get('POSTGRES_PORT', 5432),
    username: configService.get('POSTGRES_USER', 'ontrack_user'),
    password: configService.get('POSTGRES_PASSWORD'),
    database: configService.get('POSTGRES_DB', 'ontrack_db'),
    entities: entitiesPath,
    migrations: migrationsPath,
    synchronize: isDevelopment, // Auto-create tables in development, NEVER in production
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

// DataSource for migrations (uses .ts files in development/migration context)
export const dataSourceOptions: DataSourceOptions = {
  type: 'postgres',
  host: process.env.POSTGRES_HOST || 'localhost',
  port: parseInt(process.env.POSTGRES_PORT || '5432'),
  username: process.env.POSTGRES_USER || 'ontrack_user',
  password: process.env.POSTGRES_PASSWORD,
  database: process.env.POSTGRES_DB || 'ontrack_db',
  entities: [join(process.cwd(), 'src', '**', '*.entity.ts')],
  migrations: [join(process.cwd(), 'src', 'database', 'migrations', '*.ts')],
};

const dataSource = new DataSource(dataSourceOptions);
export default dataSource;
