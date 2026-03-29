#!/bin/bash

# DEFINIÇÃO DE CORES
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
passo() { echo -e "\n${CIANO}>>> Passo 11: $2${SEM_COR}"; }

clear
titulo "GERENCIAMENTO DO LOGMEIN HAMACHI"

# --- VERIFICAÇÃO SE JÁ ESTÁ INSTALADO ---
if command -v hamachi &> /dev/null; then
    sucesso "O Hamachi já está instalado neste servidor!"
    echo -e "${CIANO}Status Atual:${SEM_COR}"
    hamachi | grep -E "status|address|nickname"
    
    IP_HAMACHI=$(hamachi | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -1)
    echo -e "\n${CIANO}Seu IP Hamachi para Configuração:${SEM_COR} ${VERDE_B}$IP_HAMACHI${SEM_COR}"
    linha
else
    # Se não estiver instalado, segue para o processo de instalação
    read -p " [?] Hamachi não encontrado. Deseja instalar agora? (S/N): " INSTALAR_HAMACHI
    
    if [[ "$INSTALAR_HAMACHI" =~ ^[Ss]$ ]]; then
        aviso "Iniciando download e instalação..."
        
        wget https://www.vpn.net/installers/logmein-hamachi_2.1.0.203-1_i386.deb -q
        
        if [ -f "logmein-hamachi_2.1.0.203-1_i386.deb" ]; then
            dpkg -i logmein-hamachi_2.1.0.203-1_i386.deb > /dev/null 2>&1
            apt-get install -f -y > /dev/null 2>&1
            rm logmein-hamachi_2.1.0.203-1_i386.deb
            
            mkdir -p /var/lib/logmein-hamachi/
            echo "Ipc.User talisman" > /var/lib/logmein-hamachi/h2-engine-override.cfg
            
            /etc/init.d/logmein-hamachi restart > /dev/null
            sleep 3
            
            echo -e "${CIANO}>>> Realizando Login...${SEM_COR}"
            hamachi login > /dev/null
            
            echo -n -e "${CIANO}Aguardando ficar online...${SEM_COR}"
            tentativas=0
            while [ "$(hamachi 2>/dev/null | grep -i 'status' | awk '{print $3}')" == "offline" ] && [ $tentativas -lt 15 ]; do
                echo -n "."
                sleep 3
                tentativas=$((tentativas+1))
            done
            echo -e "\n"
            
            read -p " [?] DIGITE O APELIDO (NICK) PARA ESTE SERVIDOR: " NOME_PC
            hamachi set-nick "$NOME_PC" > /dev/null
            
            linha
            sucesso "Hamachi configurado com sucesso!"
            IP_HAMACHI=$(hamachi | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -1)
            echo -e "${CIANO}Nick:${SEM_COR} $NOME_PC"
            echo -e "${CIANO}IP Hamachi:${SEM_COR} ${VERDE_B}$IP_HAMACHI${SEM_COR}"
            linha
        else
            erro "Falha no download. Verifique sua internet."
        fi
    else
        aviso "Instalação abortada."
    fi
fi

linha
echo -e "${AMARELO}Pressione [Enter] para voltar ao menu...${SEM_COR}"
read