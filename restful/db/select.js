const { pg } = require("./db");

// 조회할 때 sql 로직
const select = async (table, where) =>{
    if (Object.keys(where).length===0) {
        const r = await pg.query(`select * from ${table}`)
        return r.rows
    }
    else {
        const values = []
        const w = Object.entries(where)
            .map(([key, value], index)=>{
                const operation = /[!<>~]/
                if (operation.test(key)) {
		    const op = key.match(operation)
                    if (value){
                        values.push(value)
                        return key.split(op[0])[0]+' '+op[0]+'= $'+ (index+1).toString()
                    }
                    values.push(op[0]==='LIKE'? '%'+key.split(op[0])[1] +'%': key.split(op[0])[1])
                    return key.split(op[0])[0]+' '+op[0]+' $'+ (index+1).toString()
                }
                else {
                    values.push(value)
                    return key+' = $'+ (index+1).toString()
                }
            }).join(' and ')
        const r = await pg.query(`select * from ${table} where ${w}`, values)
        if (where.hasOwnProperty('id')) return r.rows[0]
        return r.rows
    }
}

module.exports={select}
