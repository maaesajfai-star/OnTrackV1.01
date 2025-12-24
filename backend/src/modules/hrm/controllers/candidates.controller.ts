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
