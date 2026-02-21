#!/usr/bin/env bash
set -euo pipefail

# ---- Pick Python
PY="/usr/local/python/current/bin/python"
if [[ ! -x "$PY" ]]; then
  PY="$(command -v python3 || true)"
fi
if [[ -z "${PY:-}" ]]; then
  echo "ERROR: python3 not found"
  exit 1
fi

# ---- Python packages
"$PY" -m pip install --upgrade pip
"$PY" -m pip show ipykernel >/dev/null 2>&1 || "$PY" -m pip install ipykernel

# ---- Register a stable kernel (idempotent)
"$PY" -m ipykernel install --user \
  --name "workspace-python" \
  --display-name "Python (Workspace)"

# ---- Install editor extensions (works for code-server and VS Code server variants)
install_ext () {
  local ext="$1"
  local cli=""

  if command -v code-server >/dev/null 2>&1; then
    cli="code-server"
  elif command -v code >/dev/null 2>&1; then
    cli="code"
  elif [[ -x "${HOME}/.local/bin/code-server" ]]; then
    cli="${HOME}/.local/bin/code-server"
  fi

  if [[ -z "$cli" ]]; then
    echo "No code/code-server CLI found; skipping extension install for $ext"
    return 0
  fi

  if "$cli" --list-extensions 2>/dev/null | grep -qx "$ext"; then
    echo "Extension already installed: $ext"
  else
    "$cli" --install-extension "$ext"
  fi
}

install_ext ms-python.python
install_ext ms-toolsai.jupyter
install_ext ms-python.vscode-pylance
install_ext donjayamanne.vscode-default-python-kernel

# ---- Force settings where code-server expects them
CS_USER_DIR="${HOME}/.local/share/code-server/User"
mkdir -p "$CS_USER_DIR"
cat > "${CS_USER_DIR}/settings.json" <<EOF
{
  "python.defaultInterpreterPath": "${PY}",
  "jupyter.jupyterServerType": "local",
  "jupyter.kernels.excludePythonEnvironments": [
    "/usr/bin/python",
    "/usr/bin/python3",
    "/bin/python",
    "/bin/python3"
  ]
}
EOF

# ---- Also set VS Code server machine settings (harmless if unused)
VSC_MACHINE_DIR="${HOME}/.vscode-server/data/Machine"
mkdir -p "$VSC_MACHINE_DIR"
cat > "${VSC_MACHINE_DIR}/settings.json" <<EOF
{
  "python.defaultInterpreterPath": "${PY}",
  "jupyter.jupyterServerType": "local"
}
EOF

echo "postCreate complete."
