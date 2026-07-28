import { Navigate } from "react-router-dom";

function ProtectedRoute({children}: {children: React.ReactNode}){
    const token = localStorage.getItem('accessToken')

    if(!token){
        return <Navigate to="/login" />
    }

    return children
}

export default ProtectedRoute