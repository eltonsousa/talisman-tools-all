#!/bin/bash

# ==========================================================
# SCRIPT MESTRE DE INSTALAÇÃO E CONFIGURAÇÃO - TALISMAN ONLINE
# CONFIGURADO PARA: UBUNTU 16.04 | by ELTON SOUSA
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
titulo "INSTALAÇÃO DO SERVIDOR TALISMAN (UBUNTU 16)"

# VERIFICAÇÃO DE ROOT
if [ "$EUID" -ne 0 ]; then
    erro "POR FAVOR, EXECUTE COMO ROOT (sudo -s)"
    exit
fi

read -p " [?] DESEJA INSTALAR O SERVER TALISMAN (S/N): " INSTALAR_SERVIDOR
if [[ "$INSTALAR_SERVIDOR" =~ ^[Ss]$ ]]; then
    
    passo "1" "ATUALIZANDO REPOSITÓRIOS"
    apt-get update -qq
    sucesso "Lista de pacotes atualizada."
    
    passo "2" "INSTALANDO SUPORTE 32 bits..."
    sudo dpkg --add-architecture i386
    sudo apt update -y
    
    passo "3" "INSTALANDO BIBLIOTECAS..."
    sudo apt install -y lib32stdc++6 libstdc++6 lib32z1 lib32ncurses5 libbz2-1.0:i386
    sudo apt install -y gcc-multilib g++-multilib make
    sucesso "Bibliotecas instaladas!"
    
    passo "4" "INSTALANDO LibMysqlClient15..."
    cd /home/talisman
    sudo dpkg -i LibMysqlClient15.deb
    sudo apt -f install -y
    
    passo "5" "INSTALANDO BANCO DE DADOS E WEB (LAMP)"
    aviso "Instalando Apache, MySQL, PHP5, Screen e bibliotecas..."
    sudo apt install -y mysql-server php libapache2-mod-php php-mysql phpmyadmin screen
    sucesso "Dependências instaladas."
    
    passo "6" "CONFIGURANDO UDF..."
    sudo apt install -y libmysqlclient-dev
    
    aviso "Compilação da biblioteca de funções do sistema..."
    wget https://raw.githubusercontent.com/mysqludf/lib_mysqludf_sys/master/lib_mysqludf_sys.c
    
    sudo gcc -m64 -fPIC -Wall -I/usr/include/mysql -I. -shared lib_mysqludf_sys.c -o /usr/lib/mysql/plugin/lib_mysqludf_sys.so
    sucesso "Compilação executada com sucesso!"
    
    sleep 2
    clear
    echo -e "\n${AMARELO}------------------------------------------------------------"
    echo -e "      CONFIGURAÇÃO DO SERVIDOR TALISMAN ONLINE"
    echo -e "------------------------------------------------------------${SEM_COR}"
    read -p "  [?] DIGITE O NOVO IP: " NOVO_IP
    read -p "  [?] DIGITE A NOVA SENHA DO BANCO: " NOVA_SENHA
    read -p "  [?] DIGITE O NOVO NOME DO SERVIDOR: " NOVO_NOME
    echo -e "${AZUL}------------------------------------------------------------${SEM_COR}"
    
    passo "7" "CONFIGURAÇÃO DOS ARQUIVOS .ini"
    DIRETORIO_BASE="/home/talisman/server"
    ORIGEM_REGISTRO="/home/talisman/pagina-registro"
    
    # VERIFICAR SE A PASTA SERVER EXISTE
    if [ -d "$DIRETORIO_BASE" ]; then
        # DANDO PERMISSÃO AOS ARQUIVOS
        chmod +x "$DIRETORIO_BASE/db/db_server"
        chmod +x "$DIRETORIO_BASE/login/login_server"
        chmod +x "$DIRETORIO_BASE/game/game_server"
        
        # VERIFICAR E CORRIGIR ESPAÇOS VAZIOS PADRAO UM ESPAÇO ANTES E DEPOIS [ = ]
        find "$DIRETORIO_BASE" -name "*.ini" -exec sed -i 's/[[:space:]]*=[[:space:]]*/ = /g' {} +
        
        # --- 1. PASTA 'db' ---
        if [ -d "$DIRETORIO_BASE/db" ]; then
            echo "[DB] Atualizando db_server_user.ini e guard_user.ini..."
            sed -i "s/Password = \".*\"/Password = \"$NOVA_SENHA\"/g" "$DIRETORIO_BASE/db/db_server_user.ini"
            sed -i "s/PublishServerIP = \".*\"/PublishServerIP = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/db/guard_user.ini"
        fi
        
        # --- 2. PASTA 'game' ---
        if [ -d "$DIRETORIO_BASE/game" ]; then
            echo "[GAME] Atualizando server_user.ini e guard_user.ini..."
            sed -i "s/PublishServerIP = \".*\"/PublishServerIP = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/game/guard_user.ini"
            
            # server_user.ini
            sed -i "s/ListenIp = \".*\"/ListenIp = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/game/server_user.ini"
            sed -i "s/ListenPortal = \".*\"/ListenPortal = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/game/server_user.ini"
            sed -i "s/ConnectIp = \".*\"/ConnectIp = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/game/server_user.ini"
            sed -i "s/location = \".*\"/location = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/game/server_user.ini"
            sed -i "s/sv1 = \".*\"/sv1 = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/game/server_user.ini"
            sed -i "s/sv2 = \".*\"/sv2 = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/game/server_user.ini"
            sed -i "s/sv3 = \".*\"/sv3 = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/game/server_user.ini"
            sed -i "s/name = \".*\"/name = \"$NOVO_NOME\"/g" "$DIRETORIO_BASE/game/server_user.ini"
        fi
        
        # --- 3. PASTA 'login' ---
        if [ -d "$DIRETORIO_BASE/login" ]; then
            echo "[LOGIN] Atualizando login_user.ini e guard_user.ini..."
            # guard_user.ini
            sed -i "s/PublishServerIP = \".*\"/PublishServerIP = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/login/guard_user.ini"
            
            # login_user.ini (Troca em todas as seções: list, user, server)
            sed -i "s/ListenIp = \".*\"/ListenIp = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/login/login_user.ini"
            sed -i "s/ListenPortal = \".*\"/ListenPortal = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/login/login_user.ini"
            sed -i "s/sv1 = \".*\"/sv1 = \"$NOVO_IP\"/g" "$DIRETORIO_BASE/login/login_user.ini"
        fi
        
        sucesso "Arquivos INI atualizados com o novo IP e Senha."
        echo "------------------------------------------"
        echo "CONCLUÍDO COM SUCESSO!"
        echo "IP definido: $NOVO_IP"
        echo "Nome do Servidor: $NOVO_NOME"
        echo "------------------------------------------"
        
    else
        erro "Pasta SERVER não encontrada!"
    fi
    
    passo "8" "GERANDO SCRIPT DE BOOT INTELIGENTE"
cat << 'EOF' > /home/talisman/ligar_servidor.sh
#!/bin/bash

# Ligar Servidor Ubuntu 16
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export HOME=/home/talisman

# Espera o MySQL acordar (tentando 30x/s)
for i in {1..30}; do
    if mysqladmin ping -u root --silent; then
        break
    fi
    sleep 2
done

sleep 5

# 2. Definição de Diretórios
DIR_DB="/home/talisman/server/db"
DIR_LOGIN="/home/talisman/server/login"
DIR_GAME="/home/talisman/server/game"
DIR_LOG_LOGIN="$DIR_LOGIN/log"

# Garante que a pasta de log existe para não quebrar o script
mkdir -p "$DIR_LOG_LOGIN"

# 3. Limpeza de processos e telas antigas
pkill -9 db_server 2>/dev/null
pkill -9 login_server 2>/dev/null
pkill -9 game_server 2>/dev/null

rm -f "$DIR_DB"/*.pid "$DIR_LOGIN"/*.pid "$DIR_GAME"/*.pid 2>/dev/null

/usr/bin/screen -wipe > /dev/null

# 4. Início dos Servidores
echo "[1/3] DB SERVER..."
/usr/bin/screen -dmS db bash -c "cd $DIR_DB && ./db_server"

sleep 10

echo "[2/3] LOGIN SERVER..."
rm -f "$DIR_LOG_LOGIN"/login_server_*.log
/usr/bin/screen -dmS login bash -c "cd $DIR_LOGIN && ./login_server"

# 5. Loop de Verificação do Login
while true; do
    ULTIMO_LOG=$(ls -t "$DIR_LOG_LOGIN"/login_server_*.log 2>/dev/null | head -1)

    if [ -n "$ULTIMO_LOG" ] && grep -q "login server init OK" "$ULTIMO_LOG"; then
        echo "Login Server pronto!"
        break
    fi

    if ! pgrep -f login_server > /dev/null; then
        echo "Erro: Login Server caiu durante o boot."
        exit 1
    fi

    sleep 2
done

sleep 10

echo "[3/3] GAME SERVER..."
/usr/bin/screen -dmS game bash -c "cd $DIR_GAME && ./game_server > log_erro_game.txt 2>&1"
EOF
    
    chmod +x /home/talisman/ligar_servidor.sh
    chown talisman:talisman /home/talisman/ligar_servidor.sh
    sucesso "Script /home/talisman/ligar_servidor.sh criado."
    
    passo "9" "CONFIGURANDO INICIALIZAÇÃO AUTOMÁTICA DO SERVIDOR TALISMAN"
    (crontab -u talisman -l 2>/dev/null; echo "@reboot sleep 30 && /home/talisman/ligar_servidor.sh > /home/talisman/log_boot.txt 2>&1") | crontab -u talisman -
    sucesso "Boot automático configurado via Crontab."
    
    passo "10" "LIBERANDO ACESSO REMOTO MYSQL"
    # Procura o bind-address em qualquer arquivo dentro da pasta mysql e troca
    find /etc/mysql/ -name "*.cnf" -exec sed -i 's/bind-address.*/bind-address = 0.0.0.0/' {} +
    service mysql restart > /dev/null
    
    mysql -u root -p"$NOVA_SENHA" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$NOVA_SENHA' WITH GRANT OPTION; UPDATE mysql.user SET plugin='mysql_native_password' WHERE User='root'; FLUSH PRIVILEGES;"
    sucesso "MySQL liberado para conexões externas (Navicat)."
    
    passo "11" "INSTALANDO PÁGINA DE REGISTRO"
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
        rm -f /var/www/html/index.html
        cp -rv "$ORIGEM_REGISTRO"/. /var/www/html/ > /dev/null
        rm -rf "$ORIGEM_REGISTRO"
        
        chown -R www-data:www-data /var/www/html/
        find /var/www/html/ -type d -exec chmod 755 {} \;
        find /var/www/html/ -type f -exec chmod 644 {} \;
        service apache2 restart > /dev/null
        sucesso "Website instalado com permissões corrigidas."
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
