import {User} from "../component/user/User";
import {Entrence} from "../component/Entrence";
import {Ask} from "../component/Ask";
import {ReportUser} from "../component/ReportUser";
import {ReportPost} from "../component/ReportPost";

export const Home = () =>
    <main style={{marginLeft: 400}}>
        <p style={{font: "50px bold", padding:"30px 50px", }}>대시보드</p>
        <User/>
        <Entrence/>
        <Ask/>
        <ReportPost/>
        <ReportUser/>
    </main>