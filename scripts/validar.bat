@echo off
echo === EJECUTANDO VALIDACIONES OBLIGATORIAS ===
echo.

echo Formateando codigo Terraform...
terraform -chdir=infra fmt

echo Validando sintaxis de Terraform...
terraform -chdir=infra validate
if %errorlevel% neq 0 goto error

echo.
echo Ejecutando TFLint para errores de estilo...
where tflint >nul 2>&1
if %errorlevel% equ 0 (
    tflint --chdir=infra
    if %errorlevel% neq 0 goto error
) else (
    echo ⚠️ TFLint no esta instalado. Omitiendo esta validacion.
)

echo.
echo Ejecutando Checkov para escaneo de seguridad...
where checkov >nul 2>&1
if %errorlevel% equ 0 (
    checkov -d infra --framework terraform
    if %errorlevel% neq 0 goto error
) else (
    echo ⚠️ Checkov no esta instalado. Omitiendo esta validacion.
)

echo.
echo ✅ TODAS LAS VALIDACIONES DISPONIBLES PASARON CORRECTAMENTE
goto end

:error
echo.
echo ❌ ERROR: Corregir problemas antes de continuar
pause
exit /b 1

:end
pause