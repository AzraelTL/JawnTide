"""
JawnTide patch notes page (/patch-notes): the same notes that go on Discord, for players who can't read them there.

Anyone can read. Staff (a wiki account flagged as admin) sign in with their wiki login and get a box on the page to
post a new set of notes, and Edit / Delete on each one. The Discord text can be pasted as it is: a line that is
only **bold** becomes a heading, "- " lines become a list.

Stored in ace_wiki.site_text (the table the Fatefall page's words use, already granted to the web user), one row per
set of notes: k = "patch:" + the UTC time it was posted (YYYYMMDDHHMMSS), v = JSON {"title", "body"}.

Starter notes: patch-notes-seed/*.md (file name = the time posted, first line "# Title") are added once, the first
time the page is opened, if that set isn't there yet. A set staff later delete is not added again.
"""
import html
import json
import os
import re
import threading
import traceback
from datetime import datetime
from urllib.parse import urlparse

import wiki

SEED_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "patch-notes-seed")
MAX_TITLE = 120
MAX_BODY = 20_000
KEY = re.compile(r"patch:(\d{14})")
SEEDED = "patchseed:"      # k of the marker row for a starter file that has been added (so deleting it sticks)

e = html.escape
_seed_lock = threading.Lock()
_seed_done = False


def _prepare(body):
    """Discord text to wiki markup: drop a surrounding ``` fence, and turn a line that is only **bold** into a heading"""
    lines = body.replace("\r\n", "\n").strip().split("\n")
    if len(lines) >= 2 and lines[0].strip().startswith("```") and lines[-1].strip() == "```":
        lines = lines[1:-1]
    out = []
    for line in lines:
        m = re.fullmatch(r"\s*\*\*([^*]+)\*\*\s*", line)
        out.append(f"### {m.group(1).strip()}" if m else line)
    return "\n".join(out)


def _seed():
    """Adds the starter notes that aren't in yet. Runs once per start; failures are retried on the next page view."""
    global _seed_done
    if _seed_done or not os.path.isdir(SEED_DIR):
        return
    with _seed_lock:
        if _seed_done:
            return
        for name in sorted(os.listdir(SEED_DIR)):
            m = re.fullmatch(r"(\d{14})\.md", name)
            if not m:
                continue
            stamp = m.group(1)
            if wiki._q("SELECT 1 FROM site_text WHERE k = %s", (SEEDED + stamp,), one=True):
                continue
            with open(os.path.join(SEED_DIR, name), encoding="utf-8") as f:
                text = f.read().strip()
            first, _, rest = text.partition("\n")
            title = first.lstrip("#").strip() if first.startswith("#") else ""
            body = rest.strip() if first.startswith("#") else text
            wiki._x("INSERT IGNORE INTO site_text (k, v, updated_at, updated_by) VALUES (%s, %s, UTC_TIMESTAMP(), %s)",
                    ("patch:" + stamp, json.dumps(dict(title=title, body=body), ensure_ascii=False), "JawnTide"))
            wiki._x("INSERT IGNORE INTO site_text (k, v, updated_at, updated_by) VALUES (%s, %s, UTC_TIMESTAMP(), %s)",
                    (SEEDED + stamp, "1", "JawnTide"))
        _seed_done = True


def _notes():
    rows = wiki._q("SELECT k, v, updated_by FROM site_text WHERE k LIKE %s ORDER BY k DESC LIMIT 200", ("patch:%",))
    notes = []
    for k, v, by in rows:
        m = KEY.fullmatch(k)
        if not m:
            continue
        try:
            data = json.loads(v)
            when = datetime.strptime(m.group(1), "%Y%m%d%H%M%S")
        except Exception:
            continue
        notes.append(dict(stamp=m.group(1), when=when, title=str(data.get("title") or ""), body=str(data.get("body") or ""), by=by))
    return notes


def _page(h, title, body, user, status=200):
    who = '<p class="muted"><a href="/wiki/login?next=/patch-notes">Staff sign in</a></p>'
    if user:
        who = f'<p class="muted">Signed in as <b>{e(user["name"])}</b>{" (staff)" if user["admin"] else ""}.</p>'
    wiki._send(h, status, wiki._layout("/patch-notes", title, body + who, None))


def _form(action, user, title="", body="", button="Post patch notes", error=""):
    return (f'<form class="wedit" method="post" action="{action}">{wiki._hidden(user)}'
            + (f'<p class="err">{e(error)}</p>' if error else "")
            + f'<label>Title (optional, for example "Stage 2")<input name="title" maxlength="{MAX_TITLE}" value="{e(title)}"></label>'
            f'<label>Notes: paste the Discord text as it is<textarea name="body" required maxlength="{MAX_BODY}" style="min-height:14rem">{e(body)}</textarea></label>'
            f'<div class="row"><button class="btn">{button}</button></div></form>')


def _list(h, user, error="", draft=None):
    try:
        _seed()
    except Exception:
        traceback.print_exc()
    staff = bool(user and user["admin"] and not user["blocked"])
    items = []
    for n in _notes():
        tools = ""
        if staff:
            tools = (f'<p class="muted"><a href="/patch-notes/{n["stamp"]}/edit">Edit</a> · '
                     f'<form class="inline" method="post" action="/patch-notes/{n["stamp"]}/delete" '
                     f'onsubmit="return confirm(\'Delete these patch notes?\')">{wiki._hidden(user)}<button class="link">Delete</button></form></p>')
        date = n["when"].strftime("%B %d, %Y").replace(" 0", " ")
        heading = f'{e(n["title"])} <span class="muted">· {date}</span>' if n["title"] else date
        items.append(f'<article class="pnote"><h2>{heading}</h2>{wiki.render(_prepare(n["body"]))[0]}{tools}</article>')
    post = ""
    if staff:
        d = draft or {}
        post = ('<details class="pnew"' + (" open" if error else "") + '><summary>Post new patch notes</summary>'
                + _form("/patch-notes/post", user, d.get("title", ""), d.get("body", ""), error=error) + '</details>')
    body = ('<h1>Patch notes</h1><p class="lede">Every change to JawnTide, newest first. These are the same notes '
            'posted on Discord.</p>' + post
            + ("".join(items) or '<p class="empty">No patch notes have been posted yet.</p>'))
    _page(h, "Patch notes", body, user)


def _read(form):
    title = " ".join((form.get("title") or "").split())[:MAX_TITLE]
    body = (form.get("body") or "").replace("\r\n", "\n").strip()
    if not body:
        return title, body, "The notes are empty."
    if len(body) > MAX_BODY:
        return title, body, f"That is too long (at most {MAX_BODY:,} characters)."
    return title, body, ""


def _staff(h, user, form):
    """True when this is a staff member's own form post; otherwise it has answered the request"""
    if not user or not user["admin"] or user["blocked"]:
        _page(h, "Not allowed", "<h1>Only staff can do that</h1><p><a href=\"/wiki/login\">Sign in</a> with a staff wiki account.</p>", user, 403)
        return False
    if not wiki._csrf_ok(h, form, user):
        _page(h, "Out of date", "<h1>This page is out of date</h1><p>Go back, reload it and try again.</p>", user, 403)
        return False
    return True


def handle(h, method):
    """Serves /patch-notes and everything under it. Returns True when it handled the request."""
    path = urlparse(h.path).path.rstrip("/") or "/"
    if path != "/patch-notes" and not path.startswith("/patch-notes/"):
        return False
    try:
        user = wiki._current_user(h)
        parts = path.split("/")[2:]
        if not parts:
            if method != "GET":
                wiki._send(h, 405, "Method not allowed", "text/plain")
            else:
                _list(h, user)
        elif parts == ["post"] and method == "POST":
            form = wiki._form(h)
            if _staff(h, user, form):
                title, body, error = _read(form)
                if not error and wiki._limited(f"patch-post:{user['id']}", 10, 60):
                    error = "Too many posts. Wait a minute."
                if error:
                    _list(h, user, error, dict(title=title, body=body))
                else:
                    wiki._x("INSERT INTO site_text (k, v, updated_at, updated_by) VALUES (%s, %s, UTC_TIMESTAMP(), %s)",
                            ("patch:" + datetime.utcnow().strftime("%Y%m%d%H%M%S"), json.dumps(dict(title=title, body=body), ensure_ascii=False),
                             str(user["name"])[:64]))
                    wiki._redirect(h, "/patch-notes")
        elif len(parts) == 2 and re.fullmatch(r"\d{14}", parts[0]) and parts[1] in ("edit", "delete"):
            key = "patch:" + parts[0]
            row = wiki._q("SELECT v FROM site_text WHERE k = %s", (key,), one=True)
            if not row:
                _page(h, "Not found", "<h1>Those patch notes are gone</h1><p><a href=\"/patch-notes\">Back to patch notes</a></p>", user, 404)
            elif method == "GET" and parts[1] == "edit":
                if not user or not user["admin"] or user["blocked"]:
                    _page(h, "Not allowed", "<h1>Only staff can do that</h1>", user, 403)
                else:
                    data = json.loads(row[0])
                    _page(h, "Edit patch notes", "<h1>Edit patch notes</h1>"
                          + _form(f"/patch-notes/{parts[0]}/edit", user, str(data.get("title") or ""), str(data.get("body") or ""), "Save")
                          + '<p><a href="/patch-notes">Cancel</a></p>', user)
            elif method == "POST":
                form = wiki._form(h)
                if _staff(h, user, form):
                    if parts[1] == "delete":
                        wiki._x("DELETE FROM site_text WHERE k = %s", (key,))
                        wiki._redirect(h, "/patch-notes")
                    else:
                        title, body, error = _read(form)
                        if error:
                            _page(h, "Edit patch notes", "<h1>Edit patch notes</h1>"
                                  + _form(f"/patch-notes/{parts[0]}/edit", user, title, body, "Save", error), user, 400)
                        else:
                            wiki._x("UPDATE site_text SET v = %s, updated_at = UTC_TIMESTAMP(), updated_by = %s WHERE k = %s",
                                    (json.dumps(dict(title=title, body=body), ensure_ascii=False), str(user["name"])[:64], key))
                            wiki._redirect(h, "/patch-notes")
            else:
                wiki._send(h, 405, "Method not allowed", "text/plain")
        else:
            _page(h, "Not found", "<h1>Not found</h1>", user, 404)
    except Exception:
        traceback.print_exc()
        try:
            wiki._send(h, 503, wiki._layout("/patch-notes", "Patch notes unavailable",
                                            "<h1>Patch notes are unavailable</h1><p>Try again in a minute.</p>", None))
        except Exception:
            pass
    return True
