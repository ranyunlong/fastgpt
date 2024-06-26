FROM mysql:8.0.36
EXPOSE 3306
CMD [ "--default-authentication-plugin=mysql_native_password"]

FROM pgvector/pgvector:0.7.0-pg15
EXPOSE 5432

FROM mongo:5.0.18
EXPOSE 27017
ENTRYPOINT bash -c |                                                                                                                        \
    openssl rand -base64 128 > /data/mongodb.key                                                                                            \
    chmod 400 /data/mongodb.key                                                                                                             \
    chown 999:999 /data/mongodb.key                                                                                                         \
    echo 'const isInited = rs.status().ok === 1                                                                                             \
    if(!isInited){                                                                                                                          \
    rs.initiate({                                                                                                                           \
        _id: "rs0",                                                                                                                         \
        members: [                                                                                                                          \
            { _id: 0, host: "mongo:27017" }                                                                                                 \
        ]                                                                                                                                   \
    })                                                                                                                                      \
    }' > /data/initReplicaSet.js                                                                                                            \
    exec docker-entrypoint.sh "$$@" &                                                                                                       \
    until mongo -u fastgpt -p fastgpt_pwd --authenticationDatabase admin --eval "print('waited for connection')" > /dev/null 2>&1; do       \
    echo "Waiting for MongoDB to start..."                                                                                                  \
    sleep 2                                                                                                                                 \
    done                                                                                                                                    \
    mongo -u fastgpt -p fastgpt_pwd --authenticationDatabase admin /data/initReplicaSet.js                                                  \ 
    wait $$!

FROM ghcr.io/labring/fastgpt:v4.8.1
EXPOSE 3000

FROM ghcr.io/songquanpeng/one-api:latest
EXPOSE 3001