import {useState} from "react";
import {Pagination} from "../../common/Pagination";

export const Table = ({title, header, data, onClick}) => {

    const [page, setPage] = useState(0)

    return <div style={{width: "100%"}} className={'flexColumn'}>
        <h2 style={{fontSize: 20}}>{title}</h2>
        <div style={{borderBottom: "1px black solid", padding: "15px 0"}} className={'flexRow'}>
            {header.map((it, index) => <div key={it.id + index.toString()}
                     style={{width: it.width, fontWeight: "bold"}}>{it.label}</div>)}
        </div>
        <div style={{height: 500}}>
        {data.map((item, index) => index >= page * 10 && index <= page * 10 + 9 &&
            <div key={item.id.toString() + index.toString() + title} onClick={()=>onClick(item.id)}
                style={{padding: "15px 0", cursor:"pointer"}} className={'flexRow'}>
                {Object.keys(item).map((it, i) => <div key={it + i.toString()}
                    style={{width: header[i].width, overflow: 'hidden', textOverflow:'ellipsis', whiteSpace:"noWrap"}}>{item[it]}</div>
                )}
            </div>
        )}
        </div>
        <Pagination data={data} page={page} setPage={setPage}/>
    </div>
}
