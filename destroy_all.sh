#!/usr/bin/env bash
set -euo pipefail

# =========================
# CONFIG – ajuste se precisar
# =========================
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
AWS_REGION="us-east-1"

# Perfis por ambiente (use os que você configurou no `aws configure sso`)
PROFILE_DEV="dev-sso"
PROFILE_STAGING="staging-sso"
PROFILE_PROD="prod-sso"

# =========================
# Funções utilitárias
# =========================

empty_versioned_bucket() {
  local bucket="$1"
  local profile="$2"

  echo ">> Esvaziando bucket versionado: $bucket (perfil: $profile)"
  # Loop até não restarem versões nem delete markers
  while true; do
    # Lista versões
    mapfile -t versions < <(aws s3api list-object-versions \
      --bucket "$bucket" \
      --query 'Versions[].{K:Key,V:VersionId}' \
      --output text \
      --profile "$profile" 2>/dev/null || true)

    # Lista delete markers
    mapfile -t markers < <(aws s3api list-object-versions \
      --bucket "$bucket" \
      --query 'DeleteMarkers[].{K:Key,V:VersionId}' \
      --output text \
      --profile "$profile" 2>/dev/null || true)

    if [[ ${#versions[@]} -eq 0 && ${#markers[@]} -eq 0 ]]; then
      echo "   - Bucket vazio."
      break
    fi

    for line in "${versions[@]}"; do
      [[ -z "$line" ]] && continue
      key=$(echo "$line" | awk '{print $1}')
      ver=$(echo "$line" | awk '{print $2}')
      aws s3api delete-object --bucket "$bucket" --key "$key" --version-id "$ver" \
        --profile "$profile" >/dev/null 2>&1 || true
    done

    for line in "${markers[@]}"; do
      [[ -z "$line" ]] && continue
      key=$(echo "$line" | awk '{print $1}')
      ver=$(echo "$line" | awk '{print $2}')
      aws s3api delete-object --bucket "$bucket" --key "$key" --version-id "$ver" \
        --profile "$profile" >/dev/null 2>&1 || true
    done
  done
}

destroy_stack() {
  local stack_dir="$1"   # ex: aws-labs/stacks/ec2
  local env="$2"         # dev | staging | prod
  local profile="$3"     # perfil AWS CLI

  local full_dir="${REPO_ROOT}/${stack_dir}"
  local backend_file="${full_dir}/environments/${env}/backend.hcl"
  local tfvars_file="${full_dir}/environments/${env}/terraform.tfvars"

  if [[ ! -d "$full_dir" ]]; then
    echo ">> [SKIP] Stack não encontrada: ${stack_dir}"
    return 0
  fi
  if [[ ! -f "$backend_file" ]]; then
    echo ">> [SKIP] backend.hcl não encontrado: ${backend_file}"
    return 0
  fi
  if [[ ! -f "$tfvars_file" ]]; then
    echo ">> [SKIP] terraform.tfvars não encontrado: ${tfvars_file}"
    return 0
  fi

  echo ""
  echo "=============================="
  echo "Destruindo stack: ${stack_dir} | env: ${env} | profile: ${profile}"
  echo "=============================="

  export AWS_PROFILE="$profile"
  export AWS_REGION="$AWS_REGION"

  pushd "$full_dir" >/dev/null

  terraform init -reconfigure -backend-config="$backend_file"
  # Destroy direto (sem workspace) porque cada env tem backend separado
  terraform destroy -auto-approve -var-file="$tfvars_file" || true

  popd >/dev/null
}

destroy_bootstrap_env() {
  local env="$1"     # dev | staging | prod
  local profile="$2" # perfil AWS CLI

  local boot_dir="${REPO_ROOT}/aws-labs/stacks/_bootstrap_state"
  local tfvars_file="${boot_dir}/${env}.tfvars"

  if [[ ! -d "$boot_dir" || ! -f "$tfvars_file" ]]; then
    echo ">> [SKIP] Bootstrap para ${env} não encontrado (dir ou tfvars ausente)."
    return 0
  fi

  echo ""
  echo "=============================="
  echo "Bootstrap destroy: env ${env} | profile: ${profile}"
  echo "=============================="

  export AWS_PROFILE="$profile"
  export AWS_REGION="$AWS_REGION"

  pushd "$boot_dir" >/dev/null

  # Bootstrap usa state local – apenas init simples
  terraform init

  # Seleciona (ou cria) workspace do env
  terraform workspace select "$env" >/dev/null 2>&1 || terraform workspace new "$env"

  # Descobre o nome do bucket via output do Terraform
  BUCKET_NAME=$(terraform output -raw state_bucket_name 2>/dev/null || true)
  if [[ -n "${BUCKET_NAME:-}" ]]; then
    # Esvazia bucket antes do destroy do recurso
    empty_versioned_bucket "$BUCKET_NAME" "$profile"
  else
    echo "   - Aviso: não foi possível ler 'state_bucket_name' via outputs. Se o bucket existir, esvazie manualmente."
  fi

  terraform destroy -auto-approve -var-file="${env}.tfvars" || true

  popd >/dev/null
}

# =========================
# Execução
# =========================

echo ">>> Iniciando destruição completa (EC2 -> ECS -> Bootstrap) para dev, staging, prod..."

# 1) EC2
destroy_stack "aws-labs/stacks/ec2" "dev" "$PROFILE_DEV"
destroy_stack "aws-labs/stacks/ec2" "staging" "$PROFILE_STAGING"
destroy_stack "aws-labs/stacks/ec2" "prod" "$PROFILE_PROD"

# 2) ECS
destroy_stack "aws-labs/stacks/ecs" "dev" "$PROFILE_DEV"
destroy_stack "aws-labs/stacks/ecs" "staging" "$PROFILE_STAGING"
destroy_stack "aws-labs/stacks/ecs" "prod" "$PROFILE_PROD"

# 3) Bootstrap (S3 + DynamoDB) — por último
destroy_bootstrap_env "dev" "$PROFILE_DEV"
destroy_bootstrap_env "staging" "$PROFILE_STAGING"
destroy_bootstrap_env "prod" "$PROFILE_PROD"

echo ""
echo " Finalizado. Verifique no Console AWS (EC2/ECS/S3/DynamoDB) se tudo foi removido."
echo "   Se algum bucket recusar exclusão: confirme se está vazio (versões e delete markers)."
