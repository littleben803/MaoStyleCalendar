#!/usr/bin/env python3
"""Validate the candidate English atlas against the unchanged Chinese source records."""
import hashlib
import json
from pathlib import Path
import re

RESOURCE_ROOT = Path(__file__).resolve().parents[1] / "Native/Resources/DailyArtwork"


def main():
    pages = json.loads((RESOURCE_ROOT / "content-packs.json").read_text())
    details = json.loads((RESOURCE_ROOT / "editorial-details.json").read_text())
    atlas = json.loads((RESOURCE_ROOT / "english-editorial.json").read_text())
    assert atlas["version"] == 1
    assert atlas["languageTag"] == "en"
    assert atlas["provenance"] == "project_editorial"
    assert atlas["status"] == "candidate"
    records = atlas["records"]
    assert len(records) == len(pages) == 365
    assert set(records) == {page["id"] for page in pages} == set(details)
    section_count = 0
    unresolved = []
    for page in pages:
        content_id = page["id"]
        record = records[content_id]
        chinese = details[content_id]
        source = {
            "quote": page["segments"], "title": page["title"],
            "sections": chinese["sections"], "sourceFragments": chinese["sourceFragments"],
        }
        checksum = hashlib.sha256(json.dumps(
            source, ensure_ascii=False, sort_keys=True, separators=(",", ":")
        ).encode()).hexdigest()
        assert record["sourceChecksum"] == checksum, (content_id, "Chinese source drift")
        assert page["reviewStatus"] == "candidate"
        assert len(record["sections"]) == len(chinese["sections"]), content_id
        for source_section, translated in zip(chinese["sections"], record["sections"]):
            assert translated["id"] == source_section["id"] + "-en", content_id
            assert translated["languageTag"] == "en", content_id
            assert translated["kind"] == source_section["kind"], content_id
            assert translated["displayOrder"] == source_section["displayOrder"], content_id
            assert len(translated["body"].split("\n\n")) >= len(source_section["body"].split("\n\n")), content_id
        for text in [record["title"], record["quote"], *(s["body"] for s in record["sections"])]:
            assert text.strip(), content_id
            assert not re.search(r"[\u3400-\u9fff]", text), (content_id, "untranslated Chinese")
            assert "English translation unavailable" not in text, content_id
            assert not re.search(r"[\x00-\x08\x0b\x0c\x0e-\x1f]", text), content_id
        if not chinese["sourceFragments"]:
            unresolved.append(content_id)
            assert all(s["kind"] != "original_context" for s in record["sections"]), content_id
        section_count += len(record["sections"])
    assert set(unresolved) == {"pack-0138", "pack-0149", "pack-0202", "pack-0282", "pack-0341"}
    assert section_count == 1085
    print(f"PASS: {len(records)} English card excerpts, {section_count} matching editorial sections; no Chinese fallback.")
    print("PASS: all Chinese source checksums match; all records remain candidate/project_editorial.")
    print(f"PASS: {len(unresolved)} unresolved-attribution cards retain their restricted source sections.")


if __name__ == "__main__":
    main()
