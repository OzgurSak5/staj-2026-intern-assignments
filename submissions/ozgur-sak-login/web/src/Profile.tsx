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
        <div className="auth-page">
            <div className="profile-card">
                <div className="profile-avatar">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
                        <circle cx="12" cy="8" r="4" />
                        <path d="M4 20c0-4.4 3.6-7 8-7s8 2.6 8 7" />
                    </svg>
                </div>

                <h2 className="profile-title">Profil</h2>

                {message && <p className="auth-message">{message}</p>}

                {email && (
                    <div className="profile-field">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
                            <rect x="3" y="5" width="18" height="14" rx="2" />
                            <path d="M3 7l9 6 9-6" />
                        </svg>
                        <span>{email}</span>
                    </div>
                )}

                <button className="logout-button" onClick={handleLogout}>
                    <span>Çıkış Yap</span>
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
                        <path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4" />
                        <path d="M16 17l5-5-5-5M21 12H9" />
                    </svg>
                </button>
            </div>
        </div>
    )
}
    
export default Profile