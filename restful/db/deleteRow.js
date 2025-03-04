const {pg} = require("./db");
const deleteRow = async (id, table) => {
    // 수정할 값 설정
    const r = pg.query(`update ${table} set active = false where id = ${id}`)
    console.log(r)
    // 성공적으로 날렸다는 메세지 반환
    // 실패는 이의 호출 함수에서 처리
    return { message: 'Deleted row' }
}

module.exports = {deleteRow}
