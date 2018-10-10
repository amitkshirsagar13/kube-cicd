FROM microsoft/dotnet:2.1.301-sdk
RUN dotnet tool install -g dotnet-serve
RUN dotnet tool install --global dotnet-sonarscanner --version 4.4.0
RUN chmod 755 -R /root/.dotnet/tools

RUN apt-get update && \
    apt-get install -y openjdk-8-jdk zip unzip

ENV SONAR_SCANNER_VERSION=3.0.3.778 \
    SONAR_SCANNER_MSBUILD_VERSION=4.0.2.892 \
    SONAR_SCANNER_MSBUILD_PATH=/opt/sonar-scanner-msbuild

ENV PATH="$SONAR_SCANNER_MSBUILD_PATH:/root/.dotnet/tools:~/.dotnet/tools:$SONAR_SCANNER_MSBUILD_PATH/sonar-scanner-$SONAR_SCANNER_VERSION/bin:${PATH}"

# Setup JAVA_HOME, this is useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME
ENV SONAR_RUNNER_OPTS="-Xmx256m -XX:MaxPermSize=128m -XX:ReservedCodeCacheSize=64m"
RUN export SONAR_RUNNER_OPTS
ENV SONAR_SCANNER_OPTS="-Xmx256m -XX:MaxPermSize=128m -XX:ReservedCodeCacheSize=64m"
RUN export SONAR_SCANNER_OPTS
