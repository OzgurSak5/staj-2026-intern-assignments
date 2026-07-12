namespace Auth.Api.Dtos;

public record TokenResponse(
    string AccessToken,
    int ExpiresInSeconds
);