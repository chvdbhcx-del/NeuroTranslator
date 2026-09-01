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

Источники моделей и ссылки (поиск в репозитории модели показал следующее):

- model_en / model_en_large:
  - Базируется на Appen Kaldi model: https://github.com/Appen/UHV-OTS-Speech
  - Возможные готовые Kaldi/Vosk модели (примерные источники): https://alphacephei.com/vosk/models

- model_ru_large / model_ru_small:
  - Русская модель для Vosk (перенесена из готовых Vosk/Kaldi моделей).
  - Репозиторий Golos (используется как часть обучающего датасета): https://github.com/sberdevices/golos
  - Официальная страница моделей Vosk: https://alphacephei.com/vosk/models

Примечание:
- Точные архивы моделей могут быть доступны на страницах Vosk или в отдельных репозиториях/репозиториях авторов моделей. Если хотите, могу попытаться найти конкретные URL-архивы моделей (zip/tar) и добавить их сюда — дайте знать.

Автор: chvdbhcx-del
