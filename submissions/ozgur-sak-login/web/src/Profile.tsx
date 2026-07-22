import {useState, useEffect} from 'react'

function Profile() {
    const [email, setEmail] = useState('')
    const [message, setMessage] = useState('Yükleniyor...')

    useEffect(() => {
        const fetchProfile = async () => {
            const accessToken = localStorage.getItem('accessToken')

            const response = await fetch('http://localhost:5075/auth/me', {
                headers: {
                    'Authorization': `Bearer ${accessToken}`,
                },
            })

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
        </div>
    )
}
    
export default Profile