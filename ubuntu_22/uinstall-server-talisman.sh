#!/bin/bash

# ==========================================================
# SCRIPT DE DESINSTALAÇÃO - SERVIDOR TALISMAN ONLINE
# CONFIGURADO PARA: UBUNTU 14.04 | by ELTON SOUSA
# ALVO: REVERTER AS ALTERAÇÕES E LIMPAR SISTEMA
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
passo() { echo -e "\n${CIANO}>>> Passo $1: $2${SEM_COR}"; }

clear

read -p " [?] DESEJA REALMENTE REMOVER TODO O AMBIENTE DO SERVIDOR? (S/N): " SIM_NAO
if [[ "$SIM_NAO" =~ ^[Ss]$ ]]; then
    
    # FUNÇÃO PARA DESTRAVAR O APT (SOLUÇÃO PARA O SEU ERRO)
    liberar_apt() {
        aviso "Limpando travas do sistema de pacotes (locks)..."
        fuser -kk /var/lib/dpkg/lock > /dev/null 2>&1
        fuser -kk /var/lib/apt/lists/lock > /dev/null 2>&1
        fuser -kk /var/cache/apt/archives/lock > /dev/null 2>&1
        rm -f /var/lib/dpkg/lock /var/lib/apt/lists/lock /var/cache/apt/archives/lock > /dev/null 2>&1
        dpkg --configure -a > /dev/null 2>&1
    }
    
    clear
    titulo "DESINSTALADOR GERAL - SERVIDOR TALISMAN"
    
    # VERIFICAÇÃO DE ROOT
    if [ "$EUID" -ne 0 ]; then
        erro "POR FAVOR, EXECUTE COMO ROOT (SUDO -S)"
        exit
    fi
    passo "1" "FINALIZANDO PROCESSOS E SERVIÇOS"
    aviso "Encerrando Screens do Jogo, MySQL e Apache..."
    pkill -9 db_server 2>/dev/null
    pkill -9 login_server 2>/dev/null
    pkill -9 game_server 2>/dev/null
    service mysql stop > /dev/null 2>&1
    service apache2 stop > /dev/null 2>&1
    sucesso "Processos finalizados."
    
    passo "2" "REMOVENDO AGENDAMENTOS DE BOOT"
    crontab -u talisman -l 2>/dev/null | grep -v "/home/talisman/ligar_servidor.sh" | crontab -u talisman -
    sed -i '/ligar_servidor.sh/d' /etc/rc.local
    sucesso "Agendamentos removidos do Crontab e rc.local."
    
    passo "3" "REMOVENDO SCRIPTS E BIBLIOTECAS"
    rm -f /home/talisman/ligar_servidor.sh
    # Chama a limpeza de lock antes de tentar o dpkg ou apt
    liberar_apt
    dpkg -r libmysqlclient15off 2>/dev/null
    sucesso "Scripts e biblioteca de compatibilidade removidos."
    
    passo "4" "DESINSTALANDO PACOTES DO SISTEMA"
    aviso "Removendo Apache, PHP, MySQL e phpMyAdmin..."
    liberar_apt
    
    # Força o apt a NÃO fazer perguntas (Debian Frontend Noninteractive)
    export DEBIAN_FRONTEND=noninteractive
    
    # Remove primeiro o phpmyadmin separadamente para evitar travas de configuração
    apt-get purge phpmyadmin -y -qq > /dev/null 2>&1
    
    # Remove o restante dos pacotes
    # Usamos php5* para pegar todas as extensões e mysql-server* para o banco
    apt-get purge apache2 php5* mysql-server* mysql-client* mysql-common -y -qq > /dev/null 2>&1
    
    # Limpeza profunda
    apt-get autoremove -y > /dev/null 2>&1
    apt-get autoclean > /dev/null 2>&1
    sucesso "Pacotes removidos e sistema limpo."
    
    passo "5" "LIMPANDO DIRETÓRIO WEB"
    rm -rf /var/www/html/*
    echo "<html><body style='background:#111; color:#eee; text-align:center;'><h1>Servidor Limpo</h1><p>Ambiente Talisman Online removido.</p></body></html>" > /var/www/html/index.html
    sucesso "Pasta /var/www/html/ limpa."
    
    passo "6" "REVERSÃO DO ACESSO REMOTO MYSQL"
    if [ -f "/etc/mysql/my.cnf" ]; then
        sed -i 's/bind-address = 0.0.0.0/bind-address = 127.0.0.1/' /etc/mysql/my.cnf
        sucesso "Configurações de rede do MySQL revertidas."
    fi
    
    sleep 2
    clear
    echo -e "\n${VERDE_B}============================================================"
    echo -e "       DESINSTALAÇÃO CONCLUÍDA COM SUCESSO!"
    echo -e "============================================================${SEM_COR}"
    echo -e "${AMARELO} NOTA:${SEM_COR} Os arquivos em /home/talisman/server/ foram mantidos."
    echo -e "${AMARELO} DICA:${SEM_COR} Execute 'reboot' para limpar totalmente a memória."
    echo -e "${VERDE_B}============================================================"
    echo -e "          SISTEMA REVERTIDO POR ELTON SOUSA!${SEM_COR}\n"
    
else
    echo -e "\n${AMARELO}>>> OPERAÇÃO CANCELADA. Nada foi removido.${SEM_COR}"
fi

linha
echo -e "${AMARELO}Pressione [Enter] para voltar ao menu...${SEM_COR}"
read
