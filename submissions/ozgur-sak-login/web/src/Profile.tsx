import {useState, useEffect} from 'react'
import { apiFetch } from './api'
import { useNavigate } from 'react-router-dom'

function Profile() {
    const [email, setEmail] = useState('')
    const [message, setMessage] = useState('Yükleniyor...')
    const navigate = useNavigate()

    const handleLogout = async () => {
        const refreshToken = localStorage.getItem('refreshToken')

        try{
            await fetch('http://localhost:5075/logout', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ refreshToken }),
            })
        }
        catch(error){
            console.error('Logout isteği başarısız oldu, yine de local temizlik yapılıyor:', error)
        }
        localStorage.clear()
        navigate('/login')
    }

    useEffect(() => {
        const fetchProfile = async () => {
            const response = await apiFetch('http://localhost:5075/auth/me')

            if(response.ok) {
                const data = await response.json()
                setEmail(data.email)
                setMessage('Profil yüklendi.')
            } else {
                setMessage('Profil yüklenemedi. Kod: ' + response.status)
            }
        }
            
        fetchProfile()
    }, [])

    return (
        <div>
            <h2>Profil</h2>
            {message && <p>{message}</p>}
            {email && <p>Giriş yapan kullanıcı: {email}</p>}
            <button onClick={handleLogout}>Çıkış Yap</button>
        </div>
    )
}
    
export default Profile