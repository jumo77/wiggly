import {useEffect, useState} from "react";
import {ServerUrl} from "../common/ServerUrl";
import {snakeToCamel} from "../common/Functions";
import {Section} from "./ui/Section";
import {Pagination} from "../common/Pagination";
import {useNavigate} from "react-router-dom";

export const Ask = () => {
    const [ask, setAsk] = useState(null)
    useEffect(() => {
        fetch(ServerUrl + '/view_ask')
            .then(r => r.json())
            .then(r => setAsk(snakeToCamel(r)))
    }, []);

    useEffect(() => {
    }, [ask]);

    const [page, setPage] = useState(0)

    const navigate = useNavigate();

    const to = (to, data)=>{
        navigate(to, {state:data})
    }

    const deleteAsk = (id)=>{
        const sure = window.confirm('삭제하시겠습니까?')
        if (sure){
            fetch(ServerUrl + '/table_ask_answer?ask_id=eq.' + id.toString(), {
                method: 'DELETE',
            })
                .then(res => res.json())
                .then(()=>alert('삭제되었습니다.'))
                .catch(err => console.error(err));
        }
    }

    return (
        <Section title={'문의사항 접수'}>
            {ask && ask.length > 0 && <>
                <div style={{width: "100%"}} className={'flexColumn'}>
                    <div style={{minHeight: 500}}>
                        {ask.map((item, index) => index >= page * 10 && index <= page * 10 + 9 &&
                            <div style={{padding: "15px 0"}} className={'flexColumn topBottom'}>
                                <div key={`${item.id}${index}ask`} className={'flexRow sB'}
                                     style={{padding: "15px 0", width: "100%"}}>
                                    <h3 style={{display:'inline-block', width: "10%"}}>문의</h3>
                                    <div className={'flexColumn'} style={{gap: 10, width:'80%'}}>
                                        <h4>{item.nickname}</h4>
                                        <div className={'flexRow'}>
                                            <span style={{marginRight: 20}}>{item.loginId}</span>
                                            <span>| {item.password.length>20? 'email':item.password}</span>
                                        </div>
                                        <span>{item.content}</span>
                                    </div>
                                    <span style={{width:'10%', textAlign:'right'}}>{item.createdAt}</span>
                                </div>
                                {item.answer &&
                                    <div key={`${item.id}${index}answer`} className={'flexRow sB'}
                                         style={{padding: "15px 0", width: "100%"}}>
                                    <h3 style={{display:'inline-block', width: '10%'}}>답변</h3>
                                        <span style={{width:'80%'}}>{item.answer}</span>
                                    <span style={{width:'10%', textAlign:'right'}}>{item.answerAt}</span>
                                </div>}
                                <div className={'flexRow'} style={{padding: "15px 10%", gap:20}}>
                                    <span onClick={()=>to('/report', {id: item.id, type: 'ask'})}
                                        style={{cursor: 'pointer'}}>답변하기</span>
                                    {item.answer &&
                                        <span onClick={()=>deleteAsk(item.id)}
                                              style={{cursor: 'pointer'}}>삭제하기</span>}
                                </div>
                            </div>
                        )}
                    </div>
                </div>
                <Pagination data={ask} page={page} setPage={setPage}/>
            </>}
        </Section>
    )
}