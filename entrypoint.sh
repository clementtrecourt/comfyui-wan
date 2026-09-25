#!/bin/bash
set -e

echo "=== Démarrage ComfyUI Turbo ==="

# 1. Raccorder les modèles depuis le volume persistant
MODELS_SRC="/workspace/runpod-slim/ComfyUI/models"
if [ ! -d "$MODELS_SRC" ]; then
    MODELS_SRC="/workspace/models"
fi

if [ -d "$MODELS_SRC" ]; then
    echo "Liaison des modèles depuis $MODELS_SRC..."
    rm -rf /app/ComfyUI/models
    ln -s "$MODELS_SRC" /app/ComfyUI/models
else
    echo "ATTENTION : Dossier de modèles introuvable sur /workspace !"
fi

# 2. Sauvegarder les vidéos générées directement sur le volume persistant
mkdir -p /workspace/output
rm -rf /app/ComfyUI/output
ln -s /workspace/output /app/ComfyUI/output

# 3. Lancer ComfyUI à la vitesse maximale du SSD local
cd /app/ComfyUI
exec python main.py --listen 0.0.0.0 --port 8888 --enable-cors-header "*"
