#!/bin/bash
set -e

echo "=== Installation de l'environnement IA & MCP complet ==="

# 1. Choisir le répertoire de travail
WORKSPACE_DIR="${1:-$(pwd)}"
mkdir -p "$WORKSPACE_DIR"
echo "[✓] Dossier de travail configuré : $WORKSPACE_DIR"

# 2. Vérifier et installer Node.js / npx si besoin
if ! command -v npx &> /dev/null; then
    echo "[!] Node.js / npx introuvable. Installation en cours..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    echo "[✓] Node.js est déjà installé."
fi

# 3. Vérifier et installer uv / uvx si besoin (pour le serveur Git)
if ! command -v uvx &> /dev/null; then
    echo "[!] uv / uvx introuvable. Installation en cours..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.cargo/bin:$PATH"
else
    echo "[✓] uv est déjà installé."
fi

# 4. Installer et démarrer Ollama (si non présent)
if ! command -v ollama &> /dev/null; then
    echo "[!] Ollama introuvable. Installation en cours..."
    curl -fsSL https://ollama.com/install.sh | sh
else
    echo "[✓] Ollama est déjà installé."
fi

# S'assurer que le service Ollama tourne en arrière-plan pour la suite
if ! pgrep -x "ollama" > /dev/null; then
    echo "[*] Démarrage du service Ollama..."
    ollama serve > /dev/null 2>&1 &
    sleep 3
fi

# 5. Télécharger le modèle par défaut (ex: qwen2.5-coder:7b)
MODEL_NAME="qwen2.5-coder:7b"
echo "[*] Téléchargement du modèle $MODEL_NAME (cela peut prendre quelques minutes selon la connexion)..."
ollama pull "$MODEL_NAME"
echo "[✓] Modèle $MODEL_NAME prêt à l'emploi !"

# 6. Cibler le dossier de configuration exact de Cline sous WSL
CLINE_CONFIG_DIR="$HOME/.cline/data/settings"
mkdir -p "$CLINE_CONFIG_DIR"

# 7. Remplacer le placeholder par le chemin absolu et copier le fichier JSON
if [ -f "cline_mcp_settings.template.json" ]; then
    sed "s|__WORKSPACE_PATH__|$WORKSPACE_DIR|g" cline_mcp_settings.template.json > "$CLINE_CONFIG_DIR/cline_mcp_settings.json"
    echo "[✓] Configuration MCP injectée dans : $CLINE_CONFIG_DIR/cline_mcp_settings.json"
else
    echo "[✗] Erreur : Fichier cline_mcp_settings.template.json introuvable."
    exit 1
fi

echo "=== Installation terminée avec succès ! ==="
echo "Tu peux ouvrir ton espace de travail avec : code $WORKSPACE_DIR"