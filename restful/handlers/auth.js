const {UnAuthorized, verify, noId, snakeToCamel, getPath} = require("../function");
const {select} = require("../db/select");

// 회원 인증 방화벽
const auth = async (req,res,next)=>{
    const u = getPath(req)
    let payload;
    let body;
    try {
        switch (req.method) {
            case "GET":
                if (process.env.SELECT_DENY.split(',').includes(u)) return UnAuthorized(res)
                break;

            case "POST":
                payload = await verify(req.header('access_token'))
                if (!payload ||!payload.id) return UnAuthorized(res)
                body = await req.body
                console.log('body', body)
                if (!noId(body)) return UnAuthorized(res)
                if (process.env.INSERT_DENY.split(',').includes(u)) return UnAuthorized(res)
                else if (process.env.INSERT_RESTRICT.split(',').includes(u)){
                    const originalTable = u.split('_').slice(0,-1).join('_')
                    const originalId = snakeToCamel(originalTable)+'Id'
                    if (!body.hasOwnProperty(originalId))
                        return UnAuthorized(res)
                    const id = body[originalTable]
                    if (!id) return UnAuthorized(res)
                    let r = await select(originalTable, originalId + '=' + id)
                    if (Array.isArray(r)) r=r[0]
                    if (!r.hasOwnProperty('user_id')) return UnAuthorized(res)
                    if (r['user_id']!==payload.id) return UnAuthorized(res)

                }
                else req.body = {...body, user_id: payload.id}
                break;

            case "PATCH":
                payload = await verify(req.header('access_token'))
                if (!payload ||!payload.id) return UnAuthorized(res)
                body = await req.body
                if (process.env.UPDATE_DENY.split(',').includes(u)) return UnAuthorized(res)
                else {
                    if (noId(req.query)) return UnAuthorized(res)
                    const id = req.query.id
                    const r = await select('table_'+u, { id })
                    if (r.length!==0) return res.status(404).json({ message: 'There is no entity under id: '+id.toString()})
                    if (r[0].user_id !== payload.id) return UnAuthorized(res)

                    req.body = {...body, user_id: payload.id}
                }
                break
            default:
                return res.status(404).json({ message: 'Not Proper Method' })
        }
        next()
    }catch (e) {
        console.error(e)
        return res.status()
    }
}

module.exports={auth}