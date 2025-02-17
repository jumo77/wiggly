import {Link, useLocation} from "react-router-dom";

const buttons = [
    {
        to: '/',
        title: '대시보드'
    },
    {
        to: '/report',
        title: '사용자 및 컨텐츠 관리'
    }
]

export const Sidebar = ()=> {

    const {pathname} = useLocation()

    return (
        <aside style={{
            background: 'black',
            width: '400px',
            height: '100vh',
            display: 'flex',
            flexDirection: 'column',
            overflow: 'scroll',
            boxShadow: '4px 4px 12px 0px #0000001F',
            position: 'fixed',
            padding: '45px',
            gap: '30px',
            fontSize: '30px',
            zIndex: 55,
        }}>
            <div style={{height:100}}/>
            {buttons.map((it, index) =>
                <Link key={index.toString() + it.to} to={it.to}
                      style={{textDecoration: 'none', color: 'white'}}>
                    <span style={pathname===it.to? {fontWeight:'bold'}:{}}>
                        {it.title}
                    </span>
                </Link>)}
        </aside>
    )
}
