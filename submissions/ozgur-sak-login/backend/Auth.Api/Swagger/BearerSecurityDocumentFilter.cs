using Microsoft.OpenApi;
using Swashbuckle.AspNetCore.SwaggerGen;

namespace Auth.Api.Swagger;

// Adds a global "security" requirement to the OpenAPI document so
// Swagger UI sends the Bearer token with every request.
public class BearerSecurityDocumentFilter : IDocumentFilter
{
    public void Apply(OpenApiDocument document, DocumentFilterContext context)
    {
        document.Security ??= new List<OpenApiSecurityRequirement>();
        document.Security.Add(new OpenApiSecurityRequirement
        {
            [new OpenApiSecuritySchemeReference("Bearer", document)] = new List<string>()
        });
    }
}