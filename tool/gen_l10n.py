#!/usr/bin/env python3
"""Generates lib/l10n/app_<lang>.arb and Android app-name resources from
tool/l10n/<lang>.py. Run from the repo root:

    python3 tool/gen_l10n.py && flutter gen-l10n

To add or change a string, edit tool/l10n/en.py and every other language file;
the script fails if any language is missing a key or has an extra one.
"""
import importlib.util
import json
import pathlib
import sys
from xml.sax.saxutils import escape

ROOT = pathlib.Path(__file__).resolve().parent.parent
SRC = ROOT / "tool" / "l10n"
ARB_DIR = ROOT / "lib" / "l10n"
RES_DIR = ROOT / "android" / "app" / "src" / "main" / "res"

# Keep in sync with lib/app_languages.dart.
LANGS = ["en", "zh", "hi", "es", "ar", "fr", "bn", "pt", "ru", "ur", "id", "de", "ja", "tr", "ko"]

# Android resource qualifiers (Indonesian historically uses "in").
ANDROID_QUALIFIER = {"id": "in"}


def load(lang):
    spec = importlib.util.spec_from_file_location(lang, SRC / f"{lang}.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod.T


def main():
    en = load("en")
    errors = []
    for lang in LANGS:
        t = load(lang)
        missing = en.keys() - t.keys()
        extra = t.keys() - en.keys()
        if missing:
            errors.append(f"{lang}: missing {sorted(missing)}")
        if extra:
            errors.append(f"{lang}: extra {sorted(extra)}")
        for k, v in t.items():
            if "{" in v or "}" in v:
                errors.append(f"{lang}.{k}: braces are not allowed")
        if errors:
            continue

        arb = {"@@locale": lang}
        arb.update({k: t[k] for k in en})
        (ARB_DIR / f"app_{lang}.arb").write_text(
            json.dumps(arb, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

        qualifier = "" if lang == "en" else "-" + ANDROID_QUALIFIER.get(lang, lang)
        values = RES_DIR / f"values{qualifier}"
        values.mkdir(parents=True, exist_ok=True)
        name = escape(t["appTitle"]).replace("'", "\\'")
        (values / "strings.xml").write_text(
            '<?xml version="1.0" encoding="utf-8"?>\n<resources>\n'
            f'    <string name="app_name">{name}</string>\n</resources>\n',
            encoding="utf-8")

    if errors:
        print("\n".join(errors), file=sys.stderr)
        sys.exit(1)

    xml_dir = RES_DIR / "xml"
    xml_dir.mkdir(parents=True, exist_ok=True)
    locales = "\n".join(f'    <locale android:name="{l}" />' for l in LANGS)
    (xml_dir / "locales_config.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<locale-config xmlns:android="http://schemas.android.com/apk/res/android">\n'
        f"{locales}\n</locale-config>\n", encoding="utf-8")
    print(f"Generated {len(LANGS)} languages, {len(en)} strings each.")


if __name__ == "__main__":
    main()
