# Use the official ERPNext image as the base (using latest v15)
FROM frappe/erpnext:v15

# Install build dependencies as root
USER root
RUN apt-get update && apt-get install -y \
    pkg-config \
    default-libmysqlclient-dev \
    gcc \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Switch to the frappe user
USER frappe

# Set working directory
WORKDIR /home/frappe/frappe-bench

# Remove the pre-installed ERPNext app (but keep frappe)
RUN rm -rf apps/erpnext

# Install custom apps from Git repositories
RUN bench get-app golbazaar https://github.com/abhiknack/golbazaar.git
RUN bench get-app --branch my-fixed-branch erpnext https://github.com/abhiknack/golerpnext.git
USER root
RUN /home/frappe/frappe-bench/env/bin/pip install mysqlclient
USER frappe
RUN bench get-app insights https://github.com/frappe/insights.git
# Skip insights - it has complex build dependencies
# You can install it later manually with: bench get-app insights
# RUN bench get-app insights https://github.com/frappe/insights.git

# Update apps.txt to reflect installed apps
RUN ls -1 apps > sites/apps.txt

# Clean up cache
RUN rm -rf ~/.cache/pip

# Optional: Copy custom site configurations
# COPY --chown=frappe:frappe ./custom_site_config.json ./sites/common_site_config.json

# Keep the default command
CMD ["/home/frappe/frappe-bench/env/bin/gunicorn", "--chdir=/home/frappe/frappe-bench/sites", "--bind=0.0.0.0:8000", "--threads=4", "--workers=2", "--worker-class=gthread", "--worker-tmp-dir=/dev/shm", "--timeout=120", "--preload", "frappe.app:application"]
