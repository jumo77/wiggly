import {ServerUrl} from "../common/ServerUrl";
import {snakeToCamel} from "../common/Functions";
import {useEffect, useState} from "react";
import {Section} from "./ui/Section";
import {Table} from "./ui/Table";
import {map} from "../common/TextMap";
import {useNavigate} from "react-router-dom";

export const ReportPost = () => {
    const [data, setData] = useState(null)
    useEffect(() => {
        fetch(ServerUrl+'/view_report_post')
            .then(r=>r.json())
            .then(r=>setData(snakeToCamel(r)))
    }, []);

    const [report, setReport] = useState(null)
    useEffect(() => {
        if (data){
            console.log(data)
            const a = []
            data.forEach(it=>{
                const date = new Date(it.createdAt)
                const year = date.getFullYear()
                const month = date.getMonth()+1
                const day = date.getDate()
                a.push({
                    id:it.id,
                    compId: it.compId,
                    postId: it.postId,
                    desc: it.desc,
                    createdAt: `${year}-${month}-${day}`,
                    content: it.content,
                })
            })
            setReport(a)
        }
    }, [data]);
    const width =["10%","10%","10%", "10%", "10%","50%"]

    const navigate = useNavigate()
    const onClick = (id) => navigate('/report',{state:{ id, type: 'post' }})

    return(
        <Section title={'신고 조회'}>
            {data&&data.length>0&&report&&report.length>0&&
                <Table title={'신고 접수된 콘텐츠'} onClick={onClick} data={report}
                       header={Object.keys(report[0]).map((it, index)=>
                           ({id: it+index.toString(), width: width[index], label: map[it]}))}/>}
        </Section>
    )
}