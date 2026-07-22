import { useState } from 'react'
import { useNavigate } from 'react-router-dom'

function Login() {
    const [email, setEmail] = useState('')
    const [password, setPassword] = useState('')
    const [message, setMessage] = useState('')
    const navigate = useNavigate()

    const handleLogin = async () => {
        setMessage('Giriş yapılıyor...')

        try {
            const response = await fetch('http://localhost:5075/auth/login', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ email, password }),
            })

            if (response.ok) {
                const data = await response.json()
                localStorage.setItem('accessToken', data.accessToken)
                localStorage.setItem('refreshToken', data.refreshToken)
                setMessage('Giriş başarılı!')
                navigate('/profile')
            }
            else{
                setMessage('Giriş başarısız. Kod: ' + response.status)
            }
        } catch (error) {
            setMessage('HATA! : ' + error)
        }
    }

    return (
        <div>
            <h2>Giriş Yap</h2>
            <div>
                <label>Email</label>
                <input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                />
            </div>

            <div>
                <label>Şifre</label>
                <input
                    type="password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                />
            </div>

            <button onClick={handleLogin}>
                Giriş Yap
            </button>

            <p>{message}</p>
        </div>
    )
}

export default Login