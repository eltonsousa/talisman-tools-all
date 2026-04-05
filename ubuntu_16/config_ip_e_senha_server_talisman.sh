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

clear
titulo "CONFIGURAÇÃO DO SERVIDOR TALISMAN ONLINE"

read -p " [?] DESEJA CONFIGURAR OS IP'S E SENHA? (S/N): " SIM_NAO
if [[ "$SIM_NAO" =~ ^[Ss]$ ]]; then
    
    read -p "  [?] DIGITE O NOVO IP: " NOVO_IP
    read -p "  [?] DIGITE A NOVA SENHA DO BANCO: " NOVA_SENHA
    read -p "  [?] DIGITE O NOVO NOME DO SERVIDOR: " NOVO_NOME
    linha
    
    passo "6" "ATUALIZANDO BINÁRIOS E INIs"
    DIRETORIO_BASE="/home/talisman/server"
    
    # Padroniza espaços ao redor do "=" para facilitar a substituição
    echo -e "${CIANO}[i]${SEM_COR} Padronizando sintaxe dos arquivos .ini..."
    find "$DIRETORIO_BASE" -name "*.ini" -exec sed -i 's/[[:space:]]*=[[:space:]]*/ = /g' {} +
    
    # --- 1. PASTA 'db' ---
    if [ -d "$DIRETORIO_BASE/db" ]; then
        echo -e "${VERDE}[DB]${SEM_COR} Atualizando arquivos..."
        [ -f "$DIRETORIO_BASE/db/db_server_user.ini" ] && sed -i "s/Password = \".*\"/Password = \"$NOVA_SENHA\"/g" "$DIRETORIO_BASE/db/db_server_user.ini"
        [ -f "$DIRETORIO_BASE/db/guard_user.ini" ] && sed -i "s/PublishServerIP = \".*\"/PublishServerIP = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/db/guard_user.ini"
    fi
    
    # --- 2. PASTA 'game' ---
    if [ -d "$DIRETORIO_BASE/game" ]; then
        echo -e "${VERDE}[GAME]${SEM_COR} Atualizando arquivos..."
        [ -f "$DIRETORIO_BASE/game/guard_user.ini" ] && sed -i "s/PublishServerIP = \".*\"/PublishServerIP = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/game/guard_user.ini"
        
        if [ -f "$DIRETORIO_BASE/game/server_user.ini" ]; then
            sed -i "s/ListenIp = \".*\"/ListenIp = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/game/server_user.ini"
            sed -i "s/ListenPortal = \".*\"/ListenPortal = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/game/server_user.ini"
            sed -i "s/ConnectIp = \".*\"/ConnectIp = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/game/server_user.ini"
            sed -i "s/location = \".*\"/location = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/game/server_user.ini"
            sed -i "s/sv1 = \".*\"/sv1 = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/game/server_user.ini"
            sed -i "s/sv2 = \".*\"/sv2 = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/game/server_user.ini"
            sed -i "s/sv3 = \".*\"/sv3 = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/game/server_user.ini"
            sed -i "s/name = \".*\"/name = \"$NOVO_NOME\"/g" "$DIRETORIO_BASE/game/server_user.ini"
        fi
    fi
    
    # --- 3. PASTA 'login' ---
    if [ -d "$DIRETORIO_BASE/login" ]; then
        echo -e "${VERDE}[LOGIN]${SEM_COR} Atualizando arquivos..."
        [ -f "$DIRETORIO_BASE/login/guard_user.ini" ] && sed -i "s/PublishServerIP = \".*\"/PublishServerIP = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/login/guard_user.ini"
        [ -f "$DIRETORIO_BASE/login/login_user.ini" ] && sed -i "s/ListenIp = \".*\"/ListenIp = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/login/login_user.ini"
        [ -f "$DIRETORIO_BASE/login/login_user.ini" ] && sed -i "s/ListenPortal = \".*\"/ListenPortal = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/login/login_user.ini"
        [ -f "$DIRETORIO_BASE/login/login_user.ini" ] && sed -i "s/sv1 = \".*\"/sv1 = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/login/login_user.ini"
    fi
    
    echo -e "\n------------------------------------------"
    sucesso "CONFIGURAÇÃO APLICADA COM SUCESSO!"
    echo -e "  IP definido: ${VERDE_B}$NOVO_IP${SEM_COR}"
    echo -e "  Nome do Server: ${VERDE_B}$NOVO_NOME${SEM_COR}"
    echo -e "------------------------------------------"
    
else
    aviso "Instalação abortada!"
fi

linha
echo -e "${AMARELO}Pressione [Enter] para voltar ao menu...${SEM_COR}"
read