namespace Auth.Api.Dtos;

public record TokenResponse(
    string AccessToken,
    string RefreshToken,
    int ExpiresInSeconds
);