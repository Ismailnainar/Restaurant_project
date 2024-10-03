# Use the latest Flutter image from the stable channel
FROM cirrusci/flutter:stable

LABEL maintainer="THARIQ & ISMAIL"

# Set a non-root user to avoid running Flutter as root
RUN adduser -u 1001 --disabled-password --gecos "" flutteruser && \
    mkdir -p /app && \
    chown -R flutteruser:flutteruser /app

# Set ownership of the Flutter SDK to the new user
RUN chown -R flutteruser:flutteruser /sdks/flutter

# Switch to the non-root user
USER flutteruser

# Switch to Flutter version 3.24.1
RUN cd /sdks/flutter && \
    git fetch --all --tags && \
    git checkout 3.24.1 && \
    flutter doctor

# Set the working directory inside the container
WORKDIR /app

# Copy the current project files, including assets and fonts, to the working directory
COPY --chown=flutteruser:flutteruser . /app

# Check that assets/fonts directory exists and contains the necessary font files
RUN ls -la /app/assets/fonts

# Install Flutter dependencies including flutter_typeahead
RUN flutter pub get

# Build the Flutter project for the web, ensuring fonts, assets, and flutter_typeahead are included
RUN flutter build web

# Switch back to root for Nginx installation and permissions setup
USER root

# Install Nginx to serve the Flutter web build
RUN apt-get update && apt-get install -y nginx

# Replace the default Nginx config with the custom one
RUN rm /etc/nginx/sites-available/default
COPY nginx.conf /etc/nginx/sites-available/default

# Copy the Flutter web build files, including assets, to the Nginx web server directory
RUN cp -r /app/build/web/* /var/www/html/

# Ensure assets and fonts are properly copied for web build
RUN ls -la /var/www/html/assets/fonts

# Expose port 80 for serving the Flutter app
EXPOSE 80

# Start Nginx when the container starts
CMD ["nginx", "-g", "daemon off;"]
