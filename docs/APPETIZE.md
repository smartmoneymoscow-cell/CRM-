# Appetize.io — эмулятор в браузере

Приложение запускается в облачном Android-эмуляторе прямо в браузере.

## Ссылка

🔗 **https://appetize.io/app/ycj34xymn6yympbgogaxwil37i**

## API-ключ

```
tok_5l2agl6ota5qqqbeduznpztfa4
```

> ⚠️ Не публикуй ключ в открытом доступе. Используй только для автоматизации сборок.

## Обновление APK

После сборки новой версии загрузи APK через API:

```bash
curl -X POST "https://api.appetize.io/v1/apps" \
  -u "tok_5l2agl6ota5qqqbeduznpztfa4:" \
  -F "file=@app-release.apk" \
  -F "platform=android" \
  -F "note=Crazy Trout Arena CRM vX.Y.Z"
```

Ответ вернёт `publicURL` — это и есть ссылка на эмулятор.

## Лимиты

- Бесплатный тариф: **100 минут/месяц**
- Сессия: ~15 минут бездействия → автозакрытие
- Платформа: Android (по умолчанию)

## Управление

- Панель: https://appetize.io/manage/ycj34xymn6yympbgogaxwil37i
- Настройки API-ключей: https://appetize.io/account/api-keys