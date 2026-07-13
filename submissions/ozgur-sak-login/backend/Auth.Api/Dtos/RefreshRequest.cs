using System.ComponentModel.DataAnnotations;

namespace Auth.Api.Dtos;

public record RefreshRequest(
    [Required] string RefreshToken
);