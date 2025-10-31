# Usa la imagen de Node.js 22-alpine como base
FROM node:22-alpine

# Establece el directorio de trabajo en la imagen
WORKDIR /app

# Copia el archivo package.json a la imagen
COPY package.json .

# Instala las dependencias del proyecto
RUN npm install --production

# Copia el resto del proyecto a la imagen
COPY . .

# Exponer el puerto 3000
EXPOSE 3000

# Ejecuta el comando para iniciar el servidor
CMD ["npm", "start"]