#!/bin/bash

set -e

PROJECT_DIR="$HOME/aws-terraform-ansible-demo"

echo "=========================================="
echo " Git Project Setup"
echo "=========================================="

# --------------------------------------------------
# 1. Verify project directory
# --------------------------------------------------

if [ ! -d "$PROJECT_DIR" ]; then
    echo "ERROR: Project directory does not exist:"
    echo "$PROJECT_DIR"
    exit 1
fi

cd "$PROJECT_DIR"

echo
echo "[1/7] Project directory"
echo "OK: $(pwd)"

# --------------------------------------------------
# 2. Verify Git
# --------------------------------------------------

echo
echo "[2/7] Checking Git"

if ! command -v git >/dev/null 2>&1; then
    echo "ERROR: Git is not installed."
    exit 1
fi

echo "Git version: $(git --version)"

# --------------------------------------------------
# 3. Create .gitignore
# --------------------------------------------------

echo
echo "[3/7] Checking .gitignore"

if [ ! -f .gitignore ]; then

cat > .gitignore <<'EOF'
# Python
.venv/
__pycache__/
*.py[cod]
*.pyo

# Environment variables / secrets
.env
.env.*
*.pem
*.key

# Terraform
.terraform/
*.tfstate
*.tfstate.*
crash.log
crash.*.log
override.tf
override.tf.json
*_override.tf
*_override.tf.json
.terraform.tfstate.lock.info

# Ansible
*.retry

# OS / editor files
.DS_Store
Thumbs.db
.vscode/

# Logs
*.log
EOF

    echo "Created .gitignore"

else
    echo ".gitignore already exists"
fi

# --------------------------------------------------
# 4. Initialize Git
# --------------------------------------------------

echo
echo "[4/7] Initializing Git repository"

if [ ! -d .git ]; then
    git init
    echo "Git repository initialized"
else
    echo "Git repository already exists"
fi

# --------------------------------------------------
# 5. Basic secret check
# --------------------------------------------------

echo
echo "[5/7] Checking for possible credentials"

SECRET_MATCHES=$(grep -RniE \
    'AKIA[0-9A-Z]{16}|aws_secret_access_key[[:space:]]*=|aws_access_key_id[[:space:]]*=' \
    --exclude-dir=.git \
    --exclude-dir=.venv \
    --exclude-dir=.terraform \
    . 2>/dev/null || true)

if [ -n "$SECRET_MATCHES" ]; then
    echo
    echo "WARNING: Possible AWS credentials detected."
    echo "$SECRET_MATCHES"
    echo
    echo "Git setup stopped for safety."
    echo "Review the files before continuing."
    exit 1
fi

echo "No obvious AWS credentials detected."

# --------------------------------------------------
# 6. Stage files
# --------------------------------------------------

echo
echo "[6/7] Staging project files"

git add .

echo "Files staged:"
git status --short

# --------------------------------------------------
# 7. Configure branch and commit
# --------------------------------------------------

echo
echo "[7/7] Configuring main branch"

git branch -M main

if git diff --cached --quiet; then
    echo "No new changes to commit."
else
    git commit -m "Initial infrastructure automation project"
fi

echo
echo "=========================================="
echo " Git setup complete"
echo "=========================================="

echo
echo "Git status:"
git status

echo
echo "Git branch:"
git branch --show-current

echo
echo "Recent commits:"
git log --oneline -3
