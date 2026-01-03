import { DataSource } from 'typeorm';
import { User } from '../modules/users/entities/user.entity';
import { entities } from '../config/typeorm.config';

/**
 * Database initialization script
 * Runs migrations and creates initial admin user if needed
 */
async function initializeDatabase() {
  console.log('🔧 Initializing database...');

  // Create datasource with explicit entities
  const dataSource = new DataSource({
    type: 'postgres',
    host: process.env.POSTGRES_HOST || 'localhost',
    port: parseInt(process.env.POSTGRES_PORT || '5432'),
    username: process.env.POSTGRES_USER || 'ontrack_user',
    password: process.env.POSTGRES_PASSWORD,
    database: process.env.POSTGRES_DB || 'ontrack_db',
    entities: entities,
    migrations: ['src/database/migrations/*.ts'],
    synchronize: false,
  });

  try {
    await dataSource.initialize();
    console.log('✓ Database connection established');

    // Run pending migrations
    console.log('📦 Running migrations...');
    const migrations = await dataSource.runMigrations({ transaction: 'all' });

    if (migrations.length > 0) {
      console.log(`✓ Ran ${migrations.length} migration(s):`);
      migrations.forEach(migration => {
        console.log(`  - ${migration.name}`);
      });
    } else {
      console.log('✓ No pending migrations');
    }

    // Check if admin user exists
    const userRepository = dataSource.getRepository(User);
    const adminExists = await userRepository.findOne({ where: { username: 'Admin' } });

    if (!adminExists) {
      console.log('👤 Creating default Admin user...');

      // Password will be hashed by the @BeforeInsert hook in User entity
      const admin = userRepository.create({
        username: 'Admin',
        email: 'admin@ontrack.local',
        password: 'AdminAdmin@123', // Plain text - will be hashed by entity hook
        firstName: 'System',
        lastName: 'Administrator',
        role: 'admin',
        isActive: true,
      });

      await userRepository.save(admin);
      console.log('✓ Admin user created: Admin / AdminAdmin@123');
    } else {
      console.log('✓ Admin user already exists');
    }

    await dataSource.destroy();
    console.log('🎉 Database initialization completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Database initialization failed:', error);
    await dataSource.destroy();
    process.exit(1);
  }
}

initializeDatabase();
