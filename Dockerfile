FROM nousresearch/hermes-agent:latest

RUN mkdir -p /usr/local/lib/docker/cli-plugins && \
    curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
    -o /usr/local/lib/docker/cli-plugins/docker-compose && \
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# --- Hermes Self-Evolution ---
RUN apt-get update && apt-get install -y --no-install-recommends git && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/NousResearch/hermes-agent-self-evolution.git /opt/hermes-evolution && \
    /opt/hermes/.venv/bin/pip install -e "/opt/hermes-evolution[dev]"

ENV HERMES_AGENT_REPO=/opt/data

# Wrapper so `hermes-evolve` is callable like any other hermes subcommand.
# Uses bare `python`, which resolves to /opt/hermes/.venv/bin/python — the
# same venv the pip install above targeted, so dspy and friends are on path.
RUN printf '#!/bin/bash\ncd /opt/hermes-evolution\nexec python -m evolution.skills.evolve_skill "$@"\n' \
    > /usr/local/bin/hermes-evolve && \
    chmod +x /usr/local/bin/hermes-evolve

# Idempotent repo-init script — safe to run every container start,
# no-ops if /opt/data is already a git repo
COPY init-evolution-repo.sh /usr/local/bin/init-evolution-repo.sh
RUN chmod +x /usr/local/bin/init-evolution-repo.sh

# Wraps the base image's real entrypoint so init runs first, every start
COPY docker-entrypoint-wrapper.sh /usr/local/bin/docker-entrypoint-wrapper.sh
RUN chmod +x /usr/local/bin/docker-entrypoint-wrapper.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint-wrapper.sh"]
