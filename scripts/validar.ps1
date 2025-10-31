@echo off
echo === EJECUTANDO VALIDACIONES OBLIGATORIAS ===
echo.

echo Formateando codigo Terraform...
terraform -chdir=infra fmt

echo Validando sintaxis de Terraform...
terraform -chdir=infra validate
if %errorlevel% neq 0 goto error

echo Ejecutando TFLint para errores de estilo...
tflint --chdir=infra
if %errorlevel% neq 0 goto error

echo Ejecutando Checkov para escaneo de seguridad...
checkov -d infra --framework terraform
if %errorlevel% neq 0 goto error

echo ✅ TODAS LAS VALIDACIONES PASARON CORRECT Estudiantes
goto end

:error
echo ❌ ERROR: Corregir problemas antes de continuar
pause
exit /b 1

:end
pause