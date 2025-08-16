FROM alpine:3.22

RUN apk update && apk upgrade && apk add --no-cache nginx openssl

# Create needed directories
#RUN mkdir -p /var/www /run/nginx && \
RUN mkdir -p /var/www /etc/nginx/ssl /run/nginx && \
    chown -R nginx:nginx /var/www

# Copy NGINX config (HTTP configs go into /etc/nginx/http.d/)
#COPY conf/ /etc/nginx/http.d/
COPY requirements/nginx/conf/ /etc/nginx/http.d/

# Make sure SSL dir exists but don't overwrite it (secrets will be mounted)
VOLUME ["/etc/nginx/ssl"]

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
