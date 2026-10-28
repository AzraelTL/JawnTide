# JawnTide resource monitor: a small read-only web page for the LAN. See README.md.
FROM python:3.12.7-slim
RUN pip install --no-cache-dir PyMySQL==1.1.1 && mkdir /data && chown nobody /data
WORKDIR /app
COPY monitor.py settings_catalog.json ./
USER nobody
CMD ["python", "-u", "monitor.py"]
