-- -------------------------------------------------------------
-- TablePlus 6.2.1(578)
--
-- https://tableplus.com/
--
-- Database: server
-- Generation Time: 2025-02-11 18:04:00.7920
-- -------------------------------------------------------------
















































-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS rest.ask_id_seq;

-- Table Definition
CREATE TABLE "rest"."ask" (
    "id" int8 NOT NULL DEFAULT nextval('rest.ask_id_seq'::regclass),
    "user_id" int8 NOT NULL,
    "subject" text NOT NULL,
    "content" text NOT NULL,
    "created_at" timestamp NOT NULL DEFAULT now(),
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS rest.ask_answer_id_seq;

-- Table Definition
CREATE TABLE "rest"."ask_answer" (
    "id" int4 NOT NULL DEFAULT nextval('rest.ask_answer_id_seq'::regclass),
    "answer" text NOT NULL,
    "ask_id" int8 NOT NULL,
    "created_at" timestamp NOT NULL DEFAULT now(),
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS rest.avatar_category_id_seq;

-- Table Definition
CREATE TABLE "rest"."avatar_category" (
    "id" int2 NOT NULL DEFAULT nextval('rest.avatar_category_id_seq'::regclass),
    "category" text NOT NULL,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS rest.avatar_id_seq;

-- Table Definition
CREATE TABLE "rest"."avatar_table" (
    "id" int8 NOT NULL DEFAULT nextval('rest.avatar_id_seq'::regclass),
    "name" text NOT NULL,
    "img" text NOT NULL,
    "part_index" text NOT NULL,
    "category_id" int2 NOT NULL,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS rest.chat_id_seq;

-- Table Definition
CREATE TABLE "rest"."chat" (
    "id" int8 NOT NULL DEFAULT nextval('rest.chat_id_seq'::regclass),
    "created_at" timestamp NOT NULL DEFAULT '2025-01-09 08:46:10.718882'::timestamp without time zone,
    "chat" text NOT NULL,
    "room_id" int8 NOT NULL,
    "user_id" int8 NOT NULL,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS rest.comment_id_seq;

-- Table Definition
CREATE TABLE "rest"."comment_table" (
    "id" int8 NOT NULL DEFAULT nextval('rest.comment_id_seq'::regclass),
    "created_at" timestamp NOT NULL DEFAULT '2025-01-09 08:27:45.168162'::timestamp without time zone,
    "comment" text NOT NULL,
    "post_id" int8 NOT NULL,
    "user_id" int8 NOT NULL,
    "parent_id" int8,
    "active" bool NOT NULL DEFAULT true,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS rest.entrence_id_seq;

-- Table Definition
CREATE TABLE "rest"."entrance_table" (
    "id" int8 NOT NULL DEFAULT nextval('rest.entrence_id_seq'::regclass),
    "room_id" int8 NOT NULL,
    "created_at" timestamp NOT NULL DEFAULT now(),
    "user_id" int8 NOT NULL,
    "enter" bool NOT NULL DEFAULT true,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS rest.experience_id_seq;

-- Table Definition
CREATE TABLE "rest"."experience_table" (
    "id" int8 NOT NULL DEFAULT nextval('rest.experience_id_seq'::regclass),
    "exp" int2 NOT NULL,
    "desc" text NOT NULL DEFAULT ''::text,
    "created_at" timestamp NOT NULL DEFAULT '2025-01-09 09:53:46.851196'::timestamp without time zone,
    "user_id" int8 NOT NULL,
    "type_id" int2 NOT NULL DEFAULT 1,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS rest.untitled_table_29_id_seq;

-- Table Definition
CREATE TABLE "rest"."experience_type" (
    "id" int4 NOT NULL DEFAULT nextval('rest.untitled_table_29_id_seq'::regclass),
    "type" text NOT NULL,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS rest.follow_id_seq;

-- Table Definition
CREATE TABLE "rest"."follow" (
    "id" int4 NOT NULL DEFAULT nextval('rest.follow_id_seq'::regclass),
    "follower" int8 NOT NULL,
    "user_id" int8 NOT NULL,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS rest.like_id_seq;

-- Table Definition
CREATE TABLE "rest"."like_table" (
    "id" int8 NOT NULL DEFAULT nextval('rest.like_id_seq'::regclass),
    "created_at" timestamp NOT NULL DEFAULT now(),
    "post_id" int8 NOT NULL,
    "user_id" int8 NOT NULL,
    "like" int2 NOT NULL DEFAULT 1,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS rest.log_id_seq;

-- Table Definition
CREATE TABLE "rest"."log" (
    "id" int4 NOT NULL DEFAULT nextval('rest.log_id_seq'::regclass),
    "user_id" int8 NOT NULL,
    "created_at" timestamp NOT NULL DEFAULT now(),
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS rest."Post_id_seq";

-- Table Definition
CREATE TABLE "rest"."post" (
    "id" int8 NOT NULL DEFAULT nextval('rest."Post_id_seq"'::regclass),
    "create_at" timestamp NOT NULL DEFAULT now(),
    "content" text NOT NULL,
    "user_id" int8 NOT NULL,
    "active" bool NOT NULL DEFAULT true,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS rest.post_images_id_seq;

-- Table Definition
CREATE TABLE "rest"."post_images" (
    "id" int4 NOT NULL DEFAULT nextval('rest.post_images_id_seq'::regclass),
    "post_id" int8 NOT NULL,
    "img" text NOT NULL,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS profile_id_seq;

-- Table Definition
CREATE TABLE "rest"."profile" (
    "id" int8 NOT NULL DEFAULT nextval('profile_id_seq'::regclass),
    "name" text NOT NULL DEFAULT ''::text,
    "nickname" text NOT NULL DEFAULT ''::text,
    "profile_pic" text NOT NULL DEFAULT '기본 이미지'::text,
    "tag" text NOT NULL DEFAULT ''::text,
    "position_x" float4 NOT NULL DEFAULT 0,
    "position_y" float4 NOT NULL DEFAULT 0,
    "desc" text NOT NULL DEFAULT ''::text,
    "user_id" int8 NOT NULL,
    "is_male" bool DEFAULT true,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS rest.report_id_seq;

-- Table Definition
CREATE TABLE "rest"."report" (
    "id" int8 NOT NULL DEFAULT nextval('rest.report_id_seq'::regclass),
    "post_id" int8 NOT NULL,
    "desc" text NOT NULL DEFAULT ''::text,
    "created_at" timestamp NOT NULL DEFAULT now(),
    "user_id" int8 NOT NULL,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS rest.room_id_seq;

-- Table Definition
CREATE TABLE "rest"."room_table" (
    "id" int8 NOT NULL DEFAULT nextval('rest.room_id_seq'::regclass),
    "room_content" text NOT NULL DEFAULT ''::text,
    "show_nickname" bool NOT NULL DEFAULT true,
    "user_id" int8 NOT NULL,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "rest"."typeorm_metadata" (
    "type" varchar NOT NULL,
    "database" varchar,
    "schema" varchar,
    "table" varchar,
    "name" varchar,
    "value" text
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS user_id_seq;

-- Table Definition
CREATE TABLE "rest"."user" (
    "id" int8 NOT NULL DEFAULT nextval('user_id_seq'::regclass),
    "login_id" text NOT NULL,
    "password" text NOT NULL,
    "is_active" bool NOT NULL DEFAULT true,
    "validated" bool NOT NULL DEFAULT false,
    "fcm_token" text,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS rest.user_avatar_id_seq;

-- Table Definition
CREATE TABLE "rest"."user_avatar" (
    "id" int4 NOT NULL DEFAULT nextval('rest.user_avatar_id_seq'::regclass),
    "user_id" int8 NOT NULL,
    "avatar_id" int8 NOT NULL,
    "wear" bool NOT NULL DEFAULT false,
    PRIMARY KEY ("id")
);

INSERT INTO "rest"."chat" ("id", "created_at", "chat", "room_id", "user_id") VALUES
(1, '2025-01-09 08:46:10.718882', 'this is chat', 1, 12),
(2, '2025-01-09 08:46:10.718882', 'this is chat', 1, 12),
(3, '2025-01-09 08:46:10.718882', 'this is chat', 1, 12),
(4, '2025-01-09 08:46:10.718882', 'this is chat', 1, 18),
(5, '2025-01-09 08:46:10.718882', 'this is chat', 1, 18),
(6, '2025-01-09 08:46:10.718882', 'this is chat', 1, 18),
(7, '2025-01-09 08:46:10.718882', 'this is chat', 1, 18),
(8, '2025-01-09 08:46:10.718882', 'this is chat', 1, 18),
(9, '2025-01-09 08:46:10.718882', 'this is chat', 1, 18),
(10, '2025-01-09 08:46:10.718882', 'this is chat', 1, 18);

INSERT INTO "rest"."entrance_table" ("id", "room_id", "created_at", "user_id", "enter") VALUES
(0, 1, '2025-02-01 11:29:49.412591', 1, 't'),
(1, 3, '2025-02-01 15:07:18.977483', 12, 't'),
(2, 1, '2025-02-01 15:07:41.426151', 1, 'f'),
(3, 1, '2025-02-01 15:07:54.665181', 1, 't'),
(4, 3, '2025-02-01 15:08:16.984365', 12, 'f'),
(5, 3, '2025-02-01 15:08:37.395568', 12, 't'),
(6, 3, '2025-02-01 15:16:02.421624', 12, 'f'),
(32, 1, '2025-02-02 05:00:44.695594', 13, 't'),
(33, 1, '2025-02-09 12:00:20.234965', 18, 't'),
(34, 1, '2025-02-09 12:02:03.449522', 18, 't'),
(35, 1, '2025-02-09 12:02:53.442068', 18, 't'),
(36, 1, '2025-02-09 12:08:35.749026', 18, 't'),
(37, 1, '2025-02-09 12:09:15.653625', 18, 't'),
(38, 1, '2025-02-09 12:10:04.824161', 18, 't'),
(39, 1, '2025-02-09 12:10:34.924142', 18, 't');

INSERT INTO "rest"."experience_type" ("id", "type") VALUES
(0, '단순 경험치');

INSERT INTO "rest"."follow" ("id", "follower", "user_id") VALUES
(1, 1, 1),
(2, 1, 2),
(3, 1, 2),
(4, 1, 2),
(5, 1, 2),
(6, 1, 2),
(7, 1, 2),
(8, 1, 2),
(9, 1, 2);

INSERT INTO "rest"."profile" ("id", "name", "nickname", "profile_pic", "tag", "position_x", "position_y", "desc", "user_id", "is_male") VALUES
(1, 'wiggly', 'wigglymania', 'url', '', 0, 0, '', 1, 't'),
(2, 'daniel', '012_da', '', '', 0, 0, 'I love Cyberpunk', 2, 't'),
(3, 'Wiggle man', '_072k', '기본 이미지', '', 0, 0, 'Who wants to dance?', 3, 't'),
(4, 'Haein 해인', 'haein_0727', '기본 이미지', '', 0, 0, '', 4, 't'),
(5, 'Googoo Kim', 'googoo_toys', '기본 이미지', '', 0, 0, '', 5, 't'),
(6, '김영일', '012', '기본 이미지', '', 0, 0, 'desc', 18, 't');

INSERT INTO "rest"."room_table" ("id", "room_content", "show_nickname", "user_id") VALUES
(1, '@haeintheworld', 't', 4),
(3, 'Discover what''s next on Wiggly', 't', 1);

INSERT INTO "rest"."user" ("id", "login_id", "password", "is_active", "validated", "fcm_token") VALUES
(1, 'email', 'userSet', 't', 'f', NULL),
(2, 'kakaoToken', 'kakaoSet', 't', 'f', NULL),
(3, 'googleToken', 'googleSet', 't', 'f', NULL),
(4, 'appleToken', 'appleSet', 't', 'f', NULL),
(5, 'facebookToken', 'facebookSet', 't', 'f', NULL),
(6, 'jumo.kang77', '21046290-dfa8-11ef-b7b9-9d7a21e59c47', 't', 'f', NULL),
(10, 'jumo', '$2a$07$DYX28bmxehfIldUZB6deJOdWWavX4aZNdRGWBzm3BssQhARrrh/Ty', 't', 'f', NULL),
(11, 'jum', '$2a$07$secTTecgxt1BqvIFcAw/9.ZaOu33JfF1k/9L4nread1xltsk21zdC', 't', 'f', NULL),
(12, 'juma', '$2a$07$RbVVEO/m.Esp8VEtpekeluE.3zSvFFfaUhHHiJaQ5vqtxmrsHBcr6', 't', 'f', NULL),
(13, 'jaja', '$2a$07$c/wV/AYL58k.fjEewPe8wu.EXlc14KfkVC0RvjRymxpTXiHJLXm7C', 't', 'f', NULL),
(15, '103234927963285602090', '', 't', 'f', NULL),
(16, '3908196749', '', 't', 'f', NULL),
(17, 'jumo.kang77@gmail.com', '$2a$07$pys6yLpPxClWkZ/41xrAF..7QJzDvFrWM.mj9E9/rXrTHdURqLgiq', 't', 't', 'cpEE4DwZRLuA49sMEbIO4l:APA91bERVH7B8SoC9XE0bR_p4CerC_eUwzPwBJEqCKnWs8znshCJa43ZlcBGPT41jF7gmtazLgcHmypw4c-ayqNMo6q3fYqe4O5x-hQIEURpE5Ny7qBbYHk'),
(18, 'jm', '$2a$07$jis0wzqF2IPqxmb.J8Aohu3O/6GZmCy5Ie6Bg/On0vi3yNVb1xyv6', 't', 'f', NULL),
(20, 'kf6wd9chfy@privaterelay.appleid.com', '', 't', 'f', NULL),
(21, '122106723740751641', '', 't', 'f', NULL);

CREATE VIEW "rest"."avatar" AS ;
CREATE VIEW "rest"."comment" AS ;
CREATE VIEW "rest"."entrence" AS ;
CREATE VIEW "rest"."entrences" AS ;
CREATE VIEW "rest"."experience" AS ;
CREATE VIEW "rest"."experiences" AS ;
CREATE VIEW "rest"."followers" AS ;
CREATE VIEW "rest"."following" AS ;
CREATE VIEW "rest"."like" AS ;
CREATE VIEW "rest"."likes" AS ;
CREATE VIEW "rest"."posts" AS ;
CREATE VIEW "rest"."profiles" AS ;
CREATE VIEW "rest"."room" AS ;
CREATE VIEW "rest"."view_ask" AS ;
CREATE VIEW "rest"."view_chat" AS ;
CREATE VIEW "rest"."view_comment" AS ;
CREATE VIEW "rest"."view_entrence" AS ;
CREATE VIEW "rest"."view_experience" AS ;
CREATE VIEW "rest"."view_like" AS ;
CREATE VIEW "rest"."view_log" AS ;
CREATE VIEW "rest"."view_post" AS ;
CREATE VIEW "rest"."view_room" AS ;
CREATE VIEW "rest"."view_user" AS ;
ALTER TABLE "rest"."ask" ADD FOREIGN KEY ("user_id") REFERENCES "rest"."user"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "rest"."ask_answer" ADD FOREIGN KEY ("ask_id") REFERENCES "rest"."ask"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "rest"."avatar_table" ADD FOREIGN KEY ("category_id") REFERENCES "rest"."avatar_category"("id") ON DELETE RESTRICT ON UPDATE CASCADE;


-- Indices
CREATE UNIQUE INDEX avatar_pkey ON rest.avatar_table USING btree (id);
ALTER TABLE "rest"."chat" ADD FOREIGN KEY ("user_id") REFERENCES "rest"."user"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "rest"."chat" ADD FOREIGN KEY ("room_id") REFERENCES "rest"."room_table"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "rest"."comment_table" ADD FOREIGN KEY ("parent_id") REFERENCES "rest"."comment_table"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "rest"."comment_table" ADD FOREIGN KEY ("post_id") REFERENCES "rest"."post"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "rest"."comment_table" ADD FOREIGN KEY ("user_id") REFERENCES "rest"."user"("id") ON DELETE RESTRICT ON UPDATE CASCADE;


-- Indices
CREATE UNIQUE INDEX comment_pkey ON rest.comment_table USING btree (id);
ALTER TABLE "rest"."entrance_table" ADD FOREIGN KEY ("user_id") REFERENCES "rest"."user"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "rest"."entrance_table" ADD FOREIGN KEY ("room_id") REFERENCES "rest"."room_table"("id") ON DELETE RESTRICT ON UPDATE CASCADE;


-- Indices
CREATE UNIQUE INDEX entrence_pkey ON rest.entrance_table USING btree (id);


-- Indices
CREATE UNIQUE INDEX experience_pkey ON rest.experience_table USING btree (id);


-- Indices
CREATE UNIQUE INDEX untitled_table_29_pkey ON rest.experience_type USING btree (id);
ALTER TABLE "rest"."follow" ADD FOREIGN KEY ("follower") REFERENCES "rest"."user"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "rest"."follow" ADD FOREIGN KEY ("user_id") REFERENCES "rest"."user"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "rest"."like_table" ADD FOREIGN KEY ("post_id") REFERENCES "rest"."post"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "rest"."like_table" ADD FOREIGN KEY ("user_id") REFERENCES "rest"."user"("id") ON DELETE RESTRICT ON UPDATE CASCADE;


-- Indices
CREATE UNIQUE INDEX like_pkey ON rest.like_table USING btree (id);
ALTER TABLE "rest"."log" ADD FOREIGN KEY ("user_id") REFERENCES "rest"."user"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "rest"."post" ADD FOREIGN KEY ("user_id") REFERENCES "rest"."user"("id") ON DELETE RESTRICT ON UPDATE CASCADE;


-- Indices
CREATE UNIQUE INDEX "Post_pkey" ON rest.post USING btree (id);
ALTER TABLE "rest"."profile" ADD FOREIGN KEY ("user_id") REFERENCES "rest"."user"("id") ON DELETE RESTRICT ON UPDATE CASCADE;


-- Indices
CREATE UNIQUE INDEX profile_user_id ON rest.profile USING btree (user_id);
ALTER TABLE "rest"."room_table" ADD FOREIGN KEY ("user_id") REFERENCES "rest"."user"("id") ON DELETE RESTRICT ON UPDATE CASCADE;


-- Indices
CREATE UNIQUE INDEX room_pkey ON rest.room_table USING btree (id);
CREATE UNIQUE INDEX room_user_id ON rest.room_table USING btree (user_id);
ALTER TABLE "rest"."user_avatar" ADD FOREIGN KEY ("avatar_id") REFERENCES "rest"."avatar_table"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "rest"."user_avatar" ADD FOREIGN KEY ("user_id") REFERENCES "rest"."user"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
