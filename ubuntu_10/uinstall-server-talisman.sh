#!/bin/bash

# ==========================================================
# SCRIPT DE DESINSTALAÇÃO - SERVIDOR TALISMAN ONLINE
# CONFIGURADO PARA: UBUNTU 10 | by ELTON SOUSA
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
    crontab -u talisman -l 2>/dev/null | grep -v "ligar_server_ubuntu_10.sh" | crontab -u talisman -
    sucesso "Agendamentos removidos do Crontab e rc.local."
    
    passo "3" "REMOVENDO SCRIPTS E BIBLIOTECAS"
    echo "=== [3] REMOVENDO SCRIPTS E COMPONENTES DE COMPATIBILIDADE ==="
    rm -f /home/talisman/ligar_server_ubuntu_10.sh
    dpkg -r libmysqlclient15off 2>/dev/null
    # Removemos também a lib que criamos manualmente em /usr/lib no início do projeto
    rm -f /usr/lib/libmysqlclient.so.15
    sucesso "Scripts e biblioteca de compatibilidade removidos."
    
    passo "4" "DESINSTALANDO PACOTES DO SISTEMA"
    aviso "Removendo Apache, PHP, MySQL e phpMyAdmin..."
    apt-get purge apache2 php5* mysql-server* phpmyadmin screen -y
    apt-get autoremove -y
    
    # 5. REVERTE REPOSITÓRIOS
    if [ -f "/etc/apt/sources.list.bkp" ]; then
        echo "=== [5] REVERTENDO SOURCES.LIST PARA O BACKUP ORIGINAL ==="
        mv /etc/apt/sources.list.bkp /etc/apt/sources.list
        apt-get update
    fi
    
    # 6. LIMPAR DIRETÓRIO WEB
    echo "=== [6] LIMPANDO DIRETÓRIO /VAR/WWW/ ==="
    rm -rf /var/www/*
    echo "<html><body><h1>Servidor Revertido</h1></body></html>" > /var/www/index.html
    sucesso "Pasta /var/www/html/ limpa."
    
    passo "6" "REVERSÃO DO ACESSO REMOTO MYSQL"
    if [ -f "/etc/mysql/my.cnf" ]; then
        sed -i 's/bind-address = 0.0.0.0/bind-address = 127.0.0.1/' /etc/mysql/my.cnf
        sucesso "Configurações de rede do MySQL revertidas."
    fi
    
    # 3. REVERTE AS BIBLIOTECAS DO SISTEMA
    echo "=== [8] REVERTENDO BIBLIOTECAS DO SISTEMA (LIBSTDC++) ==="
    rm -f /usr/lib/libstdc++.so.6
    rm -f /usr/lib/i386-linux-gnu/libstdc++.so.6.0.17
    
    # Restaura o link padrão do Ubuntu 10.04 (Versão nativa)
    if [ -f "/usr/lib/i386-linux-gnu/libstdc++.so.6.0.13" ]; then
        ln -s /usr/lib/i386-linux-gnu/libstdc++.so.6.0.13 /usr/lib/libstdc++.so.6
        elif [ -f "/usr/lib/libstdc++.so.6.0.13" ]; then
        ln -s /usr/lib/libstdc++.so.6.0.13 /usr/lib/libstdc++.so.6
    fi
    
    ldconfig
    
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
