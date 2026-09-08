# NeuroTranslator

## О проекте

NeuroTranslator — набор скриптов для установки зависимостей, скачивания и проверки моделей (архивы с контрольными суммами SHA-256), а также выгрузки моделей в S3 или Google Drive.

В репозитории есть пары скриптов для **Bash** (`.sh`) и **PowerShell** (`.ps1`). Отдельного приложения или runtime здесь нет — только утилиты для зависимостей и моделей.

## Требования

- **Python 3** — для виртуального окружения (`venv`); `install_deps` ставит пакеты из `requirements.txt`, если файл есть
- **curl** или **wget** (Linux/macOS) — для скачивания архивов моделей; в PowerShell используется `Invoke-WebRequest`
- **jq** — для разбора JSON в bash-скриптах (`download_models.sh`, `compute_checksums.sh`)
- **unzip** — распаковка скачанных `.zip` (в PowerShell — `Expand-Archive`)
- Опционально:
  - **AWS CLI** (`aws`) — для `upload_to_s3`
  - **rclone** — для `upload_to_gdrive` (нужен настроенный remote, например `gdrive`)

## Установка

```bash
git clone https://github.com/chvdbhcx-del/NeuroTranslator.git
cd NeuroTranslator

python3 -m venv venv
# Linux / macOS:
source venv/bin/activate
# Windows PowerShell:
# .\venv\Scripts\Activate.ps1

# deps
./scripts/install_deps.sh
# или:
# .\scripts\install_deps.ps1
```

Скрипт install_deps обрабатывает манифесты в корне репозитория.

## Скачивание моделей

Модели скачиваются в каталог `models/` (архив `models/<name>.zip` и распаковка в `models/<name>/`).

Пример списка — `scripts/models.json.sample` (массив объектов `name` / `url` / `sha256`):

```bash
# нужен jq для JSON
./scripts/download_models.sh scripts/models.json.sample

# без аргумента — встроенный список
./scripts/download_models.sh
```

```powershell
.\scripts\download_models.ps1 -ModelsFile scripts/models.json.sample
# или встроенный список:
.\scripts\download_models.ps1
```

Если для записи указан `sha256`, скрипт проверяет сумму после загрузки; при совпадении с уже скачанным архивом повторная загрузка пропускается. Пустой `sha256` — проверка пропускается (рекомендуется заполнить суммы через `compute_checksums`).

## Управление моделями

### Контрольные суммы

Сканирует `.zip` в `models/` и пишет JSON со SHA-256:

```bash
./scripts/compute_checksums.sh models models.json
```

```powershell
.\scripts\compute_checksums.ps1 -ModelsDir models -OutFile models.json
```

Полученный `models.json` можно дополнить полем `url` и использовать как вход для `download_models`.

### Выгрузка в S3

Нужны настроенный AWS CLI и имя бакета:

```bash
./scripts/upload_to_s3.sh <s3-bucket> [models_dir]
# пример: ./scripts/upload_to_s3.sh my-bucket models
```

```powershell
.\scripts\upload_to_s3.ps1 -Bucket my-bucket -ModelsDir models
# опционально: -PublicRead
```

Загружаются все `.zip` из каталога моделей (aws s3 cp).

### Выгрузка в Google Drive (rclone)

Сначала настройте remote rclone, затем:

```bash
./scripts/upload_to_gdrive.sh <rclone-remote-name> <remote-path> [models_dir]
# пример: ./scripts/upload_to_gdrive.sh gdrive NeuroTranslator/models models
```

```powershell
.\scripts\upload_to_gdrive.ps1 -Remote gdrive -RemotePath NeuroTranslator/models -ModelsDir models
```

Копируется содержимое каталога моделей: rclone copy с --progress.

## Структура `scripts/`

| Файл | Назначение |
|------|------------|
| `install_deps.sh` / `install_deps.ps1` | Установка зависимостей при наличии манифестов |
| `download_models.sh` / `download_models.ps1` | Скачивание и проверка моделей по JSON или встроенному списку |
| `models.json.sample` | Пример списка моделей (`name`, `url`, `sha256`) |
| `models.json` | Рабочий список (может генерироваться compute_checksums) |
| `compute_checksums.sh` / `compute_checksums.ps1` | SHA-256 для локальных `.zip` → JSON |
| `upload_to_s3.sh` / `upload_to_s3.ps1` | Выгрузка `.zip` в S3 через AWS CLI |
| `upload_to_gdrive.sh` / `upload_to_gdrive.ps1` | Выгрузка каталога моделей через rclone |

## Примечания

- Репозиторий — про скрипты установки и работы с архивами моделей, не про запуск нейросети «из коробки».
- Для S3 заранее настройте credentials AWS CLI; для Google Drive — rclone config и имя remote.
- После compute_checksums при необходимости вручную проставьте `url` в JSON перед повторной раздачей через download_models.
