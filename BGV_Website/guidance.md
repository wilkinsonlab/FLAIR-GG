# Maintaining this site — guidance for Claude

This file is written for whoever (human or Claude session) next needs to
update this site. It has no build step and no framework — read this once
and you can safely edit anything here by hand.

## What this is

The public site for the **Banco de Germoplasma Vegetal "César Gómez
Campo"** (UPM), migrated off an unfinished/abandoned Drupal install
(formerly at `http://138.4.92.204`) onto plain static HTML in August 2026.
It is bilingual (Spanish/English) and includes a page on the associated
**FLAIR-GG** virtual platform (`VP/vp-interface` elsewhere in this repo).

**Deliberate constraints — do not "improve" these away without asking:**
- **No JavaScript, no build tools, no framework.** Every page is a
  complete, hand-written `.html` file. This was an explicit request
  ("straightforward HTML — no fancy stuff"), not an oversight.
- **No templating engine.** The header, nav, language switch and footer
  are duplicated verbatim in every page (see "Editing shared chrome"
  below for how to do this safely).
- Deploy by copying the folder to any static file host / web server.
  Nothing to install, nothing to compile.

## File structure

```
BGV_Website/
  index.html, historia.html, colecciones.html, conservacion.html,
  documentos.html, localizacion.html, flair-gg.html   ← Spanish (site root)
  en/
    index.html, history.html, collections.html, conservation.html,
    documents.html, location.html, flair-gg.html       ← English
  css/style.css        ← the entire design system, one file
  images/               ← all photos + the SVG favicon, shared by both languages
  README.md
```

Spanish pages keep their original Drupal-era URLs at the site root
(`historia.html`, not `es/historia.html`) so old bookmarks/links keep
working. English pages live under `en/` with **translated slugs**
(not `en/historia.html`) — the mapping is:

| Spanish              | English                  |
|-----------------------|---------------------------|
| `index.html`          | `en/index.html`           |
| `historia.html`       | `en/history.html`         |
| `colecciones.html`    | `en/collections.html`     |
| `conservacion.html`   | `en/conservation.html`    |
| `documentos.html`     | `en/documents.html`       |
| `localizacion.html`   | `en/location.html`        |
| `flair-gg.html`       | `en/flair-gg.html`        |

Every page's header carries a small **ES / EN** switch that links straight
to its sibling in the other language — if you add a page, add it to both
languages and wire up the switch on both (copy the pattern from any
existing page's `<div class="lang-switch">`).

## Editing content on an existing page

Just open the `.html` file and edit the text/markup directly — there is
no source-of-truth elsewhere to keep in sync (except: if you change a
*fact*, e.g. an accession count, update it in **both** the Spanish and
English page, since the two are independent translations, not generated
from one source).

Each page is built from a small set of reusable CSS classes defined once
in `css/style.css` — reuse them rather than inventing new inline styles:

- `.hero` / `.hero--page` — big banner (with photo) or plain-colour page-title banner
- `.section`, `.section--alt` (tinted), `.section--deep` (dark green) — page bands
- `.card`, `.collection-card` — boxed content tiles, used in grids (`.grid.grid--2/3/4`)
- `.prose` — long-form article text (used on Historia, Conservación)
- `.notice` — dashed-border callout for "this section is still being filled in" honesty notes (see Documentos)
- `.citation` — mustard-edged block for the academic paper reference (see FLAIR-GG page)
- `.flower-mark` — the four-petal SVG motif (see below)

## Editing shared chrome (header / nav / footer)

Because there's no templating, the header and footer markup is
byte-for-byte identical across all 14 files except for: which nav item
has `class="is-active"`, and the language-switch hrefs. **If you need to
change the nav (add/remove/rename a page), the brand text, or the
footer**, you must edit it in all 14 files identically.

The safe way to do this with Claude: ask it to make the change in one
file first, confirm it looks right, then have it apply the **same**
literal edit across the rest with a scripted find/replace (not
freehand retyping — retyping 14 times is how nav items silently drift
out of sync). After any chrome-wide edit, re-run the verification
commands below before considering it done.

The reusable flower SVG (used in the brand mark, footer, card icons and
list bullets — the four-petal shape is a nod to "Cruciferae", cross-bearing):

```html
<svg class="flower-mark" viewBox="0 0 100 100" aria-hidden="true">
  <path d="M50,10 C62,10 66,26 58,38 C54,44 46,44 42,38 C34,26 38,10 50,10 Z"/>
  <path d="M50,10 C62,10 66,26 58,38 C54,44 46,44 42,38 C34,26 38,10 50,10 Z" transform="rotate(90 50 50)"/>
  <path d="M50,10 C62,10 66,26 58,38 C54,44 46,44 42,38 C34,26 38,10 50,10 Z" transform="rotate(180 50 50)"/>
  <path d="M50,10 C62,10 66,26 58,38 C54,44 46,44 42,38 C34,26 38,10 50,10 Z" transform="rotate(270 50 50)"/>
  <circle cx="50" cy="50" r="6"/>
</svg>
```
It always inherits `currentColor` — wrap it in an element with the color
you want, don't hardcode a fill.

## Adding a brand-new page

1. Copy the closest existing page (Spanish and English versions) as a
   starting point — it already has the correct `<head>`, header, footer,
   and asset paths for its location (root vs. `en/`).
2. Add a nav `<li>` for it in **every** page's header (all 14 files —
   see "Editing shared chrome").
3. If it should appear in the footer's "Explorar/Explore" column, add it
   there too (currently: Historia, Colecciones, Conservación, Documentos).
4. Add the `<div class="lang-switch">` pair pointing the two language
   versions at each other.
5. Add `<link rel="icon">`/`<title>`/`<meta name="description">` in the
   `<head>` — every page has its own, there's no shared `<head>` include.
6. Run the verification commands below.

## Verifying changes before committing

No test suite — just structural sanity checks. Run from the
`BGV_Website/` directory:

```bash
# Every tag closes correctly (catches a stray/missing </div> etc.)
python3 -c "
import glob
from html.parser import HTMLParser
VOID = {'area','base','br','col','embed','hr','img','input','link','meta','param','source','track','wbr'}
class Check(HTMLParser):
    def __init__(self, name): super().__init__(); self.name=name; self.stack=[]
    def handle_starttag(self, tag, attrs):
        if tag not in VOID: self.stack.append(tag)
    def handle_endtag(self, tag):
        if not self.stack: print(f'{self.name}: stray </{tag}>'); return
        if self.stack[-1]==tag: self.stack.pop()
        else: print(f'{self.name}: mismatch expected </{self.stack[-1]}> got </{tag}>')
for f in sorted(glob.glob('**/*.html', recursive=True)):
    c = Check(f); c.feed(open(f, encoding='utf-8').read())
    print(f, 'OK' if not c.stack else f'UNCLOSED {c.stack}')
"

# Every href/src that points at a local file actually resolves
python3 -c "
import re, glob, os
for f in sorted(glob.glob('**/*.html', recursive=True)):
    base_dir = os.path.dirname(f)
    html = open(f, encoding='utf-8').read()
    for m in re.finditer(r'(?:href|src)=\"([^\"]+)\"', html):
        v = m.group(1)
        if v.startswith(('http://','https://','mailto:','tel:','#')): continue
        path = os.path.normpath(os.path.join(base_dir, v))
        if not os.path.exists(path): print(f'BROKEN in {f}: {v} -> {path}')
print('link check complete')
"
```

Both should print `OK` / no `BROKEN` lines for every file. Also open the
page in a browser at both a phone and a desktop width before calling a
visual change done — there's no CSS framework doing responsiveness for
you, just the rules in `style.css`.

## Images

All photos currently on the site were pulled from the old Drupal
install and downsized (`~1600px` max edge, JPEG quality ~82) so the
whole site stays lightweight — see `images/`. If you add a new photo:
- keep it under ~300 KB (resize/re-encode first — Pillow, ImageMagick,
  or `sips` on macOS all work)
- add a real, specific `alt` text (not "image" / "photo") — several
  existing images are low-resolution originals from the old site and
  are captioned honestly as archival material rather than upgraded
- `images/favicon.svg` and `images/flair-gg-logo.png` are logos, not
  content photos — leave them as-is unless a logo actually changes

## Content-honesty conventions

Some of the source content (inherited from the abandoned Drupal draft)
had real gaps. Two patterns were used instead of inventing facts —
follow them if you find more gaps rather than guessing a number or
leaving debug text in place:

- **A specific missing fact** (e.g. an accession count the original
  author never filled in): marked inline, e.g.
  `<em>[cifra pendiente de completar]</em>` / `[figure to be completed]`
  in `historia.html` / `en/history.html`. Replace with the real number
  the moment someone has it — search both language files for
  `pendiente` / `to be completed`.
- **A whole section not ready yet** (`documentos.html` / `en/documents.html`):
  use the `.notice` box pattern — an honest "this section is in
  preparation" message with a way to get in touch, not a placeholder
  full of lorem ipsum or a leftover TODO comment.

## The FLAIR-GG page specifically

`flair-gg.html` / `en/flair-gg.html` describes the **FLAIR-GG Virtual
Platform**, whose actual implementation lives in `VP/vp-interface`
elsewhere in this repo (a Ruby/Sinatra app — see its own `README.md` and
`CHANGELOG.md`). The page content (what the platform does: federated
resource discovery, keyword/ontology/SPARQL search, cross-network
service execution, word cloud, the MCP endpoint for AI assistants) was
written from that code, not guessed — if the platform's feature set
changes materially, this page should be updated to match, ideally by
re-reading `VP/vp-interface/app/controllers/routes.rb` and
`VP/vp-interface/lib/mcp_tools/` rather than editing from memory.

The page cites the project's paper: Cámara Ballesteros et al. (2024),
*Scientific Data* 11:1386, DOI `10.1038/s41597-024-04243-7`. Update the
citation if a newer paper supersedes it.

The primary CTA link is `https://w3id.org/flair-gg` (the platform's
permanent identifier). If that identifier is ever reassigned, update it
in both language versions.

## Design system quick reference

Full tokens are in `css/style.css` under `:root`. Summary:

- **Palette**: warm paper background, deep botanical green (`--green-deep`,
  `--green-mid`) as the primary color, mustard yellow (`--mustard`,
  `--mustard-deep`) as the accent — evoking a crucifer flower — plum
  (`--plum`) used sparingly for the endemics collection card.
- **Type**: `Newsreader` (serif, via Google Fonts) for headings and
  italic Latin species names; `Public Sans` for body text. Both loaded
  in `css/style.css`'s `@import`.
- **Motif**: the four-petal flower SVG (above) — echoes "Cruciferae"
  (cross-bearing), the family this bank specializes in.

Stay inside this system for new content — reuse the existing CSS
classes rather than adding new colors, fonts, or one-off component
styles, so the site stays visually coherent as more people edit it.
