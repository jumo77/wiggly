import {useState} from "react";

export const Table = ({title, header, data, onClick}) => {

    const [page, setPage] = useState(0)
    const endPage = Math.floor(data.length/10)+1

    return <div style={{display: "flex", flexDirection: "column", width: "100%"}}>
        <h2 style={{fontSize: 20}}>{title}</h2>
        <div style={{borderBottom: "1px black solid", display: "flex", flexDirection: "row", padding: "15px 0"}}>
            {header.map((it, index) =>
                <div key={header.id + index.toString()}
                     style={{width: it.width, fontWeight: "bold"}}>{it.label}</div>)}
        </div>
        <div style={{height: 500}}>
        {data.map((item, index) => index >= page * 10 && index <= page * 10 + 9 &&
            <div key={item.id.toString() + index.toString() + title} onClick={()=>onClick(item.id)}
                style={{display: "flex", flexDirection: "row",  padding: "15px 0", cursor:"pointer"}}>
                {Object.keys(item).map((it, i) => <div key={it + i.toString()}
                    style={{width: header[i].width, overflow: 'hidden', textOverflow:'ellipsis', whiteSpace:"noWrap"}}>{item[it]}</div>
                )}
            </div>
        )}
        </div>
        <ul style={{display: "flex", flexDirection: "row", justifyContent: "space-between"}}>
            <button onClick={()=>setPage(p => p>10? p-10: 0)}
                style={page === 0 ? {visibility:"hidden"}: {visibility: "none"}}>
                <img src='play.png' style={{transform:"scaleX(-1)", width:20}}/></button>
            {Array.from({ length: endPage }, (_, i)=>i+1).map((it, index)=> index<10 &&
                index+page*10<endPage && <button onClick={()=>setPage(it)}>{page*10+it}</button>)}
            <button onClick={()=>setPage(p => p+10>data.length/10? p+10: data.length/10)}
                style={page+1>(data.length/10) ? {visibility:"hidden"}: {visibility: "none"}}>
                <img src='play.png' style={{width: 20}}/></button>
        </ul>
    </div>
}
