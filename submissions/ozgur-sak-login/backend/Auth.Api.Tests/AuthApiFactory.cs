using Auth.Api.Data;
using Auth.Api.Services;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace Auth.Api.Tests;

public class AuthApiFactory : WebApplicationFactory<Program>, IAsyncLifetime
{
    private readonly string _dbName = $"Authdb_test_{Guid.NewGuid():N}";

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseSetting("RateLimit:IpPermitLimit", "10000");
        builder.UseSetting("RateLimit:IpWindowMinutes", "5");
        builder.UseSetting("RateLimit:EmailPermitLimit", "10000");
        builder.UseSetting("RateLimit:EmailWindowMinutes", "5");
        
        builder.UseSetting("ConnectionStrings:DefaultConnection",
            $"Host=localhost;Port=5432;Database={_dbName};Username=postgres;Password=devpassword");

        builder.UseSetting("Jwt:Key", "test-only-key-not-a-secret-32-bytes-min!!");
    }

    public async Task InitializeAsync()
    {
        using var scope = Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        await db.Database.MigrateAsync();
    }

    public new async Task DisposeAsync()
    {
        using var scope = Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        await db.Database.EnsureDeletedAsync();
        await base.DisposeAsync();
    }
}