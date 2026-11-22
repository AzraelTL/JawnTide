# JawnTide public website. See README.md.
FROM python:3.12.7-slim
RUN pip install --no-cache-dir PyMySQL==1.1.1
WORKDIR /app
COPY site.py wiki.py patchnotes.py market.py suit.py fatefall.py home.html fatefall.html emblem.webp favicon.ico favicon-32.png favicon-192.png apple-touch-icon.png fatefall-favicon.ico fatefall-icon-32.png fatefall-icon-192.png ./
COPY fatefall-clip-1.mp4 fatefall-clip-2.mp4 fatefall-clip-3.mp4 fatefall-clip-4.mp4 fatefall-clip-1.jpg fatefall-clip-2.jpg fatefall-clip-3.jpg fatefall-clip-4.jpg ./
COPY wiki-seed ./wiki-seed
COPY patch-notes-seed ./patch-notes-seed
USER nobody
CMD ["python", "-u", "site.py"]
