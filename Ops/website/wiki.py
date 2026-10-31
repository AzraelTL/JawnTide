"""
JawnTide wiki: articles about the server's custom content, edited by players who have linked their game account.

Contributors: staff tick one character per game account on the LAN monitor's Levels page (table contributor). Only
that character can link, and a login stops working as soon as it is unticked or another character is ticked.
Linking: /wiki/link makes a short code; the contributor types /wiki CODE in game (WikiCommands.cs fills in the account and
character); the site then lets them set a wiki password. Later logins use character name + password. Running the code
step again resets the password. Staff (game accounts with an access level above 0) can revert, lock and block.

Storage is the ace_wiki database (wiki-schema.sql), reached with the website's own user, which can write only there.
Every save is a new revision; nothing is ever overwritten. Page text is a small, safe markup (see render()).
"""
import hashlib
import hmac
import html
import os
import re
import secrets
import threading
import time
import traceback
from datetime import datetime, timedelta
from urllib.parse import parse_qs, quote, urlparse

e = lambda v: html.escape("" if v is None else str(v))
WIKI_DB = os.environ.get("WIKI_DB", "ace_wiki")
SEED_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "wiki-seed")
SESSION_DAYS = 30
CODE_MINUTES = 10
MAX_BODY = 100_000
CODE_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"   # no 0/O or 1/I

_db_args = None
_layout = None
_limits = {}
_limits_lock = threading.Lock()


def init(db_args, layout):
    """Called once by site.py with its database settings and page layout function."""
    global _db_args, _layout
    _db_args = dict(db_args, database=WIKI_DB, autocommit=True)
    _layout = layout
    threading.Thread(target=_seed_when_ready, daemon=True).start()


def _conn():
    import pymysql
    return pymysql.connect(**_db_args)


def _q(sql, args=None, one=False):
    conn = _conn()
    try:
        cur = conn.cursor()
        cur.execute(sql, args)
        rows = cur.fetchall()
        return (rows[0] if rows else None) if one else rows
    finally:
        conn.close()


def _x(sql, args=None):
    conn = _conn()
    try:
        cur = conn.cursor()
        cur.execute(sql, args)
        return cur.lastrowid
    finally:
        conn.close()


def _limited(key, count, seconds):
    """True when key has been used count times in the last seconds."""
    now = time.time()
    with _limits_lock:
        hits = [t for t in _limits.get(key, []) if now - t < seconds]
        if len(hits) >= count:
            _limits[key] = hits
            return True
        hits.append(now)
        _limits[key] = hits
        return False


# ---------------------------------------------------------------- markup

def slugify(title):
    s = re.sub(r"[^a-z0-9]+", "-", title.lower()).strip("-")
    return s[:80] or "page"


def _inline(text):
    """Escape first, then apply a few safe inline styles. Only http(s), site-relative and wiki links are made.
    Code spans are set aside first so nothing inside them is styled or linked."""
    codes = []

    def stash(m):
        codes.append(m.group(1))
        return f"\x00{len(codes) - 1}\x00"

    t = re.sub(r"`([^`]+)`", stash, e(text))
    t = re.sub(r"\[\[([^\]|]{1,120})(?:\|([^\]]{1,120}))?\]\]",
               lambda m: f'<a href="/wiki/{slugify(html.unescape(m.group(1)))}">{m.group(2) or m.group(1)}</a>', t)
    t = re.sub(r"\[([^\]]{1,200})\]\((https?://[^\s)]{1,500})\)",
               lambda m: f'<a href="{m.group(2)}" rel="nofollow noopener" target="_blank">{m.group(1)}</a>', t)
    t = re.sub(r"\[([^\]]{1,200})\]\((/(?![/\\])[^\s)]{0,300})\)", r'<a href="\2">\1</a>', t)
    t = re.sub(r"\*\*([^*]+)\*\*", r"<b>\1</b>", t)
    t = re.sub(r"(?<![\w*])\*([^*\n]+)\*(?![\w*])", r"<i>\1</i>", t)
    return re.sub(r"\x00(\d+)\x00", lambda m: f"<code>{codes[int(m.group(1))]}</code>", t)


def render(body):
    """Small wiki markup: # headings, - lists, 1. lists, | tables |, > notes, ``` code, **bold**, *italic*,
    `code`, [[Wiki link]] or [[Page|text]], [text](https://...). Everything is HTML-escaped first."""
    out, para, lines = [], [], body.replace("\r\n", "\n").split("\n")
    toc = []

    def flush():
        if para:
            out.append("<p>" + " ".join(_inline(x) for x in para) + "</p>")
            para.clear()

    i = 0
    while i < len(lines):
        line = lines[i]
        s = line.strip()
        if s.startswith("```"):
            flush()
            code = []
            i += 1
            while i < len(lines) and not lines[i].strip().startswith("```"):
                code.append(lines[i]); i += 1
            out.append("<pre><code>" + e("\n".join(code)) + "</code></pre>")
        elif re.match(r"^#{1,4} ", s):
            flush()
            level = max(2, min(4, len(s) - len(s.lstrip("#"))))    # # and ## are sections, ### and #### smaller
            text = s.lstrip("#").strip()
            anchor = slugify(text)
            if level == 2: toc.append((anchor, text))
            out.append(f'<h{level} id="{anchor}">{_inline(text)}</h{level}>')
        elif re.match(r"^[-*] ", s):
            flush()
            items = []
            while i < len(lines) and re.match(r"^[-*] ", lines[i].strip()):
                items.append("<li>" + _inline(lines[i].strip()[2:]) + "</li>"); i += 1
            out.append("<ul>" + "".join(items) + "</ul>"); continue
        elif re.match(r"^\d+\. ", s):
            flush()
            items = []
            while i < len(lines) and re.match(r"^\d+\. ", lines[i].strip()):
                items.append("<li>" + _inline(re.sub(r"^\d+\. ", "", lines[i].strip())) + "</li>"); i += 1
            out.append("<ol>" + "".join(items) + "</ol>"); continue
        elif s.startswith("|") and s.endswith("|"):
            flush()
            rows = []
            while i < len(lines) and lines[i].strip().startswith("|") and lines[i].strip().endswith("|"):
                cells = [c.strip().replace("\\|", "|") for c in re.split(r"(?<!\\)\|", lines[i].strip()[1:-1])]   # \| is a literal pipe
                if not all(re.fullmatch(r":?-{2,}:?", c) for c in cells):
                    rows.append(cells)
                i += 1
            if rows:
                head = "".join(f"<th>{_inline(c)}</th>" for c in rows[0])
                body_rows = "".join("<tr>" + "".join(f"<td>{_inline(c)}</td>" for c in r) + "</tr>" for r in rows[1:])
                out.append(f'<div class="wrap"><table><thead><tr>{head}</tr></thead><tbody>{body_rows}</tbody></table></div>')
            continue
        elif s.startswith("> "):
            flush()
            note = []
            while i < len(lines) and lines[i].strip().startswith("> "):
                note.append(_inline(lines[i].strip()[2:])); i += 1
            out.append('<aside class="note">' + " ".join(note) + "</aside>"); continue
        elif not s:
            flush()
        else:
            para.append(s)
        i += 1
    flush()
    return "".join(out), toc


# ---------------------------------------------------------------- accounts

def _hash(password, salt):
    return hashlib.scrypt(password.encode("utf-8"), salt=salt, n=2 ** 14, r=8, p=1, dklen=64)


def _new_session(user_id):
    token, csrf = secrets.token_hex(32), secrets.token_hex(16)
    _x("INSERT INTO session (token, user_id, csrf, expires_at) VALUES (%s, %s, %s, %s)",
       (token, user_id, csrf, datetime.utcnow() + timedelta(days=SESSION_DAYS)))
    _x("UPDATE wiki_user SET last_login = UTC_TIMESTAMP() WHERE id = %s", (user_id,))
    return token


def _current_user(h):
    cookie = h.headers.get("Cookie", "")
    m = re.search(r"(?:^|;\s*)jtw=([0-9a-f]{64})", cookie)
    if not m:
        return None
    # signed in only while the linked character is still its account's contributor (unticking it signs them out)
    row = _q("SELECT u.id, u.name, u.is_admin, u.blocked, s.csrf, s.token FROM session s JOIN wiki_user u ON u.id = s.user_id "
             "JOIN contributor c ON c.account_id = u.account_id AND c.char_id = u.char_id "
             "WHERE s.token = %s AND s.expires_at > UTC_TIMESTAMP()", (m.group(1),), one=True)
    if not row:
        return None
    return dict(id=row[0], name=row[1], admin=bool(row[2]), blocked=bool(row[3]), csrf=row[4], token=row[5])


def _is_contributor(account_id, char_id):
    return bool(account_id and char_id and _q("SELECT 1 FROM contributor WHERE account_id = %s AND char_id = %s",
                                             (account_id, char_id), one=True))


def _client_ip(h):
    return h.headers.get("CF-Connecting-IP") or h.client_address[0]


# ---------------------------------------------------------------- responses

def _send(h, status, body, ctype="text/html; charset=utf-8", headers=None):
    data = body.encode("utf-8")
    h.send_response(status)
    h.send_header("Content-Type", ctype)
    h.send_header("Content-Length", str(len(data)))
    h.send_header("Cache-Control", "no-store")
    h.send_header("X-Content-Type-Options", "nosniff")
    h.send_header("Referrer-Policy", "strict-origin-when-cross-origin")
    h.send_header("X-Frame-Options", "DENY")
    for k, v in (headers or {}).items():
        h.send_header(k, v)
    h.end_headers()
    h.wfile.write(data)


def _redirect(h, where, cookie=None, extra_cookie=None):
    h.send_response(303)
    h.send_header("Location", where)
    h.send_header("Cache-Control", "no-store")
    if extra_cookie:
        h.send_header("Set-Cookie", extra_cookie + "; Path=/wiki; HttpOnly; SameSite=Lax"
                      + ("; Secure" if h.headers.get("X-Forwarded-Proto", "") == "https" else ""))
    if cookie is not None:
        secure = "; Secure" if h.headers.get("X-Forwarded-Proto", "") == "https" else ""
        if cookie:
            h.send_header("Set-Cookie", f"jtw={cookie}; Path=/; Max-Age={SESSION_DAYS * 86400}; HttpOnly; SameSite=Lax{secure}")
        else:
            h.send_header("Set-Cookie", f"jtw=; Path=/; Max-Age=0; HttpOnly; SameSite=Lax{secure}")
    h.send_header("Content-Length", "0")
    h.end_headers()


def _page(h, title, body, user, status=200):
    bar = (f'<div class="wikibar"><a href="/wiki">Wiki home</a><a href="/wiki/recent">Recent changes</a>'
           f'<a href="/wiki/new">New article</a>'
           f'<form class="wsearch" action="/wiki" method="get"><input name="q" placeholder="Search the wiki" aria-label="Search the wiki"></form>'
           + (f'<span class="who">Signed in as <b>{e(user["name"])}</b>{" (staff)" if user["admin"] else ""}'
              f'<form method="post" action="/wiki/logout"><input type="hidden" name="csrf" value="{user["csrf"]}"><button class="link">Sign out</button></form></span>'
              if user else '<span class="who"><a href="/wiki/login">Sign in</a> or <a href="/wiki/link">link your game account</a></span>')
           + '</div>')
    _send(h, status, _layout("/wiki", title, bar + body, None))


def _csrf_ok(h, form, user):
    origin = h.headers.get("Origin")
    host = h.headers.get("Host", "")
    if origin and urlparse(origin).netloc != host:
        return False
    return user is None or hmac.compare_digest(form.get("csrf", ""), user["csrf"])


def _form(h):
    length = min(int(h.headers.get("Content-Length") or 0), MAX_BODY * 2)
    raw = h.rfile.read(length).decode("utf-8", "replace")
    return {k: v[0] for k, v in parse_qs(raw, keep_blank_values=True).items()}


def _hidden(user):
    return f'<input type="hidden" name="csrf" value="{user["csrf"]}">' if user else ""


def _ago(dt):
    s = int((datetime.utcnow() - dt).total_seconds())
    if s < 90: return "just now"
    if s < 3600: return f"{s // 60} min ago"
    if s < 86400: return f"{s // 3600} h ago"
    return f"{s // 86400} d ago"


# ---------------------------------------------------------------- views

def _index(h, user, query):
    q = (query.get("q", [""])[0] or "").strip()[:80]
    if q:
        like = f"%{q}%"
        rows = _q("SELECT p.slug, p.title FROM page p JOIN revision r ON r.id = p.current_rev "
                  "WHERE p.title LIKE %s OR r.body LIKE %s ORDER BY p.title LIMIT 100", (like, like))
        items = "".join(f'<li><a href="/wiki/{e(s)}">{e(t)}</a></li>' for s, t in rows) or "<li class=muted>Nothing matched.</li>"
        return _page(h, "Wiki search", f'<h1>Search: {e(q)}</h1><ul class="wlist">{items}</ul>', user)
    pages = _q("SELECT slug, title FROM page ORDER BY title")
    recent = _q("SELECT r.slug, r.title, r.created_at, COALESCE(u.name, 'JawnTide') FROM revision r LEFT JOIN wiki_user u ON u.id = r.user_id "
                "ORDER BY r.id DESC LIMIT 8")
    plist = "".join(f'<li><a href="/wiki/{e(s)}">{e(t)}</a></li>' for s, t in pages) or "<li class=muted>No articles yet.</li>"
    rlist = "".join(f'<li><a href="/wiki/{e(s)}">{e(t)}</a> <span class="muted">by {e(n)}, {_ago(c)}</span></li>' for s, t, c, n in recent)
    intro = ('<p class="lede">The JawnTide wiki covers the server\'s custom content: world bosses, Town Control, the arena, '
             'loot stages and more. Contributors chosen by staff can edit.</p>')
    _page(h, "Wiki", f'<h1>JawnTide Wiki</h1>{intro}<div class="cols"><section><h2>Articles</h2><ul class="wlist">{plist}</ul></section>'
                     f'<section><h2>Recent changes</h2><ul class="wlist">{rlist}</ul></section></div>', user)


def _view(h, user, slug, rev_id=None):
    page = _q("SELECT title, current_rev, locked, updated_at FROM page WHERE slug = %s", (slug,), one=True)
    if not page:
        create = (f'<p><a class="btn" href="/wiki/{e(slug)}/edit">Create this article</a></p>' if user and not user["blocked"]
                  else '<p><a href="/wiki/login">Sign in</a> to create it.</p>')
        return _page(h, "Not found", f'<h1>No article here yet</h1><p class="lede">There is no article called “{e(slug)}”.</p>{create}', user, 404)
    title, current, locked, updated = page
    rid = rev_id or current
    rev = _q("SELECT r.title, r.body, r.created_at, COALESCE(u.name, 'JawnTide'), r.id FROM revision r LEFT JOIN wiki_user u ON u.id = r.user_id "
             "WHERE r.id = %s AND r.slug = %s", (rid, slug), one=True)
    if not rev:
        return _page(h, "Not found", "<h1>That version doesn't exist</h1>", user, 404)
    body, toc = render(rev[1])
    old = (f'<aside class="note">You are looking at an older version from {e(rev[2].strftime("%b %d, %Y %H:%M"))} UTC by {e(rev[3])}. '
           f'<a href="/wiki/{e(slug)}">See the current article</a>.'
           + (f' <form class="inline" method="post" action="/wiki/{e(slug)}/revert/{rid}">{_hidden(user)}<button class="link">Restore this version</button></form>'
              if user and user["admin"] else '') + '</aside>') if rid != current else ''
    can_edit = user and not user["blocked"] and (not locked or user["admin"])
    tools = [f'<a href="/wiki/{e(slug)}/history">History</a>']
    if can_edit: tools.insert(0, f'<a href="/wiki/{e(slug)}/edit">Edit</a>')
    if user and user["admin"]:
        tools.append(f'<form class="inline" method="post" action="/wiki/{e(slug)}/lock">{_hidden(user)}<button class="link">{"Unlock" if locked else "Lock"}</button></form>')
    lock_note = ' · <span class="badge">Locked</span>' if locked else ''
    toc_html = ('<nav class="toc"><b>On this page</b>' + "".join(f'<a href="#{a}">{e(t)}</a>' for a, t in toc) + '</nav>') if len(toc) >= 3 else ''
    _page(h, rev[0], f'{old}<div class="wtools">{" · ".join(tools)}{lock_note}</div><h1>{e(rev[0])}</h1>'
                     f'<p class="muted wmeta">Last edited by {e(rev[3])}, {_ago(rev[2])}</p>{toc_html}<article class="wiki">{body}</article>', user)


def _edit_form(h, user, slug, title, body, summary="", error=""):
    err = f'<p class="err">{e(error)}</p>' if error else ''
    help_ = ('<details class="help"><summary>Formatting help</summary><pre># Heading\n## Section\n**bold**  *italic*  `code`\n'
             '- list item\n1. numbered item\n> a highlighted note\n| Column | Column |\n| --- | --- |\n| cell | cell |\n'
             '[[Another article]]  [[Another article|link text]]\n[a website](https://example.com)</pre></details>')
    _page(h, f"Editing {title or slug}", f'<h1>Editing {e(title or slug)}</h1>{err}'
          f'<form method="post" class="wedit" action="/wiki/{e(slug)}/edit">{_hidden(user)}'
          f'<label for="wtitle">Title</label><input id="wtitle" name="title" maxlength="120" value="{e(title)}" required>'
          f'<label for="wbody">Article</label><textarea id="wbody" name="body" rows="24" required>{e(body)}</textarea>'
          f'<label for="wsum">What did you change?</label><input id="wsum" name="summary" maxlength="200" value="{e(summary)}" placeholder="Fixed boss health, added drops">'
          f'<div class="row"><button class="btn">Save</button><a href="/wiki/{e(slug)}">Cancel</a></div></form>{help_}', user)


def _edit(h, user, slug, method):
    if not user:
        return _redirect(h, "/wiki/login?next=" + quote(f"/wiki/{slug}/edit"))
    if user["blocked"]:
        return _page(h, "Editing blocked", "<h1>Editing is blocked for your account</h1><p>Ask staff on Discord if you think this is a mistake.</p>", user, 403)
    page = _q("SELECT title, current_rev, locked FROM page WHERE slug = %s", (slug,), one=True)
    if page and page[2] and not user["admin"]:
        return _page(h, "Locked", "<h1>This article is locked</h1><p>Only staff can edit it right now.</p>", user, 403)
    if method == "GET":
        if page:
            title, body = _q("SELECT title, body FROM revision WHERE id = %s", (page[1],), one=True)
        else:
            title, body = slug.replace("-", " ").title(), ""
        return _edit_form(h, user, slug, title, body)
    form = _form(h)
    if not _csrf_ok(h, form, user):
        return _page(h, "Expired", "<h1>That form expired</h1><p>Go back, reload the page and save again.</p>", user, 400)
    title = form.get("title", "").strip()[:120]
    body = form.get("body", "").replace("\r\n", "\n")
    summary = form.get("summary", "").strip()[:200]
    if not title or not body.strip():
        return _edit_form(h, user, slug, title, body, summary, "An article needs a title and some text.")
    if len(body) > MAX_BODY:
        return _edit_form(h, user, slug, title, body, summary, f"Articles can be up to {MAX_BODY // 1000} KB.")
    if _limited(f"edit:{user['id']}", 8, 60):
        return _edit_form(h, user, slug, title, body, summary, "You're saving very fast. Wait a minute and try again.")
    if page:
        cur = _q("SELECT title, body FROM revision WHERE id = %s", (page[1],), one=True)
        if cur and cur[0] == title and cur[1] == body:
            return _redirect(h, f"/wiki/{slug}")
    rid = _x("INSERT INTO revision (slug, title, body, summary, user_id) VALUES (%s, %s, %s, %s, %s)", (slug, title, body, summary, user["id"]))
    if page:
        _x("UPDATE page SET title = %s, current_rev = %s, updated_at = UTC_TIMESTAMP() WHERE slug = %s", (title, rid, slug))
    else:
        _x("INSERT INTO page (slug, title, current_rev) VALUES (%s, %s, %s)", (slug, title, rid))
    _redirect(h, f"/wiki/{slug}")


def _history(h, user, slug):
    page = _q("SELECT title, current_rev FROM page WHERE slug = %s", (slug,), one=True)
    if not page:
        return _view(h, user, slug)
    rows = _q("SELECT r.id, r.created_at, COALESCE(u.name, 'JawnTide'), r.summary, LENGTH(r.body), u.id, u.blocked "
              "FROM revision r LEFT JOIN wiki_user u ON u.id = r.user_id WHERE r.slug = %s ORDER BY r.id DESC LIMIT 200", (slug,))
    trs = []
    for rid, at, name, summ, size, uid, blocked in rows:
        cur = ' <span class="badge">Current</span>' if rid == page[1] else ''
        block = ''
        if user and user["admin"] and uid and uid != user["id"]:
            block = (f'<form class="inline" method="post" action="/wiki/user/{uid}/block">{_hidden(user)}'
                     f'<button class="link">{"Unblock" if blocked else "Block"} {e(name)}</button></form>')
        trs.append(f'<tr><td><a href="/wiki/{e(slug)}/rev/{rid}">{e(at.strftime("%b %d, %Y %H:%M"))}</a>{cur}</td><td>{e(name)}</td>'
                   f'<td class="wrapcell">{e(summ) or "<span class=muted>no summary</span>"}</td><td class="n">{size:,}</td><td>{block}</td></tr>')
    _page(h, f"History of {page[0]}", f'<h1>History: <a href="/wiki/{e(slug)}">{e(page[0])}</a></h1>'
          f'<div class="wrap"><table><thead><tr><th>Saved (UTC)</th><th>By</th><th>Change</th><th class="n">Characters</th><th></th></tr></thead>'
          f'<tbody>{"".join(trs)}</tbody></table></div>', user)


def _recent(h, user):
    rows = _q("SELECT r.slug, r.title, r.created_at, COALESCE(u.name, 'JawnTide'), r.summary, r.id FROM revision r "
              "LEFT JOIN wiki_user u ON u.id = r.user_id ORDER BY r.id DESC LIMIT 100")
    items = "".join(f'<li><a href="/wiki/{e(s)}">{e(t)}</a> <span class="muted">· {e(n)} · {_ago(c)}</span>'
                    f'{" · " + e(m) if m else ""} · <a href="/wiki/{e(s)}/rev/{rid}">this version</a></li>' for s, t, c, n, m, rid in rows)
    _page(h, "Recent changes", f'<h1>Recent changes</h1><ul class="wlist">{items or "<li class=muted>Nothing yet.</li>"}</ul>', user)


def _new(h, user, query):
    if not user:
        return _redirect(h, "/wiki/login?next=/wiki/new")
    title = (query.get("title", [""])[0] or "").strip()[:120]
    if title:
        return _redirect(h, f"/wiki/{slugify(title)}/edit")
    _page(h, "New article", '<h1>New article</h1><form class="wedit" method="get" action="/wiki/new">'
          '<label for="ntitle">Title</label><input id="ntitle" name="title" maxlength="120" required placeholder="Death (world boss)">'
          '<div class="row"><button class="btn">Continue</button></div></form>', user)


# ---------------------------------------------------------------- linking and sign-in

def _link_start(h, user):
    if _limited("code:" + _client_ip(h), 6, 600):
        return _page(h, "Slow down", "<h1>Too many codes</h1><p>Wait a few minutes before asking for another code.</p>", user, 429)
    code = "".join(secrets.choice(CODE_ALPHABET) for _ in range(8))
    _x("INSERT INTO link_code (code, expires_at) VALUES (%s, %s)", (code, datetime.utcnow() + timedelta(minutes=CODE_MINUTES)))
    # the code only finishes in the browser that asked for it, so a code seen over someone's shoulder is useless
    _redirect(h, f"/wiki/link?code={code}", extra_cookie=f"jtl={code}; Max-Age={(CODE_MINUTES + 30) * 60}")


def _same_browser(h, code):
    for part in h.headers.get("Cookie", "").split(";"):
        k, _, v = part.strip().partition("=")
        if k == "jtl" and hmac.compare_digest(v, code):
            return True
    return False


def _link_page(h, user, query):
    code = re.sub(r"[^A-Z0-9]", "", (query.get("code", [""])[0] or "").upper())[:8]
    if not code:
        return _page(h, "Link your game account",
                     '<h1>Link your game account</h1><p class="lede">Anyone can read the wiki. Editing is for contributors: staff pick one character per player. '
                     'If you\'re a contributor, prove it by typing a code in game with that character, then pick a password for the wiki. '
                     'Already linked but forgot your password? Do the same steps to set a new one.</p>'
                     '<ol class="steps"><li>Get a code below.</li><li>Log in to JawnTide with your contributor character and type <code>/wiki CODE</code>.</li>'
                     '<li>Come back here and pick your wiki password.</li></ol>'
                     '<form method="post" action="/wiki/link/start"><button class="btn">Get a code</button></form>', user)
    row = _q("SELECT expires_at, account_id, char_name, confirmed_at, used_at, char_id FROM link_code WHERE code = %s", (code,), one=True)
    if not row or row[4] or (not row[3] and row[0] < datetime.utcnow()):
        return _page(h, "Code expired", '<h1>That code expired</h1><p><a href="/wiki/link">Get a new code</a>.</p>', user, 410)
    if not _same_browser(h, code):
        return _page(h, "Wrong browser", '<h1>Finish in the browser that made the code</h1><p>Or <a href="/wiki/link">get a new code</a> here.</p>', user, 403)
    if not row[3]:
        mins = max(1, int((row[0] - datetime.utcnow()).total_seconds() // 60))
        return _page(h, "Type the code in game",
                     f'<h1>Type this in game</h1><div class="codebox linkcode">/wiki {code}</div>'
                     f'<p class="lede">Log in to JawnTide with your contributor character and type the line above in chat. '
                     f'The code works for about {mins} more minute{"s" if mins != 1 else ""}. This page checks automatically.</p>'
                     f'<p class="muted">Waiting for the game server…</p><meta http-equiv="refresh" content="4">', user)
    if not _is_contributor(row[1], row[5]):
        return _page(h, "Not a contributor", f'<h1>{e(row[2])} isn\'t a wiki contributor</h1><p>Staff choose one character per player '
                     f'who can edit. Ask on Discord.</p>', user, 403)
    existing = _q("SELECT name FROM wiki_user WHERE account_id = %s", (row[1],), one=True)
    name = row[2]
    what = "set a new password" if existing else "pick a wiki password"
    _page(h, "Pick a password",
          f'<h1>Linked to {e(row[2])}</h1><p class="lede">Your account is confirmed. Now {what}. You will sign in as <b>{e(name)}</b>.</p>'
          f'<form class="wedit" method="post" action="/wiki/link/finish"><input type="hidden" name="code" value="{code}">'
          f'<label for="pw1">Password (at least 10 characters)</label><input id="pw1" name="password" type="password" minlength="10" maxlength="200" required autocomplete="new-password">'
          f'<label for="pw2">Same password again</label><input id="pw2" name="password2" type="password" minlength="10" maxlength="200" required autocomplete="new-password">'
          f'<p class="muted">Don\'t reuse your game password.</p><div class="row"><button class="btn">Save and sign in</button></div></form>', user)


def _link_finish(h, user):
    form = _form(h)
    if not _csrf_ok(h, form, None):
        return _page(h, "Expired", "<h1>That form expired</h1>", user, 400)
    code = re.sub(r"[^A-Z0-9]", "", form.get("code", "").upper())[:8]
    pw, pw2 = form.get("password", ""), form.get("password2", "")
    row = _q("SELECT account_id, char_name, access_level, confirmed_at, used_at, char_id FROM link_code WHERE code = %s", (code,), one=True)
    if not row or not row[3] or row[4] or row[3] < datetime.utcnow() - timedelta(minutes=30) or not _same_browser(h, code):
        return _page(h, "Code expired", '<h1>That code expired</h1><p><a href="/wiki/link">Start again</a>.</p>', user, 410)
    if len(pw) < 10 or pw != pw2:
        return _page(h, "Try again", f'<h1>Passwords didn\'t match</h1><p>Passwords must match and be at least 10 characters. '
                                     f'<a href="/wiki/link?code={code}">Try again</a>.</p>', user, 400)
    account_id, char_name, access_level, char_id = row[0], row[1], int(row[2] or 0), row[5]
    if not _is_contributor(account_id, char_id):
        return _page(h, "Not a contributor", f'<h1>{e(char_name)} isn\'t a wiki contributor</h1><p>Ask staff on Discord.</p>', user, 403)
    salt = secrets.token_bytes(16)
    ph = _hash(pw, salt)
    admin = 1 if access_level > 0 else 0
    existing = _q("SELECT id FROM wiki_user WHERE account_id = %s", (account_id,), one=True)
    name = char_name
    if _q("SELECT 1 FROM wiki_user WHERE name = %s AND account_id <> %s", (name, account_id), one=True):
        name = f"{char_name[:26]}-{account_id % 10000}"     # a deleted character's name reused by someone else
    if existing:
        # same account: the login follows the account's current contributor character (its name may have changed)
        uid = existing[0]
        _x("UPDATE wiki_user SET char_id = %s, name = %s, pass_hash = %s, pass_salt = %s, is_admin = %s WHERE id = %s",
           (char_id, name, ph, salt, admin, uid))
        _x("DELETE FROM session WHERE user_id = %s", (uid,))    # a password reset signs out everywhere else
    else:
        uid = _x("INSERT INTO wiki_user (account_id, char_id, name, pass_hash, pass_salt, is_admin) VALUES (%s, %s, %s, %s, %s, %s)",
                 (account_id, char_id, name, ph, salt, admin))
    _x("UPDATE link_code SET used_at = UTC_TIMESTAMP() WHERE code = %s", (code,))
    _redirect(h, "/wiki", cookie=_new_session(uid))


def _login(h, user, method, query):
    nxt = (query.get("next", ["/wiki"])[0] or "/wiki")
    if not nxt.startswith("/wiki"): nxt = "/wiki"
    def form(err=""):
        _page(h, "Sign in", f'<h1>Sign in to the wiki</h1>{f"<p class=err>{e(err)}</p>" if err else ""}'
              f'<form class="wedit" method="post" action="/wiki/login?next={quote(nxt)}">'
              f'<label for="lname">Character name you linked with</label><input id="lname" name="name" maxlength="32" required autocomplete="username">'
              f'<label for="lpw">Wiki password</label><input id="lpw" name="password" type="password" maxlength="200" required autocomplete="current-password">'
              f'<div class="row"><button class="btn">Sign in</button></div></form>'
              f'<p>New here, or forgot your password? <a href="/wiki/link">Link your game account</a>.</p>', user)
    if method == "GET":
        return form()
    f = _form(h)
    if not _csrf_ok(h, f, None):
        return form("That form expired. Try again.")
    if _limited("login:" + _client_ip(h), 10, 600):
        return form("Too many sign-in attempts. Wait a few minutes.")
    row = _q("SELECT u.id, u.pass_hash, u.pass_salt, c.char_id FROM wiki_user u "
             "LEFT JOIN contributor c ON c.account_id = u.account_id AND c.char_id = u.char_id WHERE u.name = %s",
             (f.get("name", "").strip()[:32],), one=True)
    if not row or not hmac.compare_digest(_hash(f.get("password", "")[:200], bytes(row[2])), bytes(row[1])):
        return form("That name and password don't match.")
    if row[3] is None:
        return form("That character isn't a wiki contributor right now. Ask staff on Discord.")
    _redirect(h, nxt, cookie=_new_session(row[0]))


def _logout(h, user):
    f = _form(h)
    if user and _csrf_ok(h, f, user):
        _x("DELETE FROM session WHERE token = %s", (user["token"],))
    _redirect(h, "/wiki", cookie="")


def _admin_action(h, user, kind, target):
    f = _form(h)
    if not user or not user["admin"] or not _csrf_ok(h, f, user):
        return _page(h, "Not allowed", "<h1>Only staff can do that</h1>", user, 403)
    if kind == "lock":
        _x("UPDATE page SET locked = 1 - locked WHERE slug = %s", (target,))
        return _redirect(h, f"/wiki/{target}")
    if kind == "revert":
        slug, rid = target
        rev = _q("SELECT title, body FROM revision WHERE id = %s AND slug = %s", (rid, slug), one=True)
        if rev:
            new = _x("INSERT INTO revision (slug, title, body, summary, user_id) VALUES (%s, %s, %s, %s, %s)",
                     (slug, rev[0], rev[1], f"Restored the version from revision {rid}", user["id"]))
            _x("UPDATE page SET title = %s, current_rev = %s, updated_at = UTC_TIMESTAMP() WHERE slug = %s", (rev[0], new, slug))
        return _redirect(h, f"/wiki/{slug}")
    if kind == "block":
        _x("UPDATE wiki_user SET blocked = 1 - blocked WHERE id = %s AND is_admin = 0", (target,))
        _x("DELETE FROM session WHERE user_id = %s AND (SELECT blocked FROM wiki_user WHERE id = %s) = 1", (target, target))
        return _redirect(h, h.headers.get("Referer") or "/wiki/recent")


# ---------------------------------------------------------------- routing

def handle(h, method):
    """Serves /wiki and everything under it. Returns True when it handled the request."""
    url = urlparse(h.path)
    path = url.path.rstrip("/") or "/"
    if path != "/wiki" and not path.startswith("/wiki/"):
        return False
    query = parse_qs(url.query)
    try:
        user = _current_user(h)
        parts = path.split("/")[2:]     # after /wiki
        if method == "POST" and h.headers.get("Origin") and urlparse(h.headers["Origin"]).netloc != h.headers.get("Host", ""):
            _page(h, "Not allowed", "<h1>That request came from another site</h1>", user, 403); return True
        if not parts:
            _index(h, user, query) if method == "GET" else _send(h, 405, "Method not allowed", "text/plain")
        elif parts == ["recent"]:
            _recent(h, user)
        elif parts == ["new"]:
            _new(h, user, query)
        elif parts == ["login"]:
            _login(h, user, method, query)
        elif parts == ["logout"] and method == "POST":
            _logout(h, user)
        elif parts == ["link"]:
            _link_page(h, user, query)
        elif parts == ["link", "start"] and method == "POST":
            _link_start(h, user)
        elif parts == ["link", "finish"] and method == "POST":
            _link_finish(h, user)
        elif len(parts) == 3 and parts[0] == "user" and parts[2] == "block" and parts[1].isdigit() and method == "POST":
            _admin_action(h, user, "block", int(parts[1]))
        elif len(parts) == 1 and re.fullmatch(r"[a-z0-9-]{1,80}", parts[0]) and method == "GET":
            _view(h, user, parts[0])
        elif len(parts) == 2 and re.fullmatch(r"[a-z0-9-]{1,80}", parts[0]):
            slug, action = parts
            if action == "edit": _edit(h, user, slug, method)
            elif action == "history": _history(h, user, slug)
            elif action == "lock" and method == "POST": _admin_action(h, user, "lock", slug)
            else: _page(h, "Not found", "<h1>Not found</h1>", user, 404)
        elif len(parts) == 3 and re.fullmatch(r"[a-z0-9-]{1,80}", parts[0]) and parts[2].isdigit():
            if parts[1] == "rev": _view(h, user, parts[0], int(parts[2]))
            elif parts[1] == "revert" and method == "POST": _admin_action(h, user, "revert", (parts[0], int(parts[2])))
            else: _page(h, "Not found", "<h1>Not found</h1>", user, 404)
        else:
            _page(h, "Not found", "<h1>Not found</h1>", user, 404)
    except Exception:
        traceback.print_exc()
        try:
            _send(h, 503, _layout("/wiki", "Wiki unavailable", "<h1>The wiki is unavailable</h1><p>Try again in a minute.</p>", None))
        except Exception:
            pass
    return True


# ---------------------------------------------------------------- starter articles

def _seed_when_ready():
    """Adds the starter articles from wiki-seed/*.md the first time the wiki database is reachable.
    Only pages that don't exist yet are added, so edits are never overwritten."""
    for _ in range(60):
        try:
            if not os.path.isdir(SEED_DIR):
                return
            for fn in sorted(os.listdir(SEED_DIR)):
                if not fn.endswith(".md"):
                    continue
                with open(os.path.join(SEED_DIR, fn), encoding="utf-8") as f:
                    text = f.read()
                first, _, body = text.partition("\n")
                title = first.lstrip("#").strip()
                slug = slugify(title)
                if _q("SELECT 1 FROM page WHERE slug = %s", (slug,), one=True):
                    continue
                rid = _x("INSERT INTO revision (slug, title, body, summary, user_id) VALUES (%s, %s, %s, %s, NULL)",
                         (slug, title, body.strip() + "\n", "Starter article"))
                _x("INSERT INTO page (slug, title, current_rev) VALUES (%s, %s, %s)", (slug, title, rid))
                print(f"[wiki] added starter article: {title}", flush=True)
            return
        except Exception as ex:
            print(f"[wiki] waiting for the wiki database: {ex}", flush=True)
            time.sleep(30)
