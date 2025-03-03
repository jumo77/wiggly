import { TypeOrmModule } from '@nestjs/typeorm';
import { Module } from '@nestjs/common';

import { ChatModule } from './chat/chat.module';
import { UserModule } from './user/user.module';
import { AuthModule } from './auth/auth.module';
import { ConfigModule } from '@nestjs/config';
import { RoomModule } from './room/room.module';
import { AlertModule } from './alert/alert.module';
import { MailModule } from './mail/mail.module';
import { ScheduleModule } from '@nestjs/schedule';

@Module({
  imports: [
    ConfigModule.forRoot({
      envFilePath: '/home/ubuntu/wiggly/.env',
    }),
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DB_HOST,
      schema: process.env.DB_SCHEMA,
      port: +process.env.DB_PORT,
      username: process.env.DB_USERNAME,
      password: process.env.DB_PASS,
      database: process.env.DB_NAME,
      autoLoadEntities: true,
    }),
    ScheduleModule.forRoot(),
    ChatModule,
    UserModule,
    AuthModule,
    RoomModule,
    AlertModule,
    MailModule,
  ],
  providers: [],
})
export class AppModule {}
