#!/usr/bin/env bash
# Levanta el backend PHP (SQLite, puerto 8000) y el frontend de Quasar (puerto 9000)
# a la vez. Requiere PHP en el PATH (con extensión pdo_sqlite) y pnpm/npm instalados.
set -e

cd "$(dirname "$0")"

BACKEND_PORT=8000
BACKEND_DIR="viabus-backend"

echo "==> Iniciando backend PHP en http://localhost:$BACKEND_PORT"
php -S "localhost:$BACKEND_PORT" -t "$BACKEND_DIR" "$BACKEND_DIR/router.php" &
BACKEND_PID=$!

cleanup() {
  echo ""
  echo "==> Deteniendo backend (PID $BACKEND_PID)"
  kill "$BACKEND_PID" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

echo "==> Iniciando frontend Quasar en http://localhost:9000"
if command -v pnpm >/dev/null 2>&1; then
  pnpm dev
elif command -v npm >/dev/null 2>&1; then
  npm run dev
else
  echo "No se encontró pnpm ni npm en el PATH." >&2
  exit 1
fi
