



1. Собираем контейнеры
docker compose up -d

2. Настройка конфи-сервера
Подключение к БД
2.1. docker exec -it configSrv mongosh --port 27016
Настройка как кофиг
2.2. rs.initiate(   {    _id : "config_server",       configsvr: true,    members: [      { _id : 0, host : "configSrv:27016" }    ]  });
Отключаемся от БД exit()

3. Инициализируйте шард 1
Подключение к БД
3.1. docker exec -it shard1 mongosh --port 27018
3.2. rs.initiate(     {      _id : "shard1",      members: [        { _id : 0, host : "shard1:27018" }     ]    });
3.3. exit()


3. Инициализируйте шард 2
Подключение к БД
3.1. docker exec -it shard2 mongosh --port 27019
3.2. rs.initiate(     {      _id : "shard2",      members: [        { _id : 1, host : "shard2:27019" }     ]    });
3.3. exit()

4. Инициализиролвать Роутер
4.1. docker exec -it mongos_router mongosh --port 27020
Шарду 1
4.2. sh.addShard( "shard1/shard1:27018"); 
Шарду 2 
4.3. sh.addShard( "shard2/shard2:27019"); 
Указываем БД для шардинга
4.4. sh.enableSharding("somedb");
Указваем шардирование по хэшу имени 
4.5. sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )
4.6. exit()

5. Наполняем данными
5.1.  exec -it mongos_router mongosh --port 27020
5.2. use somedb
Заполняем 1000 элементов
5.3. for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i})
Проверка кол-ва на роутере - д.б. 1000
5.4. db.helloDoc.countDocuments()  
5.5. exit();

6. Проверяем шарды
Должно быть на каждой около 500
Шарда1
6.1.1. docker exec -it shard1 mongosh --port 27018     
6.1.2. use somedb
6.1.3. db.helloDoc.countDocuments()  
6.1.4. exit();
У меня получилось 492 - норма

Шарда2
6.2.1 docker exec -it shard2 mongosh --port 27019
6.2.2. use somedb
6.2.3. db.helloDoc.countDocuments()  
6.2.4. exit();
У меня получилось 508 - норма

Результат - хорошо, шарды работают. Распределение равномерное.

