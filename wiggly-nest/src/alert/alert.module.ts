import { Module } from '@nestjs/common';
import { AlertGateway } from './alert.gateway';
import { UserModule } from '../user/user.module';
import { AuthModule } from '../auth/auth.module';
import { AlertService } from './alert.service';

@Module({
  imports: [UserModule, AuthModule],
  providers: [AlertGateway, AlertService],
})
export class AlertModule {}
