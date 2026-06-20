# Skill Manager

Marketplace search, GitHub scanning, and skill installation manager for the [OPL AI](https://github.com/varkrish/opl-crew-mono) platform. Provides a write API and embedded UI for managing the skills ecosystem, complementing the read-only [Skills Service](https://github.com/varkrish/skills-service).

## Features

- **Marketplace search** — browse 107,000+ skills from [agentskill.sh](https://agentskill.sh) with pagination, sorting, and category filtering
- **GitHub repo scanning** — scan any GitHub repo for SKILL.md files using the Git Tree API
- **Single and bulk install** — async job-based installation with polling
- **Skill deletion** — remove installed skills with automatic reindex
- **Embedded UI** — self-contained HTML UI at `/` for visual management
- **Automatic reindex** — triggers the Skills Service to rebuild its vector index after install/delete

## Quick Start

### Run standalone

```bash
pip install -e .
SKILLS_MARKETPLACE_DIR=./marketplace SKILLS_SERVICE_URL=http://localhost:8090 \
  uvicorn main:app --port 8091
```

### Run with Docker/Podman

```bash
podman build -t skill-manager -f Containerfile .
podman run -p 8091:8091 \
  -e SKILLS_SERVICE_URL=http://skills-service:8090 \
  -v marketplace:/app/skills/marketplace \
  skill-manager
```

### Run as part of OPL Crew (dev compose)

This service is a **Git submodule** of [opl_ai_mono](https://github.com/varkrish/opl-crew-mono) at `skill-manager/` (alongside `skills-service/`, which must be running for installs to trigger reindex). Clone the mono repo with submodules:

```bash
git clone --recurse-submodules https://github.com/varkrish/opl-crew-mono.git opl_ai_mono
cd opl_ai_mono && git submodule update --init skills-service skill-manager
podman compose -f dev-compose.yml --profile skills up -d
```

Optional `.env` overrides: `SKILL_MANAGER_DIR`, `SKILLS_SERVICE_DIR`, `FRAPPE_SKILLS_DIR` (see mono `dev-compose.yml`).

## API

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/health` | Health check |
| GET | `/api/marketplace/search` | Search agentskill.sh (params: `q`, `page`, `limit`, `sort`, `category`) |
| POST | `/api/marketplace/install` | Install a single skill (async, returns `job_id`) |
| GET | `/api/github/scan` | Scan a GitHub repo for SKILL.md files (param: `repo_url`) |
| POST | `/api/github/install-bulk` | Bulk install from scan results (async, returns `job_id`) |
| GET | `/api/jobs/{job_id}` | Poll job status |
| GET | `/api/installed` | List installed skills |
| DELETE | `/api/installed/{slug}` | Delete an installed skill |
| GET | `/` | Embedded management UI |

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `SKILLS_SERVICE_URL` | `http://skills-service:8090` | URL of the read-only Skills Service (for reindex trigger) |
| `SKILLS_MARKETPLACE_DIR` | `/app/skills/marketplace` | Directory where installed skills are stored |
| `GITHUB_TOKEN` | — | Optional GitHub token for higher API rate limits |

## Project Structure

```
skill-manager/
├── main.py              # FastAPI app, all REST endpoints
├── marketplace.py       # agentskill.sh API client, GitHub scanning, SKILL.md fetch
├── requirements.txt     # Python dependencies
├── ui/
│   └── index.html       # Embedded management UI (marketplace, GitHub, installed tabs)
├── tests/
│   ├── test_api.py      # API endpoint tests
│   └── test_marketplace.py  # Marketplace/GitHub client tests
├── Containerfile        # Production image (UBI9 + Python 3.11)
└── pyproject.toml       # Project metadata
```

## Development

```bash
pip install -e ".[test]"
pytest
```

## License

MIT
