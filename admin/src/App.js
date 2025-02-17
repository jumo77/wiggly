import './App.css';
import {BrowserRouter, Route, Routes} from "react-router-dom";
import {Home} from "./pages/Home";
import {Report} from "./pages/Report";
import {Sidebar} from "./component/ui/Sidebar";

export const App = ()=>
    <>
        <BrowserRouter>
            <Sidebar/>
            <Routes>
                <Route index Component={Home}/>
                <Route path='/report' Component={Report}/>
            </Routes>
        </BrowserRouter>
    </>