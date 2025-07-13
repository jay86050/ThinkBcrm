FROM python:3.10-slim

LABEL maintainer="gjay02194@gmail.com"

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git gcc g++ make \
    libxml2-dev libxslt1-dev zlib1g-dev \
    libsasl2-dev libldap2-dev libpq-dev \
    libjpeg-dev libffi-dev libssl-dev \
    libwebp-dev libharfbuzz-dev libfribidi-dev libglib2.0-0 \
    libjpeg62-turbo-dev liblcms2-dev libblas-dev libatlas-base-dev \
    nodejs npm curl \
    wkhtmltopdf \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create Odoo user
RUN useradd -m -d /opt/odoo -U -r -s /bin/bash odoo

# Set working directory
WORKDIR /opt/odoo

# Copy Odoo source code
COPY --chown=odoo:odoo ./odoo /opt/odoo

# Create .local for Python packages
RUN mkdir -p /opt/odoo/.local && chmod -R 777 /opt/odoo/.local

# Copy configuration file
COPY ./odoo.conf /etc/odoo.conf
RUN chown odoo:odoo /etc/odoo.conf

# Copy wait-for-it.sh and fix permissions
COPY wait-for-it.sh /wait-for-it.sh
RUN chmod +x /wait-for-it.sh

# Install Python dependencies
RUN pip install --upgrade pip setuptools wheel && \
    pip install --only-binary=gevent gevent==22.10.2 && \
    sed '/gevent==/d' requirements.txt > temp-requirements.txt && \
    pip install -r temp-requirements.txt && \
    rm temp-requirements.txt

# Switch to odoo user
USER odoo

# Default command (overridden by docker-compose)
CMD ["python3", "odoo-bin", "-c", "/etc/odoo.conf"]

