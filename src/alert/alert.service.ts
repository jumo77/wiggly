import { Injectable } from '@nestjs/common';
import * as admin from 'firebase-admin';

@Injectable()
export class AlertService {
  async sendPushNotification(
    token: string,
    title: string,
    body: string,
    data?: any,
  ) {
    const message = {
      notification: { title, body },
      data: data || {},
      token,
    };

    try {
      const res = await admin.messaging().send(message);
      console.log(new Date(), 'Sent Push Notification', res);
    } catch (e) {
      console.error(new Date(), e);
    }
  }
}
