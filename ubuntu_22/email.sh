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
passo() { echo -e "\n${CIANO}>>> Passo 9.1: $2${SEM_COR}"; }

clear

read -p " [?] DESEJA VERIFICAR SE EXISTE O CAMPO EMAIL? (S/N): " SIM_NAO
if [[ "$SIM_NAO" =~ ^[Ss]$ ]]; then
    
    titulo "VERIFICAÇÃO DO CAMPO EMAIL"
    
    echo -e "${AMARELO}------------------------------------------------------------"
    echo -e "  AUTENTICAÇÃO NECESSÁRIA PARA O BANCO DE DADOS"
    echo -e "------------------------------------------------------------${SEM_COR}"
    
    # Solicita a senha uma vez e guarda na variável
    read -s -p "  [?] DIGITE A SENHA DO ROOT DO MYSQL: " SENHA_MYSQL
    echo -e "\n"
    
    # Verifica se a coluna existe usando a senha fornecida
    COLUNA_EXISTE=$(mysql -u root -p"$SENHA_MYSQL" -N -s -e "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='db_account' AND TABLE_NAME='t_account' AND COLUMN_NAME='email';" 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        erro "Senha do MySQL incorreta ou erro de conexão."
        elif [ "$COLUNA_EXISTE" -eq 0 ]; then
        aviso "Coluna 'email' não encontrada. Adicionando..."
        mysql -u root -p"$SENHA_MYSQL" -e "USE db_account; ALTER TABLE t_account ADD COLUMN email VARCHAR(255) DEFAULT '' AFTER pw2;" 2>/dev/null
        if [ $? -eq 0 ]; then
            sucesso "Coluna 'email' adicionada com sucesso após 'pw2'."
        else
            erro "Falha ao adicionar a coluna. Verifique as permissões."
        fi
    else
        sucesso "A coluna 'email' já existe na tabela t_account."
    fi
    
else
    aviso "Instalação abortada."
fi

linha
echo -e "${AMARELO}Pressione [Enter] para voltar ao menu...${SEM_COR}"
read