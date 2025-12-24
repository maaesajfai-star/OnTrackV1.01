import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ThrottlerModule } from '@nestjs/throttler';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { CrmModule } from './modules/crm/crm.module';
import { HrmModule } from './modules/hrm/hrm.module';
import { DmsModule } from './modules/dms/dms.module';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { typeOrmConfig } from './config/typeorm.config';

@Module({
  imports: [
    // Configuration
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env', '.env.local'],
    }),

    // Database
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: typeOrmConfig,
      inject: [ConfigService],
    }),

    // Rate limiting
    ThrottlerModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        ttl: config.get('RATE_LIMIT_TTL', 60),
        limit: config.get('RATE_LIMIT_MAX', 100),
      }),
    }),

    // Feature modules
    AuthModule,
    UsersModule,
    CrmModule,
    HrmModule,
    DmsModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
