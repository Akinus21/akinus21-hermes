FROM nousresearch/hermes-agent:latest

RUN mkdir -p /usr/local/lib/docker/cli-plugins && \
    curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
    -o /usr/local/lib/docker/cli-plugins/docker-compose && \
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# --- Hermes Self-Evolution ---
RUN apt-get update && apt-get install -y --no-install-recommends git && \
    rm -rf /var/lib/apt/lists/*

# Cloned from our own fork, pinned to the commit with the SkillModule /
# constraint-validation bugfixes — not upstream, and not tracking main,
# so a future push to the fork doesn't silently change what this
# image builds against.
RUN git clone https://forge.akinus21.com/akinus/akinus21-hermes-agent-self-evolution.git /opt/hermes-evolution && \
    cd /opt/hermes-evolution && git checkout aa7e47a

ENV HERMES_AGENT_REPO=/opt/data

# Wrapper so `hermes-evolve` is callable like any other hermes subcommand.
# Uses bare `python`, which resolves to /opt/hermes/.venv/bin/python at
# runtime — the same venv init-evolution-repo.sh installs into.
RUN printf '#!/bin/bash\ncd /opt/hermes-evolution\nexec python -m evolution.skills.evolve_skill "$@"\n' \
    > /usr/local/bin/hermes-evolve && \
    chmod +x /usr/local/bin/hermes-evolve

# Idempotent init — repo setup AND evolution-tool pip install, both need
# to run after the venv exists, i.e. at container start, not build time
# (the base image provisions /opt/hermes/.venv at runtime, not in the
# image layers, so anything installed into it can't happen in a RUN step)
COPY init-evolution-repo.sh /usr/local/bin/init-evolution-repo.sh
RUN chmod +x /usr/local/bin/init-evolution-repo.sh

# Wraps the base image's real entrypoint so init runs first, every start
COPY docker-entrypoint-wrapper.sh /usr/local/bin/docker-entrypoint-wrapper.sh
RUN chmod +x /usr/local/bin/docker-entrypoint-wrapper.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint-wrapper.sh"]