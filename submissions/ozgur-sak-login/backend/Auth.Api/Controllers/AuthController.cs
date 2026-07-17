using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Auth.Api.Dtos;
using Auth.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;

namespace Auth.Api.Controllers;


[Produces("application/json")]
[ProducesResponseType(StatusCodes.Status400BadRequest, Type = typeof(ValidationProblemDetails))]
[ApiController]
[Route("auth")]
public class AuthController : ControllerBase
{
    private readonly AuthService _authService;

    public AuthController(AuthService authService)
    {
        _authService = authService;
    }

    [HttpPost("register")]
    [ProducesResponseType(StatusCodes.Status201Created, Type = typeof(AuthResponse))]
    [ProducesResponseType(StatusCodes.Status409Conflict, Type = typeof(ProblemDetails))]
    public async Task<IActionResult> Register([FromBody] RegisterRequest request)
    {
        var response = await _authService.RegisterAsync(request);
        return Created($"/users/{response.UserId}", response);
    }

    [EnableRateLimiting("login-ip")]
    [HttpPost("login")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(TokenResponse))]
    [ProducesResponseType(StatusCodes.Status401Unauthorized, Type = typeof(ProblemDetails))]
    [ProducesResponseType(StatusCodes.Status429TooManyRequests, Type = typeof(ProblemDetails))]
    public async Task<ActionResult<TokenResponse>> Login([FromBody] LoginRequest request)
    {
        var response = await _authService.LoginAsync(request);
        return Ok(response);
    }

    [Authorize]
    [HttpGet("me")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(AuthResponse))]
    [ProducesResponseType(StatusCodes.Status401Unauthorized, Type = typeof(ProblemDetails))]
    public IActionResult Me()
    {
        var userId = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value ?? User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        var email = User.FindFirst(JwtRegisteredClaimNames.Email)?.Value ?? User.FindFirst(ClaimTypes.Email)?.Value;

        return Ok(new { userId, email });
    }

    [HttpPost("refresh")]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(TokenResponse))]
    [ProducesResponseType(StatusCodes.Status401Unauthorized, Type = typeof(ProblemDetails))]
    public async Task<IActionResult> Refresh([FromBody] RefreshRequest request)
    {
        var response = await _authService.RefreshAsync(request);
        return Ok(response);
    }

    [HttpPost("logout")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> Logout([FromBody] RefreshRequest request)
    {
        await _authService.LogoutAsync(request);
        return NoContent();
    }

}