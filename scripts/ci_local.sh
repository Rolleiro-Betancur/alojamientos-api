#!/usr/bin/env bash
# CI LOCAL equivalente a .github/workflows/ci.yml. NO es un servicio de CI remoto.
# Uso: bash scripts/ci_local.sh   (desde la raiz del repo)  | RUN_ID=nombre PYTHON=python3.11
set -u
cd "$(dirname "$0")/.."
PY=${PYTHON:-python3.11}
RUN_ID=${RUN_ID:-$(date +%Y%m%dT%H%M%S)}
LOG="ci-logs/$RUN_ID"; mkdir -p "$LOG" dist-ci
COMMIT=$(git rev-parse HEAD); DESC=$(git describe --tags --always --dirty 2>/dev/null)
BLOCK_FAIL=0; ROWS=""
stage() { # stage <nombre> <blocking|advisory> <comando...>
  local n=$1 m=$2; shift 2
  local t0=$(date +%s); bash -c "$*" > "$LOG/$n.log" 2>&1; local rc=$?; local dt=$(( $(date +%s)-t0 ))
  local st="PASS"
  if [ $rc -ne 0 ]; then if [ "$m" = blocking ]; then st="FAIL"; BLOCK_FAIL=1; else st="ADVISORY-FINDINGS"; fi; fi
  ROWS+="| $n | $m | $st | rc=$rc | ${dt}s | $LOG/$n.log |\n"; echo "[$st] $n (rc=$rc, ${dt}s)"
}
echo "== CI local | run $RUN_ID | commit $COMMIT ($DESC) | $(date -Is)"
stage 01_arbol_limpio    blocking "test -z \"\$(git status --porcelain)\""
stage 02_venv_e_instalar blocking "rm -rf venv && $PY -m venv venv && venv/bin/python -m pip install -r requirements-dev.txt"
stage 03_pip_check       blocking "venv/bin/python -m pip check"
stage 04_ruff            blocking "venv/bin/ruff check ."
stage 05_black           blocking "venv/bin/black --check ."
stage 06_pytest          blocking "venv/bin/python -m pytest -q"
stage 07_pip_audit       advisory "venv/bin/python -m pip install pip-audit && venv/bin/pip-audit -r requirements.txt"
stage 08_empaquetar      blocking "git archive --format=tar --prefix=alojamientos-api-$DESC/ HEAD | gzip -n > dist-ci/alojamientos-api-$DESC-src.tar.gz && (cd dist-ci && sha256sum alojamientos-api-$DESC-src.tar.gz | tee SHA256SUMS)"
stage 09_sin_secretos    blocking "! tar -tzf dist-ci/alojamientos-api-$DESC-src.tar.gz | grep -E '(^|/)\.env\$'"
{ echo "# Resumen CI local (API) - run $RUN_ID"; echo "- commit: $COMMIT ($DESC)"; echo "- fecha: $(date -Is)"; echo "- python: $($PY --version) | host: $(uname -srm)"
  echo "- resultado global (solo etapas bloqueantes): $([ $BLOCK_FAIL -eq 0 ] && echo APROBADO || echo BLOQUEADO)"; echo
  echo "| etapa | tipo | estado | codigo | duracion | log |"; echo "|---|---|---|---|---|---|"; printf "$ROWS"; } > "$LOG/summary.md"
cat "$LOG/summary.md"
exit $BLOCK_FAIL
