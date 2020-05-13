FROM php:7.3-apache

#RUN apt-get update && apt-get upgrade -y \
#    && apt-get -y install git \
#    && apt-get clean 

COPY . /var/www/html
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli && a2enmod rewrite && rm -f /var/www/html/Dockerfile
