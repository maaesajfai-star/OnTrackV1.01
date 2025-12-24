import { DataSource } from 'typeorm';
import { dataSourceOptions } from '../../config/typeorm.config';
import { User } from '../../modules/users/entities/user.entity';
import * as bcrypt from 'bcrypt';

async function seed() {
  console.log('🌱 Starting database seed...');

  const dataSource = new DataSource(dataSourceOptions);
  await dataSource.initialize();

  const userRepository = dataSource.getRepository(User);

  // Create default admin user
  const adminExists = await userRepository.findOne({ where: { email: 'admin@uems.com' } });

  if (!adminExists) {
    const admin = userRepository.create({
      email: 'admin@uems.com',
      password: await bcrypt.hash('Admin@123456', 12),
      firstName: 'System',
      lastName: 'Administrator',
      role: 'admin',
      isActive: true,
    });
    await userRepository.save(admin);
    console.log('✓ Admin user created: admin@uems.com / Admin@123456');
  } else {
    console.log('✓ Admin user already exists');
  }

  // Create sample HR Manager
  const hrExists = await userRepository.findOne({ where: { email: 'hr@uems.com' } });

  if (!hrExists) {
    const hrManager = userRepository.create({
      email: 'hr@uems.com',
      password: await bcrypt.hash('HR@123456', 12),
      firstName: 'HR',
      lastName: 'Manager',
      role: 'hr_manager',
      isActive: true,
    });
    await userRepository.save(hrManager);
    console.log('✓ HR Manager created: hr@uems.com / HR@123456');
  }

  // Create sample Sales User
  const salesExists = await userRepository.findOne({ where: { email: 'sales@uems.com' } });

  if (!salesExists) {
    const salesUser = userRepository.create({
      email: 'sales@uems.com',
      password: await bcrypt.hash('Sales@123456', 12),
      firstName: 'Sales',
      lastName: 'User',
      role: 'sales_user',
      isActive: true,
    });
    await userRepository.save(salesUser);
    console.log('✓ Sales User created: sales@uems.com / Sales@123456');
  }

  await dataSource.destroy();
  console.log('🎉 Database seeding completed!');
}

seed().catch((error) => {
  console.error('❌ Seeding failed:', error);
  process.exit(1);
});
