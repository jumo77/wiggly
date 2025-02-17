import {useLocation} from "react-router-dom";
import {useEffect, useState} from "react";
import {ServerUrl} from "../common/ServerUrl";
import {Section} from "../component/ui/Section";
import {snakeToCamel} from "../common/Functions";
import {map} from "../common/TextMap";

export const Report = () => {
    const location = useLocation()
    const report = { ...location.state }
    const { id, type } = report
    const [data, setData] = useState(null)
    useEffect(() => {
        fetch(ServerUrl+`view_report_${type}?id=eq.${id}`)
            .then(r=>r.json())
            .then(r=>setData(snakeToCamel(r[0])))
    }, []);

    const [status, setStatus] = useState(null)
    useEffect(() => {
        data && typeof data === 'object' && setStatus(type ==='user'?data.status:data.active)
    }, [data]);

    useEffect(() => {
        console.log(status)
    }, [status]);

    const saveChange = ()=>{
        console.log(data)
        fetch(ServerUrl+`table_${type}?id=eq.${type==='user'?data.defId: data.postId}`, {
            headers:{'Content-Type':'application/json; charset=utf-8'},
            method:'PATCH',
            body: JSON.stringify(type==='user' ? {status} : {active: status})
        }).then(()=>alert('저장되었습니다.'))
            .catch(e=>alert(e))
    }

    return(
        <main style={{marginLeft: 400}}>
            <h1 style={{font: "50px bold", padding:"30px 50px", }}>신고된 사용자 및 컨텐츠</h1>
            {report && data && typeof data === 'object' &&
                <Section title={type === 'post' ? '신고 접수된 컨텐츠' : type === 'user' ? '신고 접수된 계정' : null}>
                    {Object.keys(data).map((it, index) => index<Object.keys(data).length-1&&
                    <div style={{display: "flex", flexDirection: "row"}}>
                        <div style={{width: "30%"}}>{map[it]}</div>
                        <div style={{width: "70%"}}>{data[it]}</div>
                    </div>)}
                    <div style={{display: "flex", flexDirection: "row"}}>
                        <div style={{width: "30%"}}>
                            {type === 'user'?'회원 상태':type === 'post'?'콘텐츠 상태':null}
                        </div>
                        <div style={{width: "70%"}}>
                            <select value={status} onChange={event => setStatus(event.target.value)}>
                                {type === 'user'?
                                    <>
                                <option value={0}>활성화</option>
                                <option value={1}>정지</option>
                                <option value={2}>탈퇴</option>
                                    </>:<>
                                <option value={'true'}>공개</option>
                                <option value={'false'}>비공개</option>
                                    </>

                                }
                            </select>
                        </div>
                    </div>
                    <div style={{display: "flex", flexDirection: "row", justifyContent:"right"}}>
                        <button style={{backgroundColor:"black", color:"white", padding:"5px 20px"}}
                        onClick={saveChange}>저장</button>
                    </div>

                </Section>
            }
        </main>
    )
}