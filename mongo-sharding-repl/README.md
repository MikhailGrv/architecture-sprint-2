Спринт 2 
задача 3
Реплики к шардам

Дока architecture-sprint-2\Docs\sprint2task1.drawio закладка Part-4-repl

Как запустить:
1. в текущей дирректории docker compose  up -d
2. в баше в папке scripts ./mongo-init.sh
Проверить:
1. в баше в папке scripts ./mongo-test.sh
Удалить:
Руками из docker удалить Container "mongo-sharding-repl" и Volumes


TODO
App-server потребовалось запихнуть в ту же подсеть, что и БД т.к. недостаточно знаний по настройке Docker
Подсеть естественно дожна быть разная со строго ограниченными проходами.
