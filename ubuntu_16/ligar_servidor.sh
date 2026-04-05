#!/bin/bash

# Ligar Servidor v. Ubuntu 16

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export HOME=/home/talisman

# Espera o MySQL acordar (tentando 30x/s)
for i in {1..30}; do
    if mysqladmin ping -u root --silent; then
        break
    fi
    sleep 2
done

sleep 5

# 2. Definição de Diretórios
DIR_DB="/home/talisman/server/db"
DIR_LOGIN="/home/talisman/server/login"
DIR_GAME="/home/talisman/server/game"
DIR_LOG_LOGIN="$DIR_LOGIN/log"

# Garante que a pasta de log existe para não quebrar o script
mkdir -p "$DIR_LOG_LOGIN"

# 3. Limpeza de processos e telas antigas
pkill -9 db_server 2>/dev/null
pkill -9 login_server 2>/dev/null
pkill -9 game_server 2>/dev/null

rm -f "$DIR_DB"/*.pid "$DIR_LOGIN"/*.pid "$DIR_GAME"/*.pid 2>/dev/null

/usr/bin/screen -wipe > /dev/null

# 4. Início dos Servidores
echo "[1/3] DB SERVER..."
/usr/bin/screen -dmS db bash -c "cd $DIR_DB && ./db_server"

sleep 10

echo "[2/3] LOGIN SERVER..."
rm -f "$DIR_LOG_LOGIN"/login_server_*.log
/usr/bin/screen -dmS login bash -c "cd $DIR_LOGIN && ./login_server"

# 5. Loop de Verificação do Login
while true; do
    ULTIMO_LOG=$(ls -t "$DIR_LOG_LOGIN"/login_server_*.log 2>/dev/null | head -1)
    
    if [ -n "$ULTIMO_LOG" ] && grep -q "login server init OK" "$ULTIMO_LOG"; then
        echo "Login Server pronto!"
        break
    fi
    
    if ! pgrep -f login_server > /dev/null; then
        echo "Erro: Login Server caiu durante o boot."
        exit 1
    fi
    
    sleep 2
done

sleep 10

echo "[3/3] GAME SERVER..."
/usr/bin/screen -dmS game bash -c "cd $DIR_GAME && ./game_server > log_erro_game.txt 2>&1"
