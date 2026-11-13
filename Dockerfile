FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
# Harden container permissions for healthcare workload compliance
RUN chown -R nginx:nginx /usr/share/nginx/html /var/cache/nginx /var/log/nginx /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && chown -R nginx:nginx /var/run/nginx.pid
EXPOSE 80
