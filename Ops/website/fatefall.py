"""The Fatefall page (jawntide.com/fatefall) and its text editing.

fatefall.html is one self-contained page with its own look. Its words can be changed in place by staff: anyone signed in
to the site (the wiki's sign-in) whose game account is staff gets an Admin button that outlines every piece of text,
and Save keeps the result in ace_wiki.site_text. The saved words are laid over the page for every visitor; the words
in the file are what shows until something is saved, and whenever the database cannot be reached.

Tables: ace_wiki.site_text (wiki-schema.sql; wiki-setup.sh grants it to the web user).
"""
import hmac
import json
import os
import re
import threading
import time
import traceback
from urllib.parse import urlparse

import wiki

PAGE_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "fatefall.html")
STATE_MARK = "<!--FATEFALL_STATE-->"
MAX_SAVE = 200_000          # bytes of JSON in one save
KEY = re.compile(r"[a-z0-9-]{1,60}")
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
    state = f"<script>window.FATEFALL_TEXT = {_script_json(_saved())}; window.FATEFALL_EDIT = {_script_json(edit)};</script>"
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
    """Serves /fatefall and /fatefall/save. Returns True when it handled the request."""
    path = urlparse(h.path).path.rstrip("/") or "/"
    if path == "/fatefall" and method == "GET":
        _page(h)
    elif path == "/fatefall/save" and method == "POST":
        _save(h)
    else:
        return False
    return True
