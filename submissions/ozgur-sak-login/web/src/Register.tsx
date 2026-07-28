import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { Link } from 'react-router-dom'

function Register(){
    const [email, setEmail] = useState('')
    const [password, setPassword] = useState('')
    const [message, setMessage] = useState('')
    const navigate = useNavigate()

    const handleRegister = async () => {
        setMessage('Kayıt olunuyor...')

        try{
            const response = await fetch('http://localhost:5075/auth/register', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email, password }),
            })

            if(response.ok){
                setMessage('Kayıt başarılı! Giriş sayfasına yönlendiriliyorsun...')
                navigate('/login')
            }
            else{
                setMessage('Kayıt başarısız. Kod: ' + response.status)
            }
        }
        catch(error){
            setMessage('HATA! : ' + error)
        }
    }

    return(
        <div className="auth-page">
            <div className="auth-card">
                <div className="auth-avatar">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
                        <circle cx="10" cy="8" r="4" />
                        <path d="M2 20c0-4.4 3.6-7 8-7s8 2.6 8 7" />
                        <path d="M19 8v6M16 11h6" />
                    </svg>
                </div>

                <h2 className="auth-title">Kayıt ol</h2>

                <div className="auth-form">
                    <div className="auth-field">
                        <label className="sr-only" htmlFor="register-email">Email</label>
                        <span className="auth-field-icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
                                <rect x="3" y="5" width="18" height="14" rx="2" />
                                <path d="M3 7l9 6 9-6" />
                            </svg>
                        </span>
                        <input
                            id="register-email"
                            type="email"
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                        />
                    </div>

                    <div className="auth-field">
                        <label className="sr-only" htmlFor="register-password">Şifre</label>
                        <span className="auth-field-icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
                                <rect x="5" y="11" width="14" height="9" rx="2" />
                                <path d="M8 11V8a4 4 0 018 0v3" />
                            </svg>
                        </span>
                        <input
                            id="register-password"
                            type="password"
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                        />
                    </div>

                    <button className="auth-button" onClick={handleRegister}>
                        Kayıt Ol
                    </button>
                </div>

                <p className="auth-message">{message}</p>
                <p className="auth-footer">Zaten hesabın var mı? <Link to="/login">Giriş yap</Link></p>
            </div>
        </div>
    )
}

export default Register