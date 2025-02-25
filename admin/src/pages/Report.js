import {useLocation} from "react-router-dom";
import {useEffect, useState} from "react";
import {ServerUrl} from "../common/ServerUrl";
import {Section} from "../component/ui/Section";
import {snakeToCamel} from "../common/Functions";
import {map} from "../common/TextMap";
import {logDOM} from "@testing-library/dom";
import {User} from "../component/User";
import {Feed} from "../component/Feed";

export const Report = () => {
    const location = useLocation()
    const report = {...location.state}
    const {id, type} = report
    const [data, setData] = useState(null)
    useEffect(() => {
        const param = type === 'ask' ? `view_ask?id=eq.${id}` : `view_report_${type}?id=eq.${id}`
        fetch(ServerUrl + param)
            .then(r => r.json())
            .then(r => setData(snakeToCamel(r[0])))
    }, []);

    const [status, setStatus] = useState(null)
    const [answer, setAnswer] = useState(null);
    useEffect(() => {
        if (data && typeof data === 'object') {
            if (type === 'ask') setAnswer(data.answer ? data.answer : '')
            else setStatus(type === 'user' ? data.status : data.active)
        }
    }, [data]);

    useEffect(() => {
    }, [status]);

    const saveChange = () => {
        fetch(ServerUrl + `table_${type}?id=eq.${type === 'user' ? data.defId : data.postId}`, {
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            method: 'PATCH',
            body: JSON.stringify(type === 'user' ? {status} : {active: status})
        }).then(() => alert('저장되었습니다.'))
            .catch(e => alert(e))
    }


    const saveAnswer = () => {
        console.log(data.answer? 'p':'a')
        fetch(ServerUrl + `table_ask_answer?ask_id=eq.${id}`, {
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            method: data.answer ? 'PATCH' : 'POST',
            body: JSON.stringify({answer, ask_id: id}),
        })
            .then(() => alert('저장되었습니다.'))
            .catch(e => alert(e))
    }

    return (
        <main style={{marginLeft: 400}}>
            <h1 style={{font: "50px bold", padding: "30px 50px",}}>사용자 및 컨텐츠 관리</h1>
            {report && data && typeof data === 'object' && (type === 'user' || type === 'post') ?
                <Section title={type === 'post' ? '신고 접수된 컨텐츠' : type === 'user' ? '신고 접수된 계정' : null}>
                    {Object.keys(data).map((it, index) => index < Object.keys(data).length - 1 &&
                        <div style={{display: "flex", flexDirection: "row"}}>
                            <div style={{width: "30%"}}>{map[it]}</div>
                            <div style={{width: "70%"}}>{data[it]}</div>
                        </div>)}
                    <div style={{display: "flex", flexDirection: "row"}}>
                        <div style={{width: "30%"}}>
                            {type === 'user' ? '회원 상태' : type === 'post' ? '콘텐츠 상태' : null}
                        </div>
                        <div style={{width: "70%"}}>
                            <select value={status} onChange={event => setStatus(event.target.value)}>
                                {type === 'user' ?
                                    <>
                                        <option value={0}>활성화</option>
                                        <option value={1}>정지</option>
                                        <option value={2}>탈퇴</option>
                                    </> : <>
                                        <option value={'true'}>공개</option>
                                        <option value={'false'}>비공개</option>
                                    </>

                                }
                            </select>
                        </div>
                    </div>
                    <div style={{display: "flex", flexDirection: "row", justifyContent: "right"}}>
                        <button style={{backgroundColor: "black", color: "white", padding: "5px 20px"}}
                                onClick={saveChange}>저장
                        </button>
                    </div>

                </Section> :
                type ==='ask' ? <Section title={'문의 답변'}>
                    {data && typeof data === 'object'
                        && Object.keys(data).map((it, index) => (
                        index < Object.keys(data).length - 2 &&
                        <div key={it} className={'flexRow'}>
                            <div style={{width: "30%"}}>{map[it]}</div>
                            <div style={{width: "70%"}}>{data[it]}</div>
                        </div>
                    ))}
                    <div className={'flexRow'}>
                        <div style={{width: "30%"}}>답변내용</div>
                        <textarea style={{width: "70%", fontSize: "1rem", padding:10}}
                               value={answer} placeholder={'답변내용'}
                        onChange={e=>
                            setAnswer(e.target.value)}/>
                    </div>
                    <div style={{display: "flex", flexDirection: "row", justifyContent: "right"}}>
                    <button style={{backgroundColor: "black", color: "white", padding: "5px 20px"}}
                            onClick={saveAnswer}>저장
                    </button>
                </div>
                </Section>: null
            }
            <User/>
            <Feed/>
        </main>
    )
}