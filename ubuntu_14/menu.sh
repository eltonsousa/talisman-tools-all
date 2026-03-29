#!/bin/bash

# ==========================================================
# TALISMAN TOOLS - MENU PRINCIPAL (VERSÃO FINAL)
# DESENVOLVIDO POR: ELTON SOUSA
# ==========================================================

# CONFIGURAÇÃO DE ATALHO DO MENU
if ! grep -q "alias talisman=" ~/.bashrc; then
    echo "alias talisman='bash /home/talisman/.talisman-tools/menu.sh'" >> ~/.bashrc
    echo "alias menu='bash /home/talisman/.talisman-tools/menu.sh'" >> ~/.bashrc
fi

AZUL_B='\033[1;34m'
CIANO='\033[0;36m'
AMARELO='\033[1;33m'
VERMELHO='\033[0;31m'
SEM_COR='\033[0m'

linha() { echo -e "${AZUL_B}============================================================${SEM_COR}"; }
titulo() { linha; echo -e "   $1 "; linha; }

menu() {
    clear
    titulo "TALISMAN TOOLS - GERENCIAMENTO"
    echo -e "  ${CIANO}1)${SEM_COR} Instalar Servidor Talisman (Completo)"
    echo -e "  ${CIANO}2)${SEM_COR} Desinstalar Servidor Talisman"
    echo -e "  ${CIANO}3)${SEM_COR} Instalar LogMeIn Hamachi"
    echo -e "  ${CIANO}4)${SEM_COR} Desinstalar LogMeIn Hamachi"
    echo -e "  ${CIANO}5)${SEM_COR} Configurar IP, Senha e Nome do Server"
    echo -e "  ${CIANO}6)${SEM_COR} Verificar/Criar campo 'email' na DB"
    echo -e "  ${CIANO}7)${SEM_COR} Criar Usuário GM (Admin)"
    echo -e "  ${CIANO}8)${SEM_COR} LIGAR SERVIDOR (DB, Login e Game)"
    echo -e "  ${CIANO}9)${SEM_COR} DESLIGAR SERVIDOR"
    echo -e "  ${CIANO}0)${SEM_COR} Sair"
    linha
    read -p " [?] Escolha uma opção: " OPCAO
    
    case $OPCAO in
        1) bash /home/talisman/.talisman-tools/install-server-talisman.sh ;;
        2) bash /home/talisman/.talisman-tools/uinstall-server-talisman.sh ;;
        3) bash /home/talisman/.talisman-tools/install-hamachi-ubuntu14.sh ;;
        4) bash /home/talisman/.talisman-tools/uinstall-hamachi-ubuntu14.sh ;;
        5) bash /home/talisman/.talisman-tools/config_ip_e_senha_server_talisman.sh ;;
        6) bash /home/talisman/.talisman-tools/email.sh ;;
        7) bash /home/talisman/.talisman-tools/criar_gm.sh ;;
        8) bash /home/talisman/.talisman-tools/ligar_server_ubuntu_14.sh ;;
        9) bash /home/talisman/.talisman-tools/desligar_server_ubuntu_14.sh ;; # Nova Opção!
        0) exit 0 ;;
        *) echo -e "${VERMELHO}Opção Inválida!${SEM_COR}"; sleep 2; menu ;;
    esac
    menu
}

# Boas-vindas inicial
clear
titulo "BEM-VINDO AO TALISMAN TOOLS"
echo -e "${AMARELO}O que deseja fazer hoje?${SEM_COR}"
echo -e "1) Abrir o Menu de Ferramentas"
echo -e "2) Iniciar Instalação do Zero"
echo -e "0) Sair"
linha
read -p "Opção: " INICIO

if [ "$INICIO" == "1" ]; then
    menu
    elif [ "$INICIO" == "2" ]; then
    bash /home/talisman/.talisman-tools/install-server-talisman.sh
else
    exit 0
fi

