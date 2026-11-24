// Conexión a PostgreSQL con un "pool" (varias conexiones reutilizables)
require('dotenv').config(); // lee las variables del archivo .env
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: Number(process.env.DB_PORT) || 5432,
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME || 'reportacalle',
});

module.exports = pool;
