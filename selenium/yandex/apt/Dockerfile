FROM selenoid/base:4.0

ARG VERSION
ARG CLEANUP
ARG ADDITIONAL_APT_INSTALL_OPTS
ARG SANDBOX_PATH

RUN \
        ( [ "$CLEANUP" != "true" ] && rm -f /etc/apt/apt.conf.d/docker-clean ) || true && \
        wget -q -O - https://repo.yandex.ru/yandex-browser/YANDEX-BROWSER-KEY.GPG | apt-key add - && \
        echo 'deb [arch=amd64] https://repo.yandex.ru/yandex-browser/deb/ beta main' > /etc/apt/sources.list.d/google.list && \
        apt-get update && \
        apt-get -y  --no-install-recommends $ADDITIONAL_APT_INSTALL_OPTS install yandex-browser-beta=$VERSION && \
        chown root:root /opt/yandex/browser-beta/yandex_browser-sandbox && \
        chmod 4755 /opt/yandex/browser-beta/yandex_browser-sandbox && \
        ($CLEANUP && rm -Rf /tmp/* && rm -Rf /var/lib/apt/lists/*) || true
