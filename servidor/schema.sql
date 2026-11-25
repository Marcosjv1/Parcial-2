-- Script de la base de datos de ReportaCalle (PostgreSQL)
-- Se corre una vez: psql -U postgres -f schema.sql

-- Crea la base (si ya existe, esta línea marca error y se puede ignorar)
CREATE DATABASE reportacalle;

\c reportacalle

-- Tabla donde se guardan los reportes que manda la app
CREATE TABLE IF NOT EXISTS reportes (
    id           SERIAL PRIMARY KEY,
    tipo         VARCHAR(50)  NOT NULL,
    descripcion  TEXT         NOT NULL,
    fecha        VARCHAR(40)  NOT NULL,
    estado       VARCHAR(30)  NOT NULL DEFAULT 'Pendiente',
    latitud      DOUBLE PRECISION,
    longitud     DOUBLE PRECISION,
    urgencia     SMALLINT     NOT NULL DEFAULT 3 CHECK (urgencia BETWEEN 1 AND 5),
    referencia   VARCHAR(80),
    peligroso    BOOLEAN      NOT NULL DEFAULT FALSE,
    fecha_visto  DATE,
    foto         BYTEA,
    creado_en    TIMESTAMP    NOT NULL DEFAULT NOW()
);
