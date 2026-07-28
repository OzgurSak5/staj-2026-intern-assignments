# Web Client (React + TypeScript)

Login System'in web arayüzü. Backend'in beş auth endpoint'ini de kullanır.

## Çalıştırma

Önce backend ayakta olmalı (bkz. `../README.md`). Backend `localhost:5075`'te
çalışıyor olmalı, çünkü web client oraya istek atıyor.

```bash
cd web
npm install
npm run dev
```

Uygulama `http://localhost:5173` adresinde açılır.

> **Windows/PowerShell notu:** script politikası nedeniyle `npm` yerine
> `npm.cmd` kullanmak gerekebilir (`npm.cmd install`, `npm.cmd run dev`).

## Sayfalar

| Rota | Sayfa | Korumalı |
|------|-------|----------|
| `/login` | Giriş | Hayır |
| `/register` | Kayıt | Hayır |
| `/profile` | Profil | Evet |

## Dosya Yapısı
src/
|── App.tsx → React Router yapısı
├── Login.tsx → giriş formu
├── Register.tsx → kayıt formu
├── Profile.tsx → korumalı profil sayfası + çıkış
├── ProtectedRoute.tsx → route guard (token yoksa /login'e yönlendirir)
├── api.ts → apiFetch: 401'de otomatik token yenileme
├── App.css → tasarım (Crimson Minimalist)
└── assets/ → arka plan görseli

## Token Yönetimi

Access ve refresh token `localStorage`'da tutulur.

**Otomatik yenileme (`api.ts`):** Korumalı endpoint'lere `apiFetch` ile gidilir.
Bu fonksiyon isteğe `Authorization: Bearer <access>` header'ını ekler. İstek `401`
dönerse:

1. `localStorage`'daki refresh token ile `/auth/refresh` çağrılır
2. Dönen **yeni access ve yeni refresh** token'ları kaydedilir (rotation)
3. Orijinal istek yeni access token ile tekrarlanır

Refresh de başarısız olursa (refresh token da ölmüşse) `localStorage` temizlenir
ve kullanıcı `/login`'e yönlendirilir.

**Route guard (`ProtectedRoute.tsx`):** Token yoksa korumalı sayfa hiç render
edilmez, doğrudan `/login`'e yönlendirilir — API'ye gereksiz istek atılmaz.

## Tasarım

Tasarım [Google Stitch](https://stitch.withgoogle.com) ile üretildi ("Crimson
Minimalist" teması), Stitch MCP sunucusu Claude Code'a bağlanarak koda aktarıldı.
Renk paleti, tipografi (Inter) ve arka plan görseli ekran görüntüsünden tahmin
edilmek yerine doğrudan tasarım kaynağından alındı.

Mobil client ile aynı tasarım dili kullanılır.

## Teknoloji Gerekçesi

- **React + TypeScript:** TypeScript tip güvenliği sağlıyor; mobil tarafta
  OpenAPI codegen kullanıldığı için web'de de tipli bir dil tercih edildi.
- **Vite:** hızlı dev sunucusu ve hot reload.
- **React Router:** sayfa yönlendirme ve route guard.
- **Çıplak `fetch` + wrapper:** ayrı bir HTTP kütüphanesi (axios vb.) yerine
  `fetch` üstüne ince bir `apiFetch` sarmalayıcı yazıldı — token yenileme
  mantığının nasıl çalıştığı açıkça görülüyor.

## Bilinen Sınırlamalar

- Token'lar `localStorage`'da tutuluyor; XSS'e karşı `httpOnly` cookie kadar
  güvenli değil. Gerekçe ve trade-off için `../docs/decisions.md`.
- API tipleri elle yazıldı; mobil tarafta OpenAPI codegen kullanılıyor.
- Form doğrulaması react-hook-form/zod yerine tarayıcının native HTML5
  doğrulamasıyla yapılıyor; küçük form sayısı (3 form) için ek kütüphane
  getirisi düşük görüldü, zaman kısıtı içinde bilinçli bir kapsam kararı.