#!/bin/bash

# UEMS HRM and DMS Modules Setup

set -e
ROOT="/home/mahmoud/AI/Projects/claude-Version1"
cd "$ROOT"

echo "Creating HRM Module..."

# HRM DTOs
cat > backend/src/modules/hrm/dto/create-employee.dto.ts << 'EOF'
import { IsString, IsEmail, IsOptional, IsDateString, IsNumber } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateEmployeeDto {
  @ApiProperty() @IsString() employeeId: string;
  @ApiProperty() @IsString() firstName: string;
  @ApiProperty() @IsString() lastName: string;
  @ApiProperty() @IsEmail() email: string;
  @ApiPropertyOptional() @IsString() @IsOptional() phoneNumber?: string;
  @ApiProperty() @IsString() jobTitle: string;
  @ApiProperty() @IsString() department: string;
  @ApiProperty() @IsDateString() startDate: string;
  @ApiPropertyOptional() @IsDateString() @IsOptional() endDate?: string;
  @ApiPropertyOptional() @IsNumber() @IsOptional() salary?: number;
  @ApiPropertyOptional() @IsString() @IsOptional() emergencyContactName?: string;
  @ApiPropertyOptional() @IsString() @IsOptional() emergencyContactPhone?: string;
  @ApiPropertyOptional() @IsString() @IsOptional() address?: string;
  @ApiPropertyOptional() @IsDateString() @IsOptional() dateOfBirth?: string;
  @ApiPropertyOptional() @IsString() @IsOptional() notes?: string;
}
EOF

cat > backend/src/modules/hrm/dto/update-employee.dto.ts << 'EOF'
import { PartialType } from '@nestjs/swagger';
import { CreateEmployeeDto } from './create-employee.dto';
export class UpdateEmployeeDto extends PartialType(CreateEmployeeDto) {}
EOF

cat > backend/src/modules/hrm/dto/create-job-posting.dto.ts << 'EOF'
import { IsString, IsEnum, IsOptional, IsNumber, IsDateString } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { JobStatus } from '../entities/job-posting.entity';

export class CreateJobPostingDto {
  @ApiProperty() @IsString() title: string;
  @ApiProperty() @IsString() department: string;
  @ApiPropertyOptional() @IsString() @IsOptional() location?: string;
  @ApiPropertyOptional({ enum: JobStatus }) @IsEnum(JobStatus) @IsOptional() status?: JobStatus;
  @ApiProperty() @IsString() description: string;
  @ApiPropertyOptional() @IsString() @IsOptional() requirements?: string;
  @ApiPropertyOptional() @IsNumber() @IsOptional() salaryMin?: number;
  @ApiPropertyOptional() @IsNumber() @IsOptional() salaryMax?: number;
  @ApiPropertyOptional() @IsDateString() @IsOptional() applicationDeadline?: string;
  @ApiPropertyOptional() @IsNumber() @IsOptional() numberOfOpenings?: number;
}
EOF

cat > backend/src/modules/hrm/dto/update-job-posting.dto.ts << 'EOF'
import { PartialType } from '@nestjs/swagger';
import { CreateJobPostingDto } from './create-job-posting.dto';
export class UpdateJobPostingDto extends PartialType(CreateJobPostingDto) {}
EOF

cat > backend/src/modules/hrm/dto/create-candidate.dto.ts << 'EOF'
import { IsString, IsEmail, IsOptional, IsUUID, IsEnum, IsNumber, IsDateString } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { CandidateStage } from '../entities/candidate.entity';

export class CreateCandidateDto {
  @ApiProperty() @IsString() firstName: string;
  @ApiProperty() @IsString() lastName: string;
  @ApiProperty() @IsEmail() email: string;
  @ApiPropertyOptional() @IsString() @IsOptional() phoneNumber?: string;
  @ApiProperty() @IsUUID() jobPostingId: string;
  @ApiPropertyOptional({ enum: CandidateStage }) @IsEnum(CandidateStage) @IsOptional() stage?: CandidateStage;
  @ApiPropertyOptional() @IsNumber() @IsOptional() score?: number;
  @ApiPropertyOptional() @IsString() @IsOptional() notes?: string;
  @ApiPropertyOptional() @IsString() @IsOptional() linkedinUrl?: string;
  @ApiPropertyOptional() @IsDateString() @IsOptional() appliedDate?: string;
}
EOF

cat > backend/src/modules/hrm/dto/update-candidate.dto.ts << 'EOF'
import { PartialType } from '@nestjs/swagger';
import { CreateCandidateDto } from './create-candidate.dto';
export class UpdateCandidateDto extends PartialType(CreateCandidateDto) {}
EOF

echo "✓ HRM DTOs created"

# HRM Services
cat > backend/src/modules/hrm/services/employees.service.ts << 'EOF'
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Employee } from '../entities/employee.entity';
import { CreateEmployeeDto } from '../dto/create-employee.dto';
import { UpdateEmployeeDto } from '../dto/update-employee.dto';

@Injectable()
export class EmployeesService {
  constructor(@InjectRepository(Employee) private repo: Repository<Employee>) {}

  create(dto: CreateEmployeeDto) { return this.repo.save(this.repo.create(dto)); }
  findAll() { return this.repo.find({ where: { isActive: true }, order: { createdAt: 'DESC' } }); }
  async findOne(id: string) {
    const item = await this.repo.findOne({ where: { id } });
    if (!item) throw new NotFoundException(`Employee #${id} not found`);
    return item;
  }
  async update(id: string, dto: UpdateEmployeeDto) {
    const item = await this.findOne(id);
    return this.repo.save({ ...item, ...dto });
  }
  async remove(id: string) {
    const item = await this.findOne(id);
    await this.repo.remove(item);
  }
  findByDepartment(department: string) {
    return this.repo.find({ where: { department, isActive: true } });
  }
}
EOF

cat > backend/src/modules/hrm/services/job-postings.service.ts << 'EOF'
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JobPosting } from '../entities/job-posting.entity';
import { CreateJobPostingDto } from '../dto/create-job-posting.dto';
import { UpdateJobPostingDto } from '../dto/update-job-posting.dto';

@Injectable()
export class JobPostingsService {
  constructor(@InjectRepository(JobPosting) private repo: Repository<JobPosting>) {}

  create(dto: CreateJobPostingDto) { return this.repo.save(this.repo.create(dto)); }
  findAll() { return this.repo.find({ order: { createdAt: 'DESC' } }); }
  async findOne(id: string) {
    const item = await this.repo.findOne({ where: { id } });
    if (!item) throw new NotFoundException(`Job Posting #${id} not found`);
    return item;
  }
  async update(id: string, dto: UpdateJobPostingDto) {
    const item = await this.findOne(id);
    return this.repo.save({ ...item, ...dto });
  }
  async remove(id: string) {
    const item = await this.findOne(id);
    await this.repo.remove(item);
  }
  findByStatus(status: string) {
    return this.repo.find({ where: { status: status as any } });
  }
}
EOF

cat > backend/src/modules/hrm/services/candidates.service.ts << 'EOF'
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Candidate } from '../entities/candidate.entity';
import { CreateCandidateDto } from '../dto/create-candidate.dto';
import { UpdateCandidateDto } from '../dto/update-candidate.dto';

@Injectable()
export class CandidatesService {
  constructor(@InjectRepository(Candidate) private repo: Repository<Candidate>) {}

  create(dto: CreateCandidateDto) { return this.repo.save(this.repo.create(dto)); }
  findAll() { return this.repo.find({ relations: ['jobPosting'], order: { createdAt: 'DESC' } }); }
  async findOne(id: string) {
    const item = await this.repo.findOne({ where: { id }, relations: ['jobPosting'] });
    if (!item) throw new NotFoundException(`Candidate #${id} not found`);
    return item;
  }
  async update(id: string, dto: UpdateCandidateDto) {
    const item = await this.findOne(id);
    return this.repo.save({ ...item, ...dto });
  }
  async remove(id: string) {
    const item = await this.findOne(id);
    await this.repo.remove(item);
  }
  findByStage(stage: string) {
    return this.repo.find({ where: { stage: stage as any }, relations: ['jobPosting'] });
  }
  findByJobPosting(jobPostingId: string) {
    return this.repo.find({ where: { jobPostingId }, relations: ['jobPosting'] });
  }
}
EOF

cat > backend/src/modules/hrm/services/cv-parser.service.ts << 'EOF'
import { Injectable } from '@nestjs/common';
import * as pdfParse from 'pdf-parse';
import * as fs from 'fs';

@Injectable()
export class CvParserService {
  async parsePdf(filePath: string): Promise<any> {
    try {
      const dataBuffer = fs.readFileSync(filePath);
      const data = await pdfParse(dataBuffer);
      const text = data.text;

      // Basic extraction logic
      const emailRegex = /[\w.-]+@[\w.-]+\.\w+/;
      const phoneRegex = /[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}/;
      const nameRegex = /^([A-Z][a-z]+ [A-Z][a-z]+)/m;

      const email = text.match(emailRegex)?.[0] || null;
      const phone = text.match(phoneRegex)?.[0] || null;
      const name = text.match(nameRegex)?.[0] || null;

      return {
        email,
        phone,
        name,
        fullText: text,
        extractedAt: new Date(),
      };
    } catch (error) {
      throw new Error(`Failed to parse CV: ${error.message}`);
    }
  }
}
EOF

echo "✓ HRM Services created"

# HRM Controllers
mkdir -p backend/src/modules/hrm/controllers

cat > backend/src/modules/hrm/controllers/employees.controller.ts << 'EOF'
import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Query } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { EmployeesService } from '../services/employees.service';
import { CreateEmployeeDto } from '../dto/create-employee.dto';
import { UpdateEmployeeDto } from '../dto/update-employee.dto';
import { JwtAuthGuard } from '../../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { Roles, UserRole } from '../../../common/decorators/roles.decorator';

@ApiTags('hrm')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('hrm/employees')
export class EmployeesController {
  constructor(private readonly service: EmployeesService) {}

  @Post() @Roles(UserRole.ADMIN, UserRole.HR_MANAGER)
  @ApiOperation({ summary: 'Create employee' })
  create(@Body() dto: CreateEmployeeDto) { return this.service.create(dto); }

  @Get() @ApiOperation({ summary: 'Get all employees' })
  findAll(@Query('department') department?: string) {
    return department ? this.service.findByDepartment(department) : this.service.findAll();
  }

  @Get(':id') @ApiOperation({ summary: 'Get employee' })
  findOne(@Param('id') id: string) { return this.service.findOne(id); }

  @Patch(':id') @Roles(UserRole.ADMIN, UserRole.HR_MANAGER)
  @ApiOperation({ summary: 'Update employee' })
  update(@Param('id') id: string, @Body() dto: UpdateEmployeeDto) { return this.service.update(id, dto); }

  @Delete(':id') @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Delete employee' })
  remove(@Param('id') id: string) { return this.service.remove(id); }
}
EOF

cat > backend/src/modules/hrm/controllers/job-postings.controller.ts << 'EOF'
import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Query } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { JobPostingsService } from '../services/job-postings.service';
import { CreateJobPostingDto } from '../dto/create-job-posting.dto';
import { UpdateJobPostingDto } from '../dto/update-job-posting.dto';
import { JwtAuthGuard } from '../../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { Roles, UserRole } from '../../../common/decorators/roles.decorator';

@ApiTags('hrm')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('hrm/job-postings')
export class JobPostingsController {
  constructor(private readonly service: JobPostingsService) {}

  @Post() @Roles(UserRole.ADMIN, UserRole.HR_MANAGER)
  @ApiOperation({ summary: 'Create job posting' })
  create(@Body() dto: CreateJobPostingDto) { return this.service.create(dto); }

  @Get() @ApiOperation({ summary: 'Get all job postings' })
  findAll(@Query('status') status?: string) {
    return status ? this.service.findByStatus(status) : this.service.findAll();
  }

  @Get(':id') @ApiOperation({ summary: 'Get job posting' })
  findOne(@Param('id') id: string) { return this.service.findOne(id); }

  @Patch(':id') @Roles(UserRole.ADMIN, UserRole.HR_MANAGER)
  @ApiOperation({ summary: 'Update job posting' })
  update(@Param('id') id: string, @Body() dto: UpdateJobPostingDto) { return this.service.update(id, dto); }

  @Delete(':id') @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Delete job posting' })
  remove(@Param('id') id: string) { return this.service.remove(id); }
}
EOF

cat > backend/src/modules/hrm/controllers/candidates.controller.ts << 'EOF'
import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Query, UploadedFile, UseInterceptors } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiConsumes } from '@nestjs/swagger';
import { CandidatesService } from '../services/candidates.service';
import { CvParserService } from '../services/cv-parser.service';
import { CreateCandidateDto } from '../dto/create-candidate.dto';
import { UpdateCandidateDto } from '../dto/update-candidate.dto';
import { JwtAuthGuard } from '../../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { Roles, UserRole } from '../../../common/decorators/roles.decorator';
import { diskStorage } from 'multer';
import { extname } from 'path';

@ApiTags('hrm')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('hrm/candidates')
export class CandidatesController {
  constructor(
    private readonly service: CandidatesService,
    private readonly cvParser: CvParserService,
  ) {}

  @Post() @Roles(UserRole.ADMIN, UserRole.HR_MANAGER)
  @ApiOperation({ summary: 'Create candidate' })
  create(@Body() dto: CreateCandidateDto) { return this.service.create(dto); }

  @Post('upload-cv')
  @Roles(UserRole.ADMIN, UserRole.HR_MANAGER)
  @ApiOperation({ summary: 'Upload and parse CV' })
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(FileInterceptor('file', {
    storage: diskStorage({
      destination: './uploads/cvs',
      filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, `cv-${uniqueSuffix}${extname(file.originalname)}`);
      },
    }),
  }))
  async uploadCv(@UploadedFile() file: Express.Multer.File) {
    const parsed = await this.cvParser.parsePdf(file.path);
    return { filePath: file.path, parsed };
  }

  @Get() @ApiOperation({ summary: 'Get all candidates' })
  findAll(@Query('stage') stage?: string, @Query('jobPostingId') jobPostingId?: string) {
    if (stage) return this.service.findByStage(stage);
    if (jobPostingId) return this.service.findByJobPosting(jobPostingId);
    return this.service.findAll();
  }

  @Get(':id') @ApiOperation({ summary: 'Get candidate' })
  findOne(@Param('id') id: string) { return this.service.findOne(id); }

  @Patch(':id') @Roles(UserRole.ADMIN, UserRole.HR_MANAGER)
  @ApiOperation({ summary: 'Update candidate' })
  update(@Param('id') id: string, @Body() dto: UpdateCandidateDto) { return this.service.update(id, dto); }

  @Delete(':id') @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Delete candidate' })
  remove(@Param('id') id: string) { return this.service.remove(id); }
}
EOF

echo "✓ HRM Controllers created"

# HRM Module
cat > backend/src/modules/hrm/hrm.module.ts << 'EOF'
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Employee } from './entities/employee.entity';
import { JobPosting } from './entities/job-posting.entity';
import { Candidate } from './entities/candidate.entity';
import { EmployeesController } from './controllers/employees.controller';
import { JobPostingsController } from './controllers/job-postings.controller';
import { CandidatesController } from './controllers/candidates.controller';
import { EmployeesService } from './services/employees.service';
import { JobPostingsService } from './services/job-postings.service';
import { CandidatesService } from './services/candidates.service';
import { CvParserService } from './services/cv-parser.service';

@Module({
  imports: [TypeOrmModule.forFeature([Employee, JobPosting, Candidate])],
  controllers: [EmployeesController, JobPostingsController, CandidatesController],
  providers: [EmployeesService, JobPostingsService, CandidatesService, CvParserService],
  exports: [EmployeesService, JobPostingsService, CandidatesService],
})
export class HrmModule {}
EOF

echo "✓ HRM Module complete!"

# Create DMS Module
echo "Creating DMS Module..."

cat > backend/src/modules/dms/dms.module.ts << 'EOF'
import { Module } from '@nestjs/common';
import { DmsController } from './dms.controller';
import { NextcloudService } from './services/nextcloud.service';

@Module({
  controllers: [DmsController],
  providers: [NextcloudService],
  exports: [NextcloudService],
})
export class DmsModule {}
EOF

cat > backend/src/modules/dms/services/nextcloud.service.ts << 'EOF'
import { Injectable, HttpException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';
import * as xml2js from 'xml2js';

@Injectable()
export class NextcloudService {
  private baseUrl: string;
  private adminUser: string;
  private adminPassword: string;
  private webdavUrl: string;

  constructor(private configService: ConfigService) {
    this.baseUrl = this.configService.get('NEXTCLOUD_URL');
    this.adminUser = this.configService.get('NEXTCLOUD_ADMIN_USER');
    this.adminPassword = this.configService.get('NEXTCLOUD_ADMIN_PASSWORD');
    this.webdavUrl = `${this.baseUrl}/remote.php/dav`;
  }

  private getAuthHeader() {
    const auth = Buffer.from(`${this.adminUser}:${this.adminPassword}`).toString('base64');
    return { Authorization: `Basic ${auth}` };
  }

  async createUser(userId: string, password: string, email: string): Promise<any> {
    try {
      const response = await axios.post(
        `${this.baseUrl}/ocs/v1.php/cloud/users`,
        { userid: userId, password, email },
        {
          headers: {
            ...this.getAuthHeader(),
            'OCS-APIRequest': 'true',
          },
        },
      );
      return response.data;
    } catch (error) {
      throw new HttpException(`Failed to create NextCloud user: ${error.message}`, 500);
    }
  }

  async createFolder(userId: string, folderPath: string): Promise<any> {
    try {
      const fullPath = `${this.webdavUrl}/files/${userId}/${folderPath}`;
      await axios.request({
        method: 'MKCOL',
        url: fullPath,
        headers: this.getAuthHeader(),
      });
      return { success: true, path: folderPath };
    } catch (error) {
      throw new HttpException(`Failed to create folder: ${error.message}`, 500);
    }
  }

  async listFiles(userId: string, path: string = '/'): Promise<any> {
    try {
      const fullPath = `${this.webdavUrl}/files/${userId}${path}`;
      const response = await axios.request({
        method: 'PROPFIND',
        url: fullPath,
        headers: {
          ...this.getAuthHeader(),
          Depth: '1',
        },
      });

      const parser = new xml2js.Parser();
      const result = await parser.parseStringPromise(response.data);
      return result;
    } catch (error) {
      throw new HttpException(`Failed to list files: ${error.message}`, 500);
    }
  }

  async uploadFile(userId: string, filePath: string, fileData: Buffer): Promise<any> {
    try {
      const fullPath = `${this.webdavUrl}/files/${userId}/${filePath}`;
      await axios.put(fullPath, fileData, {
        headers: {
          ...this.getAuthHeader(),
          'Content-Type': 'application/octet-stream',
        },
      });
      return { success: true, path: filePath };
    } catch (error) {
      throw new HttpException(`Failed to upload file: ${error.message}`, 500);
    }
  }

  async deleteFile(userId: string, filePath: string): Promise<any> {
    try {
      const fullPath = `${this.webdavUrl}/files/${userId}/${filePath}`;
      await axios.delete(fullPath, {
        headers: this.getAuthHeader(),
      });
      return { success: true };
    } catch (error) {
      throw new HttpException(`Failed to delete file: ${error.message}`, 500);
    }
  }

  async provisionUserWithFolders(userId: string, password: string, email: string, userType: 'client' | 'employee', entityName: string): Promise<any> {
    try {
      // Create user in NextCloud
      await this.createUser(userId, password, email);

      // Create folder structure based on user type
      if (userType === 'client') {
        await this.createFolder(userId, `Clients/${entityName}`);
      } else if (userType === 'employee') {
        await this.createFolder(userId, `HR/${entityName}`);
      }

      return {
        success: true,
        userId,
        folders: userType === 'client' ? [`Clients/${entityName}`] : [`HR/${entityName}`],
      };
    } catch (error) {
      throw new HttpException(`Failed to provision user: ${error.message}`, 500);
    }
  }
}
EOF

cat > backend/src/modules/dms/dms.controller.ts << 'EOF'
import { Controller, Get, Post, Delete, Body, Param, Query, UseGuards, UploadedFile, UseInterceptors } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { NextcloudService } from './services/nextcloud.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('dms')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtAuthGuard)
@Controller('dms')
export class DmsController {
  constructor(private readonly nextcloudService: NextcloudService) {}

  @Get('files')
  @ApiOperation({ summary: 'List files in NextCloud' })
  async listFiles(@CurrentUser('id') userId: string, @Query('path') path?: string) {
    return this.nextcloudService.listFiles(userId, path || '/');
  }

  @Post('upload')
  @ApiOperation({ summary: 'Upload file to NextCloud' })
  @UseInterceptors(FileInterceptor('file'))
  async uploadFile(
    @CurrentUser('id') userId: string,
    @Query('path') path: string,
    @UploadedFile() file: Express.Multer.File,
  ) {
    return this.nextcloudService.uploadFile(userId, path, file.buffer);
  }

  @Delete('files')
  @ApiOperation({ summary: 'Delete file from NextCloud' })
  async deleteFile(@CurrentUser('id') userId: string, @Query('path') path: string) {
    return this.nextcloudService.deleteFile(userId, path);
  }

  @Post('provision')
  @ApiOperation({ summary: 'Provision NextCloud user with folders' })
  async provision(@Body() body: { userId: string; password: string; email: string; userType: 'client' | 'employee'; entityName: string }) {
    return this.nextcloudService.provisionUserWithFolders(body.userId, body.password, body.email, body.userType, body.entityName);
  }
}
EOF

echo "✓ DMS Module complete!"

# Create uploads directory
mkdir -p backend/uploads/cvs

echo "========================================="
echo "✓ HRM and DMS modules created successfully!"
echo "========================================="
