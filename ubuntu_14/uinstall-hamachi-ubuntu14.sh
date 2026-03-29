#!/bin/bash

# ==========================================================
# SCRIPT DE DESINSTALAÇÃO - LOGMEIN HAMACHI
# CONFIGURADO PARA: UBUNTU 14.04 | by ELTON SOUSA
# ==========================================================

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

clear
titulo "DESINSTALADOR - LOGMEIN HAMACHI"

# VERIFICAÇÃO DE [ROOT]
if [ "$EUID" -ne 0 ]; then
    erro "POR FAVOR, EXECUTE COMO ROOT (SUDO -S)"
    exit
fi

read -p " [?] TEM CERTEZA QUE DESEJA REMOVER O HAMACHI? (S/N): " CONFIRMAR
if [[ "$CONFIRMAR" =~ ^[Ss]$ ]]; then
    
    echo -e "${CIANO}>>> Encerrando processos e realizando logout...${SEM_COR}"
    hamachi logout > /dev/null 2>&1
    /etc/init.d/logmein-hamachi stop > /dev/null 2>&1
    
    echo -e "${CIANO}>>> Removendo pacote do sistema...${SEM_COR}"
    # Remove o pacote e as configurações de instalação
    apt-get purge logmein-hamachi -y > /dev/null 2>&1
    apt-get autoremove -y > /dev/null 2>&1
    
    echo -e "${CIANO}>>> Limpando pastas de configuração e logs...${SEM_COR}"
    # Remove as pastas de configuração criadas (incluindo o h2-engine-override.cfg)
    rm -rf /var/lib/logmein-hamachi
    rm -rf /var/run/logmein-hamachi
    
    linha
    sucesso "O Hamachi foi removido completamente do seu Ubuntu 14."
    aviso "As configurações de rede e apelido foram apagadas."
    linha
else
    aviso "Desinstalação cancelada pelo usuário."
fi

# --- PAUSA PARA O MENU NÃO LIMPAR A TELA ---
echo -e "\n${AMARELO}Pressione [Enter] para voltar ao menu...${SEM_COR}"
read
