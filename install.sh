#!/bin/bash

# --- CONFIGURAÇÕES DO REPOSITÓRIO ---
# Troque pelo seu novo repositório quando criar
REPO_USER="eltonsousa"
REPO_NAME="talisman-tools-all"
RAW_URL="https://raw.githubusercontent.com/$REPO_USER/$REPO_NAME/main"
TARGET_DIR="/home/talisman/.talisman-tools"

clear
echo "============================================================"
echo "          INSTALADOR TALISMAN-TOOLS-ALL | by ELTON"
echo "============================================================"

# 1. Identifica a versão do Ubuntu (Método Universal)
if [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    OS_VER=$DISTRIB_RELEASE
    elif [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_VER=$VERSION_ID
    elif [ -f /etc/debian_version ]; then
    # Fallback para versões muito antigas (10.04 por exemplo)
    OS_VER=$(cat /etc/issue | grep -oP '\d+\.\d+' | head -n1)
else
    # Se tudo falhar, tenta via comando lsb_release
    OS_VER=$(lsb_release -rs 2>/dev/null)
fi

# Limpa aspas se houver (ex: "14.04" vira 14.04)
OS_VER=$(echo $OS_VER | tr -d '"')

if [ -z "$OS_VER" ]; then
    echo "❌ Erro: Sistema operacional não identificado."
    exit 1
fi

echo "[*] Sistema Detectado: Ubuntu $OS_VER"

# 2. Prepara dependências básicas
apt-get update -qq && apt-get install wget unzip curl -y -qq > /dev/null 2>&1

# 3. Lógica de Instalação Específica (Baixa apenas o necessário)
mkdir -p "$TARGET_DIR"
cd /tmp

case $OS_VER in
    
    "10.04")
        echo "[*] Baixando instalador legado para Ubuntu 10.04..."
        wget -q "$RAW_URL/ubuntu_10/install-server-talisman.sh" -O setup_os.sh
    ;;
    
    "14.04")
        echo "[*] Baixando instalador legado para Ubuntu 14.04..."
        wget -q "$RAW_URL/ubuntu_14/install-server-talisman.sh" -O setup_os.sh
    ;;
    
    "16.04")
        echo "[*] Baixando instalador legado para Ubuntu 16.04..."
        wget -q "$RAW_URL/ubuntu_16/install-server-talisman.sh" -O setup_os.sh
    ;;
    
    "22.04")
        echo "[*] Baixando instalador otimizado para Ubuntu 22.04..."
        wget -q "$RAW_URL/ubuntu_22/install-server-talisman.sh" -O setup_os.sh
    ;;
    
    *)
        echo "⚠️ Versão $OS_VER ainda não mapeada no All-in-One."
        exit 1
    ;;
esac

# Executa o script de ambiente (MySQL, Apache, PHP, etc)
if [ -f "setup_os.sh" ]; then
    chmod +x setup_os.sh
    sudo ./setup_os.sh
else
    echo "❌ Erro ao baixar o script de configuração do SO."
    exit 1
fi

# 4. Baixa os arquivos de ferramentas (Menu, Scripts de Gerenciamento)
echo "[*] Sincronizando ferramentas do Talisman-Tools..."
ZIP_URL="https://github.com/$REPO_USER/$REPO_NAME/archive/refs/heads/main.zip"
wget -q "$ZIP_URL" -O /tmp/talisman.zip
unzip -oq /tmp/talisman.zip -d /tmp/

# Definimos a subpasta baseada na versão detectada no Passo 3
case $OS_VER in
    "10.04") SUB_FOLDER="ubuntu_10" ;;
    "14.04") SUB_FOLDER="ubuntu_14" ;;
    "16.04") SUB_FOLDER="ubuntu_16" ;;
    "20.04") SUB_FOLDER="ubuntu_20" ;;
    "22.04") SUB_FOLDER="ubuntu_22" ;;
esac

# O '*' no final garante que os arquivos dentro da pasta vão para a raiz de .talisman-tools
cp -rf /tmp/$REPO_NAME-main/$SUB_FOLDER/* "$TARGET_DIR/" 2>/dev/null

# 5. Configuração de Atalhos e Permissões
chmod +x "$TARGET_DIR"/*.sh

# Cria o alias 'menu' para root e para o usuário talisman
for rc in "/root/.bashrc" "/home/talisman/.bashrc"; do
    if [ -f "$rc" ]; then
        sed -i '/alias menu=/d' "$rc"
        echo "alias menu='bash $TARGET_DIR/menu.sh'" >> "$rc"
    fi
done

# Garante o comando no sistema todo
sudo ln -sf "$TARGET_DIR/menu.sh" /usr/local/bin/menu
sudo chmod +x /usr/local/bin/menu

# 6. Finalização
clear
echo "============================================================"
echo "   ✅ INSTALAÇÃO CONCLUÍDA NO UBUNTU $OS_VER!"
echo "   DIGITE 'menu' PARA GERENCIAR SEU SERVIDOR."
echo "============================================================"

sleep 2
bash "$TARGET_DIR/menu.sh"
