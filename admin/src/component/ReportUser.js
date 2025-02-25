import {ServerUrl} from "../common/ServerUrl";
import {snakeToCamel} from "../common/Functions";
import {useEffect, useState} from "react";
import {useNavigate} from "react-router-dom";
import {Section} from "./ui/Section";
import {Table} from "./ui/Table";
import {map} from "../common/TextMap";

export const ReportUser = () => {
    const [report, setReport] = useState(null)
    useEffect(() => {
        fetch(ServerUrl + '/view_report_user')
            .then(r => r.json())
            .then(r => setReport(snakeToCamel(r)))
    }, []);

    useEffect(() => {
    }, [report]);
    const width = ["10%", "10%", "10%", "15%", "10%", "10%", "10%"]

    const navigate = useNavigate()
    const onClick = (id) => navigate('/report', {state: {id, type: 'user'}})

    return (
        <Section title={'신고 조회'}>
            {report && report.length > 0 &&
                <Table title={'신고 접수된 계정'} onClick={onClick} data={report}
                       header={Object.keys(report[0]).map((it, index) =>
                           ({id: it + index.toString(), width: width[index], label: map[it]}))}/>}
        </Section>
    )
}