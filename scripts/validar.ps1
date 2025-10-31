Write-Host "=== EJECUTANDO VALIDACIONES OBLIGATORIAS ===`n"

Write-Host "Formateando codigo Terraform..."
terraform -chdir=infra fmt

Write-Host "Validando sintaxis de Terraform..."
terraform -chdir=infra validate
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host "Ejecutando TFLint para errores de estilo..."
tflint infra
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host "Ejecutando Checkov para escaneo de seguridad..."
checkov -d infra --framework terraform
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host "✅ TODAS LAS VALIDACIONES PASARON CORRECTAMENTE"