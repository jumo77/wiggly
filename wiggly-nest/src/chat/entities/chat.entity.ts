import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
} from 'typeorm';

@Entity('table_chat')
export class Chat {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  chat: string;

  @CreateDateColumn()
  created_at: Date;

  @Column({ name: 'room_id' })
  roomId: number;

  @Column({ name: 'user_id' })
  userId: number;
}
