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

## Rate limiting: iki sayaç, iki katman
IP sayacı middleware'de ve her 5 dakikada bir 20 deneme izin veriyor. Email sayacı AuthService'te
her 5 dakikada bir 5 deneme. Sebebi teknik, IP HttpContext'te hazır duruyor. Email ise istek
gövdesinde ve gövde bir kere okunuyor. Middleware'de gövdeyi okursam model binding'e bir şey kalmaz.
Her sayaç, ihtiyacı olan bilginin zaten hazır olduğu katmanda.
Tek başına IP dağıtık saldırıyı kaçırır. Tek başına email credential stuffing'i kaçırır
(saldırgan her hesaba 1 deneme yapar, limit hiç dolmaz). İkisi birbirinin açığını kapatıyor.

## Sliding window, fixed window değil
Fixed window'da pencere sınırında iki kat burst mümkün: 12:04:59'da 5 istek, 12:05:01'de 5
daha, iki pencere de kurallara uymuş görünür. bcrypt yavaş olduğu için bu CPU spike'ı demek.
Token bucket burst'e izin vermek üzere tasarlanmış, login'de istemediğim şey tam da o.
Concurrency hızı değil eşzamanlılığı ölçüyor, sıralı istekleri hiç yakalamaz.

## Email sayacı sadece başarısızlıkları sayıyor
Başarılı login, hesabın sahibinin geldiğinin kanıtıdır. Saldırı sayacına yazmak anlamsız.
Çünkü meşru kullanıcı ne kadar girip çıkarsa çıksın kilitlenmiyor.
Bedeli: önce peek (permitCount: 0) sonra başarısızsa tüket. İki ayrı işlem, arada yarış var
(TOCTOU) — eşzamanlı istekler limiti biraz aşabilir. IP sayacı hacmi zaten kıstığı için
kabul ettim.

## Sayaçlar bellekte, süreç başına
Tek instance çalıştığım için sorun değil. İki container'da çalışsa iki ayrı sayaç olur,
limit fiilen ikiye katlanır. Ölçeklenirse Redis gibi paylaşımlı bir sayaç lazım.

## Retry-After: metadata yoksa 60
Sliding window bu metadata'yı her durumda vermiyor, tüm istekler tek segmente sıkışınca
tahmin üretemiyor, yani en çok lazım olduğu anda yok. Fallback pencere/segment = 60 saniye.
Saldırgana ne zaman devam edeceğini söylüyor ama HTTP standardı bu header'ı bunun için
tanımlamış, meşru client'a faydası daha büyük.

## Log seviyeleri: başarısız login Information, rate limit Warning
Her başarısız login bir tehlike değil. Kullanıcı şifresini yanlış yazmıştır, günde
binlerce kez olur. Bunlara Warning dersem o kanal çöpe döner, gerçek bir saldırı geldiğinde
aralarında kaybolur. Tehlike sinyali "şifre yanlış" değil, "bu hesaba beş kez üst üste yanlış 
girildi".Yani limiter'ın tetiklenmesi. Zaten limiter'ın işi gürültüyle sinyali ayırmak.
Şifreyi loglamıyorum. Email'i logluyorum: log'ları görebilen biri hangi hesapların
kayıtlı olduğunu da görür, ama saldırıyı hiç fark edememek daha kötü.

## Email normalizasyonu: ToLowerInvariant
Register ve login'de email'i trim'leyip küçük harfe çeviriyorum. Öncesinde Postgres
karşılaştırmayı büyük/küçük harfe duyarlı yaptığı için TEST@x.com ile test@x.com iki
ayrı kullanıcıydı insan kendi hesabına giremiyordu.
ToLower() değil ToLowerInvariant(): Türkçe'de I'nin küçüğü ı. ToLower() makinenin dil
ayarına baktığı için aynı kod bende başka, Nisa'da başka sonuç verebilirdi. Türkçe
Windows'tayım, bu teorik bir risk değil. Rate limiter da aynı fonksiyonu çağırıyor. 
Çağırmasaydı saldırgan harf büyüklüğünü değiştirerek her varyasyona ayrı bir kova açtırır,
sayacı işe yaramaz hale getirirdi.

## IExceptionHandler: lambda handler'ı sınıfa taşıdım
Handler Program.cs'te çalışan bir lambda'ydı. Sorun şu ki, .NET 10 handler handle etmiyorsa
Error loglamayayım diyor, ama bunu sadece DI'a kayıtlı bir IExceptionHandler için yapıyor.
Lambda o arayüzü uygulamadığı için framework onu handler saymıyordu. Her 401'i, her 409'u
tam stack trace'le Error olarak logluyordu. Beş başarısız login = 120 satır gürültü.
Sınıfa taşıyınca framework doğru sinyali aldı, gürültü bitti.

## Bilinmeyen exception'da false dönüyorum
true = "ben hallettim, sen karışma". Postgres çökerse true dersem framework loglamayı bırakır
En çok bilgiye ihtiyacım olan anda hiçbir şey yapamam. false diyorum çünkü framework normal hata yoluna
düşüyor, stack trace'i tutuyor. Bedava gelen kazanç ise false dönünce cevabı ben yazmıyorum.
Yani eskiden istemciye giden (exception.Message) artık gitmiyor. Npgsql'in mesajı host/DB/kullanıcı adı içerebiliyordu.
bildiğimi ele aldım, bilmediğime karışmadım.

## UseStatusCodePages: çıplak 401'i de Problem Details'e çevirdim
[Authorize] başarısız olunca JWT middleware boş gövdeli 401 dönüyordu — orada exception
fırlamadığı için handler'a hiç uğramıyor. Client bazen JSON bazen boş gövde görürse iki
tarafta da özel durum yazmak gerekir. AddProblemDetails() zaten kayıtlıydı, eksik olan
tetikleyiciydi.