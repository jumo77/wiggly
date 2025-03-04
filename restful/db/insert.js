const {pg} = require("./db");
const {camelToSnake} = require("../function");

// 삽입할 때 sql 로직
async function insert(table, body) {
    // 삽입할 column parse
    // 삽입할 값이 여러개일 때는 하나의 키값만 가지고 진행
    const keys = Object.keys(Array.isArray(body)? body[0]: body).map(camelToSnake);
    // 삽입할 값 설정
    // 삽입할 값의 배열 여부에 따라 수행 로직 변화
    const values = Array.isArray(body)?
        // 배열이면 (값), (값) 형태로, 객체면 (값) 형태로 데이터 가공
        body.map(it => {
            const value = keys.map(i => {
                const val = JSON.parse(it[i])
                return typeof val === 'string'? `'${val}'`: val
            })
            return '('+value.join(',')+')';
        }).join(','):
        '('+keys.map(it=>{
            const val = body[it]
            return typeof val === 'string'? `'${val}'`: val
        }).join(',') + ')'
    const r = await pg.query('insert into '+table+'('+keys.map(it=>'"'+it+'"')
                .join(',')+') values'+values+';')
    const rowCount = r.rowCount;
    // 삽입된 결과에 따라 단수/복수 구분
    if (rowCount === 1) return {message: r.rowCount.toString() + ' row inserted'}
    return {message: r.rowCount.toString() + ' rows inserted'}
}

module.exports={insert}
