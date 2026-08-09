import subprocess, os, zipfile, sys
from pathlib import Path

REPO = Path(__file__).parent

name = input("Nombre del ZIP (sin .zip): ").strip()
if not name:
    print("Cancelado.")
    sys.exit(1)

result = subprocess.run(
    ["git", "diff", "--name-only", "HEAD~1", "HEAD"],
    capture_output=True, text=True, cwd=str(REPO)
)
changes = [f.strip().replace("/", os.sep) for f in result.stdout.strip().split("\n") if f.strip()]

if not changes:
    print("No hay cambios entre HEAD~1 y HEAD.")
    sys.exit(1)

dest = Path.home() / "Desktop" / f"{name}.zip"

with zipfile.ZipFile(str(dest), "w", zipfile.ZIP_DEFLATED) as zf:
    for f in changes:
        src = REPO / f
        if src.exists():
            zf.write(str(src), f)
            print(f"  + {f}")
        else:
            print(f"  (borrado) {f}")

size_kb = round(dest.stat().st_size / 1024, 1)
print(f"\nZIP creado: {dest} ({size_kb} KB)")
print("Subilo al File Manager de TCAdmin y extraelo en la raiz.")
