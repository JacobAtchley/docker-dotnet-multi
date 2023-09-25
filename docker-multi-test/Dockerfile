FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:7.0-bullseye-slim-amd64 AS build

ARG TARGETARCH
ARG TARGETOS

RUN arch=$TARGETARCH \
    && if [ "$arch" = "amd64" ]; then arch="x64"; fi \
    && echo $TARGETOS-$arch > /tmp/rid

WORKDIR /src
COPY ["docker-multi-test/docker-multi-test.csproj", "docker-multi-test/"]
RUN dotnet restore "docker-multi-test/docker-multi-test.csproj" -r $(cat /tmp/rid)
COPY . .
WORKDIR "/src/docker-multi-test"
RUN dotnet build "docker-multi-test.csproj" -c Release -o /app/build -r $(cat /tmp/rid)

FROM build AS publish
RUN dotnet publish "docker-multi-test.csproj" -c Release -o /app/publish --self-contained false -r $(cat /tmp/rid)

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "docker-multi-test.dll"]