using System.Net.Http.Headers;
using System.Net;
using System.Net.Http.Json;
using Auth.Api.Dtos;

namespace Auth.Api.Tests;

public class AuthFlowTests : IClassFixture<AuthApiFactory>
{
    private readonly AuthApiFactory _factory;

    public AuthFlowTests(AuthApiFactory factory)
    {
        _factory = factory;
    }

    private static string UniqueEmail() => $"testuser_{Guid.NewGuid():N}@example.com";

    [Fact]
    public async Task Register_Login_Me_ReturnsUser()
    {
        var client = _factory.CreateClient();

        var email = UniqueEmail();
        var password = "TestPassword123!";

        var registerResponse = await client.PostAsJsonAsync("/auth/register", new RegisterRequest(email, password));
        Assert.Equal(HttpStatusCode.Created, registerResponse.StatusCode);

        var loginResponse = await client.PostAsJsonAsync("/auth/login", new LoginRequest(email, password));
        Assert.Equal(HttpStatusCode.OK, loginResponse.StatusCode);

        var tokens = await loginResponse.Content.ReadFromJsonAsync<TokenResponse>();

        Assert.NotNull(tokens);
        Assert.False(string.IsNullOrWhiteSpace(tokens.AccessToken));

        client.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", tokens.AccessToken);

        var meResponse = await client.GetAsync("/auth/me");

        Assert.Equal(HttpStatusCode.OK, meResponse.StatusCode);

        var me = await meResponse.Content.ReadFromJsonAsync<AuthResponse>();

        Assert.NotNull(me);
        Assert.Equal(email, me.Email);
    }

    [Fact]
    public async Task Login_WithWrongPassword_Returns401()
    {
        var client = _factory.CreateClient();

        var email = UniqueEmail();
        var password = "TestPassword123!";

        var registerResponse = await client.PostAsJsonAsync("/auth/register", new RegisterRequest(email, password));
        Assert.Equal(HttpStatusCode.Created, registerResponse.StatusCode);

        var loginResponse = await client.PostAsJsonAsync("/auth/login", new LoginRequest(email, "WrongPassword!"));
        Assert.Equal(HttpStatusCode.Unauthorized, loginResponse.StatusCode);
    }

    [Fact]
    public async Task Register_WithExistingEmail_Returns409()
    {
        var client = _factory.CreateClient();

        var email = UniqueEmail();
        var password = "TestPassword123!";

        var registerResponse1 = await client.PostAsJsonAsync("/auth/register", new RegisterRequest(email, password));
        Assert.Equal(HttpStatusCode.Created, registerResponse1.StatusCode);

        var registerResponse2 = await client.PostAsJsonAsync("/auth/register", new RegisterRequest(email, "AnotherPassword123!"));
        Assert.Equal(HttpStatusCode.Conflict, registerResponse2.StatusCode);
    }

    [Fact]
    public async Task Refresh_ReturnsNewTokens()
    {
        var client = _factory.CreateClient();

        var email = UniqueEmail();
        var password = "TestPassword123!";

        var registerResponse = await client.PostAsJsonAsync("/auth/register", new RegisterRequest(email, password));
        var loginResponse = await client.PostAsJsonAsync("/auth/login", new LoginRequest(email, password));
        var loginTokens = await loginResponse.Content.ReadFromJsonAsync<TokenResponse>();
        Assert.NotNull(loginTokens);

        var refreshResponse = await client.PostAsJsonAsync("/auth/refresh", new RefreshRequest(loginTokens.RefreshToken));
        Assert.Equal(HttpStatusCode.OK, refreshResponse.StatusCode);

        var newTokens = await refreshResponse.Content.ReadFromJsonAsync<TokenResponse>();
        Assert.NotNull(newTokens);

        Assert.NotEqual(loginTokens.RefreshToken, newTokens.RefreshToken);

        var reuseResponse = await client.PostAsJsonAsync("/auth/refresh", new RefreshRequest(loginTokens.RefreshToken));
        Assert.Equal(HttpStatusCode.Unauthorized, reuseResponse.StatusCode);
    }    
}