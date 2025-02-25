import {useEffect, useState} from "react";
import {ServerUrl} from "../common/ServerUrl";
import {Section} from "./ui/Section";
import {snakeToCamel} from "../common/Functions";
import {Table} from "./ui/Table";
import {map} from "../common/TextMap";

export const Entrence = () => {
    const [entrence, setEntrence] = useState(null)
    useEffect(() => {
        fetch(ServerUrl + '/view_room_views')
            .then(r => r.json())
            .then(r => setEntrence(snakeToCamel(r)))
    }, []);

    const [realTime, setRealTime] = useState(null)
    const [total, setTotal] = useState(null)
    useEffect(() => {
        if (entrence) {
            const r = {}
            const t = {}
            entrence.forEach(it => {
                const key = it.id + '#$%' + it.nickname
                t[key] = (t[key] || 0) + 1;
                const date = new Date(it.createdAt)
                if (new Date() - date < 1) r[key] = (r[key] || 0) + 1
                console.log(r, t)
            })
            const real = Object.entries(r).map(([key, view]) => ({
                id: key.split('#$%')[0],
                nickname: key.split('#$%')[1],
                view
            }))
            const tot = Object.entries(t).map(([key, view]) => ({
                id: key.split('#$%')[0],
                nickname: key.split('#$%')[1],
                view
            }))
            setRealTime(real)
            setTotal(tot)
        }
    }, [entrence]);
    const width = ["40%", "30%", "20%"]

    useEffect(() => {
        console.log('realTime', realTime)
        console.log('total', total)
    }, [realTime, total]);
    return <Section title={'가상공간 통계'}>
        {entrence && <div className={'flexRow'}>
            {realTime && <Table title='실시간 조회수가 많은 공간' data={realTime}
                    header={Object.keys(realTime.length > 0 ? realTime[0] : total[0])
                        .map((it, index) =>
                            ({id: it + index.toString(), width: width[index], label: map[it]}))}/>}
            <div style={{width: 80}}/>
            {total && <Table title='누적 조회수가 많은 공간' data={total}
                    header={Object.keys(total[0]).map((it, index) =>
                        ({id: it + index.toString(), width: width[index], label: map[it]}))}/>}
        </div>}
    </Section>
}