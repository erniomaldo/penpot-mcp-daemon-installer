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
git clone https://github.com/erniomaldo/penpot-mcp-daemon-installer.git
cd penpot-mcp-daemon-installer
```

**Opción B - Manual**
1. Ve a https://github.com/erniomaldo/penpot-mcp-daemon-installer
2. Click verde "Code" → "Download ZIP"
3. Descomprime en tu carpeta de descargas
4. Abre terminal en esa carpeta

### Paso 4: Instala

```bash
chmod +x installer.sh
./installer.sh install
```

Espera a que termine (puede tomar unos segundos descargando Penpot MCP server dependiendo de tu velocidad).

El instalador agregó automáticamente `~/.local/bin` a tu PATH.

### Paso 5: Recarga el PATH

Para que puedas usar `penpot-mcp-installer` sin la ruta completa:

```bash
source ~/.bashrc
```

Si usas zsh:
```bash
source ~/.zshrc
```

### Paso 6: Activa el servidor

Tienes dos opciones:

**Opción 1: Activar ahora mismo**
```bash
penpot-mcp-installer setup-autostart
penpot-mcp-installer start
```

**Opción 2: Activar al reiniciar el sistema**
```bash
penpot-mcp-installer setup-autostart
```

Luego reinicia tu sistema para que se active automáticamente.

### Paso 7: Verifica que está funcionando

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

El servidor debería estar corriendo si elegiste la **Opción 1** en el Paso 6. Puedes:

1. **Conectar Claude Desktop** (ver README.md sección "Conexión con clientes MCP")
2. **Ver logs**: `penpot-mcp-installer logs`
3. **Ver estado**: `penpot-mcp-installer status`
4. **Detener**: `penpot-mcp-installer stop`
5. **Reiniciar**: `penpot-mcp-installer restart`

## Primeras actualizaciones

Si elegiste la **Opción 2** en el Paso 6, cada vez que reinicies tu PC el servidor se levantará automáticamente.

Para verificar si hay actualizaciones disponibles:
```bash
penpot-mcp-installer check-updates
```

Para actualizar a la última versión:
```bash
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
pwd  # Debería mostrar algo con "penpot-mcp-daemon-installer"
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

### La instalación falla o se interrumpe

Si la instalación se detiene con error:

1. Verifica que tienes las dependencias instaladas (Paso 2)
2. Limpia la instalación parcial:
   ```bash
   rm -rf ~/.local/penpot-mcp
   ```
3. Reinstala desde el Paso 4

### El comando "penpot-mcp-installer" no se encuentra

Si después del Paso 5 sigues necesitando usar `~/.local/bin/penpot-mcp-installer`:

1. Cierra y abre una nueva terminal
2. O ejecuta: `source ~/.bashrc`
3. Verifica que `~/.local/bin` esté en tu PATH:
   ```bash
   echo $PATH | grep -o ".local/bin"
   ```

### El servidor no inicia correctamente

Verifica los logs:
```bash
# Logs del servidor MCP
cat ~/.local/penpot-mcp/logs/mcp-server.log

# Logs del daemon
cat ~/.local/penpot-mcp/logs/daemon.log
```

Si el puerto 4401 está en uso:
```bash
# Verifica qué proceso usa el puerto
sudo lsof -i :4401
# O cambia el puerto editando el launcher
nano ~/.local/bin/penpot-mcp
# Busca y modifica: export PENPOT_MCP_SERVER_PORT=4401
```

Para reiniciar el servidor:
```bash
penpot-mcp-installer restart
```

---

## Desinstalación completa

```bash
penpot-mcp-installer uninstall
```

El proceso te mostrará qué archivos se van a eliminar y te pedirá confirmación.

Esto elimina:
- `~/.local/penpot-mcp/` (toda la instalación)
- `~/.local/bin/penpot-mcp*` (scripts)
- `~/.config/autostart/penpot-mcp.desktop` (autostart)
- Limpia el PATH de tu `.bashrc` o `.zshrc`

Después de desinstalar, recarga tu shell:
```bash
source ~/.bashrc  # o ~/.zshrc
```