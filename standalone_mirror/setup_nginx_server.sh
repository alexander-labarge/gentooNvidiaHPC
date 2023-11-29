#!/bin/bash

# Install Nginx
sudo apt-get install nginx -y

# Start Nginx service
sudo systemctl start nginx

# Take Ownership
sudo chown -R www-data:www-data /mirror/

# Remove Conflicts
sudo rm /etc/nginx/sites-available/*
sudo rm /etc/nginx/sites-enabled/*

# Create Nginx site configuration
sudo tee /etc/nginx/sites-available/typhon-mirror <<'EOF'
server {
    listen 80;
    server_name _;

    location / {
        root /mirror/;
        autoindex on;  # Enables directory listing
        try_files $uri $uri/ =404;
    }
}
EOF

# Create symbolic link to enable the site
sudo ln -s /etc/nginx/sites-available/typhon-mirror /etc/nginx/sites-enabled/typhon-mirror

# Reload Nginx to apply changes
sudo systemctl reload nginx
