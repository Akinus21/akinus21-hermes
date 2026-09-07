#!/bin/bash
set -e

DATA_DIR="${HERMES_HOME:-/opt/data}"
VENV_PIP="/opt/hermes/.venv/bin/pip"
VENV_PYTHON="/opt/hermes/.venv/bin/python"

cd "$DATA_DIR"

git config --system --add safe.directory "$DATA_DIR" 2>/dev/null || true

if [ ! -d .git ]; then
    echo "[init-evolution-repo] Initializing git repo in $DATA_DIR for self-evolution"
    gosu hermes git init
    gosu hermes git config user.email "hermes@akinus21.com"
    gosu hermes git config user.name "Hermes Self-Evolution"
    cat > "$DATA_DIR/.gitignore" << 'EOF'
config.yaml
config.yaml.bak-*
.env
.env.bak-*
auth.json
platforms/
.gh-token
.gh-credentials/
.ssh/
sessions/
memories/
home/.rustup/
home/.cargo/
home/.npm/
home/.local/
home/bin/gh-cred
home/Gabriel-profile.json
lsp/node_modules/
lazy-packages/
skills/.hub/
skills/.usage.json*
skills/.curator_ledger.jsonl
skills/.curator_state
*.db
*.db-shm
*.db-wal
*.db.*.lock
*.log
vectordb/
models_dev_cache.*
provider_models_cache.json
ollama_cloud_models_cache.json
context_length_cache.yaml
apply_fix*.py
fix_sed*.py
check_*.py
iron_*
tmp_iron_*
tmp/
tmp_*.json
*.html
job*.json
run*.json
jobs_*.html
*_out.txt
watch-list.json
spawn-ledger.json
gateway-starts.log
gateway.pid
gateway.lock
gateway.sock
gateway_state.json
channel_directory.json
homelab-config-services.md
homelab-config-services.yaml
parse_*.py
debug_*.py
try_*.py
fetch_*.py
poll_iron.py
EOF
    chown hermes:hermes "$DATA_DIR/.gitignore"
    gosu hermes git add .gitignore
    gosu hermes git commit -m "Add gitignore before first real commit"
    gosu hermes git add -A
    gosu hermes git commit -m "Initial commit of live skills for self-evolution"
fi

# Install hermes-agent-self-evolution into the runtime venv, once
if [ -x "$VENV_PIP" ] && ! "$VENV_PYTHON" -c "import dspy" 2>/dev/null; then
    echo "[init-evolution-repo] Installing hermes-agent-self-evolution into Hermes venv"
    "$VENV_PIP" install -e "/opt/hermes-evolution[dev]"
fi
