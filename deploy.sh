#!/bin/bash

set -e

PROJECT_DIR="$HOME/aws-terraform-ansible-demo"
INVENTORY="ansible/inventory/hosts.yml"
PLAYBOOK="ansible/playbooks/site.yml"
HEALTH_URL="http://100.57.165.168/health"
APP_URL="http://100.57.165.168/"

echo "=========================================="
echo " AWS Terraform Ansible Deployment"
echo "=========================================="

echo
echo "[1/6] Checking project directory"

if [ ! -d "$PROJECT_DIR" ]; then
    echo "ERROR: Project directory does not exist:"
    echo "$PROJECT_DIR"
    exit 1
fi

cd "$PROJECT_DIR"

echo "OK: $(pwd)"

echo
echo "[2/6] Checking required tools"

if ! command -v terraform >/dev/null 2>&1; then
    echo "ERROR: Terraform is not installed."
    exit 1
fi

if ! command -v ansible-playbook >/dev/null 2>&1; then
    echo "ERROR: Ansible is not installed."
    exit 1
fi

echo "Terraform: $(terraform version -json | grep -o '"terraform_version":"[^"]*"' | head -1)"
echo "Ansible: $(ansible-playbook --version | head -1)"

echo
echo "[3/6] Checking Ansible inventory"

if [ ! -f "$INVENTORY" ]; then
    echo "ERROR: Inventory file not found:"
    echo "$INVENTORY"
    exit 1
fi

echo "OK: $INVENTORY"

ansible-inventory \
    -i "$INVENTORY" \
    --list >/dev/null

echo "Inventory validation passed."

echo
echo "[4/6] Running Ansible syntax check"

ansible-playbook \
    -i "$INVENTORY" \
    "$PLAYBOOK" \
    --syntax-check

echo "Syntax check passed."

echo
echo "[5/6] Deploying application"

ansible-playbook \
    -i "$INVENTORY" \
    "$PLAYBOOK"

echo
echo "Deployment completed."

echo
echo "[6/6] Running application health checks"

echo
echo "Health endpoint:"
curl --fail --connect-timeout 10 "$HEALTH_URL"

echo
echo
echo "Application endpoint:"
curl --fail --connect-timeout 10 "$APP_URL"

echo
echo
echo "=========================================="
echo " DEPLOYMENT SUCCESSFUL"
echo "=========================================="
