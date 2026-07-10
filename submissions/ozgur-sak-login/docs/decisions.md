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