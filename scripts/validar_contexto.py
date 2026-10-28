"""Comprueba que el paquete de contexto sea portable y tenga sus enlaces locales.

Usa solo la biblioteca estándar. No valida que una app todavía no creada funcione.
Ejecutar desde cualquier directorio: python RUTA_REPO/scripts/validar_contexto.py
"""
from pathlib import Path
import re
from urllib.parse import unquote, urlsplit


def main():
    root = Path(__file__).resolve().parents[1]
    errors = []
    required = [
        "README.md", "AGENTS.md", "docs/CONTEXTO_GENERAL.md",
        "docs/PLAN_IMPLEMENTACION.md", "docs/CONTRATOS.md",
        "docs/FLUJO_EQUIPO.md", "docs/ARRANQUE_CRISTHOPER.md",
        "docs/TRAZABILIDAD.md", "docs/VALIDACION.md", "docs/ESTADO.md",
        "docs/DISENO.md", "docs/ENTORNO_Y_APK.md",
        "docs/VIDEO_Y_SUSTENTACION.md", "docs/entregas/PLANTILLA.md",
        "prps/README.md", "prps/F01-CRISTHOPER.md", "prps/F02-JUAN.md",
        "prps/F03-BRIANNA.md", "prps/F04-ADRIANA.md", "prps/F05-CARLA.md",
    ]
    for path in required:
        if not (root / path).is_file():
            errors.append(f"Falta archivo requerido: {path}")
    files = [root / "README.md", root / "AGENTS.md"]
    for folder in ("docs", "prps", ".agents/skills"):
        files.extend(sorted((root / folder).rglob("*.md")))
    link_count = 0
    for path in files:
        if not path.is_file():
            continue
        content = path.read_text(encoding="utf-8")
        if "\ufffd" in content:
            errors.append(f"Texto con caracter de reemplazo: {path.relative_to(root)}")
        # Excluir bloques de codigo, cuyos ejemplos pueden contener sintaxis Markdown.
        content = re.sub(r"```.*?```", "", content, flags=re.S)
        for match in re.finditer(r"!?\[[^\]\n]*\]\(([^)\n]+)\)", content):
            target = match.group(1).strip()
            if target.startswith("<") and target.endswith(">"):
                target = target[1:-1]
            parsed = urlsplit(target)
            if parsed.scheme or target.startswith("#"):
                continue
            local = unquote(parsed.path)
            if not local:
                continue
            resolved = (path.parent / local).resolve()
            if not resolved.is_relative_to(root):
                errors.append(f"Enlace fuera del clon: {path.relative_to(root)} -> {target}")
            elif not resolved.exists():
                errors.append(f"Enlace roto: {path.relative_to(root)} -> {target}")
            link_count += 1
    for name in ("qupawasi-fase", "qupawasi-sqlite", "qupawasi-ui"):
        skill = root / ".agents" / "skills" / name / "SKILL.md"
        if not skill.is_file():
            errors.append(f"Falta skill: {name}")
            continue
        body = skill.read_text(encoding="utf-8")
        if not body.startswith(f"---\nname: {name}\ndescription: "):
            errors.append(f"Frontmatter inesperado: {name}")
    references = list((root / "docs" / "referencias").glob("*.png"))
    if len(references) != 8:
        errors.append(f"Esperadas 8 referencias PNG unicas; encontradas {len(references)}")
    if errors:
        print("VALIDACION FALLIDA")
        for error in errors:
            print(f"- {error}")
        return 1
    print(f"OK: {len(files)} Markdown, {link_count} enlaces locales, 5 PRP y 3 skills.")
    print("Esto verifica el contexto; no demuestra implementacion, build ni APK instalado.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
