import {UserData} from "../component/UserData";
import {Entrence} from "../component/Entrence";
import {Ask} from "../component/Ask";
import {ReportUser} from "../component/ReportUser";
import {ReportFeed} from "../component/ReportFeed";

export const Home = () =>
    <main style={{marginLeft: 400}}>
        <p style={{font: "50px bold", padding:"30px 50px", }}>대시보드</p>
        <UserData/>
        <Entrence/>
        <Ask/>
        <ReportFeed/>
        <ReportUser/>
    </main>