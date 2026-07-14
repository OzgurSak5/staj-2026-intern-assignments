using Auth.Api.Data;
using Auth.Api.Dtos;
using Auth.Api.Entities;
using Microsoft.EntityFrameworkCore;


namespace Auth.Api.Services;
public class AuthService
{
    private readonly AppDbContext _db;
    private readonly TokenService _tokenService;
    private readonly IConfiguration _config;

    public AuthService(AppDbContext db,TokenService tokenService, IConfiguration config)
    {
        _db = db;
        _tokenService = tokenService;
        _config = config;
    }

    public async Task<AuthResponse> RegisterAsync(RegisterRequest request)
    {
        var emailExists = await _db.Users.AnyAsync(u => u.Email == request.Email);

        if (emailExists)
        {
            throw new ConflictException("Email already exists.");
        }

        var passwordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);

        var user = new User
        {
            Id = Guid.NewGuid(),
            Email = request.Email,
            PasswordHash = passwordHash
        };

        _db.Users.Add(user);
        await _db.SaveChangesAsync();

        return new AuthResponse(user.Id, user.Email);
    }

    public async Task<TokenResponse> LoginAsync(LoginRequest request)
    {
        var user = await _db.Users.FirstOrDefaultAsync(u => u.Email == request.Email);

        if (user == null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
        {
            throw new UnauthorizedException("Invalid email or password.");
        }

        var (accessToken, expiresInSeconds) = _tokenService.CreateAccessToken(user);
        var refreshToken = await CreateRefreshTokenAsync(user);

        return new TokenResponse(accessToken, refreshToken, expiresInSeconds);
    }

    public async Task<TokenResponse> RefreshAsync(RefreshRequest request)
    {
        var tokenHash = _tokenService.HashToken(request.RefreshToken);
        var stored = await _db.RefreshTokens.Include(rt => rt.User)
            .FirstOrDefaultAsync(rt => rt.TokenHash == tokenHash);

        if (stored is null || !stored.IsActive)
        {
            throw new UnauthorizedException("Invalid refresh token.");
        }

        stored.RevokedAt = DateTime.UtcNow;

        var (accessToken, expiresInSeconds) = _tokenService.CreateAccessToken(stored.User);
        var newRefreshToken = await CreateRefreshTokenAsync(stored.User);

        await _db.SaveChangesAsync();

        return new TokenResponse(accessToken, newRefreshToken, expiresInSeconds);
    }

    public async Task LogoutAsync(RefreshRequest request)
    {
        var tokenHash = _tokenService.HashToken(request.RefreshToken);
        var stored = await _db.RefreshTokens.FirstOrDefaultAsync(rt => rt.TokenHash == tokenHash);

        if (stored is not null && stored.IsActive)
        {
            stored.RevokedAt = DateTime.UtcNow;
            await _db.SaveChangesAsync();
        }
    }


    private async Task<string> CreateRefreshTokenAsync(User user)
    {
        var rawToken = _tokenService.GenerateRefreshToken();
        var days = int.Parse(_config["Jwt:RefreshTokenDays"]!);

        var refreshToken = new RefreshToken
        {
            Id = Guid.NewGuid(),
            UserId = user.Id,
            TokenHash = _tokenService.HashToken(rawToken),
            ExpiresAt = DateTime.UtcNow.AddDays(days)
        };

        _db.RefreshTokens.Add(refreshToken);
        await _db.SaveChangesAsync();
        return rawToken;
    }
}