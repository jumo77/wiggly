const {select} = require("../db/select");
const {camelToSnake, verify, UnAuthorized, snakeToCamel, getPath, noId} = require("../function");

// GET 메소드에 대한 설정
const get = async (req, res) => {
    // 중간에 문제가 생길 수 있으니 한번에 처리
    try {
        const u = getPath(req)
        const query = camelToSnake(req.query)
        // 본인만 조회 가능한 테이블 (문의, 신고)
        if(process.env.SELECT_RESTRICT.includes(u)){
            // jwt에서 회원 id parsing
            const payload = await verify(req.header('access_token'))
            if (!payload ||!payload.id) return UnAuthorized(res)
            // 불러올 데이터가 id를 가지고 있는지 특정된 데이터인지 확인
            if (noId(req.query)) {
                // 없을 때는 본인이 만든 모든 데이터 반환
                const r = await select('view_'+u+'_owner', { user_id: payload.id, ...query })
                return res.json(r)
            }
            const id = req.query.id
            // 있을 때는 id와 함께 만든 사람과 함께 검색
            const r = await select('view_'+u+'_owner', { id, user_id: payload.id, ...query })
            // 검색된 데이터가 없다면 없다고 반환
            if (!r) return res.status(404).json({ message: 'There is no entity under id: '+id.toString()})
            // 있다면 검색된 데이터 반환
            return res.json(r)
        }
        // 본인만 조회 가능한 테이블이 아닐 때
        // 특정인의 데이터를 모두 조회할 때
        if (query.hasOwnProperty('userId')) {
            // jwt에서 회원 id parsing
            const payload = await verify(req.header('access_token'))
            let table
            // 본인일 때는 모든 데이터를 조회
            if (query['userId'] === payload.id.toString()) table = 'view_' + u +'_owner'
            // 타인일 때는 공개된 데이터만 조회
            else table = 'view_'+u
            // 데이터 반환
            const r = await select(table, query)
            return res.json(snakeToCamel(r))
        // 모두의 비활성화된 데이터만 가져오는 건 거절
        // 만약 본인의 비활성화된 데이터만 가져온다면 이미 위의 if문 수행
        } else if (query.hasOwnProperty('active') && query['active']==='false') {
            return UnAuthorized(res)
        // 특별하지 않을 때는 공개된 데이터에서만 조회
        } else {
            const r = await select('view_' + u, query)
            return res.json(snakeToCamel(r))
        }
        // 중간에 발생한 문제 처리
    } catch (e) {
        console.error(e)
        return res.status(500).json(e)
    }
}

module.exports={get}