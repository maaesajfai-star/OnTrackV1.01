import { Injectable } from '@nestjs/common';
import pdfParse from 'pdf-parse';
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
