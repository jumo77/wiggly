import {useEffect, useState} from "react";
import {ServerUrl} from "../common/ServerUrl";
import {Section} from "./ui/Section";
import {map} from "../common/TextMap";
import {snakeToCamel} from "../common/Functions";

export const UserData = () => {
    useEffect(() => {
        fetch(ServerUrl + '/view_log_total')
            .then(r => r.json())
            .then(r => settingTotal(snakeToCamel(r)))
        fetch(ServerUrl + '/view_log_daily')
            .then(r => r.json())
            .then(r => settingDaily(snakeToCamel(r)))
        fetch(ServerUrl + '/view_log_monthly')
            .then(r => r.json())
            .then(r => settingMonthly(snakeToCamel(r)))
    }, []);

    const [total, setTotal] = useState(null)
    const settingTotal = (_total) => {
        if (_total) {
            setTotal(_total[0])
        }
    }

    const [daily, setDaily] = useState(null)
    const settingDaily = (_daily) => {
        if (_daily) {
            const newDaily = {}
            _daily.forEach(item => {
                const key = item['logDate']
                delete item['logDate']
                newDaily[key] = {...item}
            })
            setDaily(newDaily)
        }
    }

    const [monthly, setMonthly] = useState(null)
    const settingMonthly = (_monthly) => {
        if (_monthly) {
            const newMonthly = {}
            _monthly.forEach(item => {
                const key = item['logMonth']
                delete item['logMonth']
                newMonthly[key] = {...item}
            })
            setMonthly(newMonthly)
        }
    }

    const [dailySelection, setDailySelection] = useState(null)
    useEffect(() => {
        settingDailySelection(daily)
    }, [daily]);

    useEffect(() => {

    }, [dailySelection])

    const settingDailySelection = (_daily) => {
        if (_daily && Object.keys(_daily).length > 0) {
            const keys = Object.keys(_daily)
            const lastKey = keys[keys.length - 1]
            setDailySelection(lastKey)
        }
    }

    const [monthlySelection, setMonthlySelection] = useState(null)
    useEffect(() => {
        settingMonthlySelection(monthly)
    }, [monthly]);

    useEffect(() => {
    }, [monthlySelection]);

    const settingMonthlySelection = (_monthly) => {
        if (_monthly && Object.keys(_monthly).length >= 2) {
            const keys = Object.keys(_monthly)
            const lastKey = keys[keys.length - 1]
            setMonthlySelection(lastKey)
        }
    }

    const toDate = (_date) => {
        const newDate = new Date(_date)
        const year = newDate.getFullYear()
        const month = newDate.getMonth() + 1
        const date = newDate.getDate()
        return `${year}년 ${month}월 ${date}일`
    }

    const toMonth = (_month) => {
        const newMonth = _month.split('-')
        const year = newMonth[0]
        const month = newMonth[1]
        return `${year}년 ${month}월`
    }

    return (
        <Section title={'사용자 통계'}>
            {
                total &&<>
            <div>
                <h2 style={{display: 'inline-block', width: 200}}>전체 사용자 통계</h2>
            </div>

            <div>
                {total && Object.keys(total).map((it, i) => (
                     <div key={it+i.toString()+'body'} style={{display: 'inline-block', width: 280}}>
                        <p style={{fontSize: 20}} key={it+i.toString()+'label'}>{map[it]}</p>
                        <p style={{fontSize: 40}} key={it+i.toString()+'content'}>
                            {total[it].toLocaleString()}</p>
                    </div>
                ))}
            </div>
                </>}

            {daily && <>
            <div>
                <h2 style={{display: 'inline-block', width: 200}}>일간 사용자 통계</h2>
                <select value={dailySelection}
                    onChange={e =>
                    setDailySelection(e.target.value)}>
                {
                    Object.keys(daily).map((it, i) =>
                        <option key={it+i.toString()+'daily'} value={it}>{toDate(it)}</option>)
                }
            </select>
            </div>
            <div>
                {daily && dailySelection && Object.keys(daily[dailySelection]).map((it, i) => (
                    <div key={it+i.toString()+'body'} style={{display: 'inline-block', width: 280}}>
                        <p style={{fontSize: 20}} key={it+i.toString()+'label'}>{map[it]}</p>
                        <p style={{fontSize: 40}} key={it+i.toString()+'content'}>
                            {daily[dailySelection][it]}</p>
                    </div>
                ))}
            </div>
            </>}

            {monthly && <>
            <div>
                <h2 style={{display: 'inline-block', width: 200}}>월간 사용자 통계</h2>
                <select value={monthlySelection}
                    onChange={e =>
                    setMonthlySelection(e.target.value)}>
                {
                    Object.keys(monthly).map((it, i) =>
                        <option key={it+i.toString()+'monthly'} value={it}>{toMonth(it)}</option>)
                }
            </select>
            </div>
            <div>
                {monthly && monthlySelection && Object.keys(monthly[monthlySelection]).map((it, i) => (
                    <div key={it+i.toString()+'body'} style={{display: 'inline-block', width: 280}}>
                        <p style={{fontSize: 20}} key={it+i.toString()+'label'}>{map[it]}</p>
                        <p style={{fontSize: 40}} key={it+i.toString()+'content'}>
                            {monthly[monthlySelection][it]}</p>
                    </div>
                ))}
            </div>
            </>}

        </Section>
    )
}
