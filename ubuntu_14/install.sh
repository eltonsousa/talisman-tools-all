#!/bin/bash

# CONFIGURAÇÕES:
TARGET_DIR="/home/talisman/.talisman-tools"
ZIP_URL="https://github.com/eltonsousa/talisman-tools/archive/refs/heads/main.zip"

clear
echo "============================================================"
echo "       INSTALANDO TALISMAN TOOLS VIA GITHUB ZIP"
echo "============================================================"

# Instala dependências silenciosamente
apt-get update -qq && apt-get install unzip wget -y -qq > /dev/null 2>&1

# Cria a pasta oculta
mkdir -p "$TARGET_DIR"

# Baixa o ZIP
echo "[*] Baixando arquivos..."
wget -q "$ZIP_URL" -O /tmp/talisman.zip

# Extrai o conteúdo
echo "[*] Extraindo e configurando..."
unzip -oq /tmp/talisman.zip -d /tmp/

# O GitHub coloca dentro de uma pasta 'nome-do-repo-main'
# Vamos mover tudo de lá para a nossa pasta final
cp -rf /tmp/talisman-tools-main/* "$TARGET_DIR/" 2>/dev/null

# Limpeza
rm -rf /tmp/talisman-tools-main /tmp/talisman.zip

# Permissões
chmod +x "$TARGET_DIR"/*.sh

# Configura o atalho 'menu' no sistema
for rc in "/root/.bashrc" "/home/talisman/.bashrc"; do
    if [ -f "$rc" ]; then
        sed -i '/alias menu=/d' "$rc"
        echo "alias menu='bash $TARGET_DIR/menu.sh'" >> "$rc"
    fi
done

# 1. Garante o comando no sistema todo (sem reboot)
sudo ln -sf /home/talisman/.talisman-tools/menu.sh /usr/local/bin/menu
sudo chmod +x /usr/local/bin/menu

# 2. Abre o menu para o usuário imediatamente
clear
echo "============================================================"
echo "   INSTALAÇÃO CONCLUÍDA! DIGITE 'menu' PARA COMEÇAR."
echo "============================================================"
echo "============================================================"
echo "   ABRINDO O MENU..."
echo "============================================================"

sleep 3

bash /home/talisman/.talisman-tools/menu.sh

