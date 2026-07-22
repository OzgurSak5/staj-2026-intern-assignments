import { BrowserRouter, Routes, Route } from 'react-router-dom'
import Login from './Login'
import Profile from './Profile'
import './App.css'
import ProtectedRoute from './ProtectedRoute'
import Register from './Register'

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route path="/profile" element={
          <ProtectedRoute>
            <Profile />
          </ProtectedRoute>}/>
        <Route path="/" element={<Login />} />
        <Route path="/register" element={<Register/>} />
      </Routes>
    </BrowserRouter>
  )
}

export default App