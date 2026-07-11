namespace Auth.Api.Dtos;

public record AuthResponse(
    Guid UserId,
    string Email
);