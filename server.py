import zipfile, sys
from pathlib import Path

REPO = Path(__file__).parent
PLUGINS = REPO / "addons" / "amxmodx" / "plugins"

name = input("Nombre del ZIP (sin .zip): ").strip()
if not name:
    print("Cancelado.")
    sys.exit(1)

dest = Path.home() / "Desktop" / f"{name}.zip"

with zipfile.ZipFile(str(dest), "w", zipfile.ZIP_DEFLATED) as zf:
    for f in PLUGINS.rglob("*"):
        if f.is_file():
            arc = f.relative_to(REPO)
            zf.write(str(f), str(arc))
            print(f"  + {arc}")

size_kb = round(dest.stat().st_size / 1024, 1)
print(f"\nZIP creado: {dest} ({size_kb} KB)")
print("Subilo al File Manager de TCAdmin y extraelo en la raiz.")
