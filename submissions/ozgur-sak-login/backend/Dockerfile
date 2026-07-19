# Build aşaması
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Önce sadece csproj => restore katmanı önbelleğe girsin
COPY Auth.Api/Auth.Api.csproj Auth.Api/
RUN dotnet restore Auth.Api/Auth.Api.csproj

# Sonra kaynağın geri kalanı
COPY Auth.Api/ Auth.Api/
RUN dotnet publish Auth.Api/Auth.Api.csproj -c Release -o /app

# Runtime aşaması
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app
RUN apt-get update && apt-get install -y libgssapi-krb5-2 && rm -rf /var/lib/apt/lists/*
COPY --from=build /app .
ENTRYPOINT ["dotnet", "Auth.Api.dll"]