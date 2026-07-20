#!/usr/bin/env python3
"""Парсит вывод `flutter test --reporter json` и печатает имена упавших
тестов как GitHub Actions ::error:: аннотации.

Раньше единственным способом узнать ИМЕНА конкретных упавших тестов было
скачать сырые логи job'а — но они хранятся на Azure Blob Storage и
недоступны из некоторых окружений (в т.ч. из песочницы Claude). Этот
скрипт печатает имена явно, в самом выводе шага, без необходимости
скачивать что-либо ещё.

Использование (см. .github/workflows/build-apk.yml):
    flutter test --reporter json > test_results.json
    python3 scripts/parse_test_results.py test_results.json
"""
import json
import sys


def main() -> int:
    path = sys.argv[1] if len(sys.argv) > 1 else "test_results.json"
    names: dict[int, str] = {}
    failed: list[str] = []

    with open(path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                ev = json.loads(line)
            except json.JSONDecodeError:
                continue

            if ev.get("type") == "testStart":
                t = ev.get("test", {})
                names[t.get("id")] = t.get("name", "?")
            elif ev.get("type") == "testDone" and not ev.get("hidden") and ev.get("result") == "failure":
                failed.append(names.get(ev.get("testID"), f"testID={ev.get('testID')}"))
            elif ev.get("type") == "error":
                # Дополнительный контекст ошибки, если есть testID
                name = names.get(ev.get("testID"), f"testID={ev.get('testID')}")
                msg = (ev.get("error") or "").splitlines()[0] if ev.get("error") else ""
                if msg:
                    print(f"::error::[{name}] {msg[:300]}")

    if failed:
        print(f"=== УПАЛО ТЕСТОВ: {len(failed)} ===")
        for name in failed:
            print(f"::error::FAILED TEST: {name}")
        return 1

    print("Все тесты в JSON-отчёте прошли успешно (или файл пуст/не распарсился).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
