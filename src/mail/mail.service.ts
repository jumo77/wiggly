import { Injectable } from '@nestjs/common';
import * as nodemailer from 'nodemailer';

@Injectable()
export class MailService {
  async sendMail(to: string, code: string) {
    console.log(new Date(), 'sending mail to', to);
    const transport = nodemailer.createTransport({
      host: process.env.MAIL_SERVER,
      port: 587,
      secure: false,
      auth: {
        user: process.env.MAIL_ID,
        pass: process.env.MAIL_PASSWORD,
      },
    });

    const options: nodemailer.SendMailOptions = {
      from: process.env.MAIL_ID,
      to: to,
      subject: process.env.MAIL_TITLE,
      html: process.env.MAIL_HTML + code,
    };

    try {
      await transport.sendMail(options);
      console.log(new Date(), 'sent mail to', to);
    } catch (e) {
      console.error(new Date(), e);
    }
  }
}
