// Servidor web de ReportaCalle: recibe reportes de la app y los guarda en PostgreSQL
const express = require('express');
const cors = require('cors');
const pool = require('./db');

const app = express();
app.use(cors());
app.use(express.json({ limit: '10mb' })); // para leer el JSON (la foto viaja dentro, por eso el límite)

const ESTADOS = ['Pendiente', 'Resuelto'];

// Revisa que los datos del reporte sean válidos (reglas de negocio)
function validar(r) {
  if (!r.tipo || typeof r.tipo !== 'string') return 'El tipo es obligatorio';
  if (!r.descripcion || !String(r.descripcion).trim()) return 'La descripción es obligatoria';
  if (!r.fecha) return 'La fecha es obligatoria';
  if (r.urgencia != null) {
    const u = Number(r.urgencia);
    if (!Number.isInteger(u) || u < 1 || u > 5) return 'La urgencia debe estar entre 1 y 5';
  }
  if (r.referencia != null && String(r.referencia).length > 80) return 'La referencia es muy larga (máx. 80)';
  if (r.estado != null && !ESTADOS.includes(r.estado)) return 'El estado debe ser Pendiente o Resuelto';
  return null; // null = todo bien
}

// GET /api/reportes -> lista todos los reportes (los más nuevos primero)
// No mandamos la foto aquí (pesa mucho); solo avisamos si tiene (tiene_foto).
app.get('/api/reportes', async (req, res) => {
  try {
    const r = await pool.query(
      `SELECT id, tipo, descripcion, fecha, estado, latitud, longitud, urgencia, referencia,
              peligroso, to_char(fecha_visto, 'YYYY-MM-DD') AS fecha_visto,
              (foto IS NOT NULL) AS tiene_foto
       FROM reportes ORDER BY id DESC`); // to_char = la fecha sale como texto simple
    res.json(r.rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Error al consultar la base de datos' });
  }
});

// GET /api/reportes/:id/foto -> regresa la foto como imagen
app.get('/api/reportes/:id/foto', async (req, res) => {
  try {
    const r = await pool.query('SELECT foto FROM reportes WHERE id = $1', [req.params.id]);
    if (r.rowCount === 0 || !r.rows[0].foto) return res.status(404).json({ error: 'Sin foto' });
    res.type('image/jpeg').send(r.rows[0].foto);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Error al consultar la base de datos' });
  }
});

// POST /api/reportes -> guarda un reporte nuevo (con su foto si la trae)
app.post('/api/reportes', async (req, res) => {
  const d = req.body;
  const error = validar(d);
  if (error) return res.status(400).json({ error });
  try {
    // La foto llega como texto base64; la volvemos bytes para guardarla en la BD
    const foto = d.foto_base64 ? Buffer.from(d.foto_base64, 'base64') : null;
    const r = await pool.query(
      `INSERT INTO reportes
        (tipo, descripcion, fecha, estado, latitud, longitud, urgencia, referencia,
         peligroso, fecha_visto, foto)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11) RETURNING id`,
      [d.tipo, d.descripcion, d.fecha, d.estado || 'Pendiente', d.latitud ?? null,
       d.longitud ?? null, d.urgencia ?? 3, d.referencia || null, d.peligroso === true,
       d.fecha_visto ?? null, foto]
    );
    res.status(201).json({ id: r.rows[0].id });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Error al guardar en la base de datos' });
  }
});

// PUT /api/reportes/:id/estado -> cambia a Pendiente o Resuelto
app.put('/api/reportes/:id/estado', async (req, res) => {
  const { estado } = req.body;
  if (!ESTADOS.includes(estado)) {
    return res.status(400).json({ error: 'El estado debe ser Pendiente o Resuelto' });
  }
  try {
    const r = await pool.query('UPDATE reportes SET estado = $1 WHERE id = $2 RETURNING id',
      [estado, req.params.id]);
    if (r.rowCount === 0) return res.status(404).json({ error: 'No existe ese reporte' });
    res.json({ id: r.rows[0].id, estado });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Error al actualizar la base de datos' });
  }
});

const puerto = process.env.PORT || 3000;
// '0.0.0.0' para que el emulador (10.0.2.2) pueda entrar
app.listen(puerto, '0.0.0.0', () => console.log(`Servidor listo en http://localhost:${puerto}`));
