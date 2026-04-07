# 🦙 Ollama en CapRover + Túnel para el equipo

Guía para instalar Ollama en la mini PC con CapRover y exponerlo al equipo via Tailscale.

---

## Parte 1: Ollama en CapRover

### 1. Crear la app en CapRover

1. Entra a tu panel de CapRover
2. **Apps** → **One-Click Apps** → busca "Ollama" (si no aparece, usa imagen custom)
3. Si no está en one-click: **Apps** → **Create New App**
   - App Name: `ollama`
   - ✅ Marcar "Has Persistent Data"

### 2. Configurar con imagen Docker

En la app creada → **Deployment** → **Method 3: Deploy via ImageName**

```
Image: ollama/ollama
```

### 3. Configurar puertos y volumen

En **App Configs**:

**Port Mapping:**
```
Container Port: 11434
Host Port: 11434
```

**Volumes (persistencia de modelos):**
```
Host Path:      /var/ollama
Container Path: /root/.ollama
```

> Sin esto, los modelos se borran al reiniciar el contenedor.

### 4. Variables de entorno (opcionales)

```
OLLAMA_HOST=0.0.0.0
OLLAMA_ORIGINS=*
```

### 5. Deploy

Click en **Deploy** y espera que levante.

### 6. Descargar el modelo recomendado

Entra al contenedor via CapRover terminal o SSH a la mini:

```bash
docker exec -it $(docker ps | grep ollama | awk '{print $1}') ollama pull qwen2.5-coder:3b
```

Verifica que funcione:
```bash
curl http://localhost:11434/api/generate -d '{
  "model": "qwen2.5-coder:3b",
  "prompt": "Hello, are you working?",
  "stream": false
}'
```

---

## Parte 2: Túnel con Tailscale (recomendado)

Tailscale crea una VPN privada entre sus máquinas. Es la opción más segura — solo el equipo con acceso puede usar Ollama.

### Instalar Tailscale en la mini

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

Copia el link que aparece, ábrelo en el navegador y autoriza el dispositivo.

### Instalar Tailscale en sus PCs (cada quien)

- **Windows/Mac:** Descargar desde https://tailscale.com/download
- **Linux:** mismo comando de arriba

Todos deben hacer login con la **misma cuenta** (o ser invitados a la misma tailnet).

### Acceder a Ollama desde sus PCs

Una vez conectados a Tailscale, la mini tendrá una IP privada tipo `100.x.x.x`.

```bash
# Desde tu PC, prueba:
curl http://100.x.x.x:11434/api/generate -d '{
  "model": "qwen2.5-coder:3b",
  "prompt": "write a hello world in typescript",
  "stream": false
}'
```

### Configurar en VS Code (Continue.dev)

Instala la extensión **Continue** en VS Code:

1. Instala: `ext install Continue.continue`
2. Abre config (`~/.continue/config.json`):

```json
{
  "models": [
    {
      "title": "Qwen Coder (famelic-mini)",
      "provider": "ollama",
      "model": "qwen2.5-coder:3b",
      "apiBase": "http://100.x.x.x:11434"
    }
  ]
}
```

Reemplaza `100.x.x.x` con la IP Tailscale de la mini.

---

## Parte 3: Túnel con ngrok (alternativa, sin VPN)

Si no quieren usar Tailscale, ngrok expone el puerto público. Menos seguro pero más fácil.

```bash
# Instalar ngrok en la mini
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
sudo apt update && sudo apt install ngrok

# Autenticar (crear cuenta gratis en ngrok.com)
ngrok config add-authtoken TU_TOKEN

# Exponer Ollama
ngrok http 11434
```

ngrok te dará una URL tipo `https://abc123.ngrok.io` — esa es la que comparten con el equipo.

> ⚠️ Con ngrok free, la URL cambia cada vez que reinicias. Para URL fija necesitas plan de pago.

---

## Resumen del setup final

```
Mini PC (CapRover + Ollama + Tailscale)
    └── qwen2.5-coder:3b  [siempre encendido]
    └── gemma3:4b          [opcional]

José PC (RTX 4000) → modelos grandes cuando se necesite
Dwigth PC          → conectado via Tailscale
Samuel PC          → conectado via Tailscale
```

Todos en el equipo acceden a `http://100.x.x.x:11434` desde VS Code con Continue.dev.

---

## Troubleshooting

**Ollama no responde:**
```bash
docker logs $(docker ps | grep ollama | awk '{print $1}')
```

**Modelo muy lento:**
- Usa un modelo más pequeño: `ollama pull phi3:mini`
- Revisa que no haya otros procesos comiendo RAM en la mini

**Tailscale no conecta:**
```bash
sudo tailscale status
sudo tailscale ping 100.x.x.x
```
