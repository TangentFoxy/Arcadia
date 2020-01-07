FROM openresty/openresty:1.15.8.2-6-xenial

LABEL maintainer = "Tangent/Rose <tangentfoxy@gmail.com>"

EXPOSE 80
WORKDIR /app
ENTRYPOINT ["sh", "-c", "sleep 5 && lapis migrate production && lapis server production"]

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install libssl-dev git -y

RUN luarocks install lapis
RUN luarocks install luacrypto # no idea why this is still required, it should not be
RUN luarocks install bcrypt

# clean up
RUN apt-get autoremove -y
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY . .

# these need to be run in container now because I configured docker hub to automatically build on push
RUN luarocks install moonscript
RUN moonc .
