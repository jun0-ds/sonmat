#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
python3 - <<'PY'
import json
import re
import sys
import tomllib
from pathlib import Path


def fail(message):
    print(f'Static check failed: {message}', file=sys.stderr)
    sys.exit(1)


for path in sorted(Path('skills').glob('*/SKILL.md')) + sorted(Path('agents').glob('*.md')):
    content = path.read_text()
    match = re.match(r'\A---\s*\n(.*?)\n---\s*(?:\n|\Z)', content, re.DOTALL)
    if not match:
        fail(f'{path}: missing frontmatter')
    frontmatter = match.group(1)
    if '<' in frontmatter or '>' in frontmatter:
        fail(f'{path}: angle bracket in frontmatter')
    fields = dict(re.findall(r'^(name|description):[ \t]*(.*)$', frontmatter, re.MULTILINE))
    for field in ('name', 'description'):
        if not fields.get(field, '').strip().strip("'\"").strip():
            fail(f'{path}: missing {field}')
    name = fields['name'].strip().strip("'\"")
    expected = path.parent.name if path.name == 'SKILL.md' else path.stem
    if name != expected:
        fail(f'{path}: name {name!r} differs from {expected!r}')
    description = fields['description'].strip()
    if len(description) >= 2 and description[0] == description[-1] and description[0] in "'\"":
        description = description[1:-1]
    if len(description) > 1024:
        fail(f'{path}: description exceeds 1024 characters')

claude = json.loads(Path('.claude-plugin/plugin.json').read_text())
market = json.loads(Path('.claude-plugin/marketplace.json').read_text())
codex = json.loads(Path('.codex-plugin/plugin.json').read_text())
history = re.search(r'^\|\s*`(\d+\.\d+\.\d+)`\s*\|', Path('VERSIONING.md').read_text(), re.MULTILINE)
if not history:
    fail('VERSIONING.md: version history missing')
versions = [claude['version'], market['metadata']['version'], market['plugins'][0]['version'], codex['version'], history.group(1)]
if len(set(versions)) != 1:
    fail(f'version mismatch: {versions}')

md_agents = {p.stem.replace('-', '_') for p in Path('agents').glob('sonmat-*.md')}
toml_agents = {p.stem for p in Path('codex/agents').glob('sonmat_*.toml')}
if md_agents != toml_agents:
    fail(f'agent pairs differ: markdown={sorted(md_agents)}, toml={sorted(toml_agents)}')
for path in Path('codex/agents').glob('sonmat_*.toml'):
    with path.open('rb') as file:
        tomllib.load(file)

if len(Path('discipline/hints.md').read_text()) > 8000:
    fail('discipline/hints.md exceeds 8000 characters')

pattern = re.compile(r'`((?:skills|agents|discipline|docs|templates|hooks|tests|scripts|codex|\.github)/[^`\s]+)`')
for root in ('skills', 'agents', 'discipline', 'codex'):
    for path in sorted(Path(root).rglob('*')):
        if path.suffix not in ('.md', '.toml') or not path.is_file():
            continue
        for candidate in pattern.findall(path.read_text()):
            if any(char in candidate for char in '{<*$'):
                continue
            if not Path(candidate).suffix:
                continue
            if not Path(candidate).exists():
                fail(f'{path}: missing path {candidate}')
print('Static checks passed.')
PY
