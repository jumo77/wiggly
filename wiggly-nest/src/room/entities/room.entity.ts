import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity('table_room')
export class Room {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 60, name: 'room_content' })
  description: string;

  @Column({ name: 'user_id' })
  userId: number;

  @Column({ name: 'show_nickname', default: true })
  showNickname: boolean;
}
