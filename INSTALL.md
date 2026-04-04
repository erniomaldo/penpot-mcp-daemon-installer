# Guía de instalación paso a paso

## Para usuarios nuevos en terminal

### Paso 1: Abre una terminal

En MX Linux: `Ctrl + Alt + T` o busca "Terminal" en el menú

### Paso 2: Verifica que tienes los requisitos

```bash
node --version      # Debe ser v18+
npm --version       # Debe ser v9+
pnpm --version      # Si no lo tienes, instálalo con: npm install -g pnpm
git --version       # Debe ser v2.20+
```

Si falta algo, instálalo:
```bash
sudo apt update
sudo apt install nodejs npm pnpm git
```

### Paso 3: Descarga el instalador

**Opción A - Git (recomendado)**
```bash
git clone https://github.com/erniomaldo/penpot-mcp-daemon.git
cd penpot-mcp-daemon
```

**Opción B - Manual**
1. Ve a https://github.com/erniomaldo/penpot-mcp-daemon
2. Click verde "Code" → "Download ZIP"
3. Descomprime en tu carpeta de descargas
4. Abre terminal en esa carpeta

### Paso 4: Instala

```bash
chmod +x installer.sh
./installer.sh install
```

Espera a que termine (puede tomar 5-10 minutos descargando Penpot)

### Paso 5: Configura autostart (IMPORTANTE)

```bash
~/.local/bin/penpot-mcp-installer setup-autostart
```

### Paso 6: Verifica que está funcionando

```bash
penpot-mcp-installer status
```

Deberías ver:
```
Estado: Activo (PID: XXXXX)
═══════════════════════════════════════
Penpot MCP Server - Información de Conexión
...
```

## ¿Ahora qué?

El servidor está corriendo. Puedes:

1. **Conectar Claude Desktop** (ver README.md sección "Uso con Claude")
2. **Ver logs**: `penpot-mcp-installer logs`
3. **Detener**: `penpot-mcp-installer stop`
4. **Reiniciar**: `penpot-mcp-installer restart`

## Primeras actualizaciones

Cada vez que reinicies tu PC, el servidor se levantará solo. Si en algún momento hay actualizaciones nuevas en Penpot MCP:

```bash
penpot-mcp-installer check-updates
penpot-mcp-installer update
```

---

## Solución de problemas durante instalación

### Error: "pnpm: no se encontró la orden"
```bash
npm install -g pnpm
./installer.sh install
```

### Error: "No existe el fichero o directorio"
```bash
# Asegúrate de estar en el directorio correcto
pwd  # Debería mostrar algo con "penpot-mcp-daemon"
ls installer.sh  # Debería existir
chmod +x installer.sh
./installer.sh install
```

### Error: "Bootstrap falló"
Revisa el log:
```bash
cat ~/.local/penpot-mcp/logs/bootstrap.log
```

Si hay errores de dependencias:
```bash
cd ~/.local/penpot-mcp/repo/mcp
pnpm install --force
pnpm run bootstrap
```

### La instalación se queda "congelada"
- Presiona `Ctrl + C` para detener
- Ejecuta: `penpot-mcp-installer status`
- Si dice "Activo", está funcionando en background

---

## Desinstalación completa

```bash
penpot-mcp-installer uninstall
```

Esto elimina:
- `~/.local/penpot-mcp/` (toda la instalación)
- `~/.local/bin/penpot-mcp*` (scripts)
- `~/.config/autostart/penpot-mcp.desktop` (autostart)