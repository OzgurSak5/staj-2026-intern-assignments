using Auth.Api.Data;
using Auth.Api.Dtos;
using Auth.Api.Entities;
using Microsoft.EntityFrameworkCore;


namespace Auth.Api.Services;
public class AuthService
{
    private readonly AppDbContext _db;

    public AuthService(AppDbContext db)
    {
        _db = db;
    }

    public async Task<AuthResponse> RegisterAsync(RegisterRequest request)
    {
        var emailExists = await _db.Users.AnyAsync(u => u.Email == request.Email);

        if (emailExists)
        {
            throw new InvalidOperationException("Email already exists.");
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
}