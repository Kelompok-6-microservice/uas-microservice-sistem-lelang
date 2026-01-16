FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy seluruh kode
COPY . .

EXPOSE 3000

# Jalankan aplikasi (pastikan di package.json sudah ada start script atau tunjuk file utama)
CMD ["node", "index.js"]