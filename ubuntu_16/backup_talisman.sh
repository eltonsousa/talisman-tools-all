#!/bin/bash

# --- CONFIGURAÇÕES DO BANCO DE DADOS ---
USER="root"
PASSWORD="talisman"
BACKUP_DIR="/home/talisman/backups"
DATE=$(date +"%Y-%m-%d_%H-%M")
FILE_NAME="talisman_full_$DATE.sql.gz"
ARQUIVO="$BACKUP_DIR/$FILE_NAME"

# --- CONFIGURAÇÕES DO TELEGRAM ---
TOKEN="8610539285:AAG7ivnqXns446i-HyXX3F1oVXU0qpc3OVk"
CHAT_ID="302192007"

# 1. Cria a pasta de backups
mkdir -p $BACKUP_DIR

# 2. Faz o backup e compacta (Linha completa agora)
echo "Iniciando backup das bases do Talisman..."
mysqldump -u$USER -p$PASSWORD --databases db_account db_game db_log | gzip > "$ARQUIVO"

# 3. Envia para o Telegram (Linha completa agora)
echo "Enviando arquivo para o Telegram..."
curl -F document=@"$ARQUIVO" "https://api.telegram.org/bot$TOKEN/sendDocument?chat_id=$CHAT_ID&caption=Backup Talisman Online: $DATE ✅"

# 4. Limpeza
find $BACKUP_DIR -type f -mtime +7 -name "*.gz" -delete

echo "Processo concluído com sucesso!"
