const { pg } = require('./db')

// 수정할 때 sql 로직
const update = async (id, table, entity) => {
    // 수정할 값 설정
    const values = []
    // 수정할 컬럼과 값 세팅
    const s = Object.entries(entity)
        .map(([key, value], index)=> {
            // 값 추가
            values.push(value)
            // sql의 prepared query 형태로 실행
            return key + ' = $' + (index+1).toString()
        }).join(', ')
    const r = pg.query(`update ${table} set ${s} where id = ${id}`, values)
    console.log(r)
    // 성공적으로 날렸다는 메세지 반환
    // 실패는 이의 호출 함수에서 처리
    return { message: 'Updated row' }
}

module.exports = {update}