# **ModSecurity** + OpenResty **(Nginx)** Docker image

## Description
The dockerfile was created by taking inspiration from the "[Creare un WAF: libModSecurity + Nginx](https://github.com/Rev3rseSecurity/libModSecurity)" course by [Rev3rseSecurity](https://github.com/Rev3rseSecurity).


## Usage

Build

```bash
$ docker build -t modsecurity-openresty ./
```

Run
```bash
$ docker run --name waf -it -h waf -p 80:80 -p 443:443 modsecurity-openresty /bin/bash
```