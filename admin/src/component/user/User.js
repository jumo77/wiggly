import {useEffect, useState} from "react";
import {ServerUrl} from "../../common/ServerUrl";
import {Section} from "../ui/Section";
import {processLog} from "./functions";

export const User = () => {
    useEffect(() => {
        fetch(ServerUrl+'/view_log')
            .then(r => r.json())
            .then(r => settingCounts(r))
    }, []);

    const [counts, setCounts] = useState(null)
    const settingCounts = (userLog) => {
        if (userLog.length >= 1) {
            const c = processLog(userLog)
            setCounts(c)
        }
    }

    const [selection, setSelection] = useState()

    useEffect(() => {
        settingSelection(counts)
    }, [counts]);

    useEffect(() => {
    }, [selection]);

    const settingSelection = (count) => {
        if (count && Object.keys(count.dailyCounts).length >= 2) {
            const dK = Object.keys(count.dailyCounts)
            const lDK = dK[dK.length - 1]
            const mK = Object.keys(count.monthlyCounts)
            const lMK = mK[mK.length - 1]
            setSelection(({dailyCounts: lDK, monthlyCounts: lMK}))
        }
    }

    return (
        <Section title={'사용자 통계'}>
            {counts && selection && Object.keys(counts).map((item, index) => {
                console.log(item)
                return <>
                    <div key={item + index.toString() + 'header'}>
                        <h2 style={{display: 'inline-block', width: '200px'}}>{counts[item].title}</h2>
                        {item !== 'totalCounts' &&
                            <select
                                onChange={event =>
                                    setSelection(prev => ({
                                        ...prev,
                                        [item]: event.target.value
                                    }))}>
                                {
                                    Object.keys(counts[item]).map((it, i) => i >= 2 &&
                                        <option value={it}>{it.replace('-', '월 ') + '일'}</option>)
                                }
                            </select>}
                    </div>
                    <div key={item + index.toString() + 'body'}>
                        {Object.keys(counts[item]).map((it, i) =>
                            i >= 2 && Object.keys(counts[item][it]).map((t, j) =>
                                <div key={`${t}${j}${it}${i}${item}${index}`} style={{display: 'inline-block', width: 400}}>
                                    <p style={{fontSize: 20}} key={`${t}${j}${it}${i}${item}${index} label`}>
                                        {it === 'total' ? '전체 누적 ' : '신규 '}
                                        {t === 'new' ? '가입자' : t === 'active' ? '활성 사용자' : '재방문자'} 수</p>
                                    <p style={{fontSize: 40}} key={`${t}${j}${it}${i}${item}${index} content`}>
                                        {it !== 'total' ?
                                            counts[item][selection[counts[item].selection]][t].toLocaleString() :
                                            counts[item]['total'][t].toLocaleString()}</p>
                                </div>
                            ))
                        }
                    </div>
                </>
            })}
        </Section>
    )
}
