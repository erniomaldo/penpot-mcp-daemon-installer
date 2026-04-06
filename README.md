# Penpot MCP Daemon

🚀 **Ejecuta Penpot MCP Server en background automáticamente en MX Linux (y otras distros sin systemd)**

Un instalador one-shot que:
- ✅ Descarga y compila Penpot MCP desde el repositorio oficial
- ✅ Lo ejecuta como daemon en background (sin terminal abierta)
- ✅ Se inicia automáticamente al bootear
- ✅ Monitorea actualizaciones automáticamente
- ✅ Compatible con cualquier distro sin systemd (OpenRC, runit)

## Requisitos previos

Antes de instalar, asegúrate de tener:

```bash
# Debian/Ubuntu
sudo apt install git nodejs npm pnpm curl

# MX Linux
sudo apt-get install git nodejs npm pnpm curl

# Arch
sudo pacman -S git nodejs npm pnpm curl

# Fedora
sudo dnf install git nodejs npm pnpm curl
```

**Versiones mínimas:**
- Node.js: v18+
- npm: v9+
- pnpm: v8+
- git: v2.20+

## Instalación (una sola vez)

```bash
# 1. Clona el repositorio
git clone https://github.com/erniomaldo/penpot-mcp-daemon-installer.git
cd penpot-mcp-daemon-installer

# 2. Ejecuta el instalador
chmod +x installer.sh
./installer.sh install
# El instalador agrega ~/.local/bin a tu PATH automáticamente

# 3. Recarga el PATH
source ~/.bashrc  # o source ~/.zshrc si usas zsh

# 4. Activa el servidor (elige una opción)

# Opción A: Activar ahora mismo
penpot-mcp-installer setup-autostart
penpot-mcp-installer start

# Opción B: Activar al reiniciar el sistema
penpot-mcp-installer setup-autostart
# Luego reinicia tu sistema
```

Para instrucciones detalladas paso a paso, consulta [INSTALL.md](INSTALL.md).

## Uso

```bash
# Ver estado
penpot-mcp-installer status

# Iniciar
penpot-mcp-installer start

# Detener
penpot-mcp-installer stop

# Reiniciar
penpot-mcp-installer restart

# Ver logs en tiempo real
penpot-mcp-installer logs mcp-server

# Verificar actualizaciones
penpot-mcp-installer check-updates

# Actualizar a última versión
penpot-mcp-installer update

# Ver configuración
penpot-mcp-installer config

# Desinstalar completamente
penpot-mcp-installer uninstall
```

## Información de conexión

Una vez ejecutándose, el servidor está disponible en:

| Servicio | Endpoint |
|----------|----------|
| **MCP HTTP/Streamable** | `http://localhost:4401/mcp` |
| **MCP SSE** | `http://localhost:4401/sse` |
| **WebSocket (Plugin)** | `ws://localhost:4402` |
| **Plugin Web Server** | `http://localhost:4400/manifest.json` |

### Logs

- **Server MCP**: `~/.local/penpot-mcp/logs/mcp-server.log`
- **Daemon**: `~/.local/penpot-mcp/logs/daemon.log`

## Directorios instalados

```
~/.local/penpot-mcp/           # Directorio principal
├── repo/                       # Repositorio de Penpot clonado
├── logs/                       # Logs del servidor
├── penpot-mcp.pid             # PID del proceso activo
└── version.state              # Versión actual instalada

~/.local/bin/
├── penpot-mcp-installer       # Script principal
└── penpot-mcp                 # Launcher del server

~/.config/autostart/
└── penpot-mcp.desktop         # Autostart en el DE
```

## Solución de problemas

### El servidor no inicia
```bash
# Ver logs detallados
cat ~/.local/penpot-mcp/logs/daemon.log
cat ~/.local/penpot-mcp/logs/mcp-server.log
```

### El puerto 4401 ya está en uso
```bash
# Cambiar puerto editando:
nano ~/.local/bin/penpot-mcp
# Y cambiar: export PENPOT_MCP_SERVER_PORT=4401
```

### Falta pnpm
```bash
# Instálalo con:
npm install -g pnpm
```

## Cómo funciona

1. **Instalación**: Clona `penpot/penpot` rama `develop`, navega a `/mcp`, y ejecuta `pnpm install && pnpm run bootstrap`
2. **Daemon**: Usa `nohup` para ejecutar en background sin systemd
3. **Autostart**: Crea un archivo `.desktop` en `~/.config/autostart` para inicio automático
4. **Actualizaciones**: Monitorea cambios en el repositorio oficial y actualiza automáticamente

## Compatibilidad

✅ MX Linux (OpenRC)
✅ Alpine Linux (OpenRC)
✅ Devuan (sysvinit)
✅ Artix Linux (runit/openrc)
✅ Cualquier distro sin systemd

❌ No funciona con systemd (pero puedes usar esto igual como alternativa)

## Licencia

MIT - Libres de usar, modificar y distribuir

## Contribuciones

¿Encontraste un bug? ¿Tienes una mejora? 
Abre un issue o PR en: https://github.com/erniomaldo/penpot-mcp-daemon-installer

---

**Créditos**: Creado como wrapper para facilitar el uso de [Penpot MCP Server](https://github.com/penpot/penpot/tree/develop/mcp) en sistemas sin systemd.