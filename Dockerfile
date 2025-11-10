FROM debian:bullseye-slim
COPY ./nginx /usr/local/bin/nginx
EXPOSE 80 443
ENTRYPOINT ["/usr/local/bin/nginx", "-g", "daemon off;"]
