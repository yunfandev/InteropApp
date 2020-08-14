FROM mcr.microsoft.com/windows/servercore:2004 as builder
RUN @powershell -NoProfile -ExecutionPolicy Bypass -Command "$env:ChocolateyUseWindowsCompression='false'; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
RUN choco install visualstudio2019buildtools --package-parameters "--installPath C:\\BuildTools" -y --allow-empty-checksums -version 16.6.5.0 || IF "%ERRORLEVEL%"=="3010" EXIT 0
RUN choco install visualstudio2019-workload-vctools -y --allow-empty-checksums -version 1.0.0
RUN choco install visualstudio2019-workload-netcorebuildtools --allow-empty-checksums -y -version 1.0.0
RUN setx path "%path%;C:\BuildTools\MSBuild\Current\bin"
COPY . c:/src
RUN ["msbuild", "c:/src/InteropApp/InteropApp.csproj", "/restore", "/p:Configuration=Release", "/p:Platform=x64", "/p:OutputPath=c:/bin"]

FROM mcr.microsoft.com/dotnet/core/runtime:3.1.6-nanoserver-2004 as runtime
COPY --from=builder C:/bin C:/bin
COPY --from=builder C:/Windows/System32/concrt140.dll C:/Windows/System32/concrt140.dll
COPY --from=builder C:/Windows/System32/msvcp140.dll C:/Windows/System32/msvcp140.dll
COPY --from=builder C:/Windows/System32/msvcp140_1.dll C:/Windows/System32/msvcp140_1.dll
COPY --from=builder C:/Windows/System32/msvcp140_2.dll C:/Windows/System32/msvcp140_2.dll
COPY --from=builder C:/Windows/System32/msvcp140_codecvt_ids.dll C:/Windows/System32/msvcp140_codecvt_ids.dll
COPY --from=builder C:/Windows/System32/vccorlib140.dll C:/Windows/System32/vccorlib140.dll
COPY --from=builder C:/Windows/System32/vcruntime140.dll C:/Windows/System32/vcruntime140.dll
COPY --from=builder C:/Windows/System32/vcruntime140_1.dll C:/Windows/System32/vcruntime140_1.dll
ENTRYPOINT ["C:/bin/InteropApp"]

