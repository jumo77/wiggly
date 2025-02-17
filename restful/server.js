require('dotenv').config({ path: '~/wiggly/.env' });
const express = require('express');
const {pg, connect, end} = require('./db/db');
const {get} = require('./handlers/get')
const {post} = require("./handlers/post");
const {auth} = require("./handlers/auth");
const {patch} = require("./handlers/patch");

// express 셋업
const app = express();
app.use(express.urlencoded({ extended: true }));
app.use(express.json({}));

// 모든 요청에 대해 회원인증
app.use(auth)

// method 종류에 따른 함수
app.get('/*', get);
app.post('/*', post)
app.patch('/*', patch)

// 시작 설정
app.listen(3000, ()=>{
    console.log('Starting Restful.API...')
    connect()
    // 사용 스키마 선택
    pg.query('set search_path to '+process.env.DB_SCHEMA)
    console.log('Listening on 3000')
});


// graceful shutdown 로직 (데이터베이스 연결 종료, 작업 완료 등)
process.on('SIGINT', () => {
    console.log('Shutting down gracefully...');
    end()
    process.exit(0); // 앱 종료
});
