# Test Planı — Auth Akışı

Bu belge Login System'in test kapsamını, mevcut testleri ve bilinen boşlukları
tanımlar.

## Test Piramidi

| Katman | Araç | Ne test eder | Durum |
|---|---|---|---|
| Entegrasyon (API) | xUnit + WebApplicationFactory | Gerçek Postgres'e karşı HTTP istek/cevap | Tamamlandı - 5 test |
| E2E (Web) | Playwright | Tarayıcıda tam kullanıcı akışı | Tamamlandı - 4 test (Chromium/Firefox/WebKit) |
| E2E (Mobil) | Maestro | Emülatörde tam kullanıcı akışı | Tamamlandı - Nisa tarafından yazıldı (login_flow.yaml, register_flow.yaml) |

## Test Senaryoları

### Kimlik Doğrulama - Mutlu Yol

| # | Senaryo | Beklenen | Kapsam |
|---|---|---|---|
| 1 | Yeni kullanıcı kaydı | 201, kullanıcı oluşur | Register_Login_Me_ReturnsUser |
| 2 | Doğru bilgilerle giriş | 200, access + refresh token döner | Register_Login_Me_ReturnsUser |
| 3 | Geçerli token ile korumalı endpoint | 200, kullanıcı bilgisi döner | Register_Login_Me_ReturnsUser |
| 4 | Refresh ile yeni token çifti | 200, yeni access + yeni refresh | Refresh_ReturnsNewTokens |
| 5 | Şifre değiştirme sonrası yeni şifreyle giriş | 200 | ChangePassword_ThenLoginWithNewPassword_Works |

### Kimlik Doğrulama - Hata Yolları

| # | Senaryo | Beklenen | Kapsam |
|---|---|---|---|
| 6 | Yanlış şifreyle giriş | 401, muğlak mesaj (kullanıcı var mı sızdırılmaz) | Login_WithWrongPassword_Returns401 |
| 7 | Kayıtlı e-posta ile tekrar kayıt | 409 | Register_WithExistingEmail_Returns409 |
| 8 | Token'sız korumalı endpoint | 401 | Kapsanmadı |
| 9 | Geçersiz/bozuk token | 401 | Kapsanmadı (manuel doğrulandı) |
| 10 | Süresi dolmuş access token | 401, ardından refresh ile kurtarma | Kapsanmadı - bkz. Bilinen Boşluklar |
| 11 | Geçersiz refresh token | 401 | Kapsanmadı |
| 12 | Rate limit aşımı (aynı IP / aynı e-posta) | 429 + Retry-After | Kapsanmadı |

### Web Client - E2E

| # | Senaryo | Beklenen | Kapsam |
|---|---|---|---|
| 13 | Kayıt formundan yeni kullanıcı -> giriş sayfasına yönlendirme | /login'e düşer | login.spec.ts |
| 14 | Giriş -> profil sayfasına yönlendirme, e-posta görünür | /profile, e-posta ekranda | login.spec.ts |
| 15 | Token'sız /profile erişimi | /login'e yönlendirilir (route guard) | login.spec.ts |
| 16 | Çıkış yap | token'lar silinir, /login'e döner | login.spec.ts |
| 17 | Bozuk access token ile sayfa yenileme | interceptor otomatik refresh yapar, sayfa normal yüklenir | Kapsanmadı (manuel doğrulandı) |

## Test Ortamı

Entegrasyon testleri WebApplicationFactory ile API'yi bellek içinde ayağa
kaldırır, gerçek bir PostgreSQL veritabanına bağlanır. Her test kendi
veritabanını oluşturur ve sonunda siler - testler birbirini etkilemez, sıralı
çalıştırma zorunluluğu yoktur.

Çalıştırma:

cd backend
dotnet test


## Bilinen Boşluklar

Süresi dolmuş token (senaryo 10): Access token 15 dakika ömürlü olduğu için
gerçek zamanlı beklemek pratik değil. Otomatik test için ya token ömrü teste
özel kısaltılmalı ya da saat (clock) enjekte edilebilir hale getirilmeli.
Şu an manuel olarak doğrulandı: localStorage'daki access token bozulup sayfa
yenilendiğinde Network sekmesinde me -> 401, refresh -> 200, me -> 200
zinciri gözlendi.

Rate limiting (senaryo 12): Test edilirse sonraki testler aynı limite
takılabilir; izole etmek için limiter'ın test ortamında yeniden ayarlanabilir
olması gerekir.

Refresh token tek kullanımlık invalidation: Rotation çalışıyor ama kullanılan
refresh token anında geçersiz kılınmıyor; kısa bir pencerede tekrar kabul
edilebiliyor. Ayrıntı için decisions.md.


## CI

Backend testleri ve web E2E testleri her pull request'te GitHub Actions
üzerinde otomatik çalışır (`.github/workflows/backend-tests.yml`). Postgres
servis konteyneri ile gerçek veritabanına karşı test ediliyor; web job'ı
backend'i CI içinde ayrıca ayağa kaldırıp test kullanıcısını seed ediyor.

Mobil testler (Maestro) şu an CI'da çalışmıyor — emülatör gerektirdiği için
ayrı bir kurulum gerekiyor, ileriye dönük iyileştirme olarak not edildi.