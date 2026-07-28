# Skills

## /endpoint

### Neden yaptım
Projede 5 auth endpoint'i (register, login, me, refresh, logout) yazdım ve her
seferinde aynı 5 adımı tekrarladım: DTO oluştur, AuthService'e iş mantığı metodu
ekle, controller action yaz, gerekiyorsa exception eşle, testle kapsa. Bu tekrarı
docs/repetitions.md'ye not etmiştim. Aynı adımları altıncı kez elle yazmak yerine
skill'e çevirdim.

### Nasıl çağrılır
Claude Code içinde, doğal dille yeni bir endpoint iste:

    change-password endpoint'i ekle. Eski şifre ve yeni şifre alsın, doğruysa güncellesin.

Skill'in description'ı "yeni endpoint ekleme" niyetini yakalayıp otomatik devreye
giriyor. Ayrı bir komut yazmaya gerek yok.

### Örnek çıktı
change-password endpoint'ini eklerken skill'i çalıştırdım. Ürettiği kod:
- `Dtos/ChangePasswordRequest.cs` — positional record, [Required] + [MinLength(8)]
- `AuthService.ChangePasswordAsync` — bcrypt ile eski şifreyi doğrula, yeni hash'i yaz
- `AuthController` action — [Authorize], [ProducesResponseType(204/401)], ince (iş
  mantığı yok)
- Yeni exception gerekmedi; mevcut UnauthorizedException kullanıldı

Bu endpoint şu an projede çalışıyor, entegrasyon testiyle kapsandı (5/5 test yeşil).

### Neden işe yaradı
Skill sadece kod üretmedi, projenin kararlarını da uyguladı: şifre asla düz
saklanmıyor, hata mesajları user enumeration'a karşı muğlak, controller ince
tutuluyor, response'ta hassas alan dönülmüyor. Yani yeni bir endpoint yazan biri
(ben üç hafta sonra, ya da takım arkadaşım) bu güvenlik kararlarını hatırlamak
zorunda kalmadan otomatik uyguluyor. decisions.md'deki kuralları çalıştırılabilir
hale getiriyor. Skill login'e özel değil; herhangi bir yeni endpoint için aynı  
adımları uyguluyor (change-password, delete-account,verify-email gibi).