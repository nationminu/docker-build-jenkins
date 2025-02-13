FROM ubuntu:22.04

# ARGS
ARG UID=1000
ARG GID=1000
ARG UNAME=ghost

ARG TZ="Asia/Seoul"
ARG DEBIAN_FRONTEND=noninteractive

ARG BUILD_DATE
ARG BUILD_VERSION

# LABEL
LABEL org.opencontainers.image.authors="ssong@souljam.works"
LABEL org.opencontainers.image.build.date=${BUILD_DATE:-2025-01-01}
LABEL org.opencontainers.image.build.version=${BUILD_VERSION:-1.0.0}
LABEL org.opencontainers.image.build.comment="Docker container for a legacy PHP 5.6 application on ubuntu 22.04(jammy)"

# ADD envvars /etc/apache2/envvars
# ADD mpm_prefork.conf /etc/apache2/mods-enabled/mpm_prefork.conf
# ADD 000-default.conf /etc/apache2/sites-available/000-default.conf
# ADD 900-status.conf /etc/apache2/sites-available/900-status.conf

# INSTALL PHP5.6
RUN apt update  && \
    apt install -y software-properties-common curl

RUN apt update && \
    add-apt-repository ppa:ondrej/php && \
    apt install -y \
        php5.6 php5.6-gd php5.6-mysql php5.6-imap php5.6-curl php5.6-intl php5.6-pspell php5.6-recode php5.6-sqlite3 php5.6-tidy php5.6-xmlrpc php5.6-xsl php5.6-zip php5.6-mbstring php5.6-soap php5.6-opcache php5.6-common php5.6-json php5.6-readline php5.6-xml php5.6-imagick \
        libicu-dev libicu70 apache2 libapache2-mod-php5.6 libmagickwand-dev --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

RUN a2enmod rewrite && \
    a2ensite 900-status && \
    groupadd -g ${GID} -o ${UNAME} && \
    useradd -m -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME} && \
    ln -sf /dev/stdout /var/log/apache2/access.log && \
    ln -sf /dev/stdout /var/log/apache2/other_vhosts_access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log

EXPOSE 80
EXPOSE 8080

CMD ["apachectl", "-DFOREGROUND"]
