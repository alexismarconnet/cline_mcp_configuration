# 🚀 MCP Agent Starter

Environnement de développement portable et automatisé sous **WSL (Ubuntu)** pour **VS Code** et **Cline**. 

Ce projet permet de déployer en une seule commande un agent IA local fonctionnant sous **Ollama** (`qwen2.5-coder:7b`) couplé à deux serveurs **MCP (Model Context Protocol)** pour la gestion sécurisée des fichiers et du versionnement Git.

---

## 📂 Structure du Répertoire

```text
.
├── setup.sh                          # Script d'installation automatisé
├── cline_mcp_settings.template.json  # Modèle de configuration pour les serveurs MCP
├── test/
│   └── factorielle.py               # Script Python de test (buggé à des fins de validation IA)
└── README.md                         # Documentation du dépôt
```

---

## ⚙️ Détail des Composants

### 1. Script d'installation (`setup.sh`)
Script de déploiement autonome. Il exécute les actions suivantes :

* **Définition du Workspace :** Configure le dossier cible (par défaut le répertoire courant) ou celui passé en argument (`./setup.sh /chemin/vers/projet`).
* **Gestion des dépendances :**
  * Installe **Node.js / npx** (requis pour le serveur MCP `filesystem`).
  * Installe **uv / uvx** via Astral (requis pour le serveur MCP `git`).
* **Moteur d'IA Local :**
  * Installe et démarre le service **Ollama** en arrière-plan (port `11434`).
  * Télécharge automatiquement le modèle `qwen2.5-coder:7b`.
* **Configuration MCP Dynamique :** Injecte le chemin absolu du workspace dans `cline_mcp_settings.template.json` puis installe le résultat directement dans le dossier de configuration de Cline (`~/.cline/data/settings/cline_mcp_settings.json`).

### 2. Configuration MCP (`cline_mcp_settings.template.json`)
Ce fichier modèle configure deux serveurs MCP autorisés avec des permissions pré-approuvées :

* **`filesystem`** (via `@modelcontextprotocol/server-filesystem`) : Confine la lecture et la découverte de fichiers au dossier du projet (`__WORKSPACE_PATH__`).
* **`git`** (via `mcp-server-git`) : Permet à l'agent de consulter l'état du dépôt (`git_status`) et d'inspecter les modifications non indexées (`git_diff_unstaged`).

### 3. Fichier de test (`test/factorielle.py`)
Ce fichier contient une implémentation volontairement défaillante de la fonction factorielle en Python (erreur de syntaxe sur l'affectation `if n = 1`, récursion infinie `factorielle(n+1)`). Il sert de cas de test pour valider que l'agent Cline est capable de lire, diagnostiquer et corriger du code via l'environnement MCP.

---

## 🚀 Guide d'Installation et d'Utilisation

### Étape 1 : Rendre le script exécutable et le lancer
Dans ton terminal WSL, exécute :

```bash
chmod +x setup.sh
./setup.sh
```

*(Optionnel) Si tu souhaites cibler un autre dossier de travail :*

```bash
./setup.sh /chemin/vers/ton/projet
```

### Étape 2 : Ouvrir le projet dans VS Code
```bash
code .
```

### Étape 3 : Configurer Cline dans VS Code
1. Ouvre l'extension **Cline** dans la barre latérale de VS Code.
2. Clique sur l'icône **Engrenage (Paramètres)** et configure le provider :
   * **API Provider :** `Ollama`
   * **Base URL :** `http://localhost:11434`
   * **Model ID :** `qwen2.5-coder:7b`
3. Sauvegarde. Le voyant MCP doit indiquer que les serveurs `filesystem` et `git` sont actifs.

### Étape 4 : Valider le fonctionnement de l'agent
Demande à l'agent Cline dans VS Code :

> *"Analyse le fichier test/factorielle.py, identifie les erreurs de syntaxe et de logique, puis corrige-le."*