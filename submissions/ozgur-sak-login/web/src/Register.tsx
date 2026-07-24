import { useState } from 'react'
import { useNavigate } from 'react-router-dom'

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
        <div>
            <h2>Kayıt ol</h2>
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

            <button onClick={handleRegister}>
                Kayıt Ol
            </button>

            <p>{message}</p>
        </div>
    )
}

export default Register