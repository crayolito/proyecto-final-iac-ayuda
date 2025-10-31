# Microservicio Node.js con Docker y AWS EC2

Aplicación HTTP desarrollada en Node.js (Express) con despliegue automatizado en Amazon Web Services mediante infraestructura como código (Terraform) y pipeline CI/CD (GitHub Actions).

## Características principales

- **Aplicación**: Microservicio REST API con Node.js y Express
- **Contenedorización**: Docker con imagen optimizada Alpine Linux
- **Infraestructura**: AWS EC2 gestionada con Terraform
- **CI/CD**: Pipeline automatizado con GitHub Actions
- **Distribución**: Publicación automática en Docker Hub
- **Despliegue**: Automatización SSH para instancias EC2

## Arquitectura del proyecto

```
proyecto-ing-final/
├── app/                          # Aplicación Node.js
│   ├── app.js                   # Lógica principal de la aplicación
│   ├── server.js                # Servidor HTTP
│   ├── package.json             # Dependencias y scripts
│   └── Dockerfile               # Configuración del contenedor
├── infra/                       # Infraestructura como código
│   ├── main.tf                  # Recursos AWS principales
│   ├── variables.tf             # Variables de Terraform
│   └── output.tf                # Outputs de la infraestructura
└── .github/workflows/           # Automatización CI/CD
    └── ci-cd.yml               # Pipeline de GitHub Actions
```

## Requisitos del sistema

### Software necesario

- **AWS CLI** configurado con credenciales válidas
- **Terraform** versión 1.5.0 o superior
- **Docker** y cuenta en Docker Hub
- **Node.js** versión 18 o superior
- **Git** y acceso a GitHub

### Credenciales requeridas

- Perfil AWS con permisos para EC2, VPC y Security Groups
- Token de acceso para Docker Hub
- Par de llaves SSH para acceso a instancias EC2

## Configuración inicial

### 1. Generación de llaves SSH

**Windows (PowerShell):**

```powershell
ssh-keygen -t rsa -b 4096 -C "usuario@dominio.com"
```

**Linux/macOS (Terminal):**

```bash
ssh-keygen -t rsa -b 4096 -C "usuario@dominio.com"
```

### 2. Configuración de Secrets en GitHub

Navega a **Settings → Secrets and variables → Actions** y configura:

| Secret               | Descripción                                       |
| -------------------- | ------------------------------------------------- |
| `DOCKERHUB_USERNAME` | Usuario de Docker Hub                             |
| `DOCKERHUB_TOKEN`    | Token de acceso de Docker Hub                     |
| `EC2_SSH_KEY`        | Contenido de la llave privada SSH                 |
| `EC2_HOST`           | IP pública de la instancia EC2                    |
| `APP_PORT`           | Puerto de la aplicación (opcional, default: 3000) |

## Despliegue de infraestructura

### Variables de Terraform

| Variable         | Tipo   | Descripción                         | Valor por defecto        |
| ---------------- | ------ | ----------------------------------- | ------------------------ |
| `project_name`   | string | Nombre del proyecto para etiquetado | `pruebas-cicd-crayolito` |
| `region`         | string | Región de AWS                       | `us-east-1`              |
| `admin_cidr_ssh` | string | CIDR autorizado para SSH/HTTP       | `0.0.0.0/0`              |
| `public_ssh_key` | string | Contenido de la llave pública SSH   | Requerido                |

### Comandos de despliegue

**Windows (PowerShell):**

```powershell
cd infra
$llave = (Get-Content $env:USERPROFILE\.ssh\id_rsa.pub -Raw).Replace("`n","").Replace("`r","")
terraform init
terraform apply -var="public_ssh_key=$llave"
```

**Linux/macOS (Terminal):**

```bash
cd infra
terraform init
terraform apply -var="public_ssh_key=$(cat ~/.ssh/id_rsa.pub)"
```

### Outputs de infraestructura

Terraform proporcionará las siguientes salidas:

- `ec2_public_ip`: Dirección IP pública de la instancia
- `ec2_public_dns`: Nombre DNS público de la instancia

## Desarrollo local

### Ejecución de la aplicación

```bash
cd app
npm install
npm start
```

La aplicación estará disponible en `http://localhost:3000`

### Verificación del servicio

```bash
curl http://localhost:3000/
```

### Ejecución de pruebas

```bash
npm test
```

## Contenedorización

### Construcción local

```bash
cd app
docker build -t demo-microservice-lab:local .
docker run -d --name demo-microservice-lab -p 3000:3000 demo-microservice-lab:local
```

### Especificaciones del contenedor

- **Imagen base**: `node:22-alpine`
- **Puerto expuesto**: `3000`
- **Comando de inicio**: `npm start`
- **Optimizaciones**: Imagen multi-stage para reducir tamaño

## Pipeline CI/CD

### Flujo de integración continua

1. **Análisis de código**: Checkout del repositorio
2. **Configuración**: Node.js versión 18
3. **Dependencias**: Instalación de paquetes npm
4. **Pruebas**: Ejecución de test suite
5. **Construcción**: Build de imagen Docker
6. **Publicación**: Push a Docker Hub con tag `latest`

### Flujo de despliegue continuo

1. **Autenticación**: Configuración de agente SSH
2. **Conexión**: Verificación de acceso a instancia EC2
3. **Preparación**: Configuración de Docker y red `appnet`
4. **Actualización**: Pull de imagen desde Docker Hub
5. **Despliegue**: Lanzamiento de contenedor con mapeo de puertos

### Mapeo de puertos

- **Host EC2**: Puerto 80 (acceso público)
- **Contenedor**: Puerto 3000 (aplicación Node.js)

## Configuración de seguridad

### Security Group (AWS)

| Protocolo | Puerto | Origen           | Propósito              |
| --------- | ------ | ---------------- | ---------------------- |
| SSH       | 22     | `admin_cidr_ssh` | Administración remota  |
| HTTP      | 80     | `admin_cidr_ssh` | Acceso a la aplicación |

### Recomendaciones de seguridad

- Restringir `admin_cidr_ssh` a rangos IP específicos
- Utilizar HTTPS en entornos de producción
- Implementar autenticación por llaves SSH únicamente
- Mantener el sistema operativo y Docker actualizados
- Nunca exponer llaves privadas en repositorios

## Gestión de entornos

### Entornos recomendados

- **development**: Desarrollo activo con datos de prueba
- **staging**: Ambiente de preproducción con datos realistas
- **production**: Entorno de producción con datos reales

### Mejores prácticas

- Separar variables y secretos por entorno
- Utilizar diferentes valores de `admin_cidr_ssh` según el entorno
- Implementar versionado semántico para imágenes Docker
- Configurar monitoreo y alertas para producción

## Resolución de problemas

### Conexión SSH fallida

**Síntomas**: El pipeline falla en la etapa de despliegue
**Soluciones**:

- Verificar formato de `EC2_SSH_KEY` (sin espacios adicionales)
- Confirmar que `EC2_HOST` es accesible
- Validar reglas del Security Group para SSH

### Contenedor no inicia

**Síntomas**: El servicio no responde después del despliegue
**Soluciones**:

- Revisar logs: `docker logs demo-microservice-lab`
- Verificar que `APP_PORT` coincide con la configuración
- Confirmar que la imagen se descargó correctamente

### Servicio no accesible

**Síntomas**: No se puede acceder al servicio vía HTTP
**Soluciones**:

- Verificar mapeo de puertos: `80:3000`
- Revisar reglas del Security Group para HTTP
- Confirmar que el contenedor está ejecutándose

### Comandos de diagnóstico

```bash
# Verificar estado del contenedor
docker ps -a

# Revisar logs de la aplicación
docker logs demo-microservice-lab

# Verificar conectividad
curl http://<EC2_PUBLIC_IP>/

# Acceso SSH para diagnóstico
ssh -i ~/.ssh/id_rsa ec2-user@<EC2_PUBLIC_IP>
```

## Limpieza de recursos

Para evitar costos innecesarios, destruir la infraestructura cuando no se requiera:

```bash
cd infra
terraform destroy -var="public_ssh_key=$(cat ~/.ssh/id_rsa.pub)"
```

## Contribución

1. Fork del repositorio
2. Crear rama para nueva funcionalidad: `git checkout -b feature/nueva-funcionalidad`
3. Realizar cambios y commit: `git commit -am 'Agregar nueva funcionalidad'`
4. Push a la rama: `git push origin feature/nueva-funcionalidad`
5. Crear Pull Request
