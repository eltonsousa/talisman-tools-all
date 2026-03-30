#!/bin/bash

# ==========================================================
# SCRIPT MESTRE DE INSTALAÇÃO E CONFIGURAÇÃO - TALISMAN ONLINE
# CONFIGURADO PARA: UBUNTU 14.04 | by ELTON SOUSA
# VERSÃO: 2.1 (ESTÉTICA MODERNA + LOG INTELIGENTE)
# ==========================================================

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
titulo "INSTALAÇÃO DO SERVIDOR TALISMAN (UBUNTU 10)"

# VERIFICAÇÃO DE ROOT
if [ "$EUID" -ne 0 ]; then
    erro "POR FAVOR, EXECUTE COMO ROOT (sudo -s)"
    exit
fi

read -p " [?] DESEJA INSTALAR O SERVER TALISMAN (S/N): " INSTALAR_SERVIDOR
if [[ "$INSTALAR_SERVIDOR" =~ ^[Ss]$ ]]; then
    
    passo "1" "ATUALIZANDO REPOSITÓRIOS (OLD-RELEASES)"
    cp /etc/apt/sources.list /etc/apt/sources.list.bkp
    echo "deb http://old-releases.ubuntu.com/ubuntu/ lucid main restricted universe multiverse
deb http://old-releases.ubuntu.com/ubuntu/ lucid-updates main restricted universe multiverse
    deb http://old-releases.ubuntu.com/ubuntu/ lucid-security main restricted universe multiverse" > /etc/apt/sources.list
    apt-get update -qq
    sucesso "Repositórios configurados para Old-Releases."
    
    sleep 3
    clear
    passo "2" "INSTALANDO DEPENDÊNCIAS DO SISTEMA"
    aviso "Instalando Apache, MySQL, PHP5 e Screen..."
    apt-get install ssh apache2 mysql-server php5 php5-mysql php5-gd screen wget -y
    sucesso "Dependências instaladas."
    
    sleep 3
    clear
    
    passo "3" "BIBLIOTECA MYSQL (LIBMYSQLCLIENT15OFF)"
    if [ -f "/home/talisman/libmysqlclient15off_5.0.92-b23.87.lenny_i386.deb" ]; then
        dpkg -i /home/talisman/libmysqlclient15off_5.0.92-b23.87.lenny_i386.deb > /dev/null
        ln -sf /usr/lib/libmysqlclient.so.15.0.0 /usr/lib/libmysqlclient.so.15
        ldconfig
        sucesso "Biblioteca MySQL 15 instalada e vinculada."
    else
        erro "Arquivo .deb não encontrado em /home/talisman/"
        aviso "Copie o arquivo via FileZilla e reinicie o processo."
    fi
    
    sleep 3
    clear
    
    passo "4" "CONFIGURANDO PHPMYADMIN"
    apt-get install phpmyadmin -y
    ln -sf /usr/share/phpmyadmin /var/www/phpmyadmin
    sucesso "phpMyAdmin disponível em http://IP/phpmyadmin"
    
    sleep 2
    clear
    echo -e "\n${AMARELO}------------------------------------------------------------"
    echo -e "      CONFIGURAÇÃO DO SERVIDOR TALISMAN ONLINE"
    echo -e "------------------------------------------------------------${SEM_COR}"
    read -p "  [?] DIGITE O NOVO IP: " NOVO_IP
    read -p "  [?] DIGITE A NOVA SENHA DO BANCO: " NOVA_SENHA
    read -p "  [?] DIGITE O NOVO NOME DO SERVIDOR: " NOVO_NOME
    echo -e "${AZUL}------------------------------------------------------------${SEM_COR}"
    
    passo "5" "CONFIGURAÇÃO DOS ARQUIVOS .ini"
    DIRETORIO_BASE="/home/talisman/server"
    ORIGEM_REGISTRO="/home/talisman/pagina-registro"
    
    if [ -d "$DIRETORIO_BASE" ]; then
        # DANDO PERMISSÃO AOS ARQUIVOS
        chmod +x "$DIRETORIO_BASE/db/db_server"
        chmod +x "$DIRETORIO_BASE/login/login_server"
        chmod +x "$DIRETORIO_BASE/game/game_server"
        
        # VERIFICAR E CORRIGIR ESPAÇOS VAZIOS PADRAO UM ESPAÇO ANTES E DEPOIS [ = ]
        find "$DIRETORIO_BASE" -name "*.ini" -exec sed -i 's/[[:space:]]*=[[:space:]]*/ = /g' {} +
        
        # DB
        if [ -d "$DIRETORIO_BASE/db" ]; then
            echo -e "${CIANO}[DB]${SEM_COR} Atualizando Configs..."
            sed -i "s/Password = \".*\"/Password = \"$NOVA_SENHA\"/g" "$DIRETORIO_BASE/db/db_server_user.ini"
            sed -i "s/PublishServerIP=\".*\"/PublishServerIP=\"$NOVO_IP\"/g" "$DIRETORIO_BASE/db/guard_user.ini"
        fi
        
        # GAME
        if [ -d "$DIRETORIO_BASE/game" ]; then
            echo -e "${CIANO}[GAME]${SEM_COR} Atualizando Configs..."
            sed -i "s/PublishServerIP=\".*\"/PublishServerIP=\"$NOVO_IP\"/g" "$DIRETORIO_BASE/game/guard_user.ini"
            sed -i "s/ListenIp = \".*\"/ListenIp = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/game/server_user.ini"
            sed -i "s/ListenPortal = \".*\"/ListenPortal = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/game/server_user.ini"
            sed -i "s/ConnectIp = \".*\"/ConnectIp = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/game/server_user.ini"
            sed -i "s/location = \".*\"/location = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/game/server_user.ini"
            sed -i "s/sv1 = \".*\"/sv1 = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/game/server_user.ini"
            sed -i "s/sv2 = \".*\"/sv2 = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/game/server_user.ini"
            sed -i "s/sv3 = \".*\"/sv3 = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/game/server_user.ini"
            sed -i "s/name = \".*\"/name = \"$NOVO_NOME\"/g" "$DIRETORIO_BASE/game/server_user.ini"
        fi
        
        # LOGIN
        if [ -d "$DIRETORIO_BASE/login" ]; then
            echo -e "${CIANO}[LOGIN]${SEM_COR} Atualizando Configs..."
            sed -i "s/PublishServerIP=\".*\"/PublishServerIP=\"$NOVO_IP\"/g" "$DIRETORIO_BASE/login/guard_user.ini"
            sed -i "s/ListenIp = \".*\"/ListenIp = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/login/login_user.ini"
            sed -i "s/ListenPortal = \".*\"/ListenPortal = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/login/login_user.ini"
            sed -i "s/sv1 = \".*\"/sv1 = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/login/login_user.ini"
        fi
        sucesso "Arquivos INI atualizados."
    else
        erro "Pasta SERVER não encontrada."
    fi
    
    sleep 3
    clear
    
    passo "6" "GERANDO SCRIPT DE BOOT (ligar_server_ubuntu_10.sh)"
cat << 'EOF' > /home/talisman/ligar_server_ubuntu_10.sh
#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export HOME=/home/talisman

sleep 5

# Use este para o Ubuntu 10 (Universal)
until mysqladmin ping -h localhost --silent; do
    sleep 2
done

DIR_DB="/home/talisman/server/db"
DIR_LOGIN="/home/talisman/server/login"
DIR_GAME="/home/talisman/server/game"
DIR_LOG_LOGIN="$DIR_LOGIN/log"

pkill -9 db_server 2>/dev/null
pkill -9 login_server 2>/dev/null
pkill -9 game_server 2>/dev/null

rm -f "$DIR_DB"/*.pid "$DIR_LOGIN"/*.pid "$DIR_GAME"/*.pid 2>/dev/null

/usr/bin/screen -wipe > /dev/null

echo "[1/3] DB SERVER..."
/usr/bin/screen -dmS db /bin/bash -c "cd $DIR_DB && ./db_server"

sleep 10

echo "[2/3] LOGIN SERVER..."
rm -f "$DIR_LOG_LOGIN"/login_server_*.log
/usr/bin/screen -dmS login /bin/bash -c "cd $DIR_LOGIN && ./login_server"

while true; do
  ULTIMO_LOG=$(ls -t "$DIR_LOG_LOGIN"/login_server_*.log 2>/dev/null | head -1)

  if [ -n "$ULTIMO_LOG" ] && grep -q "login server init OK" "$ULTIMO_LOG"; then
    break
  fi

  if ! pgrep -f login_server > /dev/null; then
    exit 1
  fi

  sleep 2
done

sleep 10

echo "[3/3] GAME SERVER..."
/usr/bin/screen -dmS game /bin/bash -c "cd $DIR_GAME && ./game_server > log_erro_game.txt 2>&1"
EOF
    chmod +x /home/talisman/ligar_server_ubuntu_10.sh
    chown talisman:talisman /home/talisman/ligar_server_ubuntu_10.sh
    sucesso "Script de boot criado."
    
    sleep 3
    clear
    passo "7" "CONFIGURANDO INICIALIZAÇÃO AUTOMÁTICA DO SERVIDOR TALISMAN"
    (crontab -u talisman -l 2>/dev/null | grep -v 'ligar_server_ubuntu_10.sh'; echo "@reboot /home/talisman/ligar_server_ubuntu_10.sh") | crontab -u talisman -
    sucesso "Agendamento de boot configurado apenas no crontab."
    
    sleep 3
    clear
    passo "8" "LIBERANDO ACESSO REMOTO MYSQL"
    if [ -f "/etc/mysql/my.cnf" ]; then
        sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/my.cnf
        service mysql restart > /dev/null
    fi
    mysql -u root -p"$NOVA_SENHA" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$NOVA_SENHA' WITH GRANT OPTION; FLUSH PRIVILEGES;"
    sucesso "MySQL liberado para Navicat/Acesso Externo."
    
    sleep 3
    clear
    
    passo "10" "INSTALANDO PÁGINA DE REGISTRO"
    ORIGEM_REGISTRO="/home/talisman/pagina-registro"
    
    while [ ! -d "$ORIGEM_REGISTRO" ]; do
        linha
        erro "PASTA DE REGISTRO NÃO ENCONTRADA!"
        echo -e "${AMARELO}Caminho esperado:${SEM_COR} $ORIGEM_REGISTRO"
        echo -e "------------------------------------------------------------"
        echo -e "1) Já copiei a pasta e quero TENTAR NOVAMENTE."
        echo -e "2) Não quero instalar o site agora e quero PULAR ESTA ETAPA."
        echo -e "------------------------------------------------------------"
        read -p " [?] Escolha uma opção: " OPCAO_REGISTRO
        
        case $OPCAO_REGISTRO in
            1)
                aviso "Verificando pasta novamente..."
                sleep 2
            ;;
            2)
                aviso "Pulando instalação do website."
                break
            ;;
            *)
                erro "Opção inválida."
            ;;
        esac
    done
    
    if [ -d "$ORIGEM_REGISTRO" ]; then
        aviso "Instalando página de registro..."
        rm -f /var/www/index.html
        cp -rv "$ORIGEM_REGISTRO"/. /var/www/ > /dev/null
        rm -rf "$ORIGEM_REGISTRO"
        
        chown -R www-data:www-data /var/www/
        find /var/www/ -type d -exec chmod 755 {} \;
        find /var/www/ -type f -exec chmod 644 {} \;
        service apache2 restart > /dev/null
        sucesso "Website instalado com permissões corrigidas."
    fi
    
    sleep 3
    clear
    passo "10" "CONFIGURAÇÃO DO HAMACHI"
    read -p " [?] DESEJA INSTALAR O HAMACHI AGORA? (S/N): " INSTALAR_HAMACHI
    if [[ "$INSTALAR_HAMACHI" =~ ^[Ss]$ ]]; then
        HAMACHI_LOCAL="/home/talisman/logmein-hamachi_2.1.0.203-1_i386.deb"
        echo -e "${CIANO}>>> Preparando Libs de Compatibilidade...${SEM_COR}"
        wget http://archive.debian.org/debian/pool/main/g/gcc-4.7/libstdc++6_4.7.2-5_i386.deb --no-check-certificate -q
        
        if [ -f "libstdc++6_4.7.2-5_i386.deb" ]; then
            mkdir -p temp_lib && dpkg-deb -x libstdc++6_4.7.2-5_i386.deb temp_lib/
            mkdir -p /usr/lib/i386-linux-gnu/
            cp temp_lib/usr/lib/i386-linux-gnu/libstdc++.so.6.0.17 /usr/lib/i386-linux-gnu/
            rm -f /usr/lib/libstdc++.so.6
            cp /usr/lib/i386-linux-gnu/libstdc++.so.6.0.17 /usr/lib/libstdc++.so.6
            rm -rf temp_lib libstdc++6_*.deb
            ldconfig
            sucesso "Libs do GCC 4.7 configuradas."
        fi
        
        if [ -f "$HAMACHI_LOCAL" ]; then
            dpkg -i "$HAMACHI_LOCAL" > /dev/null
            mkdir -p /var/lib/logmein-hamachi/
            echo "Ipc.User talisman" > /var/lib/logmein-hamachi/h2-engine-override.cfg
            apt-get install -f -y > /dev/null
            /etc/init.d/logmein-hamachi restart > /dev/null
            sleep 3
            hamachi login
            
            echo -n -e "${CIANO}Aguardando rede Hamachi...${SEM_COR}"
            tentativas=0
            while [ "$(hamachi | grep -i 'status' | awk '{print $3}')" == "offline" ] && [ $tentativas -lt 15 ]; do
                echo -n "."
                sleep 3
                tentativas=$((tentativas+1))
            done
            echo -e "\n"
            read -p " [?] DIGITE O APELIDO (NICK) PARA ESTE SERVIDOR: " NOME_PC
            hamachi set-nick "$NOME_PC"
            sucesso "Hamachi configurado."
            hamachi
        else
            erro "Instalador do Hamachi não encontrado em $HAMACHI_LOCAL"
        fi
    fi
    
    sleep 2
    clear
    echo -e "\n${VERDE_B}============================================================"
    echo -e "       INSTALAÇÃO CONCLUÍDA COM SUCESSO!"
    echo -e "============================================================${SEM_COR}"
    echo -e "${AZUL_B} IP DO SERVIDOR:${SEM_COR} $NOVO_IP"
    echo -e "${AZUL_B} PHPMYADMIN:   ${SEM_COR} http://$NOVO_IP/phpmyadmin"
    echo -e "${AZUL_B} PÁGINA DE REGISTRO:     ${SEM_COR} http://$NOVO_IP/"
    echo -e "${VERDE_B}============================================================"
    echo -e "          DIVIRTA-SE NO SEU NOVO SERVIDOR!${SEM_COR}\n"
    
else
    echo -e "\n${AMARELO}>>> OPERAÇÃO CANCELADA.${SEM_COR}"
fi

linha
echo -e "${AMARELO}Pressione [Enter] para voltar ao menu...${SEM_COR}"
read
