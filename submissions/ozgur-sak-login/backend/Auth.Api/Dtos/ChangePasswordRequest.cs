using System.ComponentModel.DataAnnotations;

namespace Auth.Api.Dtos;

public record ChangePasswordRequest(
    [Required] string OldPassword,
    [Required, MinLength(8)] string NewPassword
);
