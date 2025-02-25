import {useEffect, useState} from "react";
import {ServerUrl} from "../common/ServerUrl";
import {Section} from "./ui/Section";
import {Table} from "./ui/Table";
import {map} from "../common/TextMap";
import {snakeToCamel} from "../common/Functions";

export const User = () => {

    const [user, setUser] = useState(null)
    useEffect(() => {
        fetch(ServerUrl+'view_user_admin')
            .then(res => res.json())
            .then(r => setUser(snakeToCamel(r)))
    }, []);

    const width = ['16%', '8%', '8%','8%','8%','8%','8%','8%','14%','14%']
    return (
        <Section title={"회원 목록"}>
            {user && <div className={'flexRow'}>
                <Table header={Object.keys(user[0]).map((it, index) =>
                    ({id: it + index.toString(), width: width[index], label: map[it]}))}
                    data={user}/>
            </div> }
        </Section>
    )
}