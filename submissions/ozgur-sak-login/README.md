# Login System (2026)

VBT stajı kapsamında geliştirilen kimlik doğrulama (authentication) sistemi.
Backend .NET ile yazıldı; web ve mobil client'lar aynı API'yi kullanır.

## Takım

- **Ozgur SAK** — Backend (.NET) + Web (React)
- **Nisa Peri Aksoy** — Mobil (Flutter)

## Mimari

```
backend/   → ASP.NET Core Web API (.NET 10) + PostgreSQL
web/       → React web client        (Ozgur)
mobile/    → Flutter mobil client     (Nisa)
docs/      → Kararlar ve notlar
```

Her iki client de aynı backend API'sine bağlanır. Backend bir kez yazıldı;
web ve mobil onu ortak kullanır.

---

## Backend'i Çalıştırma

### Gereksinimler

- [.NET 10 SDK](https://dotnet.microsoft.com/download)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)

### Adımlar

```bash
# 1. Repoyu klonla
git clone https://github.com/OzgurSak5/staj-2026-intern-assignments.git
cd staj-2026-intern-assignments/submissions/ozgur-sak-login/backend

# 2. PostgreSQL'i başlat (Docker)
docker compose up -d

# 3. Veritabanı şemasını oluştur (migration'ları uygula)
cd Auth.Api
dotnet ef database update

# 4. API'yi çalıştır
dotnet run
```

API çalışınca:

- **Swagger UI:** http://localhost:5075/swagger
- **API kök:** http://localhost:5075

> `dotnet ef` komutu yoksa: `dotnet tool install --global dotnet-ef`

---

## API Endpoint'leri

Tüm istek/cevaplar JSON. Base URL: `http://localhost:5075`

### `POST /auth/register`
Yeni kullanıcı kaydı.

**İstek:**
```json
{ "email": "user@example.com", "password": "sifre12345" }
```
**Cevap (201):**
```json
{ "userId": "guid", "email": "user@example.com" }
```
Hata: e-posta zaten kayıtlıysa `409`.

---

### `POST /auth/login`
Giriş yapar, access + refresh token döner.

**İstek:**
```json
{ "email": "user@example.com", "password": "sifre12345" }
```
**Cevap (200):**
```json
{
  "accessToken": "eyJ...",
  "refreshToken": "base64string",
  "expiresInSeconds": 900
}
```
Hata: yanlış e-posta/şifre → `401` (mesaj kasıtlı olarak muğlaktır).

---

### `GET /auth/me`
Giriş yapmış kullanıcının bilgisini döner. **Token gerektirir.**

**Header:**
```
Authorization: Bearer <accessToken>
```
**Cevap (200):**
```json
{ "userId": "guid", "email": "user@example.com" }
```
Hata: token yok/geçersiz/süresi dolmuş → `401`.

---

### `POST /auth/refresh`
Access token'ın süresi dolunca yeni bir çift alır. **Rotation:** eski
refresh token iptal edilir, yenisi verilir.

**İstek:**
```json
{ "refreshToken": "base64string" }
```
**Cevap (200):** login ile aynı format (yeni access + yeni refresh).
Hata: geçersiz/iptal/süresi dolmuş refresh → `401`.

---

### `POST /auth/logout`
Refresh token'ı iptal eder (oturumu kapatır).

**İstek:**
```json
{ "refreshToken": "base64string" }
```
**Cevap:** `204 No Content` (token geçerli olmasa da 204 döner).

---

## Token Akışı (mobil/web için önemli)

1. `login` → access (15 dk) + refresh (7 gün) al
2. Her istekte `Authorization: Bearer <access>` gönder
3. Access token 15 dk sonra `401` verir → `refresh` ile yeni çift al
4. Yeni access ile isteği tekrarla
5. `logout` → refresh token iptal, oturum kapanır

Client tarafında otomatik yenileme (interceptor) önerilir: bir istek `401`
alınca `refresh` çağır, yeni access ile isteği tekrarla.

---

## Güvenlik Notları

- Şifreler **bcrypt** ile hash'lenir (düz metin saklanmaz).
- Refresh token DB'de **SHA-256 hash** olarak saklanır; ham token yalnızca client'ta.
- Access token JWT, gizli anahtarla imzalanır; sahte token üretilemez.
- Detaylı kararlar için `docs/decisions.md`.

---

## Teknoloji Seçimleri

- **ASP.NET Core (.NET 10):** Problem Details ve rate limiting framework'te hazır.
- **PostgreSQL + EF Core:** ORM + migration ile versiyonlanan şema.
- **JWT + bcrypt:** standart, güvenli kimlik doğrulama.

Ayrıntılı gerekçeler: `docs/decisions.md`