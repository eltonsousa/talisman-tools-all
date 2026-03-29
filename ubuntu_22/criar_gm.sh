#!/bin/bash

# DEFINIÇÃO DE CORES (Mantendo seu padrão)
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
titulo "BANCO DE DADOS E CONTA ADMINISTRATIVA"

read -p " [?] DESEJA CRIAR UM USUARIO GM? (S/N): " SIM_NAO
if [[ "$SIM_NAO" =~ ^[Ss]$ ]]; then
    
    # Solicitação da senha do MySQL
    echo -e "${AMARELO}------------------------------------------------------------"
    echo -e "       AUTENTICAÇÃO NECESSÁRIA PARA O BANCO DE DADOS"
    echo -e "------------------------------------------------------------${SEM_COR}"
    read -s -p "  [?] DIGITE A SENHA DO ROOT DO MYSQL: " SENHA_MYSQL
    echo -e "\n"
    
    # VERIFICAÇÃO E CRIAÇÃO AUTOMÁTICA DA COLUNA EMAIL
    COLUNA_EXISTE=$(mysql -u root -p"$SENHA_MYSQL" -N -s -e "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='db_account' AND TABLE_NAME='t_account' AND COLUMN_NAME='email';" 2>/dev/null)
    
    if [ "$COLUNA_EXISTE" -eq 0 ]; then
        echo -e "${CIANO}[SQL]${SEM_COR} Adicionando coluna 'email'..."
        mysql -u root -p"$SENHA_MYSQL" -e "ALTER TABLE db_account.t_account ADD COLUMN email VARCHAR(100) DEFAULT 'contato@talisman.com' AFTER pw2;" 2>/dev/null
    else
        echo -e "${CIANO}[SQL]${SEM_COR} Coluna 'email' já existe. Verificada."
    fi
    
    # COLETA DE DADOS DO NOVO GM
    echo -e "\n${CIANO}--- DADOS DO NOVO ADMIN/GM ---${SEM_COR}"
    read -p "  > NOME DE USUÁRIO: " NEW_USER
    read -p "  > SENHA: " NEW_PASS
    read -p "  > REPITA A SENHA: " NEW_PASS2
    read -p "  > EMAIL: " NEW_EMAIL
    
    # QUERY USANDO MD5 E COLUNA 'pv' (conforme seu código funcional)
    mysql -u root -p"$SENHA_MYSQL" -e "INSERT INTO db_account.t_account (name, pwd, pw2, email, pv) VALUES ('$NEW_USER', MD5('$NEW_PASS'), ('$NEW_PASS2'), '$NEW_EMAIL', 9);" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "\n${VERDE_B}------------------------------------------------------------"
        echo -e " USUÁRIO $NEW_USER CRIADO COM SUCESSO (NÍVEL ADM/GM)!"
        echo -e "------------------------------------------------------------${SEM_COR}"
    else
        echo -e "\n${VERMELHO}[ERRO] Falha ao criar usuário. Verifique se o nome já existe.${SEM_COR}"
    fi
    
else
    aviso "Instalação abortada."
fi

linha
echo -e "${AMARELO}Pressione [Enter] para voltar ao menu...${SEM_COR}"
read
