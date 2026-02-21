#!/usr/bin/env bash
set -Eeuo pipefail

echo "=== postCreate: starting as $(whoami) in $(pwd)"

# --------- 1) Locate python
PY_CANDIDATES=(
  "/usr/local/python/current/bin/python"
  "$(command -v python3 || true)"
  "$(command -v python || true)"
)

PY=""
for c in "${PY_CANDIDATES[@]}"; do
  if [[ -n "${c:-}" && -x "${c:-}" ]]; then
    PY="$c"
    break
  fi
done

if [[ -z "$PY" ]]; then
  echo "ERROR: No python found. Candidates: ${PY_CANDIDATES[*]}"
  exit 1
fi

echo "=== postCreate: using python: $PY"
"$PY" --version || true

# --------- 2) Always use a venv in the workspace (avoids permission/externally-managed issues)
VENV_DIR="${VENV_DIR:-${PWD}/.venv}"
echo "=== postCreate: creating venv at $VENV_DIR"
"$PY" -m venv "$VENV_DIR"

VENV_PY="${VENV_DIR}/bin/python"
if [[ ! -x "$VENV_PY" ]]; then
  echo "ERROR: venv python not found at $VENV_PY"
  exit 1
fi

echo "=== postCreate: venv python: $VENV_PY"
"$VENV_PY" -m pip install --upgrade pip setuptools wheel

# --------- 3) Jupyter kernel + ipyturtle3
"$VENV_PY" -m pip show ipykernel >/dev/null 2>&1 || "$VENV_PY" -m pip install ipykernel

# Register kernel (idempotent-ish: reinstall is fine)
"$VENV_PY" -m ipykernel install --user \
  --name "workspace-python" \
  --display-name "Python (Workspace)"

# --------- 4) Install editor extensions if a CLI is available
pick_editor_cli () {
  if command -v code-server >/dev/null 2>&1; then
    echo "code-server"
    return 0
  fi
  if command -v code >/dev/null 2>&1; then
    echo "code"
    return 0
  fi
  if [[ -x "/tmp/code-server/bin/code-server" ]]; then
    echo "/tmp/code-server/bin/code-server"
    return 0
  fi
  echo ""
}

CLI="$(pick_editor_cli)"
echo "=== postCreate: editor CLI: ${CLI:-<none>}"

install_ext () {
  local ext="$1"
  if [[ -z "${CLI:-}" ]]; then
    echo "Skipping extension install (no CLI): $ext"
    return 0
  fi
  if "$CLI" --list-extensions 2>/dev/null | grep -qx "$ext"; then
    echo "Extension already installed: $ext"
  else
    echo "Installing extension: $ext"
    "$CLI" --install-extension "$ext" || echo "WARN: failed to install $ext (continuing)"
  fi
}

install_ext ms-python.python
install_ext ms-toolsai.jupyter

# --------- 5) Force settings so notebooks use the venv python automatically
# code-server user settings
CS_USER_DIR="${HOME}/.local/share/code-server/User"
mkdir -p "$CS_USER_DIR"
cat > "${CS_USER_DIR}/settings.json" <<EOF
{
  "python.defaultInterpreterPath": "${VENV_PY}",
  "jupyter.jupyterServerType": "local",
  "jupyter.kernels.excludePythonEnvironments": [
    "/usr/bin/python",
    "/usr/bin/python3",
    "/bin/python",
    "/bin/python3"
  ]
}
EOF

# VS Code server machine settings (harmless if unused)
VSC_MACHINE_DIR="${HOME}/.vscode-server/data/Machine"
mkdir -p "$VSC_MACHINE_DIR"
cat > "${VSC_MACHINE_DIR}/settings.json" <<EOF
{
  "python.defaultInterpreterPath": "${VENV_PY}",
  "jupyter.jupyterServerType": "local"
}
EOF

echo "=== postCreate: done"
