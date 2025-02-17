const {insert} = require("../db/insert");
const {getPath, camelToSnake} = require("../function");

// POST 메소드에 대한 설정
const post = async (req, res)=>{
    // 중간에 문제가 생길 수 있으니 한번에 처리
    try {
        const u = getPath(req)
        const b = await req.body
        const body = camelToSnake(b)
        const r = await insert('table_'+u, body)
        return res.status(201).json(r)
        // 중간에 발생한 문제 처리
    }catch (e) {
        console.error(e)
        return res.status(500).json(e)
    }
}

module.exports={post}