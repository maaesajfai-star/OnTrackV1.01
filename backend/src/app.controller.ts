import { Controller, Get, VERSION_NEUTRAL } from '@nestjs/common';
import { ApiTags, ApiOperation } from '@nestjs/swagger';
import { AppService } from './app.service';

@ApiTags('root')
@Controller({
  path: '',
  version: VERSION_NEUTRAL,
})
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  @ApiOperation({ summary: 'Root endpoint - API information' })
  getRoot() {
    return {
      message: 'OnTrack API v1.0.0',
      documentation: '/api/docs',
      health: '/health',
      api: '/api/v1',
    };
  }
}
