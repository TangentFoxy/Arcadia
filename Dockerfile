FROM openresty/openresty:1.15.8.2-6-xenial

LABEL maintainer = "Tangent/Rose <tangentfoxy@gmail.com>"

EXPOSE 8080
WORKDIR /app
ENTRYPOINT ["sh", "-c", "lapis migrate production && lapis server production"]

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install libssl-dev -y

RUN luarocks install lapis
#RUN luarocks install moonscript

# clean up
RUN apt-get autoremove -y
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY . .