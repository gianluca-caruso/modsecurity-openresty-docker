#############################################################################
# Description: Dockerfile ModSecurity-nginx (fast)                          #
#############################################################################

FROM ubuntu:latest 

#############################################################################
# dependencies                                                              #
#############################################################################

# install dependencies
RUN apt-get update\
    && apt-get install -y bison build-essential\
        ca-certificates curl dh-autoreconf doxygen\
        flex gawk git iputils-ping libcurl4-gnutls-dev\
        libexpat1-dev libgeoip-dev liblmdb-dev libpcre3-dev\
        libpcre++-dev libssl-dev libtool libxml2 libxml2-dev\
        libyajl-dev locales liblua5.3-dev pkg-config wget\
        zlib1g-dev zlib1g-dev libxslt1-dev libgd-dev

#############################################################################
# Modsecurity                                                               #   
#############################################################################

# clone Modsecurity
RUN cd /opt/\
    && git clone https://github.com/SpiderLabs/ModSecurity.git

# install Modsecurity
RUN cd /opt/ModSecurity\ 
    && git checkout v3/master\
    && git submodule init\
    && git submodule update\
    && ./build.sh\
    && ./configure\
    && make\
    && make install

#############################################################################
# Modsecurity-nginx (connector)                                             #
#############################################################################

# clone Modsecurity-nginx
RUN cd /opt/\
    && git clone https://github.com/SpiderLabs/ModSecurity-nginx

#############################################################################
# OpenResty - (version: 18 May 2022)                                        #
#############################################################################

# download and install OpenResty
RUN cd /opt/ && wget https://openresty.org/download/openresty-1.21.4.1.tar.gz\
    && tar -xvf openresty-1.21.4.1.tar.gz\
    && rm openresty-1.21.4.1.tar.gz\
    && cd openresty-1.21.4.1\
    && ./configure --add-module=/opt/ModSecurity-nginx\
    && gmake\
    && gmake install

#############################################################################
# prepare configuration files                                               #
#############################################################################

# copy modsecurity configuration file
RUN cp /opt/ModSecurity/modsecurity.conf-recommended /usr/local/openresty/nginx/conf/modsecurity.conf

# install OWASP Core Rule Set (CRS)
RUN cd /usr/local/openresty/nginx/conf/\
    && git clone https://github.com/coreruleset/coreruleset.git

# copy nginx configuration file
COPY ./conf/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

# create modsecurity log directory and change ownership 
RUN mkdir /usr/local/openresty/nginx/logs/modsecurity && chown -R nobody:nogroup /usr/local/openresty/nginx/logs/modsecurity

# create custom rules file
RUN touch /usr/local/openresty/nginx/conf/coreruleset/rules/custom.conf

# copy modsecurity configuration file 
COPY ./conf/modsecurity.conf /usr/local/openresty/nginx/conf/modsecurity.conf

# copy crs-setup.conf file
COPY ./conf/crs-setup.conf /usr/local/openresty/nginx/conf/coreruleset/crs-setup.conf

# expose port 
EXPOSE 80 80