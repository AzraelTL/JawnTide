# JawnTide public website. See README.md.
FROM python:3.12.7-slim
RUN pip install --no-cache-dir PyMySQL==1.1.1
WORKDIR /app
COPY site.py wiki.py home.html emblem.webp ./
COPY wiki-seed ./wiki-seed
USER nobody
CMD ["python", "-u", "site.py"]
