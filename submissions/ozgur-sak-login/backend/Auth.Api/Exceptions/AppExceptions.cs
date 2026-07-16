namespace Auth.Api.Services;

// 409
public class ConflictException : Exception
{
    public ConflictException(string message) : base(message) { }
}

// 401
public class UnauthorizedException : Exception
{
    public UnauthorizedException(string message) : base(message) { }
}

public class TooManyRequestsException : Exception
{
    public TooManyRequestsException(string message) : base(message) { }
}