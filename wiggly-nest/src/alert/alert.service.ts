import { Injectable } from '@nestjs/common';
import * as admin from 'firebase-admin';

@Injectable()
export class AlertService {
  async sendPushNotification(
    token: string, // 기기의 token값
    title: string, // 알람으로 보낼 제목 데이터
    body: string, // 알람으로 보낼 설명글 데이터
    data?: any, // UI에 보이지 않는 데이터
  ) {
    const message = {
      notification: { title, body },
      data: data || {},
      token,
    };

    // 알람 보내기 실패하면 서버가 종료되는 걸 막는 try catch
    try {
      // 알람 보내는 구문
      const res = await admin.messaging().send(message);
      // 성공시 성공에 대한 데이터 로그
      console.log(new Date(), 'Sent Push Notification', res);
    } catch (e) {
      // 실패시 실패에 대한 데이터 로그
      console.error(new Date(), e);
    }
  }
}
