# Install Operating system and dependencies
FROM ubuntu:20.04

#Install Packages and then remove extra files
ENV TZ="America/Salt Lake City"
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback lib32stdc++6 python3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# download Flutter SDK from Flutter Github repo
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

# Set flutter environment path
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run flutter doctor
RUN flutter doctor

# Enable flutter web
RUN flutter channel stable
RUN flutter upgrade
RUN flutter config --enable-web

# Share files with container
VOLUME /app
WORKDIR /app

# Record the exposed port
EXPOSE 5000
ENV PORT 5000

# make server startup script executable and start the web server
CMD bash -c "chmod +x /app/app/server/server.sh && /app/app/server/server.sh"