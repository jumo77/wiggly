const {update} = require("../db/update");
const {getPath, noId, camelToSnake} = require("../function");

// 데이터 수정
const patch = async (req, res) =>{
    // 중간에 문제가 생길 수 있으니 한번에 처리
    try {
        const u = getPath(req)
        const b = await req.body
        const body = camelToSnake(b)
        // 수정할 데이터를 특정했는지 확인
        if (noId(req.query)) {
            // 특정하지 않았다면 한번에 하나만 수정 가능하다고 전달
            throw new Error('You can only patch single data at once')
        }
        // 수정할 데이터의 id 불러오기
        const id = req.query.id
        const r = await update(id, 'table_'+u, body)
        // 수정 결과 반환
        return res.status(201).json(r)
    }catch (e) {
        console.error(e)
        return res.status(500).json(e)
    }
}

module.exports = {patch}