# NeuroTranslator

## О проекте

NeuroTranslator — набор скриптов для установки зависимостей, скачивания и проверки моделей (SHA-256), выгрузки в S3 или Google Drive.

В репозитории пары скриптов Bash (.sh) и PowerShell (.ps1). Отдельного runtime нет.

## Требования

- Python 3 (venv)
- curl или wget; jq для JSON; unzip
- Опционально: AWS CLI, rclone

## Установка

```bash
git clone https://github.com/chvdbhcx-del/NeuroTranslator.git
cd NeuroTranslator
python3 -m venv venv
source venv/bin/activate
./scripts/install_deps.sh
```

Windows PowerShell: активируйте venv, затем scripts\install_deps.ps1

## Скачивание моделей

```bash
./scripts/download_models.sh scripts/models.json.sample
```

Архивы в models/. Пример: scripts/models.json.sample

## Управление моделями

- Контрольные суммы: ./scripts/compute_checksums.sh models models.json
- S3: ./scripts/upload_to_s3.sh <bucket> [models_dir]
- Google Drive: ./scripts/upload_to_gdrive.sh <remote> <path> [models_dir]

## Структура scripts/

- install_deps.(sh|ps1)
- download_models.(sh|ps1), models.json.sample
- compute_checksums.(sh|ps1)
- upload_to_s3.(sh|ps1), upload_to_gdrive.(sh|ps1)

