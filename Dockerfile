# Use the official ERPNext image as the base (using latest v15)
FROM frappe/erpnext:v15

# Switch to the frappe user
USER frappe

# Set working directory
WORKDIR /home/frappe/frappe-bench

# Remove the pre-installed ERPNext app (but keep frappe)
RUN rm -rf apps/erpnext

# Install custom apps from Git repositories
RUN bench get-app golbazaar https://github.com/abhiknack/golbazaar.git
RUN bench get-app --branch golv1 erpnext https://github.com/abhiknack/golerpnext.git
RUN bench get-app insights

# Update apps.txt to reflect installed apps
RUN ls -1 apps > sites/apps.txt

# Clean up cache
RUN rm -rf ~/.cache/pip

# Optional: Copy custom site configurations
# COPY --chown=frappe:frappe ./custom_site_config.json ./sites/common_site_config.json

# Keep the default command
CMD ["/home/frappe/frappe-bench/env/bin/gunicorn", "--chdir=/home/frappe/frappe-bench/sites", "--bind=0.0.0.0:8000", "--threads=4", "--workers=2", "--worker-class=gthread", "--worker-tmp-dir=/dev/shm", "--timeout=120", "--preload", "frappe.app:application"]
