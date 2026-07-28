using System.Threading.RateLimiting;

namespace Auth.Api.Services;

public class LoginAttemptLimiter : IDisposable
{
    private readonly PartitionedRateLimiter<string> _rateLimiter;

    public LoginAttemptLimiter(IConfiguration configuration)
    {
        var rateLimitSection = configuration.GetSection("RateLimit");
        var emailPermitLimit = rateLimitSection.GetValue<int>("EmailPermitLimit");
        var emailWindowMinutes = rateLimitSection.GetValue<int>("EmailWindowMinutes");

        _rateLimiter = PartitionedRateLimiter.Create<string, string>(email =>
            RateLimitPartition.GetSlidingWindowLimiter(email, _ => new SlidingWindowRateLimiterOptions
            {
                PermitLimit = emailPermitLimit,
                Window = TimeSpan.FromMinutes(emailWindowMinutes),
                SegmentsPerWindow = 5,
                QueueLimit = 0
            }));
    }

    public bool IsBlocked(string email)
    {
        using var peek = _rateLimiter.AttemptAcquire(email, permitCount: 0);
        return !peek.IsAcquired;
    }

    public void RecordFailure(string email)
    {
        _rateLimiter.AttemptAcquire(email, permitCount: 1).Dispose();
    }

    public void Dispose() => _rateLimiter.Dispose();
}