import {PathOfIt} from "./ServerUrl";

export const Pagination = ({data, page, setPage}) => {
    const e = Math.floor(data.length / 10) + 1
    return (
        <ul style={{justifyContent: "space-between"}} className={'flexRow'}>
            <button onClick={() => setPage(p => p > 10 ? p - 10 : 0)}>
                <img src={'play.png'} style={{transform: "scaleX(-1)", width: 20}}/></button>

            {Array.from({length: e}, (_, i) => i + 1).map((it, i) =>
                i < 10 && i + page * 10 < e && <button onClick={() => setPage(it)}
                    style={it === page + 1?{ backgroundColor:"black", color:"white"}: {cursor: "none"}}
                >{page * 10 + it}</button>)}

            <button onClick={() => setPage(p => p + 10 > data.length / 10 ? p + 10 : data.length / 10)}>
                <img src={'play.png'} style={{width: 20}}/></button>
        </ul>
    )
}