#!/usr/bin/env python3
"""Generate a styled HTML manual site from Markdown documents in ./docs."""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import html
import os
import re
import shutil
import sys
import unicodedata
from pathlib import Path
from typing import Dict, List, Optional

ROOT = Path(__file__).resolve().parent.parent
DOCS_DIR = ROOT / "docs"
OUTPUT_DIR = ROOT / "site"
TEMPLATE_PATH = ROOT / "templates" / "manual_template.html"
INDEX_TEMPLATE_PATH = ROOT / "templates" / "index_template.html"
ASSETS_DIR = ROOT / "assets"


PLACEHOLDER_PREFIX = "@@__PH"


def format_inlines(text: str) -> str:
    """Apply inline Markdown formatting to the provided text."""

    placeholders: Dict[str, str] = {}
    counter = 0

    def new_placeholder(value: str) -> str:
        nonlocal counter
        key = f"{PLACEHOLDER_PREFIX}{counter}__@@"
        placeholders[key] = value
        counter += 1
        return key

    # Raw HTML blocks (for glassmorphism design)
    # Match HTML comment markers and div blocks with inline styles
    def raw_html_repl(match: re.Match[str]) -> str:
        raw_html = match.group(0)
        return new_placeholder(raw_html)

    # Protect HTML comments (<!-- ... -->)
    text = re.sub(r'<!--.*?-->', raw_html_repl, text, flags=re.DOTALL)

    # Protect div blocks with style attributes
    text = re.sub(r'<div\s+style="[^"]*"[^>]*>.*?</div>', raw_html_repl, text, flags=re.DOTALL | re.IGNORECASE)

    # Protect other common HTML tags with attributes
    text = re.sub(r'<(h[1-6]|p|span)\s+[^>]*>.*?</\1>', raw_html_repl, text, flags=re.DOTALL | re.IGNORECASE)

    # Code spans
    def code_repl(match: re.Match[str]) -> str:
        code = match.group(1)
        return new_placeholder(f"<code>{html.escape(code)}</code>")

    text = re.sub(r"`([^`]+?)`", code_repl, text)

    # Images
    def image_repl(match: re.Match[str]) -> str:
        alt_raw = match.group(1)
        url_raw = match.group(2)
        alt = html.escape(alt_raw, quote=True)
        url = html.escape(url_raw, quote=True)
        return new_placeholder(
            f'<img src="{url}" alt="{alt}" loading="lazy" decoding="async" />'
        )

    text = re.sub(r"!\[([^\]]*?)\]\(([^)]+?)\)", image_repl, text)

    # Links
    def link_repl(match: re.Match[str]) -> str:
        label_raw = match.group(1)
        href_raw = match.group(2)
        label = format_inlines(label_raw)
        href = html.escape(href_raw, quote=True)

        # ページ内リンク（#で始まる）の場合はtarget="_blank"を付けない
        if href_raw.startswith('#'):
            return new_placeholder(
                f'<a href="{href}">{label}</a>'
            )
        else:
            return new_placeholder(
                f'<a href="{href}" target="_blank" rel="noopener noreferrer">{label}</a>'
            )

    text = re.sub(r"\[([^\]]+?)\]\(([^)]+?)\)", link_repl, text)

    escaped = html.escape(text, quote=False)

    def apply_emphasis(value: str) -> str:
        def strong_repl(match: re.Match[str]) -> str:
            return f"<strong>{apply_emphasis(match.group(1))}</strong>"

        def em_repl(match: re.Match[str]) -> str:
            return f"<em>{apply_emphasis(match.group(1))}</em>"

        new_value = re.sub(r"\*\*([^*]+)\*\*", strong_repl, value)
        new_value = re.sub(r"\*([^*]+)\*", em_repl, new_value)
        return new_value

    formatted = apply_emphasis(escaped)

    for key, value in placeholders.items():
        formatted = formatted.replace(key, value)

    return formatted


class MarkdownConverter:
    """Very small Markdown-to-HTML converter tailored to the project docs."""

    heading_pattern = re.compile(r"^(#{1,6})\s+(.*)")
    hr_pattern = re.compile(r"^ {0,3}([-*_])(?:\s*\1){2,}\s*$")
    ul_pattern = re.compile(r"^(\s*)([-*+])\s+(.*)")
    ol_pattern = re.compile(r"^(\s*)(\d{1,3})\.\s+(.*)")
    table_row_pattern = re.compile(r"^\s*\|(.+)\|\s*$")
    table_sep_pattern = re.compile(r"^\s*\|[\s:|-]+\|\s*$")
    blockquote_pattern = re.compile(r"^>\s+(.*)")
    flowchart_pattern = re.compile(r"^\*\*コマンドフローチャートの位置づけ:\*\*\s+(.+)$")

    def __init__(self) -> None:
        self.headings: List[Dict[str, str]] = []
        self.slug_counts: Dict[str, int] = {}
        self.title: Optional[str] = None

    @staticmethod
    def parse_table_row(line: str) -> List[str]:
        """Parse a table row and return list of cell contents."""
        # Remove leading/trailing pipes and whitespace
        line = line.strip()
        if line.startswith('|'):
            line = line[1:]
        if line.endswith('|'):
            line = line[:-1]
        # Split by pipe and strip whitespace from each cell
        cells = [cell.strip() for cell in line.split('|')]
        return cells

    @staticmethod
    def parse_flowchart(content: str) -> str:
        """Parse flowchart content and convert to visual HTML infographic."""
        # Split by arrow
        steps = [s.strip() for s in content.split('→')]

        html_parts = ['<div class="flowchart-container">']

        for i, step in enumerate(steps):
            # Check if step is bold (highlighted)
            is_highlighted = step.startswith('**') and step.endswith('**')
            # Check if step is code
            is_command = step.startswith('`') and step.endswith('`')

            # Remove formatting markers
            clean_step = step
            css_class = 'flowchart-step'

            if is_highlighted:
                clean_step = step[2:-2]  # Remove **
                css_class = 'flowchart-step flowchart-highlight'
            elif is_command:
                clean_step = step[1:-1]  # Remove `
                css_class = 'flowchart-step flowchart-command'

            # Escape HTML
            clean_step = html.escape(clean_step)

            # Add step
            html_parts.append(f'<div class="{css_class}">{clean_step}</div>')

            # Add arrow if not last step
            if i < len(steps) - 1:
                html_parts.append('<div class="flowchart-arrow">→</div>')

        html_parts.append('</div>')
        return ''.join(html_parts)

    def slugify(self, text: str) -> str:
        normalized = unicodedata.normalize("NFKC", text).strip().lower()
        slug = re.sub(r"\s+", "-", normalized)
        slug = re.sub(r"[^\w\-]", "", slug)
        if not slug:
            slug = "section"
        count = self.slug_counts.get(slug, 0)
        if count:
            new_slug = f"{slug}-{count + 1}"
        else:
            new_slug = slug
        self.slug_counts[slug] = count + 1
        return new_slug

    @staticmethod
    def _indent_level(prefix: str) -> int:
        spaces = 0
        for char in prefix:
            spaces += 4 if char == "\t" else 1
        return spaces // 2

    def convert(self, text: str) -> str:
        lines = text.splitlines()
        html_parts: List[str] = []
        paragraph_buffer: List[str] = []
        code_block: Optional[Dict[str, object]] = None
        list_stack: List[Dict[str, object]] = []
        table_buffer: Optional[Dict[str, object]] = None
        blockquote_buffer: List[str] = []
        raw_html_block: Optional[Dict[str, object]] = None

        def flush_paragraph() -> None:
            nonlocal paragraph_buffer
            if not paragraph_buffer:
                return
            paragraph_text = " ".join(
                line.strip() for line in paragraph_buffer if line.strip()
            ).strip()
            if paragraph_text:
                html_parts.append(f"<p>{format_inlines(paragraph_text)}</p>")
            paragraph_buffer = []

        def close_open_li() -> None:
            if list_stack and list_stack[-1]["li_open"]:
                flush_paragraph()
                html_parts.append("</li>")
                list_stack[-1]["li_open"] = False

        def close_lists_down_to(indent_level: int) -> None:
            while list_stack and list_stack[-1]["indent"] > indent_level:
                close_open_li()
                html_parts.append(f"</{list_stack.pop()['type']}>")

        def close_all_lists() -> None:
            while list_stack:
                close_open_li()
                html_parts.append(f"</{list_stack.pop()['type']}>")

        def flush_table() -> None:
            nonlocal table_buffer
            if not table_buffer:
                return

            # Wrap table in responsive container
            html_parts.append('<div class="table-wrapper">')
            html_parts.append("<table>")

            # Add header
            if table_buffer.get("header"):
                html_parts.append("<thead><tr>")
                for cell in table_buffer["header"]:
                    html_parts.append(f"<th>{format_inlines(cell)}</th>")
                html_parts.append("</tr></thead>")

            # Add body rows
            if table_buffer.get("rows"):
                html_parts.append("<tbody>")
                for row in table_buffer["rows"]:
                    html_parts.append("<tr>")
                    for cell in row:
                        html_parts.append(f"<td>{format_inlines(cell)}</td>")
                    html_parts.append("</tr>")
                html_parts.append("</tbody>")

            html_parts.append("</table>")
            html_parts.append("</div>")
            table_buffer = None

        def flush_blockquote() -> None:
            nonlocal blockquote_buffer
            if not blockquote_buffer:
                return
            quote_text = " ".join(line.strip() for line in blockquote_buffer if line.strip()).strip()
            if quote_text:
                html_parts.append(f'<blockquote class="option-item">{format_inlines(quote_text)}</blockquote>')
            blockquote_buffer = []

        def ensure_list(list_type: str, indent_level: int) -> None:
            if not list_stack:
                html_parts.append(f"<{list_type}>")
                list_stack.append({"type": list_type, "indent": indent_level, "li_open": False})
                return

            if indent_level > list_stack[-1]["indent"]:
                if not list_stack[-1]["li_open"]:
                    html_parts.append("<li>")
                    list_stack[-1]["li_open"] = True
                html_parts.append(f"<{list_type}>")
                list_stack.append({"type": list_type, "indent": indent_level, "li_open": False})
                return

            close_lists_down_to(indent_level)

            if not list_stack:
                html_parts.append(f"<{list_type}>")
                list_stack.append({"type": list_type, "indent": indent_level, "li_open": False})
                return

            if list_stack[-1]["type"] != list_type:
                close_open_li()
                html_parts.append(f"</{list_stack.pop()['type']}>")
                html_parts.append(f"<{list_type}>")
                list_stack.append({"type": list_type, "indent": indent_level, "li_open": False})

        def start_list_item(list_type: str, indent_level: int, content: str) -> None:
            ensure_list(list_type, indent_level)
            if not list_stack:
                return
            close_open_li()
            html_parts.append("<li>")
            list_stack[-1]["li_open"] = True
            if content.strip():
                html_parts.append(format_inlines(content.strip()))

        for line in lines:
            stripped = line.strip()

            # Handle raw HTML blocks (for glassmorphism design)
            if raw_html_block is not None:
                # Check if this line closes the HTML block
                if stripped.startswith("</div>"):
                    raw_html_block["lines"].append(line)
                    # Flush the complete HTML block directly without escaping
                    html_parts.append("\n".join(raw_html_block["lines"]))
                    raw_html_block = None
                else:
                    raw_html_block["lines"].append(line)
                continue

            # Detect start of raw HTML block
            if stripped.startswith("<!--") or stripped.startswith("<div style="):
                flush_paragraph()
                close_all_lists()
                raw_html_block = {"lines": [line]}
                continue

            # Handle orphaned closing tags as raw HTML
            if stripped == "</div>" or stripped.startswith("</div>"):
                flush_paragraph()
                html_parts.append(line.strip())
                continue

            if code_block is not None:
                if stripped.startswith("```"):
                    code_html = html.escape("\n".join(code_block["lines"]))
                    language = code_block["lang"]
                    class_attr = f" class=\"language-{language}\"" if language else ""
                    html_parts.append(f"<pre><code{class_attr}>{code_html}\n</code></pre>")
                    code_block = None
                else:
                    code_block["lines"].append(line)
                continue

            if stripped.startswith("```"):
                flush_paragraph()
                lang = stripped[3:].strip()
                code_block = {"lang": lang, "lines": [], "indent": len(line) - len(line.lstrip(" "))}
                continue

            if not stripped:
                flush_paragraph()
                continue

            heading_match = self.heading_pattern.match(stripped)
            if heading_match:
                flush_paragraph()
                close_all_lists()
                level = len(heading_match.group(1))
                heading_text = heading_match.group(2).strip()
                if level == 1 and self.title is None:
                    self.title = heading_text
                slug = self.slugify(heading_text)
                self.headings.append({"level": level, "text": heading_text, "slug": slug})

                # Skip outputting h1 to content (it will be in the header)
                if level == 1:
                    continue

                # Apply magazine-quality typography to headings (h2, h3, h4)
                formatted_heading = format_inlines(heading_text)
                if level in (2, 3, 4):
                    formatted_heading = beautify_japanese_title(formatted_heading)

                html_parts.append(
                    f"<h{level} id=\"{slug}\">{formatted_heading}</h{level}>"
                )
                continue

            if self.hr_pattern.match(line):
                flush_paragraph()
                close_all_lists()
                flush_table()
                html_parts.append("<hr />")
                continue

            # Check for table row
            table_row_match = self.table_row_pattern.match(line)
            if table_row_match:
                flush_paragraph()
                close_all_lists()

                cells = self.parse_table_row(line)

                # Check if next line is separator (to identify header)
                # We'll handle this in the line processing logic
                if table_buffer is None:
                    table_buffer = {"header": cells, "rows": [], "expect_separator": True}
                elif table_buffer.get("expect_separator"):
                    # Current line should be separator, but it's data instead
                    # Treat previous as regular row
                    if self.table_sep_pattern.match(line):
                        table_buffer["expect_separator"] = False
                    else:
                        # No separator found, treat header as regular row
                        table_buffer["rows"].append(table_buffer["header"])
                        table_buffer["header"] = None
                        table_buffer["rows"].append(cells)
                        table_buffer["expect_separator"] = False
                else:
                    table_buffer["rows"].append(cells)
                continue

            # If we were in table mode but current line is not table, flush it
            if table_buffer is not None:
                flush_table()

            # Check for blockquote
            blockquote_match = self.blockquote_pattern.match(line)
            if blockquote_match:
                flush_paragraph()
                close_all_lists()
                blockquote_buffer.append(blockquote_match.group(1))
                continue

            # If we were in blockquote mode but current line is not blockquote, flush it
            if blockquote_buffer:
                flush_blockquote()

            # Check for flowchart pattern
            flowchart_match = self.flowchart_pattern.match(stripped)
            if flowchart_match:
                flush_paragraph()
                close_all_lists()
                flowchart_content = flowchart_match.group(1)
                flowchart_html = self.parse_flowchart(flowchart_content)
                html_parts.append(flowchart_html)
                continue

            ul_match = self.ul_pattern.match(line)
            if ul_match:
                flush_paragraph()
                indent = self._indent_level(ul_match.group(1))
                start_list_item("ul", indent, ul_match.group(3))
                continue

            ol_match = self.ol_pattern.match(line)
            if ol_match:
                flush_paragraph()
                indent = self._indent_level(ol_match.group(1))
                start_list_item("ol", indent, ol_match.group(3))
                continue

            if list_stack and list_stack[-1]["li_open"]:
                paragraph_buffer.append(line)
                continue

            if list_stack:
                close_all_lists()

            paragraph_buffer.append(line)

        flush_paragraph()

        # Flush unclosed raw HTML block at end of file
        if raw_html_block is not None:
            html_parts.append("\n".join(raw_html_block["lines"]))
            raw_html_block = None

        if code_block is not None:
            code_html = html.escape("\n".join(code_block["lines"]))
            language = code_block["lang"]
            class_attr = f" class=\"language-{language}\"" if language else ""
            html_parts.append(f"<pre><code{class_attr}>{code_html}\n</code></pre>")
            code_block = None

        close_all_lists()
        flush_table()
        flush_blockquote()

        return "\n".join(html_parts)


def build_toc(headings: List[Dict[str, str]]) -> str:
    sections: List[Dict[str, object]] = []
    current_section: Optional[Dict[str, object]] = None

    for heading in headings:
        level = heading["level"]
        if level <= 1:
            continue
        if level == 2:
            current_section = {"heading": heading, "children": []}
            sections.append(current_section)
        elif level in (3, 4):
            if current_section is None:
                current_section = {"heading": heading, "children": []}
                sections.append(current_section)
            children: List[Dict[str, str]] = current_section["children"]  # type: ignore[assignment]
            children.append(heading)

    if not sections:
        return (
            '<nav class="toc" aria-label="目次">'
            "<h2>Contents</h2>"
            "<p class=\"toc-placeholder\">見出しが見つかりませんでした。</p>"
            "</nav>"
        )

    parts: List[str] = [
        '<nav class="toc" aria-label="目次">',
        '<h2>Quick Links</h2>',
        '<ol class="toc-list">',
    ]

    for section in sections:
        heading = section["heading"]  # type: ignore[assignment]
        children = section["children"]  # type: ignore[assignment]

        # Apply magazine-quality typography to TOC headings
        heading_formatted = beautify_japanese_title(format_inlines(heading['text']))

        parts.append(
            f"<li><a href=\"#{heading['slug']}\">{heading_formatted}</a>"
        )
        if children:
            parts.append("<ol>")
            for child in children:  # type: ignore[assignment]
                child_formatted = beautify_japanese_title(format_inlines(child['text']))
                parts.append(
                    f"<li><a href=\"#{child['slug']}\">{child_formatted}</a></li>"
                )
            parts.append("</ol>")
        parts.append("</li>")

    parts.append("</ol>")
    parts.append("</nav>")
    return "".join(parts)


def apply_template(template: str, context: Dict[str, str]) -> str:
    result = template
    for key, value in context.items():
        result = result.replace(f"{{{{ {key} }}}}", value)
    return result


def ensure_assets(output_dir: Path) -> Path:
    assets_output = output_dir / "assets"
    assets_output.mkdir(parents=True, exist_ok=True)
    for asset_file in ASSETS_DIR.glob("*"):
        if asset_file.is_file():
            shutil.copy2(asset_file, assets_output / asset_file.name)
    return assets_output


def render_index(output_dir: Path, manuals: List[Dict[str, str]]) -> None:
    if not INDEX_TEMPLATE_PATH.exists():
        return
    template = INDEX_TEMPLATE_PATH.read_text(encoding="utf-8")
    cards: List[str] = []
    for manual in manuals:
        summary_html = f"<p>{manual['summary']}</p>" if manual['summary'] else ""
        cards.append(
            (
                '<article class="manual-card">'
                f"<h2><a href=\"{manual['href']}\">{manual['title']}</a></h2>"
                f"{summary_html}"
                f"<dl><div><dt>更新</dt><dd>{manual['generated_on']}</dd></div>"
                f"<div><dt>セクション</dt><dd>{manual['sections']}</dd></div></dl>"
                "</article>"
            )
        )
    context = {
        "cards": "\n".join(cards) if cards else "<p>表示できるマニュアルがまだありません。</p>",
        "generated_on": dt.datetime.now().strftime("%Y-%m-%d %H:%M"),
        "assets_href": "assets",
    }
    rendered = apply_template(template, context)
    (output_dir / "index.html").write_text(rendered, encoding="utf-8")


def summarize_manual(converter: MarkdownConverter) -> str:
    # No summary
    return ""


def beautify_japanese_title(title: str) -> str:
    """
    Apply magazine-quality line breaks to Japanese titles.

    Typography rules:
    1. Break after colons (：) for natural reading rhythm
    2. Break at semantic boundaries (18-25 chars per line for readability)
    3. Avoid breaking after particles (の、と)
    4. Break after による、として、について for natural flow
    5. Keep compound terms together
    """
    # Already has HTML breaks
    if '<br>' in title or '<br/>' in title or '<br />' in title:
        return title

    # Short titles don't need breaks
    if len(title) <= 22:
        return title

    # Rule 1: Break after colon for natural segmentation
    if '：' in title:
        parts = title.split('：', 1)
        if len(parts) == 2:
            prefix = parts[0]
            suffix = parts[1]

            # If suffix is still long (>22 chars), add another break
            if len(suffix) > 22:
                # Look for natural break points in order of preference
                break_patterns = [
                    ('による', 3),  # (pattern, chars to include after pattern)
                    ('について', 4),
                    ('として', 3),
                    ('での', 2),
                    ('における', 4),
                    ('に関する', 4),
                    ('と', 1),  # Added for broader coverage
                ]

                for pattern, offset in break_patterns:
                    idx = suffix.find(pattern)
                    # More flexible range: allow breaks from 10-30 chars into the suffix
                    if idx != -1 and 10 < idx + len(pattern) < min(len(suffix) - 6, 30):
                        # Break after the pattern
                        break_point = idx + len(pattern)
                        suffix = suffix[:break_point] + '<br>' + suffix[break_point:]
                        break

            return f"{prefix}：<br>{suffix}"

    # Rule 2: For long titles without colons, find semantic break
    if len(title) > 28:
        # Target line length: 18-25 chars
        target_length = 20

        # Look for natural break points
        break_patterns = [
            ('による', 3),
            ('について', 4),
            ('として', 3),
            ('における', 4),
            ('に関する', 4),
            ('、', 1),
            ('。', 1),
        ]

        for pattern, offset in break_patterns:
            idx = title.find(pattern)
            if idx != -1:
                break_point = idx + len(pattern)
                # Check if this creates reasonable line lengths
                if target_length - 8 < break_point < target_length + 8:
                    return title[:break_point] + '<br>' + title[break_point:]

        # Fallback: break near middle at any particle
        mid_point = len(title) // 2
        fallback_particles = ['と', 'の', 'を', 'に', 'で', 'が', 'は']
        for i in range(mid_point - 6, mid_point + 6):
            if 0 <= i < len(title) and title[i] in fallback_particles:
                # Don't break right after the particle, find the next character
                if i + 1 < len(title):
                    return title[:i+1] + '<br>' + title[i+1:]

    return title


def make_output_slug(title: str, existing: set[str]) -> str:
    normalized = unicodedata.normalize("NFKC", title).strip().lower()
    ascii_slug = re.sub(r"\s+", "-", normalized)
    ascii_slug = re.sub(r"[^a-z0-9-]", "", ascii_slug)
    if not ascii_slug:
        ascii_slug = f"manual-{hashlib.sha1(title.encode('utf-8')).hexdigest()[:8]}"
    candidate = ascii_slug
    counter = 2
    while candidate in existing:
        candidate = f"{ascii_slug}-{counter}"
        counter += 1
    existing.add(candidate)
    return candidate


def discover_manual_sources(docs_path: Path) -> List[Dict[str, object]]:
    sources: List[Dict[str, object]] = []
    for entry in sorted(docs_path.iterdir(), key=lambda p: p.name):
        if entry.is_dir():
            md_files = sorted(
                (child for child in entry.iterdir() if child.is_file() and child.suffix.lower() == ".md"),
                key=lambda p: p.name,
            )
            if not md_files:
                continue
            sources.append(
                {
                    "label": entry.name,
                    "paths": md_files,
                    "source_display": str(entry.relative_to(ROOT)),
                    "slug_hint": entry.name,
                }
            )
        elif entry.is_file() and entry.suffix.lower() == ".md":
            sources.append(
                {
                    "label": entry.stem,
                    "paths": [entry],
                    "source_display": str(entry.relative_to(ROOT)),
                    "slug_hint": entry.stem,
                }
            )
    return sources


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(description="Build the HTML manual site from docs/")
    parser.add_argument("--docs", type=Path, default=DOCS_DIR, help="Source markdown directory")
    parser.add_argument("--out", type=Path, default=OUTPUT_DIR, help="Output directory for generated site")
    args = parser.parse_args(argv)

    docs_path = args.docs
    output_path = args.out

    if not docs_path.exists():
        print(f"[!] Docs directory not found: {docs_path}", file=sys.stderr)
        return 1

    manual_sources = discover_manual_sources(docs_path)
    if not manual_sources:
        print("[!] No Markdown files found under docs.", file=sys.stderr)
        return 1

    if not TEMPLATE_PATH.exists():
        print(f"[!] Template not found: {TEMPLATE_PATH}", file=sys.stderr)
        return 1

    output_path.mkdir(parents=True, exist_ok=True)
    assets_output = ensure_assets(output_path)

    template = TEMPLATE_PATH.read_text(encoding="utf-8")
    manuals_index: List[Dict[str, str]] = []
    now = dt.datetime.now()

    used_slugs: set[str] = set()

    # ===== HTML直接編集モード: Markdownからの変換を無効化 =====
    # HTMLファイルに独自デザイン要素が含まれているため、
    # Markdownからのビルドは行わない（2025-10-11 方針変更）
    #
    # 以下のコードをコメントアウトして、既存HTMLを保持
    print("[!] HTML直接編集モード: Markdownからの変換はスキップされます")
    print("[!] site/ai/index.html を直接編集してください")
    return 0  # ビルド処理を中断

    # ----- 以下、従来のビルドロジック（無効化） -----
    for source in manual_sources:
        converter = MarkdownConverter()
        markdown_segments: List[str] = []
        paths: List[Path] = source["paths"]  # type: ignore[assignment]
        for path in paths:
            markdown_segments.append(path.read_text(encoding="utf-8").strip())
        markdown_text = "\n\n".join(segment for segment in markdown_segments if segment)
        html_body = converter.convert(markdown_text)

        # Wrap long procedural sections with special styled divs
        # Use a more robust approach: split by h3/h4 and wrap specific sections

        def wrap_section_by_heading(html: str, heading_text: str, css_class: str) -> str:
            """Wrap content from a specific h4 heading until the next h3 or h4."""
            # Match h4 with specific text, capture all content until next h3 or h4
            pattern = (
                r'(<h4[^>]*>' + re.escape(heading_text) + r'[^<]*</h4>)'
                r'((?:(?!<h[34]\s).)*)'
            )

            def replacer(match):
                h4_tag = match.group(1)
                content = match.group(2)
                # Check if already wrapped
                if f'class="{css_class}"' in match.group(0):
                    return match.group(0)
                return f'<div class="{css_class}">{h4_tag}{content}</div>'

            return re.sub(pattern, replacer, html, flags=re.DOTALL | re.IGNORECASE)

        # Apply wrapping for each section
        html_body = wrap_section_by_heading(html_body, '✅ Git for Windowsのインストール手順', 'git-install-section')
        html_body = wrap_section_by_heading(html_body, '✅ Claude Codeのインストール', 'claude-install-section')
        html_body = wrap_section_by_heading(html_body, '✅ 認証設定', 'auth-setup-section')

        title = converter.title or str(source["label"])
        # No subtitle block
        subtitle_block = ""
        toc_html = build_toc(converter.headings)
        slug_hint = str(source["slug_hint"])

        # Use directory name for ai-prep-manual to ensure consistent URL
        if slug_hint == "ai-prep-manual":
            slug = "ai"
            used_slugs.add(slug)
        else:
            slug = make_output_slug(title or slug_hint, used_slugs)

        manual_dir = output_path / slug
        if manual_dir.exists():
            shutil.rmtree(manual_dir)
        manual_dir.mkdir(parents=True)

        assets_href = Path(os.path.relpath(assets_output, manual_dir)).as_posix()

        source_display = source["source_display"]  # type: ignore[assignment]

        # Apply magazine-quality typography to title
        beautified_title = beautify_japanese_title(html.escape(title))

        page_html = apply_template(
            template,
            {
                "title": beautified_title,
                "subtitle_block": subtitle_block,
                "generated_on": now.strftime("%Y-%m-%d %H:%M"),
                "source_path": html.escape(source_display),
                "assets_href": assets_href,
                "toc": toc_html,
                "content": html_body,
            },
        )

        (manual_dir / "index.html").write_text(page_html, encoding="utf-8")

        # Apply magazine-quality typography to index title as well
        index_title = beautify_japanese_title(html.escape(title))

        manuals_index.append(
            {
                "title": index_title,
                "href": f"{slug}/",
                "summary": html.escape(summarize_manual(converter)),
                "sections": str(len([h for h in converter.headings if h["level"] == 2])),
                "generated_on": now.strftime("%Y-%m-%d"),
            }
        )

        print(f"[+] Generated {manual_dir / 'index.html'}")

    render_index(output_path, manuals_index)
    print(f"[✓] Done. Open {output_path / 'index.html'} in a browser.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
