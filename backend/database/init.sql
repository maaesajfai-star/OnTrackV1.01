-- UEMS Database Initialization Script
-- This script sets up the initial database configuration

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create indexes for performance
-- (TypeORM will create tables automatically)

-- Set timezone
SET timezone = 'UTC';

-- Grant necessary permissions
GRANT ALL PRIVILEGES ON DATABASE uems_db TO uems_user;

-- Performance settings
ALTER DATABASE uems_db SET random_page_cost = 1.1;
ALTER DATABASE uems_db SET effective_cache_size = '2GB';
ALTER DATABASE uems_db SET shared_buffers = '512MB';
ALTER DATABASE uems_db SET work_mem = '16MB';
ALTER DATABASE uems_db SET maintenance_work_mem = '128MB';

-- Log message
DO $$
BEGIN
  RAISE NOTICE 'UEMS Database initialized successfully';
END $$;
