NeuroTranslator

Этот репозиторий содержит код и скрипты проекта NeuroTranslator.

Внимание: модели (большие бинарные файлы) в репозиторий не включены.

Установка моделей:
1) Скачайте модели и распакуйте в папку models/ рядом с корнем репозитория.
   - model_en, model_en_large, model_ru_large, model_ru_small

2) Пример структуры:
   NeuroTranslator/
     README.md
     models/
       model_en/
       model_en_large/
       model_ru_large/
       model_ru_small/

3) Скрипт загрузки (пример PowerShell):
   Invoke-WebRequest -Uri "<URL_TO_MODEL_ARCHIVE>" -OutFile "models\model_en.zip"; Expand-Archive "models\model_en.zip" -DestinationPath "models\model_en"

Замените <URL_TO_MODEL_ARCHIVE> на реальную ссылку. Если нужно — пришлите ссылки, добавлю сюда.

Автор: chvdbhcx-del
