"""
Builds the admin command list for the monitor's Settings page straight from the server's command handler source files
(Source/ACE.Server/Command/Handlers/*.cs, mounted into the container), so a new command shows up as soon as the code is
pulled. Every [CommandHandler("name", AccessLevel.X, flags, params, "description", "usage")] attribute is read; several
attributes on one method are one command with aliases.
"""
import os
import re

LEVELS = ["Player", "Advocate", "Sentinel", "Envoy", "Developer", "Admin"]


def _scan_call(text, i):
    """From the '(' at i, returns (args, end): the top-level arguments of the call as raw strings."""
    depth, args, cur, n = 0, [], [], len(text)
    while i < n:
        c = text[i]
        if c == '@' and i + 1 < n and text[i + 1] == '"':          # verbatim string: "" is a quote
            j = i + 2
            while j < n:
                if text[j] == '"':
                    if j + 1 < n and text[j + 1] == '"':
                        j += 2
                        continue
                    break
                j += 1
            cur.append(text[i:j + 1])
            i = j + 1
            continue
        if c == '"':
            j = i + 1
            while j < n and text[j] != '"':
                j += 2 if text[j] == '\\' else 1
            cur.append(text[i:j + 1])
            i = j + 1
            continue
        if c in "([{":
            depth += 1
            if depth > 1:
                cur.append(c)
        elif c in ")]}":
            depth -= 1
            if depth == 0:
                args.append("".join(cur).strip())
                return args, i
            cur.append(c)
        elif c == ',' and depth == 1:
            args.append("".join(cur).strip())
            cur = []
        else:
            cur.append(c)
        i += 1
    return args, i


_ESC = {"n": "\n", "t": "\t", '"': '"', "\\": "\\", "'": "'", "r": ""}


def _string_value(arg):
    """The text of an argument made of string literals joined with +; None when it isn't one."""
    parts = re.findall(r'@"((?:[^"]|"")*)"|"((?:[^"\\]|\\.)*)"', arg)
    if not parts:
        return None
    out = []
    for verb, normal in parts:
        if verb:
            out.append(verb.replace('""', '"'))
        else:
            out.append(re.sub(r"\\(.)", lambda m: _ESC.get(m.group(1), m.group(1)), normal))
    return "".join(out)


def build(handler_dir):
    commands = {}
    for name in sorted(os.listdir(handler_dir)):
        if not name.endswith(".cs"):
            continue
        with open(os.path.join(handler_dir, name), encoding="utf-8", errors="replace") as f:
            text = f.read()
        for m in re.finditer(r"\[CommandHandler\s*\(", text):
            args, end = _scan_call(text, m.end() - 1)
            if len(args) < 2:
                continue
            cmd = _string_value(args[0])
            level = args[1].split(".")[-1].strip()
            if not cmd or level not in LEVELS:
                continue
            flags = args[2] if len(args) > 2 else ""
            desc = _string_value(args[4]) if len(args) > 4 else ""
            usage = _string_value(args[5]) if len(args) > 5 else ""
            meth = re.search(r"static\s+\w+\s+(\w+)\s*\(", text[end:end + 2000])
            key = (name, meth.group(1) if meth else cmd)
            c = commands.get(key)
            if c is None:
                commands[key] = dict(name=cmd, aliases=[], level=level, desc=(desc or "").strip(), usage=(usage or "").strip(),
                                     console="ConsoleInvoke" in flags and "RequiresWorld" not in flags, file=name[:-3])
            elif cmd != c["name"] and cmd not in c["aliases"]:
                c["aliases"].append(cmd)
    out = sorted(commands.values(), key=lambda c: (-LEVELS.index(c["level"]), c["name"].lower()))
    return out
