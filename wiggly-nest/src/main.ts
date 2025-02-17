import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';

import * as cookieParser from 'cookie-parser';

import { AppModule } from './app.module';

import * as path from 'path';
import * as admin from 'firebase-admin';

async function bootstrap() {
  // FCM에 인증
  const serviceAccountPath = path.resolve(__dirname, '../firebaseAccount.json');

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccountPath),
  });

  const app = await NestFactory.create(AppModule);

  // Cors 허용
  app.enableCors({
    origin: true,
    credentials: true,
  });
  // cookie 사용하게 해주는 놈인데, 왜인지 작동을 안 해서 그냥 cookie에 안 씁니다.
  // cookie 동의문이나 그런 게 많기도 해서 header를 사용하는 경우가 많아 패스했습니다.
  app.use(cookieParser());

  //swagger라는 거 세팅입니다. 없어도 되긴 하는데, 사양도 안 잡아먹어 습관처럼 썼습니다.
  const options = new DocumentBuilder()
    .setTitle('Wiggly API server')
    .setDescription("WIGGLY'S server developed by Team Rapid")
    .setVersion('1.0')
    .build();
  const document = SwaggerModule.createDocument(app, options);
  SwaggerModule.setup('api', app, document);

  await app.listen(3001);
}
bootstrap();
