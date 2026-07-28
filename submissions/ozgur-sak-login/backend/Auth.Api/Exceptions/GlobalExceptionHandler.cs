using Microsoft.AspNetCore.Diagnostics;
using Auth.Api.Services;

namespace Auth.Api.Exceptions;

public class GlobalExceptionHandler : IExceptionHandler
{
    private readonly IProblemDetailsService _problemDetailsService;

    public GlobalExceptionHandler(IProblemDetailsService problemDetailsService)
    {
        _problemDetailsService = problemDetailsService;
    }

    public async ValueTask<bool> TryHandleAsync(HttpContext context, Exception exception, CancellationToken ct)
    {
        var (status, title) = exception switch
        {
            ConflictException => (StatusCodes.Status409Conflict, "Conflict"),
            UnauthorizedException => (StatusCodes.Status401Unauthorized, "Unauthorized"),
            TooManyRequestsException => (StatusCodes.Status429TooManyRequests, "Too many requests"),
            _ => (0, "")
        };

        if (status == 0)
        {
            return false;
        }

        context.Response.StatusCode = status;

        if (exception is TooManyRequestsException)
        {
            context.Response.Headers.RetryAfter = "60";
        }

        return await _problemDetailsService.TryWriteAsync(new ProblemDetailsContext
        {
            HttpContext = context,
            ProblemDetails =
            {
                Status = status,
                Title = title,
                Detail = exception.Message
            }
        });
    }
}    