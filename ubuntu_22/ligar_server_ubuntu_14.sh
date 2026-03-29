#!/bin/bash

# DEFINIÇÃO DE CORES
VERDE='\033[0;32m'
VERDE_B='\033[1;32m'
AZUL='\033[0;34m'
AZUL_B='\033[1;34m'
AMARELO='\033[1;33m'
VERMELHO='\033[0;31m'
CIANO='\033[0;36m'
SEM_COR='\033[0m'

# FUNÇÕES DE INTERFACE
linha() { echo -e "${AZUL}============================================================${SEM_COR}"; }
titulo() { linha; echo -e "${AZUL_B}   $1 ${SEM_COR}"; linha; }
sucesso() { echo -e "${VERDE_B}[OK]${SEM_COR} $1"; }
aviso() { echo -e "${AMARELO}[AVISO]${SEM_COR} $1"; }
erro() { echo -e "${VERMELHO}[ERRO]${SEM_COR} $1"; }
passo() { echo -e "\n${CIANO}>>> Passo $1: $2${SEM_COR}"; }

# --- CONFIGURAÇÃO DE AMBIENTE ---
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
USER_TALISMAN="talisman"
DIR_DB="/home/talisman/server/db"
DIR_LOGIN="/home/talisman/server/login"
DIR_GAME="/home/talisman/server/game"
DIR_LOG_LOGIN="$DIR_LOGIN/log"

clear
read -p " [?] DESEJA LIGAR O SERVER TALISMAN? (S/N): " SIM_NAO
if [[ "$SIM_NAO" =~ ^[Ss]$ ]]; then
    
    clear
    echo -e "${AZUL}==========================================${SEM_COR}"
    echo -e "       INICIANDO SERVIDOR TALISMAN        "
    echo -e "       (EXECUTANDO COMO: $USER_TALISMAN)  "
    echo -e "${AZUL}==========================================${SEM_COR}"
    
    # --- LIMPEZA INICIAL ---
    echo "Limpando arquivos temporários e .pid..."
    rm -f $DIR_DB/*.pid $DIR_LOGIN/*.pid $DIR_GAME/*.pid 2>/dev/null
    sudo -u $USER_TALISMAN screen -wipe > /dev/null 2>&1
    echo -e "${VERDE_B}[OK]${SEM_COR} Sistema limpo. Preparando boot..."
    
    # --- [1] INICIAR DB SERVER ---
    echo -ne "\n[1/3] Iniciando DB Server..."
    sudo -u $USER_TALISMAN screen -dmS db bash -c "cd $DIR_DB && ./db_server"
    sleep 5
    echo -e " ${VERDE_B}PRONTO!${SEM_COR}"
    
    # --- [2] INICIAR LOGIN SERVER ---
    echo -ne "[2/3] Iniciando Login Server..."
    sudo -u $USER_TALISMAN screen -dmS login bash -c "cd $DIR_LOGIN && ./login_server"
    
    # Aguarda o surgimento do log
    sleep 5
    ULTIMO_LOG=$(ls -t $DIR_LOG_LOGIN/login_server_*.log 2>/dev/null | head -1)
    
    if [ -z "$ULTIMO_LOG" ]; then
        echo -e "\n${VERMELHO}[ERRO]${SEM_COR} Arquivo de log não gerado. Verifique as permissões."
    else
        echo -e "\nVigiando: $(basename $ULTIMO_LOG)"
        # Loop de Vigilância
        while ! grep -q "login server init OK" "$ULTIMO_LOG"; do
            echo -n "."
            sleep 2
        done
        echo -e " ${VERDE_B}OK!${SEM_COR}"
    fi
    
    # --- [3] INICIAR GAME SERVER ---
    echo -ne "\n[3/3] Iniciando Game Server..."
    sudo -u $USER_TALISMAN screen -dmS game bash -c "cd $DIR_GAME && ./game_server"
    echo -e " ${VERDE_B}PRONTO!${SEM_COR}"
    
    echo -e "\n${AZUL}------------------------------------------${SEM_COR}"
    echo -e "      ${VERDE_B}SERVIDOR TOTALMENTE ONLINE!${SEM_COR}         "
    echo -e "${AZUL}------------------------------------------${SEM_COR}"
    echo -e "Para ver o console, use: ${CIANO}sudo -u talisman screen -r game${SEM_COR}"
    
else
    aviso "Instalação abortada."
fi

linha
echo -e "${AMARELO}Pressione [Enter] para voltar ao menu...${SEM_COR}"
read