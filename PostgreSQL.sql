--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2 (Ubuntu 17.2-1.pgdg20.04+1)
-- Dumped by pg_dump version 17.4 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: postgrest; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA postgrest;


ALTER SCHEMA postgrest OWNER TO postgres;

--
-- Name: rest; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA rest;


ALTER SCHEMA rest OWNER TO postgres;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: user_avatar_wear_insert(); Type: FUNCTION; Schema: public; Owner: rapid
--

CREATE FUNCTION public.user_avatar_wear_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
INSERT INTO rest.table_user_avatar_wear(user_avatar_id) values(new.id);
RETURN NEW;
end; $$;


ALTER FUNCTION public.user_avatar_wear_insert() OWNER TO rapid;

--
-- Name: get_replies(bigint); Type: FUNCTION; Schema: rest; Owner: rapid
--

CREATE FUNCTION rest.get_replies(comment_id bigint) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
    replies jsonb;
BEGIN
    SELECT jsonb_agg(jsonb_build_object(
        'name', p."name",
        'profile', p.profile_pic,
        'id', c.id,
        'createdAt', c."createdAt",
        'comment', c.comment,
        'post_id', c.post_id,
        'tag', p.tag,
        'room', r.room_pic,
        'room_content', r.room_content,
        'online', r.online,
        'room_name', r.room_name,
        'follower', p.followers,
        'following', p."following",
        'reply', rest.get_replies(c.id)
    )) INTO replies
    FROM rest.comment c
    JOIN rest.view_user p ON c.user_id = p.id
    JOIN rest.room r on c.user_id = r.user_id
    WHERE c.parent_id = comment_id;

    RETURN COALESCE(replies, '[]'::jsonb);
END;
$$;


ALTER FUNCTION rest.get_replies(comment_id bigint) OWNER TO rapid;

--
-- Name: profile_id_seq; Type: SEQUENCE; Schema: public; Owner: rapid
--

CREATE SEQUENCE public.profile_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.profile_id_seq OWNER TO rapid;

--
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: rapid
--

CREATE SEQUENCE public.user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_id_seq OWNER TO rapid;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: table_feed; Type: TABLE; Schema: rest; Owner: rapid
--

CREATE TABLE rest.table_feed (
    id bigint NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    content text NOT NULL,
    user_id bigint NOT NULL,
    public boolean DEFAULT true NOT NULL,
    active boolean DEFAULT true NOT NULL
);


ALTER TABLE rest.table_feed OWNER TO rapid;

--
-- Name: Post_id_seq; Type: SEQUENCE; Schema: rest; Owner: rapid
--

CREATE SEQUENCE rest."Post_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE rest."Post_id_seq" OWNER TO rapid;

--
-- Name: Post_id_seq; Type: SEQUENCE OWNED BY; Schema: rest; Owner: rapid
--

ALTER SEQUENCE rest."Post_id_seq" OWNED BY rest.table_feed.id;


--
-- Name: table_ask_answer; Type: TABLE; Schema: rest; Owner: rapid
--

CREATE TABLE rest.table_ask_answer (
    id integer NOT NULL,
    answer text NOT NULL,
    ask_id bigint NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE rest.table_ask_answer OWNER TO rapid;

--
-- Name: ask_answer_id_seq; Type: SEQUENCE; Schema: rest; Owner: rapid
--

CREATE SEQUENCE rest.ask_answer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE rest.ask_answer_id_seq OWNER TO rapid;

--
-- Name: ask_answer_id_seq; Type: SEQUENCE OWNED BY; Schema: rest; Owner: rapid
--

ALTER SEQUENCE rest.ask_answer_id_seq OWNED BY rest.table_ask_answer.id;


--
-- Name: table_ask; Type: TABLE; Schema: rest; Owner: rapid
--

CREATE TABLE rest.table_ask (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    subject text NOT NULL,
    content text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    active boolean DEFAULT true NOT NULL
);


ALTER TABLE rest.table_ask OWNER TO rapid;

--
-- Name: ask_id_seq; Type: SEQUENCE; Schema: rest; Owner: rapid
--

CREATE SEQUENCE rest.ask_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE rest.ask_id_seq OWNER TO rapid;

--
-- Name: ask_id_seq; Type: SEQUENCE OWNED BY; Schema: rest; Owner: rapid
--

ALTER SEQUENCE rest.ask_id_seq OWNED BY rest.table_ask.id;


--
-- Name: table_avatar; Type: TABLE; Schema: rest; Owner: rapid
--

CREATE TABLE rest.table_avatar (
    id bigint NOT NULL,
    name text NOT NULL,
    img text NOT NULL,
    part_index text NOT NULL,
    category_id smallint NOT NULL
);


ALTER TABLE rest.table_avatar OWNER TO rapid;

--
-- Name: table_avatar_category; Type: TABLE; Schema: rest; Owner: rapid
--

CREATE TABLE rest.table_avatar_category (
    id smallint NOT NULL,
    category text NOT NULL
);


ALTER TABLE rest.table_avatar_category OWNER TO rapid;

--
-- Name: avatar; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.avatar AS
 SELECT a.id,
    a.name,
    a.img,
    a.part_index,
    c.category
   FROM (rest.table_avatar a
     JOIN rest.table_avatar_category c ON ((a.category_id = c.id)));


ALTER VIEW rest.avatar OWNER TO rapid;

--
-- Name: avatar_category_id_seq; Type: SEQUENCE; Schema: rest; Owner: rapid
--

CREATE SEQUENCE rest.avatar_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE rest.avatar_category_id_seq OWNER TO rapid;

--
-- Name: avatar_category_id_seq; Type: SEQUENCE OWNED BY; Schema: rest; Owner: rapid
--

ALTER SEQUENCE rest.avatar_category_id_seq OWNED BY rest.table_avatar_category.id;


--
-- Name: avatar_id_seq; Type: SEQUENCE; Schema: rest; Owner: rapid
--

CREATE SEQUENCE rest.avatar_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE rest.avatar_id_seq OWNER TO rapid;

--
-- Name: avatar_id_seq; Type: SEQUENCE OWNED BY; Schema: rest; Owner: rapid
--

ALTER SEQUENCE rest.avatar_id_seq OWNED BY rest.table_avatar.id;


--
-- Name: table_chat; Type: TABLE; Schema: rest; Owner: rapid
--

CREATE TABLE rest.table_chat (
    id bigint NOT NULL,
    created_at timestamp without time zone DEFAULT '2025-01-09 08:46:10.718882'::timestamp without time zone NOT NULL,
    chat text NOT NULL,
    room_id bigint NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE rest.table_chat OWNER TO rapid;

--
-- Name: chat_id_seq; Type: SEQUENCE; Schema: rest; Owner: rapid
--

CREATE SEQUENCE rest.chat_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE rest.chat_id_seq OWNER TO rapid;

--
-- Name: chat_id_seq; Type: SEQUENCE OWNED BY; Schema: rest; Owner: rapid
--

ALTER SEQUENCE rest.chat_id_seq OWNED BY rest.table_chat.id;


--
-- Name: table_comment; Type: TABLE; Schema: rest; Owner: rapid
--

CREATE TABLE rest.table_comment (
    id bigint NOT NULL,
    created_at timestamp without time zone DEFAULT '2025-01-09 08:27:45.168162'::timestamp without time zone NOT NULL,
    comment text NOT NULL,
    post_id bigint NOT NULL,
    user_id bigint NOT NULL,
    parent_id bigint,
    active boolean DEFAULT true NOT NULL,
    tag text DEFAULT ''::text NOT NULL
);


ALTER TABLE rest.table_comment OWNER TO rapid;

--
-- Name: comment; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.comment AS
 SELECT id,
    created_at AS "createdAt",
    comment,
    post_id,
    user_id,
    parent_id,
    active
   FROM rest.table_comment
  WHERE active;


ALTER VIEW rest.comment OWNER TO rapid;

--
-- Name: comment_id_seq; Type: SEQUENCE; Schema: rest; Owner: rapid
--

CREATE SEQUENCE rest.comment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE rest.comment_id_seq OWNER TO rapid;

--
-- Name: comment_id_seq; Type: SEQUENCE OWNED BY; Schema: rest; Owner: rapid
--

ALTER SEQUENCE rest.comment_id_seq OWNED BY rest.table_comment.id;


--
-- Name: table_entrance; Type: TABLE; Schema: rest; Owner: rapid
--

CREATE TABLE rest.table_entrance (
    id bigint NOT NULL,
    room_id bigint NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    user_id bigint NOT NULL,
    enter boolean DEFAULT true NOT NULL
);


ALTER TABLE rest.table_entrance OWNER TO rapid;

--
-- Name: entrences; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.entrences AS
 SELECT DISTINCT ON (room_id, user_id) id,
    user_id,
    room_id,
    created_at,
    enter
   FROM rest.table_entrance
  ORDER BY room_id, user_id, created_at DESC;


ALTER VIEW rest.entrences OWNER TO rapid;

--
-- Name: entrence; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.entrence AS
 SELECT id,
    room_id,
    user_id,
    created_at
   FROM rest.entrences
  WHERE enter;


ALTER VIEW rest.entrence OWNER TO rapid;

--
-- Name: entrence_id_seq; Type: SEQUENCE; Schema: rest; Owner: rapid
--

CREATE SEQUENCE rest.entrence_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE rest.entrence_id_seq OWNER TO rapid;

--
-- Name: entrence_id_seq; Type: SEQUENCE OWNED BY; Schema: rest; Owner: rapid
--

ALTER SEQUENCE rest.entrence_id_seq OWNED BY rest.table_entrance.id;


--
-- Name: table_experience; Type: TABLE; Schema: rest; Owner: rapid
--

CREATE TABLE rest.table_experience (
    id bigint NOT NULL,
    exp smallint NOT NULL,
    "desc" text DEFAULT ''::text NOT NULL,
    created_at timestamp without time zone DEFAULT '2025-01-09 09:53:46.851196'::timestamp without time zone NOT NULL,
    user_id bigint NOT NULL,
    type_id smallint DEFAULT 1 NOT NULL
);


ALTER TABLE rest.table_experience OWNER TO rapid;

--
-- Name: table_experience_type; Type: TABLE; Schema: rest; Owner: rapid
--

CREATE TABLE rest.table_experience_type (
    id integer NOT NULL,
    type text NOT NULL
);


ALTER TABLE rest.table_experience_type OWNER TO rapid;

--
-- Name: experiences; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.experiences AS
 SELECT type.type,
    t.id,
    t.exp,
    t."desc",
    t.created_at,
    t.user_id,
    t.type_id
   FROM (rest.table_experience t
     JOIN rest.table_experience_type type ON ((t.type_id = type.id)));


ALTER VIEW rest.experiences OWNER TO rapid;

--
-- Name: experience; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.experience AS
 SELECT sum(exp) AS exp,
    user_id,
    type
   FROM rest.experiences
  GROUP BY user_id, type;


ALTER VIEW rest.experience OWNER TO rapid;

--
-- Name: experience_id_seq; Type: SEQUENCE; Schema: rest; Owner: rapid
--

CREATE SEQUENCE rest.experience_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE rest.experience_id_seq OWNER TO rapid;

--
-- Name: experience_id_seq; Type: SEQUENCE OWNED BY; Schema: rest; Owner: rapid
--

ALTER SEQUENCE rest.experience_id_seq OWNED BY rest.table_experience.id;


--
-- Name: feeds; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.feeds AS
SELECT
    NULL::bigint AS "like",
    NULL::bigint AS comment_count,
    NULL::timestamp without time zone AS created_at,
    NULL::bigint AS user_id,
    NULL::bigint AS id,
    NULL::text AS content,
    NULL::text[] AS images,
    NULL::boolean AS public,
    NULL::text[] AS hashtag,
    NULL::boolean AS active;


ALTER VIEW rest.feeds OWNER TO rapid;

--
-- Name: feed; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.feed AS
 SELECT "like",
    comment_count,
    created_at,
    user_id,
    id,
    content,
    images,
    public,
    hashtag
   FROM rest.feeds
  WHERE active;


ALTER VIEW rest.feed OWNER TO rapid;

--
-- Name: table_follow; Type: TABLE; Schema: rest; Owner: rapid
--

CREATE TABLE rest.table_follow (
    id integer NOT NULL,
    follower bigint NOT NULL,
    user_id bigint NOT NULL,
    follow boolean DEFAULT true NOT NULL
);


ALTER TABLE rest.table_follow OWNER TO rapid;

--
-- Name: follow; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.follow AS
 SELECT DISTINCT ON (user_id, follower) id,
    follower,
    user_id,
    follow
   FROM rest.table_follow
  ORDER BY user_id, follower, id DESC;


ALTER VIEW rest.follow OWNER TO rapid;

--
-- Name: follow_id_seq; Type: SEQUENCE; Schema: rest; Owner: rapid
--

CREATE SEQUENCE rest.follow_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE rest.follow_id_seq OWNER TO rapid;

--
-- Name: follow_id_seq; Type: SEQUENCE OWNED BY; Schema: rest; Owner: rapid
--

ALTER SEQUENCE rest.follow_id_seq OWNED BY rest.table_follow.id;


--
-- Name: followers; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.followers AS
 SELECT user_id,
    count(follower) AS followers
   FROM rest.follow
  WHERE follow
  GROUP BY user_id;


ALTER VIEW rest.followers OWNER TO rapid;

--
-- Name: following; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.following AS
 SELECT follower AS user_id,
    count(user_id) AS following
   FROM rest.follow
  WHERE follow
  GROUP BY follower;


ALTER VIEW rest.following OWNER TO rapid;

--
-- Name: table_like; Type: TABLE; Schema: rest; Owner: rapid
--

CREATE TABLE rest.table_like (
    id bigint NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    post_id bigint NOT NULL,
    user_id bigint NOT NULL,
    lik smallint DEFAULT 1 NOT NULL,
    "like" boolean DEFAULT true NOT NULL
);


ALTER TABLE rest.table_like OWNER TO rapid;

--
-- Name: likes; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.likes AS
 SELECT DISTINCT ON (post_id, user_id) user_id,
    post_id,
    "like",
    created_at
   FROM rest.table_like
  ORDER BY post_id, user_id, created_at DESC;


ALTER VIEW rest.likes OWNER TO rapid;

--
-- Name: like; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest."like" AS
 SELECT user_id,
    post_id,
    "like",
    created_at
   FROM rest.likes
  WHERE "like";


ALTER VIEW rest."like" OWNER TO rapid;

--
-- Name: like_id_seq; Type: SEQUENCE; Schema: rest; Owner: rapid
--

CREATE SEQUENCE rest.like_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE rest.like_id_seq OWNER TO rapid;

--
-- Name: like_id_seq; Type: SEQUENCE OWNED BY; Schema: rest; Owner: rapid
--

ALTER SEQUENCE rest.like_id_seq OWNED BY rest.table_like.id;


--
-- Name: table_log; Type: TABLE; Schema: rest; Owner: rapid
--

CREATE TABLE rest.table_log (
    id integer NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE rest.table_log OWNER TO rapid;

--
-- Name: log_id_seq; Type: SEQUENCE; Schema: rest; Owner: rapid
--

CREATE SEQUENCE rest.log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE rest.log_id_seq OWNER TO rapid;

--
-- Name: log_id_seq; Type: SEQUENCE OWNED BY; Schema: rest; Owner: rapid
--

ALTER SEQUENCE rest.log_id_seq OWNED BY rest.table_log.id;


--
-- Name: table_profile; Type: TABLE; Schema: rest; Owner: rapid
--

CREATE TABLE rest.table_profile (
    id bigint DEFAULT nextval('public.profile_id_seq'::regclass) NOT NULL,
    name text DEFAULT ''::text NOT NULL,
    nickname text DEFAULT ''::text NOT NULL,
    profile_pic text DEFAULT '기본 이미지'::text NOT NULL,
    tag text DEFAULT ''::text NOT NULL,
    position_x real DEFAULT 0 NOT NULL,
    position_y real DEFAULT 0 NOT NULL,
    "desc" text DEFAULT ''::text NOT NULL,
    user_id bigint NOT NULL,
    is_male boolean DEFAULT true,
    birthday date
);


ALTER TABLE rest.table_profile OWNER TO rapid;

--
-- Name: logs; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.logs AS
 SELECT l.user_id,
    l.created_at AS "time",
    p.name,
    p.nickname
   FROM (rest.table_log l
     JOIN rest.table_profile p ON ((l.user_id = p.user_id)));


ALTER VIEW rest.logs OWNER TO rapid;

--
-- Name: table_feed_images; Type: TABLE; Schema: rest; Owner: rapid
--

CREATE TABLE rest.table_feed_images (
    id integer NOT NULL,
    post_id bigint NOT NULL,
    img text NOT NULL,
    active boolean DEFAULT true NOT NULL
);


ALTER TABLE rest.table_feed_images OWNER TO rapid;

--
-- Name: post_images_id_seq; Type: SEQUENCE; Schema: rest; Owner: rapid
--

CREATE SEQUENCE rest.post_images_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE rest.post_images_id_seq OWNER TO rapid;

--
-- Name: post_images_id_seq; Type: SEQUENCE OWNED BY; Schema: rest; Owner: rapid
--

ALTER SEQUENCE rest.post_images_id_seq OWNED BY rest.table_feed_images.id;


--
-- Name: profiles; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.profiles AS
 SELECT id,
    user_id,
    name,
    nickname,
    profile_pic,
    tag,
    position_x,
    position_y,
    "desc",
        CASE
            WHEN is_male THEN 'male'::text
            ELSE 'female'::text
        END AS gender,
    birthday
   FROM rest.table_profile p;


ALTER VIEW rest.profiles OWNER TO rapid;

--
-- Name: table_report; Type: TABLE; Schema: rest; Owner: rapid
--

CREATE TABLE rest.table_report (
    id bigint NOT NULL,
    post_id bigint,
    "desc" text DEFAULT ''::text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    comp_id bigint NOT NULL,
    def_id bigint
);


ALTER TABLE rest.table_report OWNER TO rapid;

--
-- Name: report_id_seq; Type: SEQUENCE; Schema: rest; Owner: rapid
--

CREATE SEQUENCE rest.report_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE rest.report_id_seq OWNER TO rapid;

--
-- Name: report_id_seq; Type: SEQUENCE OWNED BY; Schema: rest; Owner: rapid
--

ALTER SEQUENCE rest.report_id_seq OWNED BY rest.table_report.id;


--
-- Name: room; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.room AS
SELECT
    NULL::bigint AS online,
    NULL::bigint AS id,
    NULL::text AS room_content,
    NULL::boolean AS show_nickname,
    NULL::bigint AS user_id,
    NULL::text AS room_pic,
    NULL::text AS room_name;


ALTER VIEW rest.room OWNER TO rapid;

--
-- Name: table_room; Type: TABLE; Schema: rest; Owner: rapid
--

CREATE TABLE rest.table_room (
    id bigint NOT NULL,
    room_content text DEFAULT ''::text NOT NULL,
    show_nickname boolean DEFAULT true NOT NULL,
    user_id bigint NOT NULL,
    room_pic text DEFAULT ''::text NOT NULL,
    room_name text DEFAULT ''::text NOT NULL
);


ALTER TABLE rest.table_room OWNER TO rapid;

--
-- Name: room_id_seq; Type: SEQUENCE; Schema: rest; Owner: rapid
--

CREATE SEQUENCE rest.room_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE rest.room_id_seq OWNER TO rapid;

--
-- Name: room_id_seq; Type: SEQUENCE OWNED BY; Schema: rest; Owner: rapid
--

ALTER SEQUENCE rest.room_id_seq OWNED BY rest.table_room.id;


--
-- Name: table_feed_hashtag; Type: TABLE; Schema: rest; Owner: rapid
--

CREATE TABLE rest.table_feed_hashtag (
    id integer NOT NULL,
    post_id bigint NOT NULL,
    tag text NOT NULL
);


ALTER TABLE rest.table_feed_hashtag OWNER TO rapid;

--
-- Name: table_post_hashtag_id_seq; Type: SEQUENCE; Schema: rest; Owner: rapid
--

CREATE SEQUENCE rest.table_post_hashtag_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE rest.table_post_hashtag_id_seq OWNER TO rapid;

--
-- Name: table_post_hashtag_id_seq; Type: SEQUENCE OWNED BY; Schema: rest; Owner: rapid
--

ALTER SEQUENCE rest.table_post_hashtag_id_seq OWNED BY rest.table_feed_hashtag.id;


--
-- Name: table_user; Type: TABLE; Schema: rest; Owner: rapid
--

CREATE TABLE rest.table_user (
    id bigint DEFAULT nextval('public.user_id_seq'::regclass) NOT NULL,
    login_id text NOT NULL,
    password text NOT NULL,
    active boolean DEFAULT true NOT NULL,
    validated boolean DEFAULT false NOT NULL,
    fcm_token text,
    status smallint DEFAULT 0 NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE rest.table_user OWNER TO rapid;

--
-- Name: table_user_avatar; Type: TABLE; Schema: rest; Owner: rapid
--

CREATE TABLE rest.table_user_avatar (
    id integer NOT NULL,
    user_id bigint NOT NULL,
    avatar_id bigint NOT NULL
);


ALTER TABLE rest.table_user_avatar OWNER TO rapid;

--
-- Name: table_user_avatar_wear; Type: TABLE; Schema: rest; Owner: rapid
--

CREATE TABLE rest.table_user_avatar_wear (
    id integer NOT NULL,
    user_avatar_id bigint NOT NULL,
    wear boolean DEFAULT false NOT NULL
);


ALTER TABLE rest.table_user_avatar_wear OWNER TO rapid;

--
-- Name: table_user_avatar_wear_id_seq; Type: SEQUENCE; Schema: rest; Owner: rapid
--

CREATE SEQUENCE rest.table_user_avatar_wear_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE rest.table_user_avatar_wear_id_seq OWNER TO rapid;

--
-- Name: table_user_avatar_wear_id_seq; Type: SEQUENCE OWNED BY; Schema: rest; Owner: rapid
--

ALTER SEQUENCE rest.table_user_avatar_wear_id_seq OWNED BY rest.table_user_avatar_wear.id;


--
-- Name: table_user_status; Type: TABLE; Schema: rest; Owner: rapid
--

CREATE TABLE rest.table_user_status (
    id integer NOT NULL,
    status text
);


ALTER TABLE rest.table_user_status OWNER TO rapid;

--
-- Name: table_user_status_id_seq; Type: SEQUENCE; Schema: rest; Owner: rapid
--

CREATE SEQUENCE rest.table_user_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE rest.table_user_status_id_seq OWNER TO rapid;

--
-- Name: table_user_status_id_seq; Type: SEQUENCE OWNED BY; Schema: rest; Owner: rapid
--

ALTER SEQUENCE rest.table_user_status_id_seq OWNED BY rest.table_user_status.id;


--
-- Name: typeorm_metadata; Type: TABLE; Schema: rest; Owner: admin
--

CREATE TABLE rest.typeorm_metadata (
    type character varying NOT NULL,
    database character varying,
    schema character varying,
    "table" character varying,
    name character varying,
    value text
);


ALTER TABLE rest.typeorm_metadata OWNER TO admin;

--
-- Name: untitled_table_29_id_seq; Type: SEQUENCE; Schema: rest; Owner: rapid
--

CREATE SEQUENCE rest.untitled_table_29_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE rest.untitled_table_29_id_seq OWNER TO rapid;

--
-- Name: untitled_table_29_id_seq; Type: SEQUENCE OWNED BY; Schema: rest; Owner: rapid
--

ALTER SEQUENCE rest.untitled_table_29_id_seq OWNED BY rest.table_experience_type.id;


--
-- Name: user_avatar; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.user_avatar AS
 SELECT u.id,
    u.user_id,
    u.avatar_id,
    w.wear
   FROM (rest.table_user_avatar u
     JOIN rest.table_user_avatar_wear w ON ((u.id = w.user_avatar_id)));


ALTER VIEW rest.user_avatar OWNER TO rapid;

--
-- Name: user_avatar_id_seq; Type: SEQUENCE; Schema: rest; Owner: rapid
--

CREATE SEQUENCE rest.user_avatar_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE rest.user_avatar_id_seq OWNER TO rapid;

--
-- Name: user_avatar_id_seq; Type: SEQUENCE OWNED BY; Schema: rest; Owner: rapid
--

ALTER SEQUENCE rest.user_avatar_id_seq OWNED BY rest.table_user_avatar.id;


--
-- Name: view_ask; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.view_ask AS
 SELECT a.id,
    a.user_id,
    a.subject,
    a.content,
    p.name,
    p.nickname,
    to_char(a.created_at, 'YYYY.MM.DD'::text) AS created_at,
    u.login_id,
    u.password,
    n.answer,
    to_char(n.created_at, 'YYYY.MM.DD'::text) AS answer_at
   FROM (((rest.table_ask a
     LEFT JOIN rest.table_ask_answer n ON ((a.id = n.ask_id)))
     JOIN rest.table_profile p ON ((a.user_id = p.user_id)))
     JOIN rest.table_user u ON ((a.user_id = u.id)))
  WHERE a.active;


ALTER VIEW rest.view_ask OWNER TO rapid;

--
-- Name: view_ask_owner; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.view_ask_owner AS
 SELECT a.id,
    a.user_id,
    a.subject,
    a.content,
    a.active,
    n.answer,
    p.name,
    p.nickname
   FROM ((rest.table_ask a
     JOIN rest.table_ask_answer n ON ((a.id = n.ask_id)))
     JOIN rest.table_profile p ON ((a.user_id = p.user_id)));


ALTER VIEW rest.view_ask_owner OWNER TO rapid;

--
-- Name: view_chat; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.view_chat AS
 SELECT p.nickname,
    p.profile_pic,
    c.id,
    c.created_at,
    c.chat,
    c.room_id,
    c.user_id
   FROM (rest.table_chat c
     JOIN rest.table_profile p ON ((c.user_id = p.user_id)));


ALTER VIEW rest.view_chat OWNER TO rapid;

--
-- Name: view_comment; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.view_comment AS
 SELECT p.nickname,
    p.profile_pic AS profile,
    c.id,
    c."createdAt" AS created_at,
    c.comment,
    c.post_id,
    c.user_id,
    rest.get_replies(c.id) AS reply
   FROM (rest.comment c
     JOIN rest.profiles p ON ((c.user_id = p.user_id)))
  WHERE (c.parent_id IS NULL);


ALTER VIEW rest.view_comment OWNER TO rapid;

--
-- Name: view_comment_owner; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.view_comment_owner AS
 SELECT p.nickname,
    p.profile_pic,
    c.id,
    c."createdAt" AS created_at,
    c.comment,
    c.post_id,
    c.user_id,
    c.parent_id,
    c.active
   FROM (rest.comment c
     JOIN rest.table_profile p ON ((p.user_id = c.user_id)));


ALTER VIEW rest.view_comment_owner OWNER TO rapid;

--
-- Name: view_entrence; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.view_entrence AS
 SELECT p.nickname,
    p.profile_pic,
    e.id,
    e.room_id,
    e.user_id,
    e.created_at
   FROM (rest.entrence e
     JOIN rest.table_profile p ON ((e.user_id = p.user_id)));


ALTER VIEW rest.view_entrence OWNER TO rapid;

--
-- Name: view_experience; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.view_experience AS
 SELECT p.nickname,
    e.exp,
    e.user_id AS "userId",
    e.type
   FROM (rest.experience e
     JOIN rest.table_profile p ON ((e.user_id = p.user_id)));


ALTER VIEW rest.view_experience OWNER TO rapid;

--
-- Name: view_feed; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.view_feed AS
 SELECT u.nickname,
    u.profile_pic,
    p.user_id,
    p."like",
    p.comment_count,
    p.content,
    p.created_at,
    p.images,
    p.id,
    COALESCE(( SELECT json_agg(row_to_json(vc.*)) AS json_agg
           FROM rest.view_comment vc
          WHERE (vc.post_id = p.id)), '[]'::json) AS comments,
    p.hashtag,
    COALESCE(p.images[1], ''::text) AS uri
   FROM (rest.feed p
     JOIN rest.table_profile u ON ((p.user_id = u.user_id)))
  WHERE p.public;


ALTER VIEW rest.view_feed OWNER TO rapid;

--
-- Name: view_feed_admin; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.view_feed_admin AS
 SELECT f.id AS content_id,
    u.login_id AS id,
    p.nickname,
        CASE
            WHEN (length(u.password) >= 10) THEN ''::text
            ELSE u.password
        END AS social,
    to_char(f.created_at, 'YYYY.MM.DD'::text) AS content_at,
        CASE
            WHEN f.public THEN '공개'::text
            ELSE '비공개'::text
        END AS content_status,
    f.comment_count AS comments,
    f."like" AS likes,
    f.content
   FROM ((rest.feeds f
     JOIN rest.profiles p ON ((f.user_id = p.user_id)))
     JOIN rest.table_user u ON ((f.user_id = u.id)))
  ORDER BY f.id DESC;


ALTER VIEW rest.view_feed_admin OWNER TO rapid;

--
-- Name: view_feed_images; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.view_feed_images AS
 SELECT id,
    img,
    post_id
   FROM rest.table_feed_images
  WHERE active;


ALTER VIEW rest.view_feed_images OWNER TO rapid;

--
-- Name: view_feed_images_owner; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.view_feed_images_owner AS
 SELECT id,
    post_id,
    img,
    active
   FROM rest.table_feed_images;


ALTER VIEW rest.view_feed_images_owner OWNER TO rapid;

--
-- Name: view_like; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.view_like AS
 SELECT u.nickname,
    u.profile_pic AS "profilePic",
    u.user_id,
    l.created_at,
    l.post_id
   FROM (rest.likes l
     JOIN rest.table_profile u ON ((l.user_id = u.user_id)));


ALTER VIEW rest.view_like OWNER TO rapid;

--
-- Name: view_log; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.view_log AS
 SELECT name,
    count(user_id) AS visited,
    to_char(max("time"), 'YYYY-MM-DD HH24:MI:SS'::text) AS last,
    to_char(min("time"), 'YYYY-MM-DD HH24:MI:SS'::text) AS first
   FROM rest.logs l
  GROUP BY name;


ALTER VIEW rest.view_log OWNER TO rapid;

--
-- Name: view_log_daily; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.view_log_daily AS
 WITH RECURSIVE date_series AS (
         SELECT (CURRENT_DATE - '2 years'::interval) AS log_date
        UNION ALL
         SELECT (date_series.log_date + '1 day'::interval)
           FROM date_series
          WHERE (date_series.log_date < CURRENT_DATE)
        ), active_users_raw AS (
         SELECT date(min(table_log.created_at)) AS log_date,
            table_log.user_id,
            count(*) AS log_count
           FROM rest.table_log
          GROUP BY table_log.user_id
        ), daily_active_users AS (
         SELECT ds_1.log_date,
            count(DISTINCT a.user_id) AS active_user_count
           FROM (date_series ds_1
             LEFT JOIN active_users_raw a ON (((ds_1.log_date = a.log_date) AND (a.log_count >= 3))))
          GROUP BY ds_1.log_date
        ), returning_users AS (
         SELECT date(table_log.created_at) AS log_date,
            table_log.user_id,
            count(*) AS log_count
           FROM rest.table_log
          GROUP BY (date(table_log.created_at)), table_log.user_id
         HAVING (count(*) > 1)
        ), daily_new_active_users AS (
         SELECT ds_1.log_date,
            count(DISTINCT a.user_id) AS new_active_user_count
           FROM (date_series ds_1
             LEFT JOIN active_users_raw a ON (((ds_1.log_date = a.log_date) AND (a.log_count >= 3))))
          GROUP BY ds_1.log_date
        )
 SELECT to_char(ds.log_date, 'YYYY-MM-DD'::text) AS log_date,
    ( SELECT count(DISTINCT table_log.user_id) AS count
           FROM rest.table_log
          WHERE (date(table_log.created_at) <= ds.log_date)) AS cumulative_users,
    ( SELECT sum(daily_active_users.active_user_count) AS sum
           FROM daily_active_users
          WHERE (daily_active_users.log_date <= ds.log_date)) AS cumulative_active_users,
    dau.new_active_user_count AS new_active_users,
    ( SELECT count(DISTINCT returning_users.user_id) AS count
           FROM returning_users
          WHERE (returning_users.log_date <= ds.log_date)) AS cumulative_returning_users,
    ( SELECT round(avg(daily_new_active_users.new_active_user_count), 0) AS avg
           FROM daily_new_active_users
          WHERE ((daily_new_active_users.log_date >= (ds.log_date - '1 mon'::interval)) AND (daily_new_active_users.log_date <= ds.log_date))) AS monthly_avg_new_active_users
   FROM (date_series ds
     LEFT JOIN daily_new_active_users dau ON ((ds.log_date = dau.log_date)))
  ORDER BY ds.log_date DESC;


ALTER VIEW rest.view_log_daily OWNER TO rapid;

--
-- Name: view_log_monthly; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.view_log_monthly AS
 WITH RECURSIVE month_series AS (
         SELECT date_trunc('month'::text, (CURRENT_DATE - '2 years'::interval)) AS log_month
        UNION ALL
         SELECT (month_series.log_month + '1 mon'::interval)
           FROM month_series
          WHERE (month_series.log_month < date_trunc('month'::text, (CURRENT_DATE)::timestamp with time zone))
        ), active_users_raw AS (
         SELECT date_trunc('month'::text, min(table_log.created_at)) AS log_month,
            table_log.user_id,
            count(*) AS log_count
           FROM rest.table_log
          GROUP BY table_log.user_id
        ), monthly_active_users AS (
         SELECT ms_1.log_month,
            count(DISTINCT a.user_id) AS active_user_count
           FROM (month_series ms_1
             LEFT JOIN active_users_raw a ON (((ms_1.log_month = a.log_month) AND (a.log_count >= 3))))
          GROUP BY ms_1.log_month
        ), returning_users AS (
         SELECT date_trunc('month'::text, table_log.created_at) AS log_month,
            table_log.user_id,
            count(*) AS log_count
           FROM rest.table_log
          GROUP BY (date_trunc('month'::text, table_log.created_at)), table_log.user_id
         HAVING (count(*) > 1)
        ), monthly_new_active_users AS (
         SELECT ms_1.log_month,
            count(DISTINCT a.user_id) AS new_active_user_count
           FROM (month_series ms_1
             LEFT JOIN active_users_raw a ON (((ms_1.log_month = a.log_month) AND (a.log_count >= 3))))
          GROUP BY ms_1.log_month
        )
 SELECT to_char(ms.log_month, 'YYYY-MM'::text) AS log_month,
    ( SELECT count(DISTINCT table_log.user_id) AS count
           FROM rest.table_log
          WHERE (date_trunc('month'::text, table_log.created_at) <= ms.log_month)) AS cumulative_users,
    ( SELECT sum(monthly_active_users.active_user_count) AS sum
           FROM monthly_active_users
          WHERE (monthly_active_users.log_month <= ms.log_month)) AS cumulative_active_users,
    mau.new_active_user_count AS new_active_users,
    ( SELECT count(DISTINCT returning_users.user_id) AS count
           FROM returning_users
          WHERE (returning_users.log_month <= ms.log_month)) AS cumulative_returning_users,
    ( SELECT round(avg(monthly_new_active_users.new_active_user_count), 1) AS avg
           FROM monthly_new_active_users
          WHERE ((monthly_new_active_users.log_month >= (ms.log_month - '1 year'::interval)) AND (monthly_new_active_users.log_month <= ms.log_month))) AS monthly_avg_new_active_users
   FROM (month_series ms
     LEFT JOIN monthly_new_active_users mau ON ((ms.log_month = mau.log_month)))
  ORDER BY ms.log_month DESC;


ALTER VIEW rest.view_log_monthly OWNER TO rapid;

--
-- Name: view_log_total; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.view_log_total AS
 SELECT ( SELECT count(DISTINCT table_log.user_id) AS count
           FROM rest.table_log) AS total_users,
    ( SELECT count(DISTINCT active_users.user_id) AS count
           FROM ( SELECT table_log.user_id,
                    count(*) AS count
                   FROM rest.table_log
                  GROUP BY table_log.user_id
                 HAVING (count(*) >= 3)) active_users) AS total_active_users,
    ( SELECT count(DISTINCT returning_users.user_id) AS count
           FROM ( SELECT table_log.user_id,
                    count(*) AS count
                   FROM rest.table_log
                  GROUP BY table_log.user_id
                 HAVING (count(*) > 1)) returning_users) AS total_returning_users;


ALTER VIEW rest.view_log_total OWNER TO rapid;

--
-- Name: view_post_owner; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.view_post_owner AS
SELECT
    NULL::bigint AS likes,
    NULL::bigint AS comments,
    NULL::timestamp without time zone AS create_at,
    NULL::bigint AS user_id,
    NULL::bigint AS id,
    NULL::text AS content,
    NULL::boolean AS public,
    NULL::text[] AS images;


ALTER VIEW rest.view_post_owner OWNER TO rapid;

--
-- Name: view_report_post; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.view_report_post AS
 SELECT r.id,
    r.post_id,
    r."desc",
    to_char(r.created_at, 'YYYY-MM-DD'::text) AS created_at,
    r.comp_id,
    p.content,
    p.public
   FROM (rest.table_report r
     LEFT JOIN rest.table_feed p ON ((r.post_id = p.id)))
  WHERE (r.post_id IS NOT NULL);


ALTER VIEW rest.view_report_post OWNER TO rapid;

--
-- Name: view_report_user; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.view_report_user AS
 SELECT r.id,
    r.def_id,
    r."desc",
    to_char(r.created_at, 'YYYY-MM-DD'::text) AS created_at,
    r.comp_id,
    p.name,
    p.nickname,
    s.status
   FROM (((rest.table_report r
     LEFT JOIN rest.table_profile p ON ((r.def_id = p.user_id)))
     JOIN rest.table_user u ON ((p.user_id = u.id)))
     JOIN rest.table_user_status s ON ((u.status = s.id)))
  WHERE (r.def_id IS NOT NULL);


ALTER VIEW rest.view_report_user OWNER TO rapid;

--
-- Name: view_room; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.view_room AS
 SELECT p.nickname,
    p.profile_pic,
    r.online,
    r.id,
    r.room_content,
    r.show_nickname,
    r.user_id,
    r.room_pic
   FROM (rest.room r
     JOIN rest.table_profile p ON ((r.user_id = p.user_id)));


ALTER VIEW rest.view_room OWNER TO rapid;

--
-- Name: view_room_views; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.view_room_views AS
 SELECT p.nickname,
    p.user_id,
    u.login_id AS id,
    e.created_at
   FROM (((rest.table_entrance e
     JOIN rest.table_room r ON ((e.room_id = r.id)))
     JOIN rest.table_profile p ON ((r.user_id = p.user_id)))
     JOIN rest.table_user u ON ((e.user_id = u.id)))
  WHERE e.enter;


ALTER VIEW rest.view_room_views OWNER TO rapid;

--
-- Name: view_user; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.view_user AS
 SELECT p.user_id AS id,
    p.name,
    p.nickname,
    p.profile_pic,
    p.tag,
    p.position_x,
    p.position_y,
    p."desc",
    p.gender,
    e.followers,
    i.following
   FROM (((rest.profiles p
     JOIN rest.followers e ON ((p.user_id = e.user_id)))
     JOIN rest.following i ON ((p.user_id = i.user_id)))
     JOIN rest.table_user u ON ((p.user_id = u.id)))
  WHERE (u.status = 0);


ALTER VIEW rest.view_user OWNER TO rapid;

--
-- Name: view_u; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.view_u AS
 SELECT u.id,
    u.user_id,
    u.avatar_id,
    w.wear,
    p.nickname,
    a.img,
    a.name,
    a.part_index AS "partIndex"
   FROM (((rest.table_user_avatar u
     JOIN rest.table_user_avatar_wear w ON ((u.id = w.user_avatar_id)))
     JOIN rest.view_user p ON ((u.user_id = p.id)))
     JOIN rest.avatar a ON ((u.avatar_id = a.id)));


ALTER VIEW rest.view_u OWNER TO rapid;

--
-- Name: view_user_admin; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.view_user_admin AS
 SELECT u.login_id AS id,
    p.nickname,
        CASE
            WHEN (length(u.password) >= 10) THEN ''::text
            ELSE u.password
        END AS password,
    to_char(u.created_at, 'YYYY.MM.DD'::text) AS register_date,
    s.status,
    ( SELECT count(*) AS count
           FROM rest.view_post_owner p_1
          WHERE (u.id = p_1.user_id)) AS posts,
    ( SELECT count(*) AS count
           FROM rest.view_comment_owner c
          WHERE (u.id = c.user_id)) AS comments,
    ( SELECT count(*) AS count
           FROM rest.view_like l
          WHERE (u.id = l.user_id)) AS likes,
    ( SELECT count(*) AS count
           FROM rest.view_entrence e
          WHERE ((u.id = e.user_id) AND (date(e.created_at) = CURRENT_DATE))) AS today_view,
    ( SELECT count(*) AS count
           FROM rest.view_entrence e
          WHERE (u.id = e.user_id)) AS total_view
   FROM ((rest.table_user u
     JOIN rest.table_profile p ON ((u.id = p.user_id)))
     JOIN rest.table_user_status s ON ((u.status = s.id)));


ALTER VIEW rest.view_user_admin OWNER TO rapid;

--
-- Name: view_user_ava; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.view_user_ava AS
 SELECT name,
    profile_pic AS profile,
    json_build_object('hair', COALESCE(( SELECT json_build_object('index', a.id, 'name', a.part_index) AS json_build_object
           FROM (rest.avatar a
             JOIN rest.user_avatar ua ON ((a.id = ua.avatar_id)))
          WHERE ((ua.user_id = u.user_id) AND (a.category = 'hair'::text) AND (ua.wear = true))), json_build_object('name', 'none', 'index', '-1'::integer)), 'body', COALESCE(( SELECT json_build_object('index', a.id, 'name', a.part_index) AS json_build_object
           FROM (rest.avatar a
             JOIN rest.user_avatar ua ON ((a.id = ua.avatar_id)))
          WHERE ((ua.user_id = u.user_id) AND (a.category = 'body'::text) AND (ua.wear = true))), json_build_object('name', 'none:none:none', 'index', '-1'::integer)), 'pants', COALESCE(( SELECT json_build_object('index', a.id, 'name', a.part_index) AS json_build_object
           FROM (rest.avatar a
             JOIN rest.user_avatar ua ON ((a.id = ua.avatar_id)))
          WHERE ((ua.user_id = u.user_id) AND (a.category = 'pants'::text) AND (ua.wear = true))), json_build_object('index', '-1'::integer, 'name', 'none:none')), 'shoes', COALESCE(( SELECT json_build_object('index', a.id, 'name', a.part_index) AS json_build_object
           FROM (rest.avatar a
             JOIN rest.user_avatar ua ON ((a.id = ua.avatar_id)))
          WHERE ((ua.user_id = u.user_id) AND (a.category = 'shoes'::text) AND (ua.wear = true))), json_build_object('name', 'none:none', 'index', '-1'::integer)), 'costume', COALESCE(( SELECT json_build_object('index', a.id, 'name', a.part_index) AS json_build_object
           FROM (rest.avatar a
             JOIN rest.user_avatar ua ON ((a.id = ua.avatar_id)))
          WHERE ((ua.user_id = u.user_id) AND (a.category = 'costume'::text) AND (ua.wear = true))), json_build_object('name', 'none', 'index', '-1'::integer))) AS avatar,
        CASE
            WHEN (EXISTS ( SELECT 1
               FROM (rest.user_avatar ua
                 JOIN rest.avatar a ON ((ua.avatar_id = a.id)))
              WHERE ((ua.user_id = u.user_id) AND (a.category = 'costume'::text) AND (ua.wear = true)))) THEN 'costume'::text
            ELSE 'normal'::text
        END AS avatartype
   FROM rest.table_profile u;


ALTER VIEW rest.view_user_ava OWNER TO rapid;

--
-- Name: view_user_avatar; Type: VIEW; Schema: rest; Owner: rapid
--

CREATE VIEW rest.view_user_avatar AS
 SELECT u.id,
    w.wear,
    p.nickname,
    a.name,
    a.img,
    a.part_index,
    a.category
   FROM (((rest.table_user_avatar u
     JOIN rest.table_user_avatar_wear w ON ((u.id = w.user_avatar_id)))
     JOIN rest.view_user p ON ((u.user_id = p.id)))
     LEFT JOIN rest.avatar a ON ((u.avatar_id = a.id)));


ALTER VIEW rest.view_user_avatar OWNER TO rapid;

--
-- Name: table_ask id; Type: DEFAULT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_ask ALTER COLUMN id SET DEFAULT nextval('rest.ask_id_seq'::regclass);


--
-- Name: table_ask_answer id; Type: DEFAULT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_ask_answer ALTER COLUMN id SET DEFAULT nextval('rest.ask_answer_id_seq'::regclass);


--
-- Name: table_avatar id; Type: DEFAULT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_avatar ALTER COLUMN id SET DEFAULT nextval('rest.avatar_id_seq'::regclass);


--
-- Name: table_avatar_category id; Type: DEFAULT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_avatar_category ALTER COLUMN id SET DEFAULT nextval('rest.avatar_category_id_seq'::regclass);


--
-- Name: table_chat id; Type: DEFAULT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_chat ALTER COLUMN id SET DEFAULT nextval('rest.chat_id_seq'::regclass);


--
-- Name: table_comment id; Type: DEFAULT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_comment ALTER COLUMN id SET DEFAULT nextval('rest.comment_id_seq'::regclass);


--
-- Name: table_entrance id; Type: DEFAULT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_entrance ALTER COLUMN id SET DEFAULT nextval('rest.entrence_id_seq'::regclass);


--
-- Name: table_experience id; Type: DEFAULT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_experience ALTER COLUMN id SET DEFAULT nextval('rest.experience_id_seq'::regclass);


--
-- Name: table_experience_type id; Type: DEFAULT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_experience_type ALTER COLUMN id SET DEFAULT nextval('rest.untitled_table_29_id_seq'::regclass);


--
-- Name: table_feed id; Type: DEFAULT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_feed ALTER COLUMN id SET DEFAULT nextval('rest."Post_id_seq"'::regclass);


--
-- Name: table_feed_hashtag id; Type: DEFAULT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_feed_hashtag ALTER COLUMN id SET DEFAULT nextval('rest.table_post_hashtag_id_seq'::regclass);


--
-- Name: table_feed_images id; Type: DEFAULT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_feed_images ALTER COLUMN id SET DEFAULT nextval('rest.post_images_id_seq'::regclass);


--
-- Name: table_follow id; Type: DEFAULT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_follow ALTER COLUMN id SET DEFAULT nextval('rest.follow_id_seq'::regclass);


--
-- Name: table_like id; Type: DEFAULT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_like ALTER COLUMN id SET DEFAULT nextval('rest.like_id_seq'::regclass);


--
-- Name: table_log id; Type: DEFAULT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_log ALTER COLUMN id SET DEFAULT nextval('rest.log_id_seq'::regclass);


--
-- Name: table_report id; Type: DEFAULT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_report ALTER COLUMN id SET DEFAULT nextval('rest.report_id_seq'::regclass);


--
-- Name: table_room id; Type: DEFAULT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_room ALTER COLUMN id SET DEFAULT nextval('rest.room_id_seq'::regclass);


--
-- Name: table_user_avatar id; Type: DEFAULT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_user_avatar ALTER COLUMN id SET DEFAULT nextval('rest.user_avatar_id_seq'::regclass);


--
-- Name: table_user_avatar_wear id; Type: DEFAULT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_user_avatar_wear ALTER COLUMN id SET DEFAULT nextval('rest.table_user_avatar_wear_id_seq'::regclass);


--
-- Name: table_user_status id; Type: DEFAULT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_user_status ALTER COLUMN id SET DEFAULT nextval('rest.table_user_status_id_seq'::regclass);


--
-- Data for Name: table_ask; Type: TABLE DATA; Schema: rest; Owner: rapid
--

COPY rest.table_ask (id, user_id, subject, content, created_at, active) FROM stdin;
2	1	subjecrt	What is Lorem Ipsum?\nLorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.\n\nWhy do we use it?\nIt is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).\n\n\nWhere does it come from?\nContrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of "de Finibus Bonorum et Malorum" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, "Lorem ipsum dolor sit amet..", comes from a line in section 1.10.32.\n\nThe standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from "de Finibus Bonorum et Malorum" by Cicero are also reproduced in their exact original form, accompanied by English versions from the 1914 translation by H. Rackham.	2025-02-16 14:35:43.330661	t
\.


--
-- Data for Name: table_ask_answer; Type: TABLE DATA; Schema: rest; Owner: rapid
--

COPY rest.table_ask_answer (id, answer, ask_id, created_at) FROM stdin;
3	그렇군요 하하	2	2025-02-24 20:37:55.950389
\.


--
-- Data for Name: table_avatar; Type: TABLE DATA; Schema: rest; Owner: rapid
--

COPY rest.table_avatar (id, name, img, part_index, category_id) FROM stdin;
1	name	img	1:2	3
\.


--
-- Data for Name: table_avatar_category; Type: TABLE DATA; Schema: rest; Owner: rapid
--

COPY rest.table_avatar_category (id, category) FROM stdin;
0	sample
1	hair
2	body
3	pants
4	shoes
5	costume
\.


--
-- Data for Name: table_chat; Type: TABLE DATA; Schema: rest; Owner: rapid
--

COPY rest.table_chat (id, created_at, chat, room_id, user_id) FROM stdin;
1	2025-01-09 08:46:10.718882	this is chat	1	12
2	2025-01-09 08:46:10.718882	this is chat	1	12
3	2025-01-09 08:46:10.718882	this is chat	1	12
4	2025-01-09 08:46:10.718882	this is chat	1	18
5	2025-01-09 08:46:10.718882	this is chat	1	18
6	2025-01-09 08:46:10.718882	this is chat	1	18
7	2025-01-09 08:46:10.718882	this is chat	1	18
8	2025-01-09 08:46:10.718882	this is chat	1	18
9	2025-01-09 08:46:10.718882	this is chat	1	18
10	2025-01-09 08:46:10.718882	this is chat	1	18
\.


--
-- Data for Name: table_comment; Type: TABLE DATA; Schema: rest; Owner: rapid
--

COPY rest.table_comment (id, created_at, comment, post_id, user_id, parent_id, active, tag) FROM stdin;
2	2025-01-09 08:27:45.168162	좋은데?	1	1	\N	t	::text
3	2025-01-09 08:27:45.168162	그치?	1	1	2	t	::text
4	2025-01-09 08:27:45.168162	그르니까	1	1	3	t	::text
\.


--
-- Data for Name: table_entrance; Type: TABLE DATA; Schema: rest; Owner: rapid
--

COPY rest.table_entrance (id, room_id, created_at, user_id, enter) FROM stdin;
0	1	2025-02-01 11:29:49.412591	1	t
1	3	2025-02-01 15:07:18.977483	12	t
2	1	2025-02-01 15:07:41.426151	1	f
3	1	2025-02-01 15:07:54.665181	1	t
4	3	2025-02-01 15:08:16.984365	12	f
6	3	2025-02-01 15:16:02.421624	12	f
5	3	2025-02-01 15:08:37.395568	12	t
32	1	2025-02-02 05:00:44.695594	13	t
33	1	2025-02-09 12:00:20.234965	18	t
34	1	2025-02-09 12:02:03.449522	18	t
35	1	2025-02-09 12:02:53.442068	18	t
36	1	2025-02-09 12:08:35.749026	18	t
37	1	2025-02-09 12:09:15.653625	18	t
38	1	2025-02-09 12:10:04.824161	18	t
39	1	2025-02-09 12:10:34.924142	18	t
\.


--
-- Data for Name: table_experience; Type: TABLE DATA; Schema: rest; Owner: rapid
--

COPY rest.table_experience (id, exp, "desc", created_at, user_id, type_id) FROM stdin;
1	1	sample	2025-01-09 09:53:46.851196	1	0
2	3	sample	2025-01-09 09:53:46.851196	1	0
\.


--
-- Data for Name: table_experience_type; Type: TABLE DATA; Schema: rest; Owner: rapid
--

COPY rest.table_experience_type (id, type) FROM stdin;
0	단순 경험치
\.


--
-- Data for Name: table_feed; Type: TABLE DATA; Schema: rest; Owner: rapid
--

COPY rest.table_feed (id, created_at, content, user_id, public, active) FROM stdin;
2	2025-02-11 12:25:17.914189	1	1	t	t
9	2025-02-15 04:23:53.652462	하하	17	t	t
10	2025-02-15 04:28:51.112349	하하	17	f	t
11	2025-02-15 15:31:56.081364	하하	17	f	t
12	2025-02-15 15:32:11.031668	하하	17	f	t
1	2025-02-11 12:19:36.59121	안녕하신가요?	1	t	t
\.


--
-- Data for Name: table_feed_hashtag; Type: TABLE DATA; Schema: rest; Owner: rapid
--

COPY rest.table_feed_hashtag (id, post_id, tag) FROM stdin;
\.


--
-- Data for Name: table_feed_images; Type: TABLE DATA; Schema: rest; Owner: rapid
--

COPY rest.table_feed_images (id, post_id, img, active) FROM stdin;
2	1	abc	t
3	1	acd	t
\.


--
-- Data for Name: table_follow; Type: TABLE DATA; Schema: rest; Owner: rapid
--

COPY rest.table_follow (id, follower, user_id, follow) FROM stdin;
1	1	1	t
2	1	2	t
3	1	2	t
4	1	2	t
5	1	2	t
6	1	2	t
7	1	2	t
8	1	2	t
9	1	2	t
10	1	2	f
\.


--
-- Data for Name: table_like; Type: TABLE DATA; Schema: rest; Owner: rapid
--

COPY rest.table_like (id, created_at, post_id, user_id, lik, "like") FROM stdin;
1	2025-02-11 12:41:48.981386	1	1	1	t
2	2025-02-11 12:41:48.981386	1	1	1	t
3	2025-02-11 12:41:48.981386	1	1	1	t
5	2025-02-11 12:49:09.821427	1	1	1	f
\.


--
-- Data for Name: table_log; Type: TABLE DATA; Schema: rest; Owner: rapid
--

COPY rest.table_log (id, user_id, created_at) FROM stdin;
2	17	2025-02-11 14:31:46.176186
3	1	2025-02-11 16:52:01.863652
4	1	2025-02-11 16:56:09.839412
5	1	2025-02-12 04:40:58.801833
6	1	2025-02-12 04:41:09.37804
7	1	2025-02-12 05:42:23.12455
8	1	2025-02-12 05:55:04.429682
9	1	2025-02-12 05:55:18.546741
10	1	2025-02-12 07:42:56.983922
11	1	2025-02-12 07:56:06.904047
14	17	2025-02-12 08:03:27.285918
15	17	2025-02-12 08:04:58.536168
16	1	2025-02-12 08:42:12.925244
17	1	2025-02-12 08:44:27.071986
18	1	2025-02-12 08:48:03.028599
19	1	2025-02-12 08:48:23.188042
20	1	2025-02-12 09:05:21.07669
24	1	2025-02-12 09:17:04.183866
25	1	2025-02-12 09:25:54.449395
30	1	2025-02-12 13:56:09.766749
31	1	2025-02-12 14:00:37.133705
32	1	2025-02-12 16:22:39.009958
33	1	2025-02-12 16:22:39.009958
34	17	2025-02-14 09:08:58.375969
35	17	2025-02-14 09:10:31.874541
36	17	2025-02-14 09:11:28.587961
37	17	2025-01-14 00:00:00
38	17	2025-01-14 00:00:00
39	17	2025-01-14 00:00:00
40	2	2025-02-24 14:57:28.998858
\.


--
-- Data for Name: table_profile; Type: TABLE DATA; Schema: rest; Owner: rapid
--

COPY rest.table_profile (id, name, nickname, profile_pic, tag, position_x, position_y, "desc", user_id, is_male, birthday) FROM stdin;
3	Wiggle man	_072k	기본 이미지		0	0	Who wants to dance?	3	t	\N
4	Haein 해인	haein_0727	기본 이미지		0	0		4	t	\N
5	Googoo Kim	googoo_toys	기본 이미지		0	0		5	t	\N
2	daniel	012_da			0	0	I love Cyberpunk	2	t	\N
1	wiggly	wigglymania	url		0	0		1	t	\N
6	김영일	012	기본 이미지		0	0	desc	17	t	\N
\.


--
-- Data for Name: table_report; Type: TABLE DATA; Schema: rest; Owner: rapid
--

COPY rest.table_report (id, post_id, "desc", created_at, comp_id, def_id) FROM stdin;
1	1	desc	2025-02-17 02:03:42.866479	1	\N
2	\N	desc	2025-02-17 02:03:55.826331	1	17
\.


--
-- Data for Name: table_room; Type: TABLE DATA; Schema: rest; Owner: rapid
--

COPY rest.table_room (id, room_content, show_nickname, user_id, room_pic, room_name) FROM stdin;
1	@haeintheworld	t	4		
3	Discover what's next on Wiggly	t	1		
\.


--
-- Data for Name: table_user; Type: TABLE DATA; Schema: rest; Owner: rapid
--

COPY rest.table_user (id, login_id, password, active, validated, fcm_token, status, created_at) FROM stdin;
2	kakaoToken	kakaoSet	t	f	\N	0	2025-02-24 21:00:42.111686
3	googleToken	googleSet	t	f	\N	0	2025-02-24 21:00:42.111686
4	appleToken	appleSet	t	f	\N	0	2025-02-24 21:00:42.111686
5	facebookToken	facebookSet	t	f	\N	0	2025-02-24 21:00:42.111686
6	jumo.kang77	21046290-dfa8-11ef-b7b9-9d7a21e59c47	t	f	\N	0	2025-02-24 21:00:42.111686
10	jumo	$2a$07$DYX28bmxehfIldUZB6deJOdWWavX4aZNdRGWBzm3BssQhARrrh/Ty	t	f	\N	0	2025-02-24 21:00:42.111686
11	jum	$2a$07$secTTecgxt1BqvIFcAw/9.ZaOu33JfF1k/9L4nread1xltsk21zdC	t	f	\N	0	2025-02-24 21:00:42.111686
12	juma	$2a$07$RbVVEO/m.Esp8VEtpekeluE.3zSvFFfaUhHHiJaQ5vqtxmrsHBcr6	t	f	\N	0	2025-02-24 21:00:42.111686
13	jaja	$2a$07$c/wV/AYL58k.fjEewPe8wu.EXlc14KfkVC0RvjRymxpTXiHJLXm7C	t	f	\N	0	2025-02-24 21:00:42.111686
15	103234927963285602090		t	f	\N	0	2025-02-24 21:00:42.111686
16	3908196749		t	f	\N	0	2025-02-24 21:00:42.111686
18	jm	$2a$07$jis0wzqF2IPqxmb.J8Aohu3O/6GZmCy5Ie6Bg/On0vi3yNVb1xyv6	t	f	\N	0	2025-02-24 21:00:42.111686
20	kf6wd9chfy@privaterelay.appleid.com		t	f	\N	0	2025-02-24 21:00:42.111686
21	122106723740751641		t	f	\N	0	2025-02-24 21:00:42.111686
1	email	userSet	t	f	\N	2	2025-02-24 21:00:42.111686
17	jumo.kang77@gmail.com	$2a$07$pys6yLpPxClWkZ/41xrAF..7QJzDvFrWM.mj9E9/rXrTHdURqLgiq	t	t	cpEE4DwZRLuA49sMEbIO4l:APA91bERVH7B8SoC9XE0bR_p4CerC_eUwzPwBJEqCKnWs8znshCJa43ZlcBGPT41jF7gmtazLgcHmypw4c-ayqNMo6q3fYqe4O5x-hQIEURpE5Ny7qBbYHk	0	2025-02-24 21:00:42.111686
\.


--
-- Data for Name: table_user_avatar; Type: TABLE DATA; Schema: rest; Owner: rapid
--

COPY rest.table_user_avatar (id, user_id, avatar_id) FROM stdin;
3	1	1
\.


--
-- Data for Name: table_user_avatar_wear; Type: TABLE DATA; Schema: rest; Owner: rapid
--

COPY rest.table_user_avatar_wear (id, user_avatar_id, wear) FROM stdin;
1	3	t
\.


--
-- Data for Name: table_user_status; Type: TABLE DATA; Schema: rest; Owner: rapid
--

COPY rest.table_user_status (id, status) FROM stdin;
0	활성
1	정지
2	탈퇴
\.


--
-- Data for Name: typeorm_metadata; Type: TABLE DATA; Schema: rest; Owner: admin
--

COPY rest.typeorm_metadata (type, database, schema, "table", name, value) FROM stdin;
\.


--
-- Name: profile_id_seq; Type: SEQUENCE SET; Schema: public; Owner: rapid
--

SELECT pg_catalog.setval('public.profile_id_seq', 6, true);


--
-- Name: user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: rapid
--

SELECT pg_catalog.setval('public.user_id_seq', 21, true);


--
-- Name: Post_id_seq; Type: SEQUENCE SET; Schema: rest; Owner: rapid
--

SELECT pg_catalog.setval('rest."Post_id_seq"', 12, true);


--
-- Name: ask_answer_id_seq; Type: SEQUENCE SET; Schema: rest; Owner: rapid
--

SELECT pg_catalog.setval('rest.ask_answer_id_seq', 3, true);


--
-- Name: ask_id_seq; Type: SEQUENCE SET; Schema: rest; Owner: rapid
--

SELECT pg_catalog.setval('rest.ask_id_seq', 2, true);


--
-- Name: avatar_category_id_seq; Type: SEQUENCE SET; Schema: rest; Owner: rapid
--

SELECT pg_catalog.setval('rest.avatar_category_id_seq', 5, true);


--
-- Name: avatar_id_seq; Type: SEQUENCE SET; Schema: rest; Owner: rapid
--

SELECT pg_catalog.setval('rest.avatar_id_seq', 1, true);


--
-- Name: chat_id_seq; Type: SEQUENCE SET; Schema: rest; Owner: rapid
--

SELECT pg_catalog.setval('rest.chat_id_seq', 10, true);


--
-- Name: comment_id_seq; Type: SEQUENCE SET; Schema: rest; Owner: rapid
--

SELECT pg_catalog.setval('rest.comment_id_seq', 4, true);


--
-- Name: entrence_id_seq; Type: SEQUENCE SET; Schema: rest; Owner: rapid
--

SELECT pg_catalog.setval('rest.entrence_id_seq', 39, true);


--
-- Name: experience_id_seq; Type: SEQUENCE SET; Schema: rest; Owner: rapid
--

SELECT pg_catalog.setval('rest.experience_id_seq', 2, true);


--
-- Name: follow_id_seq; Type: SEQUENCE SET; Schema: rest; Owner: rapid
--

SELECT pg_catalog.setval('rest.follow_id_seq', 10, true);


--
-- Name: like_id_seq; Type: SEQUENCE SET; Schema: rest; Owner: rapid
--

SELECT pg_catalog.setval('rest.like_id_seq', 7, true);


--
-- Name: log_id_seq; Type: SEQUENCE SET; Schema: rest; Owner: rapid
--

SELECT pg_catalog.setval('rest.log_id_seq', 40, true);


--
-- Name: post_images_id_seq; Type: SEQUENCE SET; Schema: rest; Owner: rapid
--

SELECT pg_catalog.setval('rest.post_images_id_seq', 3, true);


--
-- Name: report_id_seq; Type: SEQUENCE SET; Schema: rest; Owner: rapid
--

SELECT pg_catalog.setval('rest.report_id_seq', 2, true);


--
-- Name: room_id_seq; Type: SEQUENCE SET; Schema: rest; Owner: rapid
--

SELECT pg_catalog.setval('rest.room_id_seq', 3, true);


--
-- Name: table_post_hashtag_id_seq; Type: SEQUENCE SET; Schema: rest; Owner: rapid
--

SELECT pg_catalog.setval('rest.table_post_hashtag_id_seq', 1, false);


--
-- Name: table_user_avatar_wear_id_seq; Type: SEQUENCE SET; Schema: rest; Owner: rapid
--

SELECT pg_catalog.setval('rest.table_user_avatar_wear_id_seq', 1, true);


--
-- Name: table_user_status_id_seq; Type: SEQUENCE SET; Schema: rest; Owner: rapid
--

SELECT pg_catalog.setval('rest.table_user_status_id_seq', 1, false);


--
-- Name: untitled_table_29_id_seq; Type: SEQUENCE SET; Schema: rest; Owner: rapid
--

SELECT pg_catalog.setval('rest.untitled_table_29_id_seq', 1, false);


--
-- Name: user_avatar_id_seq; Type: SEQUENCE SET; Schema: rest; Owner: rapid
--

SELECT pg_catalog.setval('rest.user_avatar_id_seq', 3, true);


--
-- Name: table_feed Post_pkey; Type: CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_feed
    ADD CONSTRAINT "Post_pkey" PRIMARY KEY (id);


--
-- Name: table_ask_answer ask_answer_pkey; Type: CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_ask_answer
    ADD CONSTRAINT ask_answer_pkey PRIMARY KEY (id);


--
-- Name: table_ask ask_pkey; Type: CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_ask
    ADD CONSTRAINT ask_pkey PRIMARY KEY (id);


--
-- Name: table_avatar_category avatar_category_pkey; Type: CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_avatar_category
    ADD CONSTRAINT avatar_category_pkey PRIMARY KEY (id);


--
-- Name: table_avatar avatar_pkey; Type: CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_avatar
    ADD CONSTRAINT avatar_pkey PRIMARY KEY (id);


--
-- Name: table_chat chat_pkey; Type: CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_chat
    ADD CONSTRAINT chat_pkey PRIMARY KEY (id);


--
-- Name: table_comment comment_pkey; Type: CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_comment
    ADD CONSTRAINT comment_pkey PRIMARY KEY (id);


--
-- Name: table_entrance entrence_pkey; Type: CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_entrance
    ADD CONSTRAINT entrence_pkey PRIMARY KEY (id);


--
-- Name: table_experience experience_pkey; Type: CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_experience
    ADD CONSTRAINT experience_pkey PRIMARY KEY (id);


--
-- Name: table_follow follow_pkey; Type: CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_follow
    ADD CONSTRAINT follow_pkey PRIMARY KEY (id);


--
-- Name: table_like like_pkey; Type: CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_like
    ADD CONSTRAINT like_pkey PRIMARY KEY (id);


--
-- Name: table_log log_pkey; Type: CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_log
    ADD CONSTRAINT log_pkey PRIMARY KEY (id);


--
-- Name: table_feed_images post_images_pkey; Type: CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_feed_images
    ADD CONSTRAINT post_images_pkey PRIMARY KEY (id);


--
-- Name: table_profile profile_pkey; Type: CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_profile
    ADD CONSTRAINT profile_pkey PRIMARY KEY (id);


--
-- Name: table_profile profile_user_id; Type: CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_profile
    ADD CONSTRAINT profile_user_id UNIQUE (user_id);


--
-- Name: table_report report_pkey; Type: CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_report
    ADD CONSTRAINT report_pkey PRIMARY KEY (id);


--
-- Name: table_room room_pkey; Type: CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_room
    ADD CONSTRAINT room_pkey PRIMARY KEY (id);


--
-- Name: table_room room_user_id; Type: CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_room
    ADD CONSTRAINT room_user_id UNIQUE (user_id);


--
-- Name: table_feed_hashtag table_post_hashtag_pkey; Type: CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_feed_hashtag
    ADD CONSTRAINT table_post_hashtag_pkey PRIMARY KEY (id);


--
-- Name: table_user_avatar_wear table_user_avatar_wear_pkey; Type: CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_user_avatar_wear
    ADD CONSTRAINT table_user_avatar_wear_pkey PRIMARY KEY (id);


--
-- Name: table_user_status table_user_status_pkey; Type: CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_user_status
    ADD CONSTRAINT table_user_status_pkey PRIMARY KEY (id);


--
-- Name: table_experience_type untitled_table_29_pkey; Type: CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_experience_type
    ADD CONSTRAINT untitled_table_29_pkey PRIMARY KEY (id);


--
-- Name: table_user_avatar user_avatar_pkey; Type: CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_user_avatar
    ADD CONSTRAINT user_avatar_pkey PRIMARY KEY (id);


--
-- Name: table_user user_pkey; Type: CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_user
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: feeds _RETURN; Type: RULE; Schema: rest; Owner: rapid
--

CREATE OR REPLACE VIEW rest.feeds AS
 SELECT count(l.created_at) AS "like",
    count(c.comment) AS comment_count,
    p.created_at,
    p.user_id,
    p.id,
    p.content,
    ARRAY( SELECT table_feed_images.img
           FROM rest.table_feed_images
          WHERE (table_feed_images.post_id = p.id)) AS images,
    p.public,
    ARRAY( SELECT table_feed_hashtag.tag
           FROM rest.table_feed_hashtag
          WHERE (table_feed_hashtag.post_id = p.id)) AS hashtag,
    p.active
   FROM ((rest.table_feed p
     LEFT JOIN rest."like" l ON ((p.id = l.post_id)))
     LEFT JOIN rest.table_comment c ON ((p.id = c.post_id)))
  GROUP BY p.id;


--
-- Name: room _RETURN; Type: RULE; Schema: rest; Owner: rapid
--

CREATE OR REPLACE VIEW rest.room AS
 SELECT count(e.id) AS online,
    r.id,
    r.room_content,
    r.show_nickname,
    r.user_id,
    r.room_pic,
    r.room_name
   FROM (rest.table_room r
     JOIN rest.entrence e ON ((r.id = e.room_id)))
  GROUP BY r.id;


--
-- Name: view_post_owner _RETURN; Type: RULE; Schema: rest; Owner: rapid
--

CREATE OR REPLACE VIEW rest.view_post_owner AS
 SELECT count(l.created_at) AS likes,
    count(c.comment) AS comments,
    p.created_at AS create_at,
    p.user_id,
    p.id,
    p.content,
    p.public,
    ARRAY( SELECT i.img
           FROM rest.table_feed_images i
          WHERE (i.post_id = p.id)) AS images
   FROM ((rest.table_feed p
     LEFT JOIN rest."like" l ON ((p.id = l.post_id)))
     LEFT JOIN rest.table_comment c ON ((p.id = c.post_id)))
  GROUP BY p.id;


--
-- Name: table_user_avatar set_default_wear; Type: TRIGGER; Schema: rest; Owner: rapid
--

CREATE TRIGGER set_default_wear AFTER INSERT ON rest.table_user_avatar FOR EACH ROW EXECUTE FUNCTION public.user_avatar_wear_insert();


--
-- Name: table_feed Post_user_id_fkey; Type: FK CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_feed
    ADD CONSTRAINT "Post_user_id_fkey" FOREIGN KEY (user_id) REFERENCES rest.table_user(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: table_ask_answer ask_answer_ask_id_fkey; Type: FK CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_ask_answer
    ADD CONSTRAINT ask_answer_ask_id_fkey FOREIGN KEY (ask_id) REFERENCES rest.table_ask(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: table_ask ask_user_id_fkey; Type: FK CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_ask
    ADD CONSTRAINT ask_user_id_fkey FOREIGN KEY (user_id) REFERENCES rest.table_user(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: table_avatar avatar_category_id_fkey; Type: FK CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_avatar
    ADD CONSTRAINT avatar_category_id_fkey FOREIGN KEY (category_id) REFERENCES rest.table_avatar_category(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: table_chat chat_room_id_fkey; Type: FK CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_chat
    ADD CONSTRAINT chat_room_id_fkey FOREIGN KEY (room_id) REFERENCES rest.table_room(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: table_chat chat_user_id_fkey; Type: FK CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_chat
    ADD CONSTRAINT chat_user_id_fkey FOREIGN KEY (user_id) REFERENCES rest.table_user(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: table_comment comment_liker_id_fkey; Type: FK CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_comment
    ADD CONSTRAINT comment_liker_id_fkey FOREIGN KEY (user_id) REFERENCES rest.table_user(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: table_comment comment_parent_id_fkey; Type: FK CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_comment
    ADD CONSTRAINT comment_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES rest.table_comment(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: table_comment comment_post_id_fkey; Type: FK CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_comment
    ADD CONSTRAINT comment_post_id_fkey FOREIGN KEY (post_id) REFERENCES rest.table_feed(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: table_entrance entrence_roomId_fkey; Type: FK CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_entrance
    ADD CONSTRAINT "entrence_roomId_fkey" FOREIGN KEY (room_id) REFERENCES rest.table_room(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: table_entrance entrence_user_id_fkey; Type: FK CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_entrance
    ADD CONSTRAINT entrence_user_id_fkey FOREIGN KEY (user_id) REFERENCES rest.table_user(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: table_follow follow_audience_fkey; Type: FK CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_follow
    ADD CONSTRAINT follow_audience_fkey FOREIGN KEY (user_id) REFERENCES rest.table_user(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: table_follow follow_follower_fkey; Type: FK CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_follow
    ADD CONSTRAINT follow_follower_fkey FOREIGN KEY (follower) REFERENCES rest.table_user(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: table_like like_liker_id_fkey; Type: FK CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_like
    ADD CONSTRAINT like_liker_id_fkey FOREIGN KEY (user_id) REFERENCES rest.table_user(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: table_like like_post_id_fkey; Type: FK CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_like
    ADD CONSTRAINT like_post_id_fkey FOREIGN KEY (post_id) REFERENCES rest.table_feed(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: table_log log_user_id_fkey; Type: FK CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_log
    ADD CONSTRAINT log_user_id_fkey FOREIGN KEY (user_id) REFERENCES rest.table_user(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: table_room room_user_id_fkey; Type: FK CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_room
    ADD CONSTRAINT room_user_id_fkey FOREIGN KEY (user_id) REFERENCES rest.table_user(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: table_profile table_profile_user_id_fkey; Type: FK CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_profile
    ADD CONSTRAINT table_profile_user_id_fkey FOREIGN KEY (user_id) REFERENCES rest.table_user(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: table_report table_report_comp_id_fkey; Type: FK CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_report
    ADD CONSTRAINT table_report_comp_id_fkey FOREIGN KEY (comp_id) REFERENCES rest.table_user(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: table_report table_report_def_id_fkey; Type: FK CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_report
    ADD CONSTRAINT table_report_def_id_fkey FOREIGN KEY (def_id) REFERENCES rest.table_user(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: table_report table_report_post_id_fkey; Type: FK CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_report
    ADD CONSTRAINT table_report_post_id_fkey FOREIGN KEY (post_id) REFERENCES rest.table_feed(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: table_user_avatar_wear table_user_avatar_wear_user_avatar_id_fkey; Type: FK CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_user_avatar_wear
    ADD CONSTRAINT table_user_avatar_wear_user_avatar_id_fkey FOREIGN KEY (user_avatar_id) REFERENCES rest.table_user_avatar(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: table_user table_user_status_fkey; Type: FK CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_user
    ADD CONSTRAINT table_user_status_fkey FOREIGN KEY (status) REFERENCES rest.table_user_status(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: table_user_avatar user_avatar_avatar_id_fkey; Type: FK CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_user_avatar
    ADD CONSTRAINT user_avatar_avatar_id_fkey FOREIGN KEY (avatar_id) REFERENCES rest.table_avatar(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: table_user_avatar user_avatar_user_id_fkey; Type: FK CONSTRAINT; Schema: rest; Owner: rapid
--

ALTER TABLE ONLY rest.table_user_avatar
    ADD CONSTRAINT user_avatar_user_id_fkey FOREIGN KEY (user_id) REFERENCES rest.table_user(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SCHEMA postgrest; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA postgrest TO authenticator;
GRANT USAGE ON SCHEMA postgrest TO ubuntu;
GRANT USAGE ON SCHEMA postgrest TO web_anon;


--
-- Name: SCHEMA rest; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA rest TO web;
GRANT USAGE ON SCHEMA rest TO web_anon;


--
-- Name: FUNCTION get_replies(comment_id bigint); Type: ACL; Schema: rest; Owner: rapid
--

GRANT ALL ON FUNCTION rest.get_replies(comment_id bigint) TO web_anon;


--
-- Name: TABLE table_feed; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_feed TO web_anon;
GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_feed TO web;


--
-- Name: SEQUENCE "Post_id_seq"; Type: ACL; Schema: rest; Owner: rapid
--

GRANT USAGE ON SEQUENCE rest."Post_id_seq" TO web_anon;


--
-- Name: TABLE table_ask_answer; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE rest.table_ask_answer TO web_anon;


--
-- Name: SEQUENCE ask_answer_id_seq; Type: ACL; Schema: rest; Owner: rapid
--

GRANT USAGE ON SEQUENCE rest.ask_answer_id_seq TO web_anon;


--
-- Name: TABLE table_ask; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_ask TO web_anon;


--
-- Name: SEQUENCE ask_id_seq; Type: ACL; Schema: rest; Owner: rapid
--

GRANT USAGE ON SEQUENCE rest.ask_id_seq TO web_anon;


--
-- Name: TABLE table_avatar; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_avatar TO web_anon;
GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_avatar TO web;


--
-- Name: TABLE table_avatar_category; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_avatar_category TO web_anon;
GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_avatar_category TO web;


--
-- Name: TABLE avatar; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.avatar TO web_anon;
GRANT SELECT,INSERT,UPDATE ON TABLE rest.avatar TO web;


--
-- Name: SEQUENCE avatar_category_id_seq; Type: ACL; Schema: rest; Owner: rapid
--

GRANT USAGE ON SEQUENCE rest.avatar_category_id_seq TO web_anon;


--
-- Name: SEQUENCE avatar_id_seq; Type: ACL; Schema: rest; Owner: rapid
--

GRANT USAGE ON SEQUENCE rest.avatar_id_seq TO web_anon;


--
-- Name: TABLE table_chat; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_chat TO web_anon;
GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_chat TO web;


--
-- Name: SEQUENCE chat_id_seq; Type: ACL; Schema: rest; Owner: rapid
--

GRANT USAGE ON SEQUENCE rest.chat_id_seq TO web_anon;


--
-- Name: TABLE table_comment; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_comment TO web_anon;
GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_comment TO web;


--
-- Name: TABLE comment; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.comment TO web_anon;
GRANT SELECT,INSERT,UPDATE ON TABLE rest.comment TO web;


--
-- Name: SEQUENCE comment_id_seq; Type: ACL; Schema: rest; Owner: rapid
--

GRANT USAGE ON SEQUENCE rest.comment_id_seq TO web_anon;


--
-- Name: TABLE table_entrance; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_entrance TO web_anon;
GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_entrance TO web;


--
-- Name: TABLE entrences; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.entrences TO web_anon;


--
-- Name: TABLE entrence; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.entrence TO web_anon;


--
-- Name: SEQUENCE entrence_id_seq; Type: ACL; Schema: rest; Owner: rapid
--

GRANT USAGE ON SEQUENCE rest.entrence_id_seq TO web_anon;


--
-- Name: TABLE table_experience; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_experience TO web_anon;
GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_experience TO web;


--
-- Name: TABLE table_experience_type; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_experience_type TO web_anon;
GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_experience_type TO web;


--
-- Name: TABLE experiences; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.experiences TO web_anon;
GRANT SELECT,INSERT,UPDATE ON TABLE rest.experiences TO web;


--
-- Name: TABLE experience; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.experience TO web_anon;


--
-- Name: SEQUENCE experience_id_seq; Type: ACL; Schema: rest; Owner: rapid
--

GRANT USAGE ON SEQUENCE rest.experience_id_seq TO web_anon;


--
-- Name: TABLE feeds; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.feeds TO web_anon;
GRANT SELECT,INSERT,UPDATE ON TABLE rest.feeds TO web;


--
-- Name: TABLE table_follow; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_follow TO web_anon;
GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_follow TO web;


--
-- Name: TABLE follow; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.follow TO web_anon;


--
-- Name: SEQUENCE follow_id_seq; Type: ACL; Schema: rest; Owner: rapid
--

GRANT USAGE ON SEQUENCE rest.follow_id_seq TO web_anon;


--
-- Name: TABLE followers; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.followers TO web_anon;
GRANT SELECT,INSERT,UPDATE ON TABLE rest.followers TO web;


--
-- Name: TABLE following; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.following TO web_anon;
GRANT SELECT,INSERT,UPDATE ON TABLE rest.following TO web;


--
-- Name: TABLE table_like; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_like TO web_anon;
GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_like TO web;


--
-- Name: TABLE likes; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.likes TO web_anon;
GRANT SELECT,INSERT,UPDATE ON TABLE rest.likes TO web;


--
-- Name: TABLE "like"; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest."like" TO web_anon;
GRANT SELECT,INSERT,UPDATE ON TABLE rest."like" TO web;


--
-- Name: SEQUENCE like_id_seq; Type: ACL; Schema: rest; Owner: rapid
--

GRANT USAGE ON SEQUENCE rest.like_id_seq TO web_anon;


--
-- Name: TABLE table_log; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_log TO web_anon;


--
-- Name: SEQUENCE log_id_seq; Type: ACL; Schema: rest; Owner: rapid
--

GRANT USAGE ON SEQUENCE rest.log_id_seq TO web_anon;


--
-- Name: TABLE table_profile; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_profile TO web_anon;
GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_profile TO web;


--
-- Name: TABLE logs; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.logs TO web_anon;


--
-- Name: TABLE table_feed_images; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_feed_images TO web_anon;
GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_feed_images TO web;


--
-- Name: SEQUENCE post_images_id_seq; Type: ACL; Schema: rest; Owner: rapid
--

GRANT USAGE ON SEQUENCE rest.post_images_id_seq TO web_anon;


--
-- Name: TABLE profiles; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.profiles TO web_anon;


--
-- Name: TABLE table_report; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_report TO web_anon;
GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_report TO web;


--
-- Name: SEQUENCE report_id_seq; Type: ACL; Schema: rest; Owner: rapid
--

GRANT USAGE ON SEQUENCE rest.report_id_seq TO web_anon;


--
-- Name: TABLE room; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.room TO web_anon;


--
-- Name: TABLE table_room; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_room TO web_anon;
GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_room TO web;


--
-- Name: SEQUENCE room_id_seq; Type: ACL; Schema: rest; Owner: rapid
--

GRANT USAGE ON SEQUENCE rest.room_id_seq TO web_anon;


--
-- Name: TABLE table_user; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_user TO web_anon;
GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_user TO web;


--
-- Name: TABLE table_user_avatar; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_user_avatar TO web_anon;
GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_user_avatar TO web;


--
-- Name: TABLE table_user_avatar_wear; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.table_user_avatar_wear TO web_anon;


--
-- Name: TABLE typeorm_metadata; Type: ACL; Schema: rest; Owner: admin
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.typeorm_metadata TO web_anon;


--
-- Name: SEQUENCE untitled_table_29_id_seq; Type: ACL; Schema: rest; Owner: rapid
--

GRANT USAGE ON SEQUENCE rest.untitled_table_29_id_seq TO web_anon;


--
-- Name: TABLE user_avatar; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.user_avatar TO web_anon;


--
-- Name: SEQUENCE user_avatar_id_seq; Type: ACL; Schema: rest; Owner: rapid
--

GRANT USAGE ON SEQUENCE rest.user_avatar_id_seq TO web_anon;


--
-- Name: TABLE view_ask; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT ON TABLE rest.view_ask TO web_anon;


--
-- Name: TABLE view_ask_owner; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.view_ask_owner TO web_anon;


--
-- Name: TABLE view_chat; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.view_chat TO web_anon;
GRANT SELECT,INSERT,UPDATE ON TABLE rest.view_chat TO web;


--
-- Name: TABLE view_comment; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT ON TABLE rest.view_comment TO web_anon;


--
-- Name: TABLE view_comment_owner; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.view_comment_owner TO web_anon;


--
-- Name: TABLE view_entrence; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.view_entrence TO web_anon;


--
-- Name: TABLE view_experience; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.view_experience TO web_anon;


--
-- Name: TABLE view_feed; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.view_feed TO web_anon;
GRANT SELECT,INSERT,UPDATE ON TABLE rest.view_feed TO web;


--
-- Name: TABLE view_feed_admin; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT ON TABLE rest.view_feed_admin TO web_anon;


--
-- Name: TABLE view_feed_images; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.view_feed_images TO web_anon;


--
-- Name: TABLE view_feed_images_owner; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.view_feed_images_owner TO web_anon;


--
-- Name: TABLE view_like; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.view_like TO web_anon;
GRANT SELECT,INSERT,UPDATE ON TABLE rest.view_like TO web;


--
-- Name: TABLE view_log; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.view_log TO web_anon;


--
-- Name: TABLE view_log_daily; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT ON TABLE rest.view_log_daily TO web_anon;


--
-- Name: TABLE view_log_monthly; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT ON TABLE rest.view_log_monthly TO web_anon;


--
-- Name: TABLE view_log_total; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT ON TABLE rest.view_log_total TO web_anon;


--
-- Name: TABLE view_post_owner; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.view_post_owner TO web_anon;


--
-- Name: TABLE view_report_post; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT ON TABLE rest.view_report_post TO web_anon;


--
-- Name: TABLE view_report_user; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT ON TABLE rest.view_report_user TO web_anon;


--
-- Name: TABLE view_room; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.view_room TO web_anon;


--
-- Name: TABLE view_room_views; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT ON TABLE rest.view_room_views TO web_anon;


--
-- Name: TABLE view_user; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.view_user TO web_anon;


--
-- Name: TABLE view_u; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.view_u TO web_anon;


--
-- Name: TABLE view_user_admin; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT ON TABLE rest.view_user_admin TO web_anon;


--
-- Name: TABLE view_user_avatar; Type: ACL; Schema: rest; Owner: rapid
--

GRANT SELECT,INSERT,UPDATE ON TABLE rest.view_user_avatar TO web_anon;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: rest; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA rest GRANT SELECT,INSERT,UPDATE ON TABLES TO web;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA rest GRANT SELECT,INSERT,UPDATE ON TABLES TO web_anon;


--
-- PostgreSQL database dump complete
--

