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
