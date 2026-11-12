# JawnTide public website. See README.md.
FROM python:3.12.7-slim
RUN pip install --no-cache-dir PyMySQL==1.1.1
WORKDIR /app
COPY site.py wiki.py market.py suit.py home.html emblem.webp favicon.ico favicon-32.png favicon-192.png apple-touch-icon.png ./
COPY wiki-seed ./wiki-seed
USER nobody
CMD ["python", "-u", "site.py"]
