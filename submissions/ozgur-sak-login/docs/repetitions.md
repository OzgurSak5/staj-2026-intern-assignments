# Tekrar Eden İşler

3+ kez yaptığım işleri buraya not ediyorum. Faz sonunda bunlar skill'e dönüşecek.

## Yeni endpoint ekleme (4+ kez yapıldı)
Her endpoint için aynı adımlar:
1. Dtos/ altına request + response DTO
2. AuthService'e async iş mantığı metodu (DB + exception fırlatma)
3. AuthController'a [HttpPost/Get] endpoint
4. Program.cs'e servis kaydı (gerekirse)
5. dotnet build + Swagger'da test
* Skill adayı: /endpoint (controller+service+dto+test iskeleti üreten)

## Exception → HTTP kodu eşleme
Her yeni hata türü için: AppExceptions.cs'e sınıf + Program.cs switch'e satır.
* Belki aynı skill'in parçası.

## Güvenlik kontrolü (tekrarlayan düşünce)
Her endpoint'te: şifre/hash sızıyor mu, hata mesajı bilgi veriyor mu,
token doğrulanıyor mu.
* Skill adayı: security-review agent (auth kodunu OWASP açısından tarar)