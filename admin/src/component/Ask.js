import {useEffect, useState} from "react";
import {ServerUrl} from "../common/ServerUrl";
import {snakeToCamel} from "../common/Functions";
import {Section} from "./ui/Section";
import {Table} from "./ui/Table";
import {map} from "../common/TextMap";

export const Ask = () => {
    const [data, setData] = useState(null)
    useEffect(() => {
        fetch(ServerUrl + '/view_ask')
            .then(r => r.json())
            .then(r => setData(snakeToCamel(r)))
    }, []);

    const [ask, setAsk] = useState(null)
    useEffect(() => {
        if (data) {
            const a = []
            data.forEach(it => {
                const date = new Date(it.createdAt)
                const year = date.getFullYear()
                const month = date.getMonth() + 1
                const day = date.getDate()
                a.push({
                    id: it.id,
                    nickname: it.nickname,
                    createdAt: `${year}-${month}-${day}`,
                    subject: it.subject,
                    content: it.content,
                })
            })
            setAsk(a)
        }
    }, [data]);
    const width = ["15%", "10%", "10%", "15%", "50%"]

    return (
        <Section title={'문의사항 접수'}>
            {data && ask && data.length > 0 && ask.length > 0 &&
                <Table header={Object.keys(ask[0]).map((it, index) =>
                    ({id: it + index.toString(), width: width[index], label: map[it]}))}
                       data={ask}/>}
        </Section>
    )
}