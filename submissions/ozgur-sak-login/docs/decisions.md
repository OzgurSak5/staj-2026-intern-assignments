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

## Connection string konumu (geçici)
Şu an appsettings.json'da. Dev şifresi gerçek bir sır değil ama
gerçek deployment öncesi user-secrets / ortam değişkenlerine taşınacak,
böylece git'e hiç girmez.

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