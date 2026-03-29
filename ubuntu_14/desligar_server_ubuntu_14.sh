#!/bin/bash

# ==========================================================
# SCRIPT PARA DESLIGAR O SERVIDOR (MODO ROOT -> USER)
# DESENVOLVIDO POR: ELTON SOUSA
# ==========================================================

# DEFINIÇÃO DE CORES
VERDE='\033[0;32m'
AZUL='\033[0;34m'
AZUL_B='\033[1;34m'
AMARELO='\033[1;33m'
VERMELHO='\033[0;31m'
CIANO='\033[0;36m'
SEM_COR='\033[0m'

# FUNÇÕES DE INTERFACE
linha() { echo -e "${AZUL}============================================================${SEM_COR}"; }
titulo() { linha; echo -e "${AZUL_B}   $1 ${SEM_COR}"; linha; }
sucesso() { echo -e "${VERDE}[OK]${SEM_COR} $1"; }
aviso() { echo -e "${AMARELO}[AVISO]${SEM_COR} $1"; }
erro() { echo -e "${VERMELHO}[ERRO]${SEM_COR} $1"; }
passo() { echo -e "\n${CIANO}>>> Passo $1: $2${SEM_COR}"; }

# CONFIGURAÇÃO DE CAMINHOS
DIR_DB="/home/talisman/server/db"
DIR_LOGIN="/home/talisman/server/login"
DIR_GAME="/home/talisman/server/game"
USER_TALISMAN="talisman"

clear

read -p " [?] DESEJA DESLIGAR O SERVIDOR TALISMAN? (S/N): " SIM_NAO
if [[ "$SIM_NAO" =~ ^[Ss]$ ]]; then
    
    clear
    echo -e "${VERMELHO}------------------------------------------------------------${SEM_COR}"
    echo -e "              DESLIGANDO SERVIDOR TALISMAN"
    echo -e "        (EXECUTANDO COMANDOS COMO: $USER_TALISMAN)"
    echo -e "${VERMELHO}------------------------------------------------------------${SEM_COR}"
    
    # --- [1] DESLIGAR GAME SERVER ---
    echo -e "${CIANO}[1/3] Finalizando Game Server...${SEM_COR}"
    sudo -u $USER_TALISMAN screen -S game -X quit 2>/dev/null
    sleep 2
    
    # --- [2] DESLIGAR LOGIN SERVER ---
    echo -e "${CIANO}[2/3] Finalizando Login Server...${SEM_COR}"
    sudo -u $USER_TALISMAN screen -S login -X quit 2>/dev/null
    sleep 2
    
    # --- [3] DESLIGAR DB SERVER ---
    echo -e "${CIANO}[3/3] Finalizando DB Server...${SEM_COR}"
    sudo -u $USER_TALISMAN screen -S db -X quit 2>/dev/null
    sleep 2
    
    # --- LIMPEZA DE SEGURANÇA ---
    echo -e "${AMARELO}Limpando travas de processo (.pid)...${SEM_COR}"
    rm -f $DIR_DB/*.pid $DIR_LOGIN/*.pid $DIR_GAME/*.pid 2>/dev/null
    sudo -u $USER_TALISMAN screen -wipe > /dev/null 2>&1
    
    echo -e "${VERMELHO}------------------------------------------------------------${SEM_COR}"
    sucesso "SERVIDOR DESLIGADO COM SUCESSO!"
    echo -e "${VERMELHO}------------------------------------------------------------${SEM_COR}"
    
else
    aviso "Instalação abortada."
fi

linha
echo -e "${AMARELO}Pressione [Enter] para voltar ao menu...${SEM_COR}"
read

