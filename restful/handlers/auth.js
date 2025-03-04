const {UnAuthorized, verify, noId, snakeToCamel, camelToSnake, getPath} = require("../function");
const {select} = require("../db/select");
const {deleteRow} = require("../db/deleteRow");

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
                if (!noId(body)) return UnAuthorized(res)
                if (process.env.INSERT_DENY.split(',').includes(u)) return UnAuthorized(res)
                else if (process.env.INSERT_RESTRICT.split(',').includes(u)){
                    const originalTable = u.split('_').slice(0,-1).join('_')
                    const originalId = snakeToCamel(originalTable)+'Id'
                    if (!body.hasOwnProperty(originalId))
                        return UnAuthorized(res)
                    const id = body[originalId]
                    if (!id) return UnAuthorized(res)
                    let r = await select('table_'+originalTable, { id })
                    if (Array.isArray(r)) r=r[0]
                    if (!r.hasOwnProperty('user_id')) return UnAuthorized(res)
                    if (parseInt(r['user_id'])!==payload.id) return UnAuthorized(res)
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
		    if (!r) return res.status(404).json({ message: 'There is no entity under id: '+id.toString()})
                    if (parseInt(r.user_id) !== payload.id) return UnAuthorized(res)

                    req.body = {...body, user_id: payload.id}
                }
                break
	    case "DELETE":
                if (process.env.DELETE_DENY.split(',').includes(u)) return UnAuthorized(res)
                else {
                    payload= await verify(req.header('access_token'))
                    if (!payload ||!payload.id) return UnAuthorized(res)
                    if (noId(req.query)) return UnAuthorized(res)
                    const id = req.query.id
                    const r = await select('table_'+u, { id })
                    if (!r) return res.status(404).json({ message: 'There is no entity under id: '+id.toString()})
                    if (parseInt(r.user_id) !== payload.id) return UnAuthorized(res)

                    const re = await deleteRow(id, 'table_' + u)
		    return res.status(200).json({ message: 'Deleted 1 row'})
                }
                break
            default:
                return res.status(404).json({ message: 'Not Proper Method' })
        }
        next()
    }catch (e) {
        console.error(e)
        return res.status(500).json({ message: e.name })
    }
}

module.exports={auth}
