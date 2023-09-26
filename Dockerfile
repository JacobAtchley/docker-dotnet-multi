FROM mcr.microsoft.com/dotnet/aspnet:7.0.7-alpine3.18 AS base

ARG USER=lucy
ARG HOME=/home/$USER
ARG TARGETARCH

#Envvars#
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false
#dotnet PGO 
#https://devblogs.microsoft.com/dotnet/announcing-net-6/#dynamic-pgo
ENV DOTNET_ReadyToRun=0
ENV DOTNET_TieredPGO=1
ENV DOTNET_TC_QuickJitForLoops=1
ENV ASPNETCORE_URLS=http://+:4242

#port
ENV Kestrel__Endpoints__Http__Url=http://::4242

#Datadog
ENV CORECLR_ENABLE_PROFILING=1 \
    CORECLR_PROFILER={846F5F1C-F9AE-4B07-969E-05C26BC060D8} \
    CORECLR_PROFILER_PATH=/opt/datadog/Datadog.Trace.ClrProfiler.Native.so \
    DD_INTEGRATIONS=/opt/datadog/integrations.json \
    DD_DOTNET_TRACER_HOME=/opt/datadog \
    DD_LOGS_INJECTION=true \
    DD_DOTNET_TRACER_HOME=/opt/datadog \
    LD_PRELOAD=/opt/datadog/continuousprofiler/Datadog.Linux.ApiWrapper.x64.so \
    DD_PROFILING_ENABLED=1 \
    DD_TRACE_SAMPLE_RATE=1.0 \ 
    DD_RUNTIME_METRICS_ENABLED=true \
    DD_APPSEC_ENABLED=false \
    DD_PROFILING_ENABLED=true

#install deps#
RUN sed -i 's|v3.17|edge|g' /etc/apk/repositories && \
    apk update && \
    apk upgrade -Ua && \
    apk add libgdiplus-dev fontconfig ttf-dejavu icu-data-full icu-libs tzdata curl wget --update-cache 

#install datadog
#check if arch is ARM and disregard data dog.
#not supported as of 9/26/2023
RUN if [ "$TARGETARCH" =~ "arm*" ] ; then \
    mkdir -p /opt/datadog; \
    curl -s https://api.github.com/repos/DataDog/dd-trace-dotnet/releases/119393450 \
            | grep "browser_download_url.*musl.tar.gz" \
            | cut -d : -f 2,3 \
            | tr -d \" \
            | wget -i - \
            && tar -xzf datadog-dotnet-apm-* -C /opt/datadog \ 
            && apk del -r curl wget \
            && tar -C /opt/datadog -xzf datadog-dotnet-apm-2.37.0-musl.tar.gz \
            && sh /opt/datadog/createLogPath.sh; \
fi

RUN adduser -h $HOME --shell /bin/sh -D $USER
RUN chown -R $USER:$USER /home/$USER

WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:7.0-bullseye-slim-amd64 AS build

ARG TARGETARCH

WORKDIR /src
COPY . .
RUN dotnet build "docker-multi-test/docker-multi-test.csproj" -c Release -o /app/build -a $TARGETARCH

FROM build AS publish
RUN dotnet publish "docker-multi-test/docker-multi-test.csproj" -c Release -o /app/publish --self-contained false -a $TARGETARCH

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

USER $USER

ENTRYPOINT ["dotnet", "docker-multi-test.dll"]