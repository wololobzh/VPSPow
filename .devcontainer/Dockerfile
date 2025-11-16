FROM asciidoctor/docker-asciidoctor

RUN apk add --no-cache git

RUN apk add openssh-client

RUN apk add docker openrc

RUN apk add docker-cli-compose

RUN addgroup root docker

# Mermaid installation
RUN apk add --no-cache nodejs npm \
    # Install dependencies for Puppeteer and Chromium
    && apk add --no-cache \
    udev \
    ttf-freefont \
    chromium \
    harfbuzz \
    nss

#installation de jq pour les scripts bash
RUN apk add jq

# Installer mermaid-cli globalement
RUN npm install -g @mermaid-js/mermaid-cli \
    && npm install puppeteer-core@20.7.4 \
    && npm install -g downdoc 

# Configurer le chemin pour Puppeteer pour qu'il utilise Chromium installé par apk
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

CMD sleep infinity
