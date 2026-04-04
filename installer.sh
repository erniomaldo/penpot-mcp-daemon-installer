#!/bin/bash

################################################################################
# Penpot MCP Server - Installer & Auto-Update Daemon
# Para sistemas sin systemd (MX Linux, Alpine, Devuan, Artix, etc.)
################################################################################

set -euo pipefail

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuración
INSTALL_DIR="${HOME}/.local/penpot-mcp"
REPO_URL="https://github.com/penpot/penpot"
REPO_BRANCH="develop"
MCP_SUBDIR="mcp"
BIN_DIR="${HOME}/.local/bin"
DAEMON_NAME="penpot-mcp"
LOG_DIR="${INSTALL_DIR}/logs"
PID_FILE="${INSTALL_DIR}/${DAEMON_NAME}.pid"
STATE_FILE="${INSTALL_DIR}/version.state"
AUTOSTART_DIR="${HOME}/.config/autostart"

# ============================================================================
# FUNCIONES UTILITARIAS
# ============================================================================

log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✓ $1${NC}"
}

error() {
    echo -e "${RED}✗ $1${NC}"
    exit 1
}

warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

check_dependencies() {
    log "Verificando dependencias..."
    local deps=("git" "node" "npm" "pnpm" "curl")
    
    for cmd in "${deps[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            error "Falta: $cmd. Instala con: sudo apt install $cmd"
        fi
    done
    
    local node_version=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    if (( node_version < 18 )); then
        error "Node.js v18+ requerido. Tienes: $(node -v)"
    fi
    
    success "Dependencias OK"
}

# ============================================================================
# INSTALACIÓN
# ============================================================================

install_penpot_mcp() {
    log "Iniciando instalación de Penpot MCP..."
    
    mkdir -p "$INSTALL_DIR" "$LOG_DIR" "$BIN_DIR"
    
    if [ -d "${INSTALL_DIR}/repo" ]; then
        log "Repositorio existe, actualizando..."
        cd "${INSTALL_DIR}/repo"
        git fetch origin
        git checkout "$REPO_BRANCH"
        git pull origin "$REPO_BRANCH"
    else
        log "Clonando repositorio..."
        git clone --depth 1 --branch "$REPO_BRANCH" "$REPO_URL" "${INSTALL_DIR}/repo"
    fi
    
    cd "${INSTALL_DIR}/repo/${MCP_SUBDIR}" || error "No encontrado: $MCP_SUBDIR"
    
    log "Instalando dependencias..."
    pnpm install
    
    log "Compilando..."
    pnpm run bootstrap
    
    save_version_state
    success "Instalación completada"
}

save_version_state() {
    cd "${INSTALL_DIR}/repo/${MCP_SUBDIR}" 2>/dev/null || return 1
    local commit=$(git rev-parse HEAD 2>/dev/null)
    [ -n "$commit" ] && echo "$commit" > "$STATE_FILE"
}

create_launch_script() {
    local script_path="${BIN_DIR}/${DAEMON_NAME}"
    
    cat > "$script_path" << 'EOF'
#!/bin/bash
INSTALL_DIR="${HOME}/.local/penpot-mcp"
LOG_DIR="${INSTALL_DIR}/logs"
PID_FILE="${INSTALL_DIR}/penpot-mcp.pid"

export PENPOT_MCP_LOG_LEVEL=info
export PENPOT_MCP_LOG_DIR="$LOG_DIR"
export PENPOT_MCP_SERVER_PORT=4401
export PENPOT_MCP_WEBSOCKET_PORT=4402
export PENPOT_MCP_PLUGIN_SERVER_LISTEN_ADDRESS=127.0.0.1

cd "${INSTALL_DIR}/repo/mcp"
echo $$ > "$PID_FILE"
exec pnpm start >> "$LOG_DIR/mcp-server.log" 2>&1
EOF

    chmod +x "$script_path"
    success "Launcher creado"
}

# ============================================================================
# DAEMON CONTROL
# ============================================================================

start_daemon() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            warning "Ya está corriendo (PID: $pid)"
            return 0
        fi
    fi
    
    log "Iniciando daemon..."
    nohup "${BIN_DIR}/${DAEMON_NAME}" >> "$LOG_DIR/daemon.log" 2>&1 &
    local pid=$!
    echo $pid > "$PID_FILE"
    
    sleep 3
    if kill -0 "$pid" 2>/dev/null; then
        success "Daemon iniciado (PID: $pid)"
        show_connection_info
    else
        error "No se pudo iniciar. Revisa: $LOG_DIR/daemon.log"
    fi
}

stop_daemon() {
    [ ! -f "$PID_FILE" ] && { warning "PID no encontrado"; return 0; }
    
    local pid=$(cat "$PID_FILE")
    if kill -0 "$pid" 2>/dev/null; then
        log "Deteniendo (PID: $pid)..."
        kill "$pid" 2>/dev/null || true
        sleep 2
        kill -9 "$pid" 2>/dev/null || true
        rm -f "$PID_FILE"
        success "Detenido"
    fi
}

status_daemon() {
    [ ! -f "$PID_FILE" ] && { echo -e "${RED}Estado: Detenido${NC}"; return 1; }
    
    local pid=$(cat "$PID_FILE")
    if kill -0 "$pid" 2>/dev/null; then
        echo -e "${GREEN}Estado: Activo (PID: $pid)${NC}"
        show_connection_info
    else
        echo -e "${RED}Estado: Inactivo${NC}"
        rm -f "$PID_FILE"
    fi
}

show_connection_info() {
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo -e "${GREEN}Penpot MCP - Info de Conexión${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo "HTTP/Streamable: http://localhost:4401/mcp"
    echo "SSE:             http://localhost:4401/sse"
    echo "WebSocket:       ws://localhost:4402"
    echo "Plugin Web:      http://localhost:4400/manifest.json"
    echo ""
    echo "Logs: $LOG_DIR"
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
}

# ============================================================================
# AUTOSTART
# ============================================================================

setup_autostart() {
    log "Configurando autostart..."
    mkdir -p "$AUTOSTART_DIR"
    
    cat > "${AUTOSTART_DIR}/penpot-mcp.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Penpot MCP Server
Comment=Auto-start Penpot MCP Server
Exec=${BIN_DIR}/${DAEMON_NAME}
X-GNOME-Autostart-enabled=true
StartupNotify=false
NoDisplay=true
Hidden=false
EOF

    success "Autostart configurado"
}

# ============================================================================
# CLI
# ============================================================================

show_help() {
    cat << EOF
${GREEN}Penpot MCP Manager${NC}

${BLUE}Comandos:${NC}
  install          Instalar Penpot MCP
  start            Iniciar daemon
  stop             Detener daemon
  restart          Reiniciar daemon
  status           Ver estado
  update           Actualizar a última versión
  check-updates    Verificar actualizaciones
  logs [archivo]   Ver logs
  setup-autostart  Configurar autostart
  config           Mostrar configuración
  uninstall        Desinstalar completamente

${BLUE}Ejemplos:${NC}
  penpot-mcp-installer install
  penpot-mcp-installer status
  penpot-mcp-installer logs mcp-server
EOF
}

main() {
    local cmd="${1:-help}"
    
    case "$cmd" in
        install)
            check_dependencies
            install_penpot_mcp
            create_launch_script
            log "Ejecuta: penpot-mcp-installer setup-autostart"
            ;;
        start)
            start_daemon
            ;;
        stop)
            stop_daemon
            ;;
        restart)
            stop_daemon; sleep 2; start_daemon
            ;;
        status)
            status_daemon
            ;;
        setup-autostart)
            setup_autostart
            ;;
        logs)
            local log_file="${2:-daemon.log}"
            tail -f "$LOG_DIR/$log_file"
            ;;
        config)
            echo "Instalación: $INSTALL_DIR"
            echo "Binarios: $BIN_DIR"
            echo "Logs: $LOG_DIR"
            ;;
        uninstall)
            warning "Eliminarás todo"
            read -p "¿Continuar? (s/n): " -r
            [[ $REPLY =~ ^[Ss]$ ]] && {
                stop_daemon
                rm -rf "$INSTALL_DIR" "${BIN_DIR}/penpot-mcp"*
                rm -f "${AUTOSTART_DIR}/penpot-mcp.desktop"
                success "Desinstalado"
            }
            ;;
        *)
            show_help
            ;;
    esac
}

main "$@"