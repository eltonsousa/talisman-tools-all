#!/bin/bash

# DEFINIÇÃO DE CORES
VERDE_B='\033[1;32m'
AZUL_B='\033[1;34m'
AMARELO='\033[1;33m'
VERMELHO='\033[0;31m'
CIANO='\033[0;36m'
SEM_COR='\033[0m'

# FUNÇÕES DE INTERFACE
linha() { echo -e "${AZUL_B}============================================================${SEM_COR}"; }
titulo() { linha; echo -e "    $1 "; linha; }
sucesso() { echo -e "${VERDE_B}[OK]${SEM_COR} $1"; }
aviso() { echo -e "${AMARELO}[AVISO]${SEM_COR} $1"; }
erro() { echo -e "${VERMELHO}[ERRO]${SEM_COR} $1"; }

# INÍCIO PADRONIZADO
clear
titulo "GERENCIADOR DE NEWS - TALISMAN ONLINE"

# --- AJUSTE SOLICITADO: VERIFICAÇÃO DE DIRETÓRIO ---
PASTA_MARS="/var/www/html/patch/files_to_update/local/mars"

if [ ! -d "$PASTA_MARS" ]; then
    aviso "Pasta de arquivos editados (mars) não encontrada."
    echo -e "${CIANO}>>> Criando diretório com privilégios de root...${SEM_COR}"
    
    # Criamos a pasta usando sudo
    sudo mkdir -p "$PASTA_MARS"
    
    # Ajustamos o dono da pasta para o seu usuário atual
    # para você conseguir mover arquivos para lá depois sem erro
    sudo chown -R $USER:$USER /var/www/html/patch/
    
    sudo chmod -R 755 /var/www/html/patch/
    sucesso "Pasta criada e permissões ajustadas!"
    echo ""
fi
# --------------------------------------------------

# PRIMEIRA PERGUNTA
read -p " [?] Deseja atualizar o News do Launcher agora? (s/n): " SIM_NAO
if [[ ! "$SIM_NAO" =~ ^[Ss]$ ]]; then
    echo ""
    erro "Operação cancelada pelo usuário."
    linha
    read -p "Pressione [Enter] para voltar..."
    exit 0
fi

OUTPUT="/var/www/html/patch/news.json"

listar_noticias() {
    echo -e "${CIANO}--- Notícias Atuais ---${SEM_COR}"
    if [ ! -f "$OUTPUT" ] || [ ! -s "$OUTPUT" ]; then
        echo "Nenhuma notícia encontrada."
        return 1
    fi
    grep "\"title\":" "$OUTPUT" | sed 's/.*: "//;s/".*//' | nl
}

# MENU DE OPÇÕES
echo -e "\n${CIANO}1)${SEM_COR} Adicionar Nova Notícia (Mantém as atuais)"
echo -e "${CIANO}2)${SEM_COR} Resetar e Criar Novas (Apaga as atuais)"
echo -e "${CIANO}0)${SEM_COR} Sair"
linha
read -p " [?] Escolha uma opção: " principal_opt

case $principal_opt in
    1)
        if [ ! -f "$OUTPUT" ] || [ ! -s "$OUTPUT" ]; then
            echo "[" > "$OUTPUT"
        else
            # Prepara o JSON removendo o último ']' e adicionando vírgula
            sed -i '$d' "$OUTPUT"
            sed -i '$s/$/ ,/' "$OUTPUT"
        fi
    ;;
    2)
        listar_noticias
        echo ""
        aviso "Atenção: Você vai apagar as notícias atuais."
        read -p " [?] Tem certeza disso? (s/n): " confirm
        if [[ ! "$confirm" =~ ^[Ss]$ ]]; then exit 0; fi
        echo "[" > "$OUTPUT"
    ;;
    *) exit 0 ;;
esac

# LOOP DE INSERÇÃO
continuar="s"
while [[ "$continuar" =~ ^[Ss]$ ]]; do
    echo -e "\n${CIANO}Categoria: 1) News | 2) Patch | 3) Event${SEM_COR}"
    read -p " Opção: " tipo_opt
    case $tipo_opt in
        1) tag="news"; tagName="News" ;;
        2) tag="patch"; tagName="Patch" ;;
        3) tag="event"; tagName="Event" ;;
        *) tag="news"; tagName="News" ;;
    esac
    
    read -p " Título: " titulo
    read -p " Descrição: " desc
    
    cat <<EOF >> "$OUTPUT"
  {
    "tag": "$tag",
    "tagName": "$tagName",
    "title": "$titulo",
    "description": "$desc"
  }
EOF
    
    read -p " [?] Deseja adicionar mais uma? (s/n): " continuar
    if [[ "$continuar" =~ ^[Ss]$ ]]; then
        echo "," >> "$OUTPUT"
    fi
done

echo "]" >> "$OUTPUT"
sudo chmod 644 "$OUTPUT"
echo ""
sucesso "Arquivo atualizado em: $OUTPUT"
linha
read -p "Pressione [Enter] para voltar ao menu..."
