#!/bin/bash

###
# Инициализируем бд
###

# конфиг 
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
docker compose exec -T shard1 mongosh --port 27018 <<EOF
rs.initiate(     {      _id : "shard1",      members: [        { _id : 0, host : "shard1:27018" }      ]    });
exit();
EOF

#шарда2
docker compose exec -T shard2 mongosh --port 27019 <<EOF

rs.initiate(     {      _id : "shard2",      members: [        { _id : 1, host : "shard2:27019" }      ]    }  );
exit(); 
EOF


#роутер + настройки БД
docker compose exec -T mongos_router mongosh --port 27020 <<EOF

sh.addShard( "shard1/shard1:27018");
sh.addShard( "shard2/shard2:27019");

sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )

exit(); 
EOF

#репрлики на шарде1 
docker compose exec -T shard1 mongosh --port 27018 <<EOF
rs.add({ host : "shard1-repl1:27021"});
rs.add({ host : "shard1-repl2:27022"});
exit();
EOF

#репрлики на шарде1 


#инициализация таблиц
docker compose exec -T mongos_router mongosh --port 27020 <<EOF
use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i})
db.helloDoc.countDocuments() 
exit(); 
EOF


