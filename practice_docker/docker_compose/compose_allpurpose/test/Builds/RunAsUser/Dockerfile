FROM ubuntu:22.04
LABEL maintainer="devuser@example.com"

RUN apt-get update && \
    apt-get install -y apache2 && \
    apt-get clean

# Create the default index file, so we know it is our container
RUN echo "Created by dockerfile" > /var/www/html/index.html

# Expose port 80
EXPOSE 80

# Start Apache in the foreground
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]