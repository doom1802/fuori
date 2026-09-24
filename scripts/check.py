#!/usr/bin/env python3
"""Checks for the visual reference using Python's stdlib and Node.js."""

from html.parser import HTMLParser
from pathlib import Path
import re
import subprocess
from urllib.parse import unquote, urlsplit


ROOT = Path(__file__).resolve().parent.parent
REFERENCE = ROOT / "design" / "reference"
ERRORS = []


class ReferencePage(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=False)
        self.scripts = []
        self.references = []
        self._script = None

    def handle_starttag(self, tag, attrs):
        values = dict(attrs)
        if tag == "script":
            if values.get("src"):
                self.references.append(values["src"])
            else:
                self._script = []
        if tag in ("img", "link", "a"):
            reference = values.get("src") or values.get("href")
            if reference:
                self.references.append(reference)

    def handle_data(self, data):
        if self._script is not None:
            self._script.append(data)

    def handle_endtag(self, tag):
        if tag == "script" and self._script is not None:
            self.scripts.append("".join(self._script))
            self._script = None


def check_reference(source, reference):
    if reference.startswith(("#", "//")):
        return
    parsed = urlsplit(reference)
    if parsed.scheme or parsed.netloc or not parsed.path:
        return
    target = (source.parent / unquote(parsed.path)).resolve()
    if not target.is_relative_to(ROOT) or not target.exists():
        ERRORS.append(f"{source.relative_to(ROOT)}: riferimento locale mancante: {reference}")


def check_javascript(label, source):
    try:
        result = subprocess.run(
            ["node", "--check"], input=source, text=True, capture_output=True, cwd=ROOT
        )
    except FileNotFoundError:
        ERRORS.append("Node.js non trovato: installalo per controllare la sintassi JavaScript")
        raise SystemExit("\n".join(ERRORS))
    if result.returncode:
        ERRORS.append(f"{label}: sintassi JavaScript non valida\n{result.stderr.strip()}")


def main():
    javascript_files = sorted(REFERENCE.glob("*.js"))
    html_files = sorted(REFERENCE.glob("*.html"))
    inline_count = 0

    for path in javascript_files:
        check_javascript(str(path.relative_to(ROOT)), path.read_text())

    for path in html_files:
        page = ReferencePage()
        page.feed(path.read_text())
        for reference in page.references:
            check_reference(path, reference)
        for number, source in enumerate(page.scripts, 1):
            check_javascript(f"{path.relative_to(ROOT)} script {number}", source)
            inline_count += 1

    for path in sorted((ROOT / "docs").glob("*.md")) + [ROOT / "README.md"]:
        for match in re.finditer(r"\[[^]]+\]\(([^)]+)\)", path.read_text()):
            check_reference(path, match.group(1).split()[0])

    if ERRORS:
        print("\n".join(ERRORS))
        return 1
    print(
        f"OK: {len(javascript_files)} file JS, {len(html_files)} file HTML, "
        f"{inline_count} script incorporati e link locali"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
