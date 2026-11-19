#!/usr/bin/env python3
"""Verify an actual iOS Release .app against its checked-in content sources."""
import argparse
import hashlib
import json
import plistlib
from pathlib import Path


def require(condition, message):
    if not condition:
        raise SystemExit(f"FAIL: {message}")


def digest(path):
    return hashlib.sha256(path.read_bytes()).digest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("app", type=Path)
    args = parser.parse_args()
    app = args.app.resolve()
    sources = Path(__file__).resolve().parents[1] / "Native" / "Resources"
    info = plistlib.loads((app / "Info.plist").read_bytes())
    require(info["CFBundleIdentifier"] == "com.ideaboxapps.maostylecalendar", "wrong app")
    for folder in ("DailyArtwork", "OnboardingPreview"):
        files = [p for p in (sources / folder).rglob("*") if p.is_file()]
        for source in files:
            output = app / source.relative_to(sources)
            require(output.is_file(), f"missing {output}")
            require(digest(source) == digest(output), f"content differs: {output}")
        print(f"PASS: {folder}, {len(files)} source-identical files")
    packs = json.loads((app / "DailyArtwork/content-packs.json").read_text())
    english = json.loads((app / "DailyArtwork/english-editorial.json").read_text())
    ids = {p["id"] for p in packs}
    require(len(packs) == len(ids) == 365, "incomplete or duplicate daily content")
    require(set(english["records"]) == ids, "English content coverage differs")
    for page in packs:
        require((app / "DailyArtwork" / page["filename"]).is_file(), f"missing {page['id']}")
    fonts = ("LibreBodoni.ttf", "SourceSerif4.ttf", "SourceHanSerifSC-Bold.otf")
    repo = Path(__file__).resolve().parents[2]
    for name in fonts:
        require((app / name).is_file(), f"missing font {name}")
        require(digest(app / name) == digest(repo / "docs/design/handoff/v2/fonts" / name),
                f"font differs: {name}")
    for name in ("SourceHanSerifSC-SemiBold.otf", "SourceHanSerifSC-Regular.otf"):
        require(not any(app.rglob(name)), f"removed font still bundled: {name}")
    forbidden = (b"--review-pack=", b"--review-onboarding", b"--widget-quiet-layout-qa",
                 b"debug.alwaysShowOnboarding", b"Mock IAP Purchase", b"Simulate Successful Purchase")
    executables = [app / info["CFBundleExecutable"]]
    widgets = list((app / "PlugIns").glob("*.appex"))
    require(bool(widgets), "missing Widget extension")
    for widget in widgets:
        widget_info = plistlib.loads((widget / "Info.plist").read_bytes())
        executables.append(widget / widget_info["CFBundleExecutable"])
        # CalendarResources resolves the containing app for iOS extensions.
        require(widget.parent.parent == app, "Widget cannot resolve the containing app")
    for executable in executables:
        data = executable.read_bytes()
        for flag in forbidden:
            require(flag not in data, f"Debug-only marker {flag!r} in {executable.name}")
    print("PASS: 365 bilingual packs, fonts, Widget placement and no Debug-only binary markers")
    print("Scope: package integrity only; not visual, transaction, licensing or App Store approval.")


if __name__ == "__main__":
    main()
