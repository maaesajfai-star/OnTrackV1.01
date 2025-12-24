import { SetMetadata } from '@nestjs/common';

export enum UserRole {
  ADMIN = 'admin',
  HR_MANAGER = 'hr_manager',
  SALES_USER = 'sales_user',
  USER = 'user',
}

export const ROLES_KEY = 'roles';
export const Roles = (...roles: UserRole[]) => SetMetadata(ROLES_KEY, roles);
