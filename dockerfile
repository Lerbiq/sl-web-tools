FROM debian:12

# Install packages and remove cache
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
RUN apt-get update -y && \
    apt-get install -y curl unzip nginx python3 python3-pip nodejs && \
    rm -rf /var/lib/apt/lists/*

# Download and extract the repository
RUN curl -L https://github.com/NabuCasa/sl-web-tools/archive/refs/tags/0.10.1.zip -o sl-web-tools.zip && \
    unzip sl-web-tools.zip && \
    rm sl-web-tools.zip

# Copy application files
COPY . /www/app
ADD . /www/app

# Install npm dependencies
RUN npm install @nabucasa/sl-web-tools

# Create Nginx configuration
RUN echo 'server { \
    listen 80; \
    server_name localhost; \
    root /www/sl-web-tools; \
    index index.html; \
    location / { \
        try_files $uri $uri/ =404; \
    } \
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|html)$ { \
        expires 30d; \
        add_header Cache-Control "public, no-transform"; \
    } \
    location /pyodide/ { \
        add_header "Access-Control-Allow-Origin" "*"; \
    } \
}' > /etc/nginx/sites-available/app && \
      ln -s /etc/nginx/sites-available/app /etc/nginx/sites-enabled/

CMD ["nginx", "-g", "daemon off;"]
