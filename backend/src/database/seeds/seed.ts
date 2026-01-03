import { DataSource } from 'typeorm';
import { User } from '../../modules/users/entities/user.entity';
import { entities } from '../../config/typeorm.config';

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

  // Delete existing admin to recreate with correct password
  const existingAdmin = await userRepository.findOne({ where: { username: 'Admin' } });
  if (existingAdmin) {
    await userRepository.remove(existingAdmin);
    console.log('✓ Removed existing Admin user for recreation');
  }

  // Create universal Admin account
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
  console.log('✓ Universal Admin account created:');
  console.log('  Username: Admin');
  console.log('  Password: AdminAdmin@123');
  console.log('  Email: admin@ontrack.local');

  // Delete and recreate HR Manager
  const existingHr = await userRepository.findOne({ where: { username: 'hrmanager' } });
  if (existingHr) {
    await userRepository.remove(existingHr);
  }

  const hrManager = userRepository.create({
    username: 'hrmanager',
    email: 'hr@ontrack.com',
    password: 'HR@123456', // Plain text - will be hashed by entity hook
    firstName: 'HR',
    lastName: 'Manager',
    role: 'hr_manager',
    isActive: true,
  });
  await userRepository.save(hrManager);
  console.log('✓ HR Manager created: hrmanager / HR@123456');

  // Delete and recreate Sales User
  const existingSales = await userRepository.findOne({ where: { username: 'salesuser' } });
  if (existingSales) {
    await userRepository.remove(existingSales);
  }

  const salesUser = userRepository.create({
    username: 'salesuser',
    email: 'sales@ontrack.com',
    password: 'Sales@123456', // Plain text - will be hashed by entity hook
    firstName: 'Sales',
    lastName: 'User',
    role: 'sales_user',
    isActive: true,
  });
  await userRepository.save(salesUser);
  console.log('✓ Sales User created: salesuser / Sales@123456');

  await dataSource.destroy();
  console.log('🎉 Database seeding completed!');
}

seed().catch((error) => {
  console.error('❌ Seeding failed:', error);
  process.exit(1);
});
