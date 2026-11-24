// Servidor web de ReportaCalle: recibe reportes de la app y los guarda en PostgreSQL
const express = require('express');
const cors = require('cors');
const pool = require('./db');

const app = express();
app.use(cors());
app.use(express.json()); // para leer el JSON que manda la app

// Revisa que los datos del reporte sean válidos (regla de negocio)
function validar(r) {
  if (!r.tipo || typeof r.tipo !== 'string') return 'El tipo es obligatorio';
  if (!r.descripcion || !String(r.descripcion).trim()) return 'La descripción es obligatoria';
  if (!r.fecha) return 'La fecha es obligatoria';
  if (r.tamano_cm != null) {
    const t = Number(r.tamano_cm);
    if (!Number.isInteger(t) || t < 1 || t > 1000) return 'El tamaño debe estar entre 1 y 1000 cm';
  }
  return null; // null = todo bien
}

// GET /api/reportes -> lista todos los reportes (los más nuevos primero)
app.get('/api/reportes', async (req, res) => {
  try {
    const r = await pool.query(
      `SELECT id, tipo, descripcion, fecha, estado, latitud, longitud, tamano_cm, peligroso,
              to_char(fecha_visto, 'YYYY-MM-DD') AS fecha_visto
       FROM reportes ORDER BY id DESC`) // to_char = la fecha sale como texto simple;
    res.json(r.rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Error al consultar la base de datos' });
  }
});

// POST /api/reportes -> guarda un reporte nuevo
app.post('/api/reportes', async (req, res) => {
  const d = req.body;
  const error = validar(d);
  if (error) return res.status(400).json({ error });
  try {
    const r = await pool.query(
      `INSERT INTO reportes
        (tipo, descripcion, fecha, estado, latitud, longitud, tamano_cm, peligroso, fecha_visto)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) RETURNING id`,
      [d.tipo, d.descripcion, d.fecha, d.estado || 'Pendiente', d.latitud ?? null,
       d.longitud ?? null, d.tamano_cm ?? null, d.peligroso === true, d.fecha_visto ?? null]
    );
    res.status(201).json({ id: r.rows[0].id });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Error al guardar en la base de datos' });
  }
});

const puerto = process.env.PORT || 3000;
// '0.0.0.0' para que el emulador (10.0.2.2) pueda entrar
app.listen(puerto, '0.0.0.0', () => console.log(`Servidor listo en http://localhost:${puerto}`));
