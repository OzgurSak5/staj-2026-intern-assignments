---
name: endpoint
description: Yeni bir auth endpoint'i eklerken DTO, AuthService metodu, controller action, exception eşlemesi ve Swagger dokümantasyonunu proje konvansiyonlarına uygun üretir. Kullanıcı yeni bir endpoint eklemek istediğinde tetiklenir.
---

# /endpoint

Bu projede yeni bir auth endpoint'i eklemek her seferinde aynı adımları içeriyor. Bu skill, bu adımları
otomatikleştirerek geliştiricinin işini kolaylaştırır.

## Ne zaman kullanılır?

Kullanıcı yeni bir endpoint eklemek istediğinde, örneğin:
- "change-password endpoint'i ekle"
- "hesabı silen bir endpoint yaz"
- "email doğrulama endpoint'i ekle"

## Ne üretilir?

1. Gerekiyorsa `Dtos/` altına request/response DTO(ları)
2. `AuthService`'e async iş mantığı metodu
3. `AuthController`'a action + `[ProducesResponseType]` attribute'ları
4. Yeni bir hata türü gerekiyorsa exception sınıfı + handler eşlemesi
5. `dotnet build` + Swagger'da doğrulama hatırlatması

## AuthService (`Services/AuthService.cs`)

İş mantığı burada. Her metot `public async Task<T>`, HTTP'den habersiz bir
şekilde iş yapar, sonuç döner veya exception fırlatır. HTTP kodlarını bilmez.

Şablon:

    public async Task<AuthResponse> RegisterAsync(RegisterRequest request)
    {
        var email = NormalizeEmail(request.Email);

        var emailExists = await _db.Users.AnyAsync(u => u.Email == email);
        if (emailExists)
        {
            throw new ConflictException("Email already exists.");
        }

        var passwordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);

        var user = new User
        {
            Id = Guid.NewGuid(),
            Email = email,
            PasswordHash = passwordHash
        };

        _db.Users.Add(user);
        await _db.SaveChangesAsync();

        return new AuthResponse(user.Id, user.Email);
    }

Kurallar:
- Email ile çalışan her metot önce `NormalizeEmail(request.Email)` çağırır
  (trim + ToLowerInvariant). Aksi halde büyük/küçük harf tutarsızlığı ve
  rate limiter bypass'ı oluşur.
- Beklenen hata durumları exception ile bildirilir: bulunamadı/geçersiz ->
  `UnauthorizedException`, çakışma -> `ConflictException`, çok istek ->
  `TooManyRequestsException`. Bu exception'ları `GlobalExceptionHandler`
  HTTP koduna çevirir — servis HTTP kodu döndürmez.
- Şifre her zaman `BCrypt.Net.BCrypt.HashPassword` ile hash'lenir, asla düz saklanmaz.
- Login'de hata mesajı kasıtlı muğlak: "Invalid email or password" (user
  enumeration'ı önler).
- DB'ye yazınca `await _db.SaveChangesAsync()`.

## Controller (`Controllers/AuthController.cs`)

Action ince tutulur. DTO'yu alır, `AuthService`'i çağırır, sonucu döndürür.
İş mantığı YOK! O `AuthService`'te. Try-catch YOK! Exception'ları
`GlobalExceptionHandler` yakalar.

Dönüş tipi `Task<ActionResult<T>>` (T = response DTO'su). `IActionResult`
değil. Çünkü `ActionResult<T>` Swagger'a başarı gövdesinin tipini söyler.

Her action mümkün olan HTTP kodlarını `[ProducesResponseType]` ile belgeler,
yoksa OpenAPI şeması eksik kalır ve client codegen tipleri üretemez.

Şablon:

    [HttpPost("register")]
    [ProducesResponseType(StatusCodes.Status201Created, Type = typeof(AuthResponse))]
    [ProducesResponseType(StatusCodes.Status409Conflict, Type = typeof(ProblemDetails))]
    public async Task<ActionResult<AuthResponse>> Register([FromBody] RegisterRequest request)
    {
        var response = await _authService.RegisterAsync(request);
        return Created($"/users/{response.UserId}", response);
    }

Kurallar:
- Başarı kodu action'ın döndürdüğü şeyle eşleşmeli: `Ok(...)` → 200,
  `Created(...)` → 201, `NoContent()` -> 204.
- Her fırlatılabilen exception'ın HTTP karşılığı ayrı bir
  `[ProducesResponseType(..., Type = typeof(ProblemDetails))]` satırı alır.
- Korumalı endpoint'ler `[Authorize]` taşır (ör. `/me`). Bunlar ayrıca
  401 için `[ProducesResponseType]` ekler.
- Class seviyesinde zaten `[Produces("application/json")]` ve 400 için
  `ValidationProblemDetails` tanımlı action'da tekrar etme.


## Yeni hata türü (`Exceptions/AppExceptions.cs` + `GlobalExceptionHandler.cs`)

Endpoint yeni bir beklenen hata durumu getiriyorsa (mevcut 401/409/429
yetmiyorsa), iki yere dokunulur.

Önce exception sınıfı -> hepsi aynı kalıp, `Exception`'dan türer:

    // 403
    public class ForbiddenException : Exception
    {
        public ForbiddenException(string message) : base(message) { }
    }

Sonra `GlobalExceptionHandler.TryHandleAsync` içindeki switch'e bir satır:

    ForbiddenException => (StatusCodes.Status403Forbidden, "Forbidden"),

Kurallar:
- Bilinen exception'lar switch'te HTTP koduna eşlenir. Bilinmeyenler `(0, "")`
  döner ve handler `false` verir. Framework onları gerçek hata olarak
  loglar, mesajları istemciye sızmaz.
- Mevcut hata durumu için yeni exception ekleme; var olanı kullan
  (bulunamadı/geçersiz -> `UnauthorizedException`, çakışma -> `ConflictException`).
- Yeni exception eklendiyse, onu fırlatan endpoint'in controller'ına
  karşılık gelen `[ProducesResponseType]` satırı da eklenir.

## Doğrulama (her endpoint sonrası)

1. `dotnet build` — derleme temiz mi.
2. Endpoint'i `Auth.Api.Tests`'e bir entegrasyon testiyle kapsa:
  `WebApplicationFactory` ile gerçek HTTP isteği at, durum kodunu ve
  gövdeyi doğrula. Her test benzersiz email kullanır (`UniqueEmail()`).
3. `dotnet test` — testler yeşil mi.
4. Swagger'da (`/swagger`) endpoint'in göründüğünü ve doğru yanıt
  tiplerini belgelediğini kontrol et.


## Tam örnek

Kullanıcı: "change-password endpoint'i ekle. Eski şifre + yeni şifre alsın,
doğruysa güncellesin."

Üretilecekler:

1. `Dtos/ChangePasswordRequest.cs`:

        using System.ComponentModel.DataAnnotations;

        namespace Auth.Api.Dtos;

        public record ChangePasswordRequest(
            [Required] string OldPassword,
            [Required, MinLength(8)] string NewPassword
        );

2. `AuthService`'e metot (JWT'den kullanıcıyı bulur, eski şifreyi doğrular,
   yeni hash'i yazar):

        public async Task ChangePasswordAsync(Guid userId, ChangePasswordRequest request)
        {
            var user = await _db.Users.FindAsync(userId);
            if (user is null || !BCrypt.Net.BCrypt.Verify(request.OldPassword, user.PasswordHash))
            {
                throw new UnauthorizedException("Invalid credentials.");
            }

            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
            await _db.SaveChangesAsync();
        }

3. `AuthController`'a action ([Authorize], çünkü giriş yapmış kullanıcı):

        [Authorize]
        [HttpPost("change-password")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized, Type = typeof(ProblemDetails))]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request)
        {
            var userId = Guid.Parse(User.FindFirst(JwtRegisteredClaimNames.Sub)!.Value);
            await _authService.ChangePasswordAsync(userId, request);
            return NoContent();
        }

4. Yeni exception gerekmez. Mevcut `UnauthorizedException` yeterli.

5. Test: register -> login -> change-password (204) -> eski şifreyle login (401)
   -> yeni şifreyle login (200).  