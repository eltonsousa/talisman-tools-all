# -*- coding: utf-8 -*-
import os
import hashlib
import json
import sys
import re

# ==========================================================
# CONFIGURAÇÕES DE CORES
# ==========================================================
VERDE_B  = '\033[1;32m'
AZUL_B   = '\033[1;34m'
AMARELO  = '\033[1;33m'
VERMELHO = '\033[0;31m'
CIANO    = '\033[0;36m'
SEM_COR  = '\033[0m'

def titulo(texto):
    print("\n%s============================================================%s" % (AZUL_B, SEM_COR))
    print("   %s " % (texto))
    print("%s============================================================%s" % (AZUL_B, SEM_COR))

def buscar_ip_configurado():
    ini_path = "/home/talisman/server/game/server_user.ini"
    ip_padrao = "127.0.0.1"
    if os.path.exists(ini_path):
        try:
            with open(ini_path, "r") as f:
                content = f.read()
                match = re.search(r'sv1\s*=\s*"([^"]+)"', content)
                if match: return match.group(1)
        except: pass
    return ip_padrao

# ==========================================================
# CONFIGURAÇÕES DE DIRETÓRIOS
# ==========================================================
SERVER_IP   = buscar_ip_configurado()
PATCH_ROOT  = "/var/www/html/patch"
OUTPUT_FILE = os.path.join(PATCH_ROOT, "patch.json")

FONTES = [
    {"nome": "download", "caminho": os.path.join(PATCH_ROOT, "download")},
    {"nome": "files_to_update", "caminho": os.path.join(PATCH_ROOT, "files_to_update")}
]

def get_md5(fname):
    hash_md5 = hashlib.md5()
    with open(fname, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()

def generate():
    os.system('clear')
    titulo("GERADOR DE PATCH OTIMIZADO (ORDEM DE PRIORIDADE)")

    arquivos_zip = []
    arquivos_normais = []
    count = 0

    print(" [i] IP Detectado: %s%s%s" % (CIANO, SERVER_IP, SEM_COR))
    
    for fonte in FONTES:
        print("\n%s>>> Escaneando %s...%s" % (AZUL_B, fonte["nome"].upper(), SEM_COR))
        
        for root, dirs, files in os.walk(fonte["caminho"]):
            for file in files:
                full_path = os.path.join(root, file)
                relative_path = os.path.relpath(full_path, fonte["caminho"]).replace("\\", "/")
                url = "http://%s/patch/%s/%s" % (SERVER_IP, fonte["nome"], relative_path)
                
                item = {
                    "path": relative_path,
                    "url": url,
                    "hash": get_md5(full_path)
                }

                # Separa Zips para o topo da lista
                if file.lower().endswith('.zip'):
                    arquivos_zip.append(item)
                else:
                    arquivos_normais.append(item)
                
                count += 1
                print("  %s[OK]%s %s" % (VERDE_B, SEM_COR, relative_path))

    # Junta as listas: primeiro Zips, depois o resto
    patch_data = {"files": arquivos_zip + arquivos_normais}

    try:
        with open(OUTPUT_FILE, "w") as f:
            json.dump(patch_data, f, indent=2, ensure_ascii=False)
        print("\n%s[SUCESSO] JSON Gerado com %d arquivos (Zips priorizados).%s" % (VERDE_B, count, SEM_COR))
    except Exception as e:
        print("\n%s[ERRO] Falha ao salvar: %s%s" % (VERMELHO, str(e), SEM_COR))

    print("\nPressione [Enter] para sair...")
    input()

if __name__ == "__main__":
    generate()
