#!/bin/bash

# ==========================================================
# SCRIPT DE DESINSTALAÇÃO - TALISMAN ONLINE
# CONFIGURADO PARA: UBUNTU 16.04 | by ELTON SOUSA
# ==========================================================

# DEFINIÇÃO DE CORES
VERMELHO='\033[0;31m'
VERMELHO_B='\033[1;31m'
AMARELO='\033[1;33m'
AZUL='\033[0;34m'
AZUL_B='\033[1;34m'
VERDE='\033[0;32m'
SEM_COR='\033[0m'

# FUNÇÕES DE INTERFACE
linha() { echo -e "${VERMELHO}============================================================${SEM_COR}"; }
titulo() { linha; echo -e "${VERMELHO_B}   $1 ${SEM_COR}"; linha; }
sucesso() { echo -e "${VERDE}[OK]${SEM_COR} $1"; }
aviso() { echo -e "${AMARELO}[AVISO]${SEM_COR} $1"; }
erro() { echo -e "${VERMELHO}[ERRO]${SEM_COR} $1"; }

clear
titulo "DESINSTALADOR DO SERVIDOR TALISMAN"

# VERIFICAÇÃO DE ROOT
if [ "$EUID" -ne 0 ]; then
    erro "POR FAVOR, EXECUTE COMO ROOT (sudo -s)"
    exit
fi

echo -e "${VERMELHO_B}CUIDADO!${SEM_COR} Isso irá apagar os arquivos do servidor, logs e banco de dados."
read -p " [?] TEM CERTEZA QUE DESEJA DESINSTALAR TUDO? (S/N): " CONFIRMAR

if [[ "$CONFIRMAR" =~ ^[Ss]$ ]]; then
    
    # 1. PARANDO PROCESSOS
    aviso "Parando processos do servidor e limpando telas (screen)..."
    pkill -9 db_server 2>/dev/null
    pkill -9 login_server 2>/dev/null
    pkill -9 game_server 2>/dev/null
    /usr/bin/screen -wipe > /dev/null
    sucesso "Processos encerrados."
    
    # 2. REMOVENDO AUTOMATIZAÇÃO (CRONTAB)
    aviso "Removendo inicialização automática do Crontab..."
    crontab -u talisman -l 2>/dev/null | grep -v "ligar_servidor.sh" | crontab -u talisman -
    sucesso "Crontab limpo."
    
    # 3. APAGANDO ARQUIVOS DO SERVIDOR
    aviso "Removendo pastas do servidor e scripts de boot..."
    rm -rf /home/talisman/server
    rm -f /home/talisman/ligar_servidor.sh
    rm -f /home/talisman/log_boot.txt
    sucesso "Arquivos removidos de /home/talisman."
    
    # 4. LIMPANDO O WEBSITE (OPCIONAL)
    read -p " [?] DESEJA APAGAR TAMBÉM O SITE DE REGISTRO EM /var/www/html? (S/N): " APAGAR_SITE
    if [[ "$APAGAR_SITE" =~ ^[Ss]$ ]]; then
        rm -rf /var/www/html/*
        sucesso "Website removido."
    fi
    
    # 5. REMOVENDO BANCOS DE DADOS (OPCIONAL)
    read -p " [?] DESEJA APAGAR AS DATABASES DO MYSQL? (S/N): " APAGAR_DB
    if [[ "$APAGAR_DB" =~ ^[Ss]$ ]]; then
        read -s -p " [?] Digite a senha do root do MySQL: " SENHA_MYSQL
        echo ""
        mysql -u root -p"$SENHA_MYSQL" -e "DROP DATABASE IF EXISTS account; DROP DATABASE IF EXISTS game; DROP DATABASE IF EXISTS world;" 2>/dev/null
        if [ $? -eq 0 ]; then
            sucesso "Bancos de dados (account, game, world) removidos."
        else
            erro "Não foi possível conectar ao MySQL para apagar as DBs."
        fi
    fi
    
    # 6. LIMPEZA DE DEPENDÊNCIAS (OPCIONAL)
    read -p " [?] DESEJA DESINSTALAR APACHE, PHP E MYSQL? (S/N): " LIMPAR_LAMP
    if [[ "$LIMPAR_LAMP" =~ ^[Ss]$ ]]; then
        aviso "Removendo pacotes LAMP... isso pode demorar."
        apt-get purge -y mysql-server mysql-common mysql-client apache2 php php-mysql phpmyadmin
        apt-get autoremove -y
        apt-get autoclean
        sucesso "Pacotes removidos."
    fi
    
    linha
    echo -e "${VERDE}DESINSTALAÇÃO CONCLUÍDA COM SUCESSO!${SEM_COR}"
    linha
    
else
    echo -e "\n${AMARELO}>>> OPERAÇÃO CANCELADA.${SEM_COR}"
fi

echo -e "${AZUL}Pressione [Enter] para sair...${SEM_COR}"
read
