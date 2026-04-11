# -*- coding: utf-8 -*-
import os
import hashlib
import json
import sys
import re

# ==========================================================
# DEFINIÇÃO DE CORES (COMPATÍVEL COM TERMINAIS ANTIGOS)
# ==========================================================
VERDE_B  = '\033[1;32m'
AZUL_B   = '\033[1;34m'
AMARELO  = '\033[1;33m'
VERMELHO = '\033[0;31m'
CIANO    = '\033[0;36m'
SEM_COR  = '\033[0m'

# ==========================================================
# FUNÇÕES DE INTERFACE
# ==========================================================
def linha():
    print("%s============================================================%s" % (AZUL_B, SEM_COR))

def titulo(texto):
    linha()
    print("   %s " % (texto))
    linha()

def sucesso(texto):
    print("%s[OK]%s %s" % (VERDE_B, SEM_COR, texto))

def aviso(texto):
    print("%s[AVISO]%s %s" % (AMARELO, SEM_COR, texto))

def erro(texto):
    print("%s[ERRO]%s %s" % (VERMELHO, SEM_COR, texto))

# ==========================================================
# FUNÇÃO PARA CAPTURAR O IP DO ARQUIVO .INI (DINÂMICO)
# ==========================================================
def buscar_ip_configurado():
    ini_path = "/home/talisman/server/game/server_user.ini"
    ip_padrao = "127.0.0.1"
    
    if os.path.exists(ini_path):
        try:
            with open(ini_path, "r") as f:
                content = f.read()
                match = re.search(r'sv1\s*=\s*"([^"]+)"', content)
                if match:
                    return match.group(1)
        except:
            pass
    return ip_padrao

# ==========================================================
# CONFIGURAÇÕES
# ==========================================================
SERVER_IP   = buscar_ip_configurado()
BASE_DIR    = "/var/www/patch/files_to_update"
PASTA_MARS  = "/var/www/patch/files_to_update/local/mars"
URL_PREFIX  = "http://%s/patch/files_to_update" % SERVER_IP
OUTPUT_FILE = "/var/www/patch/patch.json"

def get_md5(fname):
    hash_md5 = hashlib.md5()
    with open(fname, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()

def generate():
    os.system('clear')
    titulo("GERADOR DE PATCH - TALISMAN ONLINE")

    # --- AJUSTE SOLICITADO: VERIFICAÇÃO E CRIAÇÃO DA PASTA MARS ---
    if not os.path.exists(PASTA_MARS):
        aviso("Pasta de arquivos editados (mars) nao encontrada.")
        try:
            # os.makedirs com exist_ok=True cria toda a arvore de pastas necessária
            os.makedirs(PASTA_MARS)
            sucesso("Diretorio criado: %s" % PASTA_MARS)
        except Exception as e:
            erro("Nao foi possivel criar a pasta: %s" % str(e))
    # --------------------------------------------------------------
    
    print(" [i] IP Detectado automaticamente: %s%s%s" % (CIANO, SERVER_IP, SEM_COR))

    if sys.version_info[0] < 3:
        confirmar = raw_input(" [?] Deseja escanear arquivos e atualizar o patch.json? (s/n): ")
    else:
        confirmar = input(" [?] Deseja escanear arquivos e atualizar o patch.json? (s/n): ")

    if confirmar.lower() not in ['s', 'sim']:
        print("")
        erro("Operacao cancelada pelo utilizador.")
        linha()
        return

    patch_data = {"files": []}
    
    if not os.path.exists(BASE_DIR):
        print("")
        erro("Pasta %s nao encontrada!" % BASE_DIR)
        return

    print("\n%s>>> Mapeando ficheiros...%s" % (CIANO, SEM_COR))
    
    count = 0
    for root, dirs, files in os.walk(BASE_DIR):
        for file in files:
            full_path = os.path.join(root, file)
            relative_path = os.path.relpath(full_path, BASE_DIR).replace("\\", "/")
            
            patch_data["files"].append({
                "path": relative_path,
                "url": "%s/%s" % (URL_PREFIX, relative_path),
                "hash": get_md5(full_path)
            })
            count += 1
            print("  %s*%s Ficheiro: %s" % (VERDE_B, SEM_COR, relative_path))

    try:
        with open(OUTPUT_FILE, "w") as f:
            json.dump(patch_data, f, indent=2)
        print("")
        sucesso("Patch gerado com sucesso! (%d ficheiros)" % count)
    except Exception as e:
        print("")
        erro("Falha ao gravar ficheiro: %s" % str(e))
    
    linha()
    if sys.version_info[0] < 3:
        raw_input("Pressione [Enter] para voltar ao menu...")
    else:
        input("Pressione [Enter] para voltar ao menu...")

if __name__ == "__main__":
    generate()
