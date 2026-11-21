"""The Fatefall page (jawntide.com/fatefall) and its text editing.

fatefall.html is one self-contained page with its own look. Its words can be changed in place by staff: anyone signed in
to the site (the wiki's sign-in) whose game account is staff gets an Admin button that outlines every piece of text,
and Save keeps the result in ace_wiki.site_text. The saved words are laid over the page for every visitor; the words
in the file are what shows until something is saved, and whenever the database cannot be reached.

The game's files are downloaded from it with a password the owner hands out (/fatefall/download): the newest .zip in
DOWNLOAD_DIR (a folder of the server mounted read-only, see compose.yml), for anyone who gives FATEFALL_DOWNLOAD_PASSWORD
(kept in the server's .env, never in the repository). A right password is answered with a link that works for a few
hours, so the password itself is never in an address.

Tables: ace_wiki.site_text (wiki-schema.sql; wiki-setup.sh grants it to the web user).
"""
import hmac
import json
import os
import re
import secrets
import threading
import time
import zipfile
import traceback
from urllib.parse import parse_qs, urlparse

import wiki

PAGE_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "fatefall.html")
STATE_MARK = "<!--FATEFALL_STATE-->"
MAX_SAVE = 200_000          # bytes of JSON in one save
KEY = re.compile(r"[a-z0-9-]{1,60}")
DOWNLOAD_DIR = os.environ.get("FATEFALL_DOWNLOAD_DIR", "/downloads")
DOWNLOAD_PASSWORD = os.environ.get("FATEFALL_DOWNLOAD_PASSWORD", "")
DOWNLOAD_HOURS = 6          # how long the link given for a right password works
_download_key = secrets.token_bytes(32)   # signs those links; new each time the site starts
_cache = {"at": 0.0, "text": None}
_lock = threading.Lock()


def _saved():
    """What staff last saved (a dict), or None. Kept for 30 seconds so visitors don't each ask the database."""
    now = time.time()
    with _lock:
        if now - _cache["at"] < 30:
            return _cache["text"]
    try:
        row = wiki._q("SELECT v FROM site_text WHERE k = %s", ("fatefall",), one=True)
        text = _clean(json.loads(row[0])) if row else None
    except Exception:
        text = None             # no table yet, or the database is away: the page shows the words in its file
    with _lock:
        _cache.update(at=now, text=text)
    return text


def _clean(data):
    """Only what the page stores: short keys, each a line of text or a list of lines."""
    if not isinstance(data, dict) or len(data) > 300:
        return None
    out = {}
    for k, v in data.items():
        if not isinstance(k, str) or not KEY.fullmatch(k):
            return None
        if isinstance(v, str):
            out[k] = v[:4000]
        elif isinstance(v, list) and len(v) <= 200 and all(isinstance(line, str) for line in v):
            out[k] = [line[:4000] for line in v]
        else:
            return None
    return out


def _script_json(value):
    """JSON that is safe inside a <script> element."""
    return json.dumps(value, ensure_ascii=False).replace("<", "\\u003c").replace("\u2028", "\\u2028").replace("\u2029", "\\u2029")


def _send(h, status, body, ctype, cache):
    data = body.encode("utf-8")
    h.send_response(status)
    h.send_header("Content-Type", ctype)
    h.send_header("Content-Length", str(len(data)))
    h.send_header("Cache-Control", cache)
    h.send_header("X-Content-Type-Options", "nosniff")
    h.send_header("Referrer-Policy", "strict-origin-when-cross-origin")
    h.send_header("X-Frame-Options", "DENY")
    h.end_headers()
    h.wfile.write(data)


def _download_file():
    """(path, name, size, modified) of the newest .zip in the download folder, or None."""
    try:
        zips = [e for e in os.scandir(DOWNLOAD_DIR) if e.is_file() and e.name.lower().endswith(".zip") and not e.name.startswith(".")]
    except OSError:
        return None
    if not zips:
        return None
    newest = max(zips, key=lambda e: e.stat().st_mtime)
    st = newest.stat()
    return newest.path, newest.name, st.st_size, st.st_mtime


_version_cache = {}


def _download_version():
    """The version of the game in the download: the version.txt packed in the zip (a date and time, 20261120-183601),
    which the game's launcher compares with its own to know when to update. '' when there is none."""
    found = _download_file()
    if not found:
        return ""
    key = (found[0], found[2], found[3])
    if key not in _version_cache:
        version = ""
        try:
            with zipfile.ZipFile(found[0]) as z:
                inside = [n for n in z.namelist() if n.split("/")[-1] == "version.txt" and n.count("/") <= 1]
                if inside:
                    version = z.read(inside[0]).decode("ascii", "replace").strip()
        except Exception:
            version = ""
        if not re.fullmatch(r"20\d{6}-\d{6}", version):
            version = ""
        _version_cache.clear()
        _version_cache[key] = version
    return _version_cache[key]


def _download_info():
    """What the page may say about the download (never where it is kept), or None when there is nothing to give."""
    found = _download_file() if DOWNLOAD_PASSWORD else None
    if not found:
        return None
    return {"name": found[1], "megabytes": round(found[2] / 1048576), "date": time.strftime("%B %d, %Y", time.gmtime(found[3])),
            "version": _download_version()}


def _ticket(expires):
    return hmac.new(_download_key, str(expires).encode(), "sha256").hexdigest()


def _redirect(h, where):
    h.send_response(303)
    h.send_header("Location", where)
    h.send_header("Cache-Control", "no-store")
    h.send_header("Content-Length", "0")
    h.end_headers()


def _download_ask(h):
    """The password form's answer: a link to the file that works for a few hours, or back to the page with a reason."""
    origin = h.headers.get("Origin")
    if origin and urlparse(origin).netloc != h.headers.get("Host", ""):
        return _send(h, 403, "That request came from another site.", "text/plain", "no-store")
    length = min(int(h.headers.get("Content-Length") or 0), 4000)
    form = parse_qs(h.rfile.read(length).decode("utf-8", "replace"), keep_blank_values=True)
    given = (form.get("password") or [""])[0]
    if not DOWNLOAD_PASSWORD or not _download_file():
        return _redirect(h, "/fatefall?download=none#download")
    if wiki._limited("fatefall-download:" + wiki._client_ip(h), 8, 600):
        return _redirect(h, "/fatefall?download=wait#download")
    if not hmac.compare_digest(given.encode("utf-8"), DOWNLOAD_PASSWORD.encode("utf-8")):
        return _redirect(h, "/fatefall?download=wrong#download")
    expires = int(time.time()) + DOWNLOAD_HOURS * 3600
    _redirect(h, f"/fatefall/file?e={expires}&t={_ticket(expires)}")


def _download_send(h):
    """Sends the file to someone holding a link that is still good. Answers Range requests, so a download can resume."""
    query = parse_qs(urlparse(h.path).query)
    expires, ticket = (query.get("e") or [""])[0], (query.get("t") or [""])[0]
    found = _download_file()
    if not expires.isdigit() or int(expires) < time.time() or not hmac.compare_digest(ticket, _ticket(expires)) or not found:
        return _redirect(h, "/fatefall?download=expired#download")
    path, name, size, _ = found
    first, last, status = 0, size - 1, 200
    m = re.fullmatch(r"bytes=(\d*)-(\d*)", h.headers.get("Range", "").strip())
    if m and (m.group(1) or m.group(2)):
        if m.group(1):
            first = int(m.group(1))
            last = min(int(m.group(2)), size - 1) if m.group(2) else size - 1
        else:
            first = max(size - int(m.group(2)), 0)
        if first > last or first >= size:
            h.send_response(416)
            h.send_header("Content-Range", f"bytes */{size}")
            h.send_header("Content-Length", "0")
            h.end_headers()
            return
        status = 206
    safe = re.sub(r"[^A-Za-z0-9._-]", "_", name)
    h.send_response(status)
    h.send_header("Content-Type", "application/zip")
    h.send_header("Content-Disposition", f'attachment; filename="{safe}"')
    h.send_header("Content-Length", str(last - first + 1))
    h.send_header("Accept-Ranges", "bytes")
    if status == 206:
        h.send_header("Content-Range", f"bytes {first}-{last}/{size}")
    h.send_header("Cache-Control", "private, no-store")
    h.send_header("X-Content-Type-Options", "nosniff")
    h.end_headers()
    left = last - first + 1
    try:
        with open(path, "rb") as f:
            f.seek(first)
            while left > 0:
                chunk = f.read(min(262144, left))
                if not chunk:
                    break
                h.wfile.write(chunk)
                left -= len(chunk)
    except (BrokenPipeError, ConnectionResetError):
        pass    # they stopped the download


def _user(h):
    """The signed-in visitor, or None (also None when the database cannot be asked)."""
    if "jtw=" not in h.headers.get("Cookie", ""):
        return None
    try:
        return wiki._current_user(h)
    except Exception:
        return None


def _page(h):
    with open(PAGE_FILE, encoding="utf-8") as f:
        page = f.read()
    user = _user(h)
    edit = None
    if user:
        staff = bool(user["admin"]) and not user["blocked"]
        edit = {"staff": staff, "name": user["name"]}
        if staff:
            edit["csrf"] = user["csrf"]
    state = (f"<script>window.FATEFALL_TEXT = {_script_json(_saved())}; window.FATEFALL_EDIT = {_script_json(edit)}; "
             f"window.FATEFALL_DOWNLOAD = {_script_json(_download_info())};</script>")
    # someone signed in gets their own copy (it carries their form token); everyone else's can be kept briefly
    _send(h, 200, page.replace(STATE_MARK, state, 1), "text/html; charset=utf-8", "no-store" if user else "public, max-age=60")


def _save(h):
    def answer(status, **body):
        _send(h, status, json.dumps(body), "application/json", "no-store")

    origin = h.headers.get("Origin")
    if origin and urlparse(origin).netloc != h.headers.get("Host", ""):
        return answer(403, ok=False, error="That request came from another site.")
    user = _user(h)
    if not user or not user["admin"] or user["blocked"]:
        return answer(403, ok=False, error="Only staff can change this page. Sign in again.")
    if not hmac.compare_digest(h.headers.get("X-CSRF", ""), user["csrf"]):
        return answer(403, ok=False, error="This page is out of date. Reload it and try again.")
    if wiki._limited(f"fatefall-save:{user['id']}", 20, 60):
        return answer(429, ok=False, error="Too many saves. Wait a minute.")
    length = int(h.headers.get("Content-Length") or 0)
    if length <= 0 or length > MAX_SAVE:
        return answer(413, ok=False, error="That is too much text to save at once.")
    try:
        text = _clean(json.loads(h.rfile.read(length).decode("utf-8")))
    except Exception:
        text = None
    if text is None:
        return answer(400, ok=False, error="The page sent something that could not be saved.")
    try:
        wiki._x("REPLACE INTO site_text (k, v, updated_at, updated_by) VALUES (%s, %s, UTC_TIMESTAMP(), %s)",
                ("fatefall", json.dumps(text, ensure_ascii=False), str(user["name"])[:64]))
    except Exception:
        traceback.print_exc()
        return answer(503, ok=False, error="Could not reach the database (has wiki-setup.sh been run since this was added?).")
    with _lock:
        _cache.update(at=time.time(), text=text)
    answer(200, ok=True)


def handle(h, method):
    """Serves /fatefall and what is under it. Returns True when it handled the request."""
    path = urlparse(h.path).path.rstrip("/") or "/"
    if path == "/fatefall" and method == "GET":
        _page(h)
    elif path == "/fatefall/save" and method == "POST":
        _save(h)
    elif path == "/fatefall/download" and method == "POST":
        _download_ask(h)
    elif path == "/fatefall/file" and method == "GET":
        _download_send(h)
    elif path == "/fatefall/version" and method == "GET":
        # for the game's launcher: one line, nothing secret
        _send(h, 200, (_download_version() if DOWNLOAD_PASSWORD else "") + "\n", "text/plain; charset=utf-8", "no-store")
    else:
        return False
    return True
