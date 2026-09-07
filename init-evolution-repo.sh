#!/bin/bash
set -e

cd "${HERMES_HOME:-/opt/data}"

if [ ! -d .git ]; then
    echo "[init-evolution-repo] Initializing git repo in ${HERMES_HOME:-/opt/data} for self-evolution"
    git init
    git config user.email "hermes@akinus21.com"
    git config user.name "Hermes Self-Evolution"
    cat > .gitignore << 'EOF'
config.yaml
platforms/
*.db
*.sqlite
*.log
vectordb/
EOF
    git add .
    git commit -m "Initial commit of live skills for self-evolution" --allow-empty
fi
