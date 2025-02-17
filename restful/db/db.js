require('dotenv').config({ path: '~/wiggly/wiggly-nest/.env' });
const PG = require('pg').Client
const pg = new PG({
    database: process.env.DB_NAME,
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    user: process.env.DB_USERNAME,
    password: process.env.DB_PASS,
})

// PostgreSQL DB와 연결
function connect () {
    console.log('Connecting to Database...')
    pg.connect()
        .then(()=>console.log('Connected to PostgreSQL'))
        .catch(err => {
            console.error('Failed to connect to PostgreSQL:', err);
            // 연결 실패 시 앱을 종료하거나 다른 처리를 수행할 수 있습니다.
            process.exit(1);
        });
}

// 앱 종료 시 PostgreSQL 연결 종료
function end() {
    console.log('Disconnecting gracefully...');
    pg.end()
        .then(() => {
            console.log('Disconnected from PostgreSQL');
            process.exit(0);
        })
        .catch(err => {
            console.error('Failed to disconnect from PostgreSQL:', err);
            process.exit(1);
        });
}

module.exports = { pg, connect, end}