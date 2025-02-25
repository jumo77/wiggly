import {useEffect, useState} from "react";
import {ServerUrl} from "../common/ServerUrl";
import {snakeToCamel} from "../common/Functions";
import {Section} from "./ui/Section";
import {Table} from "./ui/Table";
import {map} from "../common/TextMap";

export const Feed = () => {
    const [feed, setFeed] = useState(null)
    useEffect(() => {
        fetch(ServerUrl+'view_feed_admin')
            .then(res => res.json())
            .then(r => setFeed(snakeToCamel(r)))
    }, []);

    const width = ['8%', '16%', '8%','8%','8%','8%','8%','8%','14%','14%']
    return (
        <Section title={"콘텐츠 목록"}>
            {feed && <div className={'flexRow'}>
                <Table header={Object.keys(feed[0]).map((it, index) =>
                    ({id: it + index.toString(), width: width[index], label: map[it]}))}
                       data={feed}/>
            </div> }
        </Section>
    )
}