#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec /home/farrukh/.local/bin/pico8 "$ROOT/carts/linesgotchi.p8"

