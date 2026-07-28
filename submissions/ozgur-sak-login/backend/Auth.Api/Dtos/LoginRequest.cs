using System.ComponentModel.DataAnnotations;

namespace Auth.Api.Dtos;

public record LoginRequest(
    [Required, EmailAddress] string Email,
    [Required] string Password
);