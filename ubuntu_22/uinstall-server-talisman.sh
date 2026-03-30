#!/bin/bash

# ==========================================================
# SCRIPT DE DESINSTALAÇÃO - TALISMAN ONLINE
# COMPATÍVEL COM: UBUNTU 22.04 | by ELTON SOUSA
# ==========================================================

# DEFINIÇÃO DE CORES
VERDE='\033[0;32m'
VERMELHO='\033[0;31m'
AMARELO='\033[1;33m'
AZUL='\033[0;34m'
SEM_COR='\033[0m'

clear
echo -e "${VERMELHO}============================================================${SEM_COR}"
echo -e "${VERMELHO}             AVISO: DESINSTALADOR DO SERVIDOR               ${SEM_COR}"
echo -e "${VERMELHO}============================================================${SEM_COR}"

# VERIFICAÇÃO DE ROOT
if [ "$EUID" -ne 0 ]; then
    echo -e "${VERMELHO}[ERRO] EXECUTE COMO ROOT (sudo -s)${SEM_COR}"
    exit
fi

read -p " [?] TEM CERTEZA QUE DESEJA REMOVER O SERVIDOR E DEPENDÊNCIAS? (S/N): " CONFIRMA
if [[ ! "$CONFIRMA" =~ ^[Ss]$ ]]; then
    echo -e "\n${VERDE}OPERAÇÃO CANCELADA.${SEM_COR}"
    exit
fi

# 1. PARANDO PROCESSOS DO JOGO
echo -e "\n${AZUL}[1/7] Parando processos do servidor Talisman...${SEM_COR}"
pkill -9 db_server 2>/dev/null
pkill -9 login_server 2>/dev/null
pkill -9 game_server 2>/dev/null
screen -wipe > /dev/null 2>&1
echo -e "${VERDE}[OK] Processos encerrados.${SEM_COR}"

# 2. REMOVENDO CRONTAB (BOOT AUTOMÁTICO)
echo -e "\n${AZUL}[2/7] Removendo inicialização automática...${SEM_COR}"
crontab -u talisman -l 2>/dev/null | grep -v "ligar_servidor.sh" | crontab -u talisman -
echo -e "${VERDE}[OK] Crontab limpo.${SEM_COR}"

# 3. REMOVENDO MYSQL 5.7 E PHPMYADMIN
echo -e "\n${AZUL}[3/7] Removendo MySQL 5.7 e PHPMyAdmin...${SEM_COR}"
apt-get purge -y phpmyadmin mysql-server mysql-community-server mysql-client mysql-community-client mysql-common 2>/dev/null
apt-get autoremove -y > /dev/null
apt-get autoclean > /dev/null
rm -rf /etc/mysql /var/lib/mysql /var/log/mysql ~/mysql57
echo -e "${VERDE}[OK] Banco de dados removido.${SEM_COR}"

# 4. REMOVENDO APACHE E PHP
echo -e "\n${AZUL}[4/7] Removendo Web Server (Apache/PHP)...${SEM_COR}"
service apache2 stop 2>/dev/null
apt-get purge -y apache2 php libapache2-mod-php php-mysql 2>/dev/null
rm -rf /var/www/html/*
echo -e "${VERDE}[OK] Web Server removido.${SEM_COR}"

# 5. REMOVENDO BIBLIOTECAS 32-BITS E LEGADAS
echo -e "\n${AZUL}[5/7] Removendo bibliotecas de compatibilidade...${SEM_COR}"
apt-get purge -y lib32stdc++6 libstdc++6:i386 lib32z1 libuuid1:i386 libncurses5:i386 libmysqlclient15off 2>/dev/null
echo -e "${VERDE}[OK] Bibliotecas removidas.${SEM_COR}"

# 6. LIMPANDO ARQUIVOS DE SCRIPT E FERRAMENTAS
echo -e "\n${AZUL}[6/7] Limpando scripts de sistema...${SEM_COR}"
rm -f /home/talisman/ligar_servidor.sh
rm -f /home/talisman/log_boot.txt
rm -f /usr/local/bin/menu
# Nota: Não removemos a pasta /home/talisman/server para proteger seus arquivos de dados (DB/Maps)
# Caso queira apagar tudo, descomente a linha abaixo:
# rm -rf /home/talisman/server
echo -e "${VERDE}[OK] Scripts removidos.${SEM_COR}"

# 7. FINALIZAÇÃO
echo -e "\n${VERDE}============================================================"
echo -e "           DESINSTALAÇÃO CONCLUÍDA COM SUCESSO!             "
echo -e "============================================================${SEM_COR}"
echo -e "${AMARELO}Recomendado reiniciar o sistema para limpar processos residuais.${SEM_COR}\n"
