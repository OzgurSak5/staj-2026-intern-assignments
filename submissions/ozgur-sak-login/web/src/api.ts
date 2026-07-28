export async function apiFetch(url: string, options: RequestInit = {}) {
    const accessToken = localStorage.getItem('accessToken')

    let response = await fetch(url, {
        ...options,
        headers: {
            ...options.headers,
            'Authorization': `Bearer ${accessToken}`,
        },
    })

    if (response.status !== 401) {
        return response
    }

    const refreshToken = localStorage.getItem('refreshToken')

    const refreshResponse = await fetch('http://localhost:5075/auth/refresh', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refreshToken }),
    })

    if (!refreshResponse.ok) {
        localStorage.clear()
        window.location.href = '/login'
        return response
    }

    const data = await refreshResponse.json()
    localStorage.setItem('accessToken', data.accessToken)
    localStorage.setItem('refreshToken', data.refreshToken)

    response = await fetch(url, {
        ...options,
        headers: {
            ...options.headers,
            'Authorization': `Bearer ${data.accessToken}`,
        },
    })

    return response
}