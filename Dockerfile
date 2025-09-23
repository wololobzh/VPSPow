# Use the official PHP image as a base image
FROM php:8.1-apache

# Copy the application code to the container
COPY src/ /var/www/html/

# Expose port 80
EXPOSE 80
