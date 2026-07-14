using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Auth.Api.Entities;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using System.Security.Cryptography;

namespace Auth.Api.Services;
public class TokenService
{
    private readonly IConfiguration _configuration;

    public TokenService(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    public (string token, int expiresInSeconds) CreateAccessToken(User user)
    {
        var jwt = _configuration.GetSection("Jwt");
        var key = jwt["Key"]!;
        var issuer = jwt["Issuer"];
        var audience = jwt["Audience"];
        var accessTokenMinutes = int.Parse(jwt["AccessTokenMinutes"]!);

        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new Claim(JwtRegisteredClaimNames.Email, user.Email),
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
        };

        var signingKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key));
        var credentials = new SigningCredentials(signingKey, SecurityAlgorithms.HmacSha256);

        var expires = DateTime.UtcNow.AddMinutes(accessTokenMinutes);

        var token = new JwtSecurityToken(
            issuer: issuer,
            audience: audience,
            claims: claims,
            expires: expires,
            signingCredentials: credentials
        );

        var tokenHandler = new JwtSecurityTokenHandler();
        var jwtToken = tokenHandler.WriteToken(token);

        return (jwtToken, accessTokenMinutes * 60);
    }

    public string GenerateRefreshToken()
    {
        var bytes = RandomNumberGenerator.GetBytes(64);
        return Convert.ToBase64String(bytes);

    }

    public string HashToken(string token)
    {
        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(token));
        return Convert.ToHexString(bytes);
    }
}