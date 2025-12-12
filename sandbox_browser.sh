#!/usr/bin/env bash

# ---------------------------------------------------------
# FIREJAIL ULTRA-SECURE BROWSER LAUNCHER - v2.1
# - Modo limpo (padrão): suprime warnings do Firejail/Gtk
# - Flag --verbose/-v: exibe output completo
# - Cria perfil ultra seguro se não existir
# - Cria regras mínimas de rede se não existir
# - Resolve redirecionamentos com timeout
# ---------------------------------------------------------

VERBOSE=false

# Parsing de argumentos
while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -*)
            echo "[ERRO] Flag desconhecida: $1"
            echo "Uso: $0 [-v|--verbose] <URL>"
            exit 1
            ;;
        *)
            URL="$1"
            shift
            ;;
    esac
done

if [ -z "$URL" ]; then
    echo "Uso: $0 [-v|--verbose] <URL>"
    exit 1
fi

echo "===================================================="
echo "[INFO] Iniciando Sandbox Browser ULTRA (v2.1)"
if [ "$VERBOSE" = true ]; then
    echo "[INFO] Modo verbose ativado"
fi
echo "===================================================="
sleep 0.5

# ---------------------------------------------------------
# 1. Criar perfil Firejail ultra seguro (se não existir)
# ---------------------------------------------------------
PROFILE="/etc/firejail/firefox-ultra.profile"

if [ ! -f "$PROFILE" ]; then
    echo "[SETUP] Criando perfil ultra seguro do Firejail..."

sudo bash -c "cat > /etc/firejail/firefox-ultra.profile" << 'EOF'
# -----------------------------------------------------
# FIREFOX ULTRA-SECURE PROFILE (MAXIMUM HARDENING)
# -----------------------------------------------------
nosound
nonewprivs
seccomp
caps.drop all

private-dev
private-tmp
private-cache
private-etc
private-opt
private-var
private

blacklist /home
blacklist /root
blacklist /mnt
blacklist /media
blacklist /srv
blacklist /var/log

blacklist /dev/video0
blacklist /dev/video1
blacklist /dev/snd
blacklist /dev/input
blacklist /dev/bus/usb
blacklist /dev/disk

x11 none
dbus-user none
dbus-system none

noexec /tmp
noexec /run/user

restrict-namespaces
protocol unix,inet,inet6

disabledmg
novideo

writable-run-user

netfilter /etc/firejail/whitelist-minimal-http.inc

include /etc/firejail/firefox.profile
EOF

    echo "[OK] Perfil criado."
else
    echo "[OK] Perfil ultra já existe."
fi


# ---------------------------------------------------------
# 2. Criar regras mínimas de rede (se não existirem)
# ---------------------------------------------------------
NETRULES="/etc/firejail/whitelist-minimal-http.inc"

if [ ! -f "$NETRULES" ]; then
    echo "[SETUP] Criando regras mínimas de rede..."

sudo bash -c "cat > /etc/firejail/whitelist-minimal-http.inc" << 'EOF'
# Permite apenas DNS + HTTP/HTTPS
whitelist udp 53
whitelist tcp 53
whitelist tcp 80
whitelist tcp 443

# Bloqueia todo o resto
blacklist all
EOF

    echo "[OK] Regras criadas."
else
    echo "[OK] Regras de rede já existem."
fi


# ---------------------------------------------------------
# 3. Resolver redirecionamentos (com timeout)
# ---------------------------------------------------------
echo
echo "[INFO] Resolvendo redirecionamentos (máx 5s)..."

FINAL_URL=$(curl --max-time 5 -s -I -L "$URL" 2>/dev/null \
    | awk '/^Location: /{print $2}' \
    | tail -n1 \
    | tr -d '\r')

if [ -z "$FINAL_URL" ]; then
    echo "[WARN] Não foi possível resolver redirecionamentos (timeout/erro)."
    FINAL_URL="$URL"
    echo "[INFO] Usando URL original: $FINAL_URL"
else
    echo "[INFO] URL final detectada: $FINAL_URL"
fi


# ---------------------------------------------------------
# 4. Abrir no Firejail Ultra-Secure
# ---------------------------------------------------------
echo
echo "===================================================="
echo "[INFO] Abrindo Firefox em sandbox ultra segura..."
echo "===================================================="
sleep 1

if [ "$VERBOSE" = true ]; then
    # Modo verbose: mostra tudo
    firejail --profile=/etc/firejail/firefox-ultra.profile firefox "$FINAL_URL"
else
    # Modo limpo: filtra warnings do Firejail e Gtk
    firejail --profile=/etc/firejail/firefox-ultra.profile firefox "$FINAL_URL" 2>&1 \
        | grep -v -E "^(Warning:|Reading profile|Seccomp|Parent pid|Child process|\(firefox:|Private /)" \
        | grep -v -E "Theme directory.*has no size field"
fi

