import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity('table_user')
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'login_id' })
  loginId: string;

  @Column()
  password: string;

  @Column()
  validated: boolean;

  @Column({ name: 'fcm_token' })
  fcmToken: string;
}
