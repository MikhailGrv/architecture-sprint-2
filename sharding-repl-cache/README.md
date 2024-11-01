Спринт 2 
задача 3 
Кэш

Дока architecture-sprint-2\Docs\sprint2task1.drawio закладка Part-3-chache

Как запустить:
1. в текущей дирректории docker compose  up -d
2. в баше в папке scripts ./mongo-init.sh
Проверить:
1. в баше в папке scripts ./mongo-test.sh
Удалить:
Руками из docker удалить Container "sharding-repl-cache" и Volumes


TODO
App-server потребовалось запихнуть в ту же подсеть, что и БД т.к. недостаточно знаний по настройке Docker
Подсеть естественно дожна быть разная со строго ограниченными проходами.

Заметки:
Тест производительности через time.sleep(1) - сильно)))
