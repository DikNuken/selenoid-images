FROM selenoid/base:4.0

ARG VERSION=noop
ARG CLEANUP=noop
ARG ADDITIONAL_APT_INSTALL_OPTS=noop
ARG CHANNEL_ALIAS
ARG SANDBOX_PATH

RUN \
        apt-get update && \
        apt-get -y --no-install-recommends install gconf-service \
         libasound2 \
         libatk1.0-0 \
         libc6 \
         libcairo2 \
         libcups2 \
         libdbus-1-3 \
         libexpat1 \
         libfontconfig1 \
         libfreetype6 \
         libgcc1 \
         libgconf-2-4 \
         libgdk-pixbuf2.0-0 \
         libglib2.0-0 \
         libgtk2.0-0 \
         libgtk-3-0 \
         libnspr4 \
         libnss3 \
         libpango1.0-0 \
         libstdc++6 \
         libx11-6 \
         libx11-xcb1 \
         libxcb1 \
         libxcomposite1 \
         libxcursor1 \
         libxdamage1 \
         libxext6 \
         libxfixes3 \
         libxi6 \
         libxrandr2 \
         libxrender1 \
         libxss1 \
         libxtst6 \
         ca-certificates \
         fonts-liberation \
         libappindicator1 \
         libappindicator3-1 \
         libnss3 \
         lsb-base \
         xdg-utils \
         libcurl3 \
         curl && \
         curl -O http://apt-repo:8080/google-chrome-stable.deb && \
         apt-get -y purge curl && \
         dpkg -i google-chrome-stable.deb && \
         rm google-chrome-stable.deb && \
         chown root:root /opt/google/$SANDBOX_PATH/chrome-sandbox && \
         chmod 4755 /opt/google/$SANDBOX_PATH/chrome-sandbox && \
         google-chrome-$CHANNEL_ALIAS --version && \
         rm -Rf /tmp/* && \
         rm -Rf /var/lib/apt/lists/*