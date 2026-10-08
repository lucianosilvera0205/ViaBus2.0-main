-- Estas columnas ya están incluidas directamente en la tabla `empresas`
-- dentro de schema.sql (junto con los datos reales de cada empresa), así
-- que este archivo queda obsoleto. Se deja solo como referencia histórica;
-- no hace falta correrlo (y si la base ya tiene estas columnas, fallaría
-- por columna duplicada).

-- ALTER TABLE empresas ADD COLUMN telefono VARCHAR(30);
-- ALTER TABLE empresas ADD COLUMN email VARCHAR(100);
-- ALTER TABLE empresas ADD COLUMN sitio_web VARCHAR(150);
-- ALTER TABLE empresas ADD COLUMN direccion VARCHAR(150);
