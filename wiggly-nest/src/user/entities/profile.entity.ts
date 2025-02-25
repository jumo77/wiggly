import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity('table_profile')
export class Profile {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'user_id' })
  userId: number;

  @Column()
  name: string;

  @Column()
  nickname: string;

  @Column({ name: 'profile_pic' })
  profilePic: string;

  @Column()
  tag: string;

  @Column()
  desc: string;

  @Column({ name: 'position_x' })
  x: number;

  @Column({ name: 'position_y' })
  y: number;

  @Column({ name: 'is_male' })
  isMale: boolean;

  @Column()
  birthday: Date;
}
