import { Injectable } from '@nestjs/common';
import * as nodemailer from 'nodemailer';
import { mail } from '../auth/html';

@Injectable()
export class MailService {
  async sendMail(to: string, code: string) {
    // 메일 송신 로그
    console.log(new Date(), 'sending mail to', to);
    // 메일 송신 객체
    const transport = nodemailer.createTransport({
      host: process.env.MAIL_SERVER,
      port: 587,
      secure: false,
      auth: {
        user: process.env.MAIL_ID,
        pass: process.env.MAIL_PASSWORD,
      },
    });

    // 메일 보내는 옵션
    const options: nodemailer.SendMailOptions = {
      from: process.env.MAIL_ID,
      to: to,
      subject: process.env.MAIL_TITLE,
      html: mail(to, code),
    };

    // 실패시 서버가 다운 되지 않도록 try catch
    try {
      await transport.sendMail(options);
      console.log(new Date(), 'sent mail to', to);
    } catch (e) {
      console.error(new Date(), e);
    }
  }
}
