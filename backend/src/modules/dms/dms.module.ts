import { Module } from '@nestjs/common';
import { DmsController } from './dms.controller';
import { NextcloudService } from './services/nextcloud.service';

@Module({
  controllers: [DmsController],
  providers: [NextcloudService],
  exports: [NextcloudService],
})
export class DmsModule {}
