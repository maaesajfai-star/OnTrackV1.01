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
    this.baseUrl = this.configService.get<string>('NEXTCLOUD_URL') || 'http://localhost:8080';
    this.adminUser = this.configService.get<string>('NEXTCLOUD_ADMIN_USER') || 'admin';
    this.adminPassword = this.configService.get<string>('NEXTCLOUD_ADMIN_PASSWORD') || 'admin';
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
