#!/bin/bash

###
# Инициализируем бд
###

# конфиг 
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!конфиг!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >&2
docker compose exec -T configSrv mongosh --port 27016 <<EOF
rs.initiate(
  {
    _id : "config_server",
       configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27016" }
    ]
  }
);
exit(); 
EOF


#шарда1
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!шарда1!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >&2
docker compose exec -T shard1 mongosh --port 27018 <<EOF
rs.initiate(     {      _id : "shard1",      members: [        { _id : 0, host : "shard1:27018" }      ]    });
exit();
EOF

#шарда2
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!шарда2!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >&2
docker compose exec -T shard2 mongosh --port 27019 <<EOF

rs.initiate(     {      _id : "shard2",      members: [        { _id : 1, host : "shard2:27019" }      ]    }  );
exit(); 
EOF


#роутер + настройки БД
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!роутер + настройки БД!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >&2
docker compose exec -T mongos_router mongosh --port 27020 <<EOF

sh.addShard( "shard1/shard1:27018");
sh.addShard( "shard2/shard2:27019");

sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )

exit(); 
EOF

#репрлики на шарде1 
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!репрлики на шарде1 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >&2
docker compose exec -T shard1 mongosh --port 27018 <<EOF
rs.add({ host : "shard1-repl1:27021"});
rs.add({ host : "shard1-repl2:27022"});
exit();
EOF

#репрлики на шарде2
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!репрлики на шарде2 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >&2
docker compose exec -T shard2 mongosh --port 27019 <<EOF
rs.add({ host : "shard2-repl1:27031"});
rs.add({ host : "shard2-repl2:27032"});
exit();
EOF

#инициализация таблиц
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!инициализация таблиц!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >&2
docker compose exec -T mongos_router mongosh --port 27020 <<EOF
use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i})
db.helloDoc.countDocuments() 
exit(); 
EOF


