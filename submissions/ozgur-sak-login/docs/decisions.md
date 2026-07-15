# Teknik Kararlar

Bu dosya, projede aldığım teknik kararları ve gerekçelerini içerir.

## Backend: ASP.NET Core (C#)
Java/Spring Boot tecrübem C#'a doğrudan taşındı. Ayrıca Problem Details
(RFC 9457) ve rate limiting framework'te hazır geliyor, ekstra paket gerekmedi.

## Kullanıcı ID'si: Guid
Sıralı int yerine Guid seçtim. Tahmin edilemez olduğu için kullanıcı
enumerasyonunu zorlaştırır (/users/1, /users/2 diye denenemez).

## Şema yönetimi: EF Core Migrations
Hibernate'in ddl-auto=update yaklaşımı yerine migration kullandım.
Şema değişiklikleri versiyonlanır ve geri alınabilir, production'a uygun.

## Bağımlılık güvenliği: Microsoft.OpenApi 2.9.0
.NET 10 şablonu dolaylı olarak güvenlik açıklı 2.0.0 getirdi
(CVE-2026-49451, DoS). NuGet denetimi (NU1903) restore'da yakaladı,
yamalı 2.9.0'a yükselttim.

## API cevabında şifre/hash dönülmüyor
AuthResponse DTO'sunda Password veya PasswordHash alanı yok. Kullanıcının
şifresini veya hash'ini hiçbir API cevabında döndürmeyiz. Gelen ve dönen
DTO'ları bu yüzden ayrı tuttum (RegisterRequest vs AuthResponse).

## Şifre saklama: bcrypt hash
Şifreler bcrypt ile hash'lenerek saklanıyor, düz metin veya çözülebilir
şifreleme değil. Veritabanı çalınsa bile şifreler geri elde edilemez.

## Login hata mesajı: kasıtlı olarak muğlak
"Email bulunamadı" ile "şifre yanlış" ayrı ayrı söylenmiyor, ikisine de
"Invalid email or password" dönüyor. Bu, saldırganın hangi email'lerin
kayıtlı olduğunu öğrenmesini (user enumeration) engeller.

## Hata yönetimi: merkezi + Problem Details (RFC 9457)
Her endpoint'te try-catch yerine tek bir global exception handler kullandım.
Kendi exception tiplerim (ConflictException, UnauthorizedException) doğru
HTTP kodlarına (409, 401) çevriliyor ve application/problem+json formatında
dönüyor. Spec'in istediği RFC 9457 standardı.

## JWT: kısa ömürlü access token
Access token 15 dakika geçerli. Çalınsa bile zarar sınırlı. JWT gizli
anahtarla imzalanıyor, sahte token üretilemez. (Refresh token akışı sonra.)

## Swagger + OpenApi 2.x uyumsuzluğu
Swashbuckle 10.x, Microsoft.OpenApi 2.x ile AddSecurityRequirement'ı
sessizce yok sayıyordu (security bölümü swagger.json'a yazılmıyordu).
Çözüm: IDocumentFilter ile security requirement'ı dokümana elle ekledim.
CVE düzeltmesi için yükselttiğimiz OpenApi 2.9.0'ı korudum.

## Logout: geçersiz token'da da 204
Logout, token geçerli olsun olmasın 204 döner. İki sebep:
1 => Logout niyeti her durumda karşılanır — token zaten geçersizse bile
    kullanıcının amacı (oturum yok) gerçekleşmiştir.
2 => Token geçerli veya geçersiz ayrımı bilgi sızdırır; login'deki
    muğlak hata mesajıyla tutarlı bir güvenlik duruşu tercih ettim.
Alternatif (geçersizde 401 dönmek) daha dürüst fakat saldırganın
hangi token'ların geçerli olduğunu anlamasına yol açar.

## Secret yönetimi: user-secrets (local) + .env (Docker)
**Başta appsettings.json'da tutuyordum, "geçici" diye not düşmüştüm — bu iş o notun karşılığı.**
.NET'in config sistemi katmanlıdır. appsettings.json => appsettings.{Env}.json =>
user-secrets (sadece Development) => environment variables. Bir sonraki katman öncekini ezer.
Kod her zaman Configuration'dan okuduğu için değerin hangi katmandan geldiğini bilmiyor.
Bu yüzden TokenService'teki okuma satırına hiç dokunmadım. Program.cs'te sadece fail-fast 
kontrolü ekledim, okuma şekli aynı kaldı.Kendi makinemde çalışırken user-secrets kullanıyorum.
Bunun güzel tarafı değerlerin proje klasörünün içinde hiç durmaması. Bilgisayarımda başka bir yerde tutuluyorlar.
Yani yanlışlıkla commit'lemem mümkün değil, çünkü git'in baktığı yerde öyle bir dosya yok.
Docker'da ise user-secrets çalışmıyor, container o klasörü göremiyor. Orada
.env dosyasından besleniyoruz. Zaten spec'te ".env ile secret yönetimi" deniyor.

## JWT key rotation
Eski key commit edilmişti. Dosyadan silmek yetmiyor, git eski halleri saklıyor.
Bir kere commit'lenirse o key artık herkesin. Tek çözüm yenisini üretmek; eskisi
geçmişte kalıyor ama artık hiçbir token'ı doğrulamadığı için değersiz.
Geçmişi temizlemeyi (filter-repo) yapmadım: tüm commit'lerin kimliği değişir,
merge edilmiş PR'lar bozulur, Nisa'nın klonu çöpe gider. Dev ortamı key'i için değmez.

## Key üretimi: Get-Random değil, RandomNumberGenerator
Get-Random rastgele görünen ama hesaplanabilir sayılar üretiyor. İmzalama key'i
tahmin edilebilirse saldırgan istediği kullanıcı adına token uydurur. 32 byte,
çünkü HS256 arka planda SHA-256 kullanıyor ve çıktısı 32 byte.

## Fail-fast: key yoksa açılışta patla
appsettings.json'da anahtarı silmedim, boşalttım. "Bu ayar var, değerini dışarıdan
ver" demek için. Ama boş string'le uygulama sorunsuz açılıp ilk login'de anlaşılmaz
bir 500 verirdi. Hatanın sebebinden uzakta çıkması en kötüsü. Şimdi açılışta
patlıyor ve mesaj hangi komutu çalıştıracağını da söylüyor.

## Bilinen tradeoff: devpassword iki yerde
Postgres şifresi hem .env'de hem user-secrets'taki connection string'in içinde.
Değişirse iki yeri de güncellemek lazım. Connection string'i kodda parçalardan
birleştirebilirdim ama bu proje için gereksiz karmaşıklık. Bilinçli tercih.