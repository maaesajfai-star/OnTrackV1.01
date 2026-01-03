import { DataSource } from 'typeorm';
import { User } from '../../modules/users/entities/user.entity';
import { entities } from '../../config/typeorm.config';
import * as bcrypt from 'bcrypt';

async function seed() {
  console.log('🌱 Starting database seed...');

  // Create datasource with explicit entities
  const dataSource = new DataSource({
    type: 'postgres',
    host: process.env.POSTGRES_HOST || 'localhost',
    port: parseInt(process.env.POSTGRES_PORT || '5432'),
    username: process.env.POSTGRES_USER || 'ontrack_user',
    password: process.env.POSTGRES_PASSWORD,
    database: process.env.POSTGRES_DB || 'ontrack_db',
    entities: entities,
    synchronize: false,
  });

  await dataSource.initialize();
  console.log('✓ Database connection established');

  const userRepository = dataSource.getRepository(User);

  // Create universal Admin account
  const adminExists = await userRepository.findOne({ where: { username: 'Admin' } });

  if (!adminExists) {
    const admin = userRepository.create({
      username: 'Admin',
      email: 'admin@ontrack.local',
      password: await bcrypt.hash('AdminAdmin@123', 12),
      firstName: 'System',
      lastName: 'Administrator',
      role: 'admin',
      isActive: true,
    });
    await userRepository.save(admin);
    console.log('✓ Universal Admin account created:');
    console.log('  Username: Admin');
    console.log('  Password: AdminAdmin@123');
    console.log('  Email: admin@ontrack.local');
  } else {
    console.log('✓ Admin user already exists');
  }

  // Create sample HR Manager
  const hrExists = await userRepository.findOne({ where: { username: 'hrmanager' } });

  if (!hrExists) {
    const hrManager = userRepository.create({
      username: 'hrmanager',
      email: 'hr@ontrack.com',
      password: await bcrypt.hash('HR@123456', 12),
      firstName: 'HR',
      lastName: 'Manager',
      role: 'hr_manager',
      isActive: true,
    });
    await userRepository.save(hrManager);
    console.log('✓ HR Manager created: hrmanager / HR@123456');
  }

  // Create sample Sales User
  const salesExists = await userRepository.findOne({ where: { username: 'salesuser' } });

  if (!salesExists) {
    const salesUser = userRepository.create({
      username: 'salesuser',
      email: 'sales@ontrack.com',
      password: await bcrypt.hash('Sales@123456', 12),
      firstName: 'Sales',
      lastName: 'User',
      role: 'sales_user',
      isActive: true,
    });
    await userRepository.save(salesUser);
    console.log('✓ Sales User created: salesuser / Sales@123456');
  }

  await dataSource.destroy();
  console.log('🎉 Database seeding completed!');
}

seed().catch((error) => {
  console.error('❌ Seeding failed:', error);
  process.exit(1);
});
