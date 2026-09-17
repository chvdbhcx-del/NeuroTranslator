# NeuroTranslator

## Быстрая установка / Quick install

**Готовый бинарник (Windows):** скачайте `neurotranslator.exe` со страницы
[Releases](https://github.com/chvdbhcx-del/NeuroTranslator/releases) — распаковка/установка не нужны,
просто запустите:

```powershell
.\neurotranslator.exe --help
.\neurotranslator.exe download scripts\models.json.sample
```

Бинарник собирается автоматически в GitHub Actions (см. `.github/workflows/build.yml`)
и прикладывается к каждому релизу и к артефактам сборки.

**Установка одной строкой из исходников:**

Linux / macOS:

```bash
curl -fsSL https://raw.githubusercontent.com/chvdbhcx-del/NeuroTranslator/main/install.sh | bash
```

Windows PowerShell:

```powershell
irm https://raw.githubusercontent.com/chvdbhcx-del/NeuroTranslator/main/install.ps1 | iex
```

**Через pip / pipx** (нужен только Python 3.8+):

```bash
pipx install git+https://github.com/chvdbhcx-del/NeuroTranslator.git
# или
pip install git+https://github.com/chvdbhcx-del/NeuroTranslator.git
```

После установки доступна команда `neurotranslator`:

```bash
neurotranslator --help
neurotranslator download scripts/models.json.sample   # скачать и проверить модели
neurotranslator checksums --models-dir models          # посчитать SHA-256
neurotranslator list scripts/models.json.sample        # показать список моделей
```

> Примечание: `neurotranslator` — CLI-обёртка (только стандартная библиотека Python)
> над скриптами из `scripts/`. Отдельного Android-приложения в репозитории нет,
> поэтому `.apk` не собирается; для десктопа поставляется `.exe`.

---

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

