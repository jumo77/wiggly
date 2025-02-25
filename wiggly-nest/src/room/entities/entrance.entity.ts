import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
} from 'typeorm';

@Entity('table_entrance')
export class Entrance {
  @PrimaryGeneratedColumn()
  id?: number;

  @Column({ name: 'room_id' })
  roomId: number;

  @Column({ name: 'user_id' })
  userId: number;

  @Column({ name: 'enter', default: true })
  enter: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
