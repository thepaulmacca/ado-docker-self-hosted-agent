FROM mcr.microsoft.com/windows/servercore:ltsc2019

ENV chocolateyUseWindowsCompression=false
RUN @powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

RUN choco config set cachelocation C:\chococache

RUN choco install \
    git  \
    nodejs \    
    curl \
    dotnet \
    visualstudio2019buildtools \
    azure-cli \
    azurepowershell \
    powershell-core \
    --ignore-package-exit-codes=3010 \
    --confirm \
    --limit-output \
    --timeout 216000 \
    && rmdir /S /Q C:\chococache

# Common Node Tools
RUN npm install gulp -g && npm install grunt -g && npm install -g less && npm install phantomjs-prebuilt -g

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Install .NET Core SDK
ENV DOTNET_SDK_DOWNLOAD_URL https://aka.ms/dotnet/net5/5.0.1xx/daily/Sdk/dotnet-sdk-win-x64.zip

RUN Invoke-WebRequest $Env:DOTNET_SDK_DOWNLOAD_URL -OutFile dotnet.zip; \
    Expand-Archive dotnet.zip -DestinationPath $Env:ProgramFiles\dotnet -Force; \
    Remove-Item -Force dotnet.zip

SHELL ["cmd", "/S", "/C"]

RUN setx /M PATH "%PATH%;%ProgramFiles%\dotnet"

# Trigger the population of the local package cache
ENV NUGET_XMLDOC_MODE skip

RUN mkdir C:\warmup \
    && cd C:\warmup \
    && dotnet new \
    && cd .. \
    && rmdir /S /Q C:\warmup 

WORKDIR /azp

COPY start.ps1 .
CMD powershell .\start.ps1