#!/bin/bash

###
# тестим БД
###

docker compose exec -T mongos_router mongosh --port 27020 <<EOF

use somedb
db.helloDoc.countDocuments() 
exit(); 
EOF

docker compose exec -T shard1 mongosh  --port 27018 <<EOF

use somedb
db.helloDoc.countDocuments() 
exit(); 
EOF

docker compose exec -T shard2 mongosh --port 27019 <<EOF

use somedb
db.helloDoc.countDocuments() 
exit(); 
EOF

docker compose exec -T shard1-repl1 mongosh --port 27021  <<EOF

use somedb
db.helloDoc.countDocuments() 
exit(); 
EOF
docker compose exec -T shard1-repl2 mongosh  --port 27022 <<EOF

use somedb
db.helloDoc.countDocuments() 
exit(); 
EOF