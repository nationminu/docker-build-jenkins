FROM php:5.6-apache

#RUN apt-get update && apt-get upgrade -y \
#    && apt-get -y install git \
#    && apt-get clean 

COPY src /var/www/html
