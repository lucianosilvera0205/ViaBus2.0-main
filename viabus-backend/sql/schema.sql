-- =============================================================
--  ViaBus - Base de Datos (PostgreSQL)
--  Generado a partir de los datos reales del frontend
-- =============================================================

-- Función auxiliar para actualizar automáticamente "updated_at" en cada UPDATE.
CREATE OR REPLACE FUNCTION set_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TABLE IF EXISTS reservas;
DROP TABLE IF EXISTS pasajeros;
DROP TABLE IF EXISTS estado_diario;
DROP TABLE IF EXISTS servicios;
DROP TABLE IF EXISTS ciudades;
DROP TABLE IF EXISTS empresas;
DROP TABLE IF EXISTS usuarios;


CREATE TABLE empresas (
    id          SERIAL PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL UNIQUE,
    logo        VARCHAR(255) DEFAULT NULL,
    descripcion TEXT DEFAULT NULL,
    telefono    VARCHAR(30)  DEFAULT NULL,
    email       VARCHAR(100) DEFAULT NULL,
    sitio_web   VARCHAR(150) DEFAULT NULL,
    direccion   VARCHAR(150) DEFAULT NULL,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Usuarios de la plataforma: clientes (compran pasajes) y administradores
-- (gestionan viajes desde el panel de administrador).
CREATE TABLE usuarios (
    id             SERIAL PRIMARY KEY,
    nombre         VARCHAR(100) NOT NULL,
    apellido       VARCHAR(100) NOT NULL,
    email          VARCHAR(150) NOT NULL UNIQUE,
    password_hash  VARCHAR(255) NOT NULL,
    rol            VARCHAR(20) NOT NULL DEFAULT 'cliente' CHECK(rol IN ('cliente','admin')),
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ciudades (
    id          SERIAL PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL UNIQUE,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE servicios (
    id          SERIAL PRIMARY KEY,
    origen_id   INTEGER NOT NULL,
    destino_id  INTEGER NOT NULL,
    empresa_id  INTEGER NOT NULL,
    hora        VARCHAR(5) NOT NULL,
    tipo        VARCHAR(80) NOT NULL DEFAULT 'De Linea',
    duracion    VARCHAR(50) DEFAULT NULL,
    precio      DECIMAL(10,2) DEFAULT NULL,
    asientos    INTEGER DEFAULT 40,
    anden       VARCHAR(10) DEFAULT NULL,
    bus         VARCHAR(30) DEFAULT NULL,
    estado      VARCHAR(20) DEFAULT 'horario',
    activo      INTEGER DEFAULT 1,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (origen_id)  REFERENCES ciudades(id),
    FOREIGN KEY (destino_id) REFERENCES ciudades(id),
    FOREIGN KEY (empresa_id) REFERENCES empresas(id)
);

CREATE TABLE pasajeros (
    id          SERIAL PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,
    apellido    VARCHAR(100) NOT NULL,
    documento   VARCHAR(20)  NOT NULL UNIQUE,
    email       VARCHAR(150) DEFAULT NULL,
    telefono    VARCHAR(30)  DEFAULT NULL,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Estado "en vivo" del tablero para cada servicio y cada día.
-- Solo guarda lo que un operador cambia a mano (la demora); todo lo demás
-- (embarcando / en horario / ya salió) se calcula solo comparando la hora
-- del servicio contra la hora actual.
CREATE TABLE estado_diario (
    id          SERIAL PRIMARY KEY,
    servicio_id INTEGER NOT NULL,
    fecha       DATE NOT NULL,
    demorado    INTEGER NOT NULL DEFAULT 0,
    updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (servicio_id) REFERENCES servicios(id),
    UNIQUE (servicio_id, fecha)
);

CREATE TABLE reservas (
    id              SERIAL PRIMARY KEY,
    servicio_id     INTEGER NOT NULL,
    pasajero_id     INTEGER NOT NULL,
    usuario_id      INTEGER DEFAULT NULL,
    fecha_viaje     DATE NOT NULL,
    asiento         INTEGER NOT NULL,
    estado          VARCHAR(20) DEFAULT 'pendiente' CHECK(estado IN ('pendiente','confirmada','cancelada')),
    estado_pago     VARCHAR(20) DEFAULT 'pendiente' CHECK(estado_pago IN ('pendiente','pagado','rechazado','cancelado')),
    total           DECIMAL(10,2) DEFAULT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (servicio_id) REFERENCES servicios(id),
    FOREIGN KEY (pasajero_id) REFERENCES pasajeros(id),
    FOREIGN KEY (usuario_id)  REFERENCES usuarios(id),
    UNIQUE (servicio_id, fecha_viaje, asiento)
);

CREATE TRIGGER trg_reservas_updated_at
BEFORE UPDATE ON reservas
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- Pagos (Mercado Pago). Una reserva tiene, como mucho, un pago asociado.
CREATE TABLE pagos (
    id                          SERIAL PRIMARY KEY,
    reserva_id                  INTEGER NOT NULL UNIQUE,
    mercadopago_preference_id   VARCHAR(255),
    mercadopago_payment_id      VARCHAR(255),
    estado                      VARCHAR(20) DEFAULT 'pendiente' CHECK(estado IN ('pendiente','pagado','rechazado','cancelado')),
    monto                       DECIMAL(10,2),
    respuesta_mp                TEXT,
    created_at                  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at                  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reserva_id) REFERENCES reservas(id)
);

CREATE TRIGGER trg_pagos_updated_at
BEFORE UPDATE ON pagos
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- Empresas
INSERT INTO empresas (nombre, logo, descripcion, telefono, email, sitio_web, direccion) VALUES
    ('Decatur', 'Decatur-logo.jpg', 'Decatur es una empresa de transporte de pasajeros y agencia de viajes ubicada en Melo, Cerro Largo. Fue fundada en 1992 por Dardo Rodríguez Realan y cuenta con más de 30 años de trayectoria. Actualmente conecta localidades como Melo, Río Branco, Aceguá, Lago Merín y Fraile Muerto, además de ofrecer excursiones y otros servicios turísticos. Con el paso de los años, se ha consolidado como una de las empresas de transporte más reconocidas del departamento.', '4642 4877', 'decatur@adinet.com.uy', NULL, 'Ansina 330, Melo, Cerro Largo'),
    ('Ega', 'Ega-logo.jpg', 'EGA es una empresa uruguaya de transporte de pasajeros y turismo. Sus orígenes se remontan a 1979 y creció gracias a la fusión con Keguay S.R.L. en 1990. Actualmente realiza viajes nacionales e internacionales, conecta Uruguay con varios países de Sudamérica y es reconocida por la modernización de su flota y la comodidad de sus servicios.', '4642 0505', 'comercial@ega.com.uy', 'www.ega.com.uy', 'Terminal de Ómnibus de Melo, Cerro Largo'),
    ('La Flotta', 'Laflota-logo.jpg', 'La Flota es una empresa de transporte de pasajeros con sede en la ciudad de Melo, departamento de Cerro Largo. Brinda servicios de ómnibus que conectan Melo con localidades como Río Branco, Aceguá, Fraile Muerto, Laguna Merín y Santa Clara de Olimar. No existe información pública sobre la fecha exacta de su fundación ni sobre quién fue su fundador, pero es una empresa reconocida en la región por su importante papel en el transporte departamental..', '4642 7668', NULL, NULL, 'Terminal de Ómnibus de Melo, Cerro Largo'),
    ('Nuñez', 'Nunez-logo.jpg', 'Nuñez Transporte y Turismo es una empresa uruguaya fundada en 1964 en Melo por Diomar Gregorio Núñez Pereira. Comenzó con recorridos regionales en Cerro Largo y luego se extendió a todo el país. En 1979 inauguró la línea Melo–Montevideo y en 1990 adquirió Viajes Cynsa. Actualmente es una de las principales empresas de transporte de pasajeros y encomiendas de Uruguay.', '4642 2566', NULL, 'www.nunez.com.uy', 'Manuela Lestido S/N, Melo, Cerro Largo'),
    ('Posada', 'Posada-logo.jpg', 'Posada es una empresa familiar de transporte de pasajeros fundada en 1993. Actualmente es dirigida por los hermanos Diego y Daniel Posada y tiene su base en Cerro Largo. Se especializa en rutas de corta y mediana distancia, conectando localidades como Melo y Aceguá, además de brindar enlaces con las terminales de Tacuarembó y Rivera.', '4642 0302', NULL, NULL, 'Terminal de Ómnibus de Melo, Cerro Largo'),
    ('Turismar', 'Turismar-logo.jpg', 'Turismar es una empresa de transporte uruguayo fundada en 1976. Comenzó realizando viajes entre Montevideo y Durazno y con el tiempo amplió sus servicios a varias rutas del país. Actualmente transporta pasajeros y encomiendas, siendo una de las empresas más importantes del transporte interdepartamental en Uruguay.', '4642 5214', NULL, 'www.turismar.com.uy', 'Terminal de Ómnibus de Melo, Cerro Largo'),
    ('Unitur', 'Unitur-logo.jpg', 'Unitur es una empresa de transporte de pasajeros, turismo y encomiendas que opera en el este de Uruguay desde comienzos de los años 2000. Su propietario es Alcides Pereda y la empresa se ha destacado por mejorar la conectividad entre distintas localidades. Actualmente conecta ciudades como Melo, Río Branco, Aceguá y Santa Clara de Olimar mediante frecuencias diarias y servicios regulares.', '4643 1233', NULL, NULL, 'Melo, Cerro Largo');
    
-- Ciudades
INSERT INTO ciudades (nombre) VALUES
    ('Aceguá'),
    ('Batlle y Ordóñez'),
    ('Casupá'),
    ('Cerro Chato'),
    ('Cerro Colorado'),
    ('Fraile Muerto'),
    ('José Pedro Varela'),
    ('Lago Merín'),
    ('Maldonado'),
    ('Mariscala'),
    ('Melo'),
    ('Minas'),
    ('Montevideo'),
    ('Pando'),
    ('Punta del Este'),
    ('Rio Branco'),
    ('Rivera'),
    ('San Ramón'),
    ('Santa Clara'),
    ('Tacuarembó'),
    ('Treinta y Tres'),
    ('Tupambaé');

-- Inserta los servicios y viajes disponibles en la aplicación. 
-- Cada registro representa un viaje con su origen, destino, empresa y horario. INSERT INTO servicios (origen_id, destino_id, empresa_id, hora, tipo, duracion, precio, asientos, anden, bus, estado) VALUES
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Punta del Este'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'00:30','De Linea','5h 00m',540.0,39,'A-01','MELPUN-9174','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Montevideo'),(SELECT id FROM empresas WHERE nombre='Ega'),'12:30','De Linea','5h 44m',610.0,33,'A-02','MELMON-4212','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Montevideo'),(SELECT id FROM empresas WHERE nombre='Ega'),'17:00','De Linea','5h 44m',610.0,35,'A-03','MELMON-5338','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Montevideo'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'18:00','De Linea','5h 44m',610.0,40,'A-04','MELMON-9454','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Montevideo'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'23:00','De Linea','5h 44m',610.0,36,'A-01','MELMON-6088','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Treinta y Tres'),(SELECT id FROM empresas WHERE nombre='Ega'),'12:30','De Linea','1h 28m',220.0,33,'A-02','MELTRE-3408','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Treinta y Tres'),(SELECT id FROM empresas WHERE nombre='Ega'),'17:00','De Linea','1h 28m',220.0,34,'A-03','MELTRE-6030','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Treinta y Tres'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'18:00','De Linea','1h 28m',220.0,44,'A-04','MELTRE-7987','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Treinta y Tres'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'14:30','De Linea','1h 28m',220.0,37,'A-01','MELTRE-2897','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Minas'),(SELECT id FROM empresas WHERE nombre='Ega'),'12:30','De Linea','3h 14m',380.0,39,'A-02','MELMIN-1111','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Minas'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'14:30','De Linea','3h 14m',380.0,41,'A-03','MELMIN-9787','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Minas'),(SELECT id FROM empresas WHERE nombre='Ega'),'17:00','De Linea','3h 14m',380.0,37,'A-04','MELMIN-4607','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Rivera'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'14:00','De Linea','3h 14m',380.0,42,'A-01','MELRIV-7113','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Rio Branco'),(SELECT id FROM empresas WHERE nombre='La Flotta'),'14:00','De Linea','1h 19m',200.0,44,'A-02','MELRIO-4752','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Rio Branco'),(SELECT id FROM empresas WHERE nombre='La Flotta'),'18:00','De Linea','1h 19m',200.0,33,'A-03','MELRIO-1899','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Maldonado'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'00:30','De Linea','4h 42m',510.0,44,'A-04','MELMAL-9810','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Rivera'),(SELECT id FROM empresas WHERE nombre='Posada'),'04:30','De Linea','3h 14m',380.0,44,'A-01','MELRIV-4362','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Rivera'),(SELECT id FROM empresas WHERE nombre='Posada'),'10:00','De Linea','3h 14m',380.0,33,'A-02','MELRIV-2247','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Rivera'),(SELECT id FROM empresas WHERE nombre='Posada'),'15:30','De Linea','3h 14m',380.0,34,'A-03','MELRIV-7680','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Rivera'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Posada'),'06:45','De Linea','3h 14m',380.0,43,'A-04','RIVMEL-7640','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Rivera'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Posada'),'13:45','De Linea','3h 14m',380.0,44,'A-01','RIVMEL-5569','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Rivera'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Posada'),'17:00','De Linea','3h 14m',380.0,38,'A-02','RIVMEL-8704','demorado'),
   
   -- Servicios entre Melo y Tacuarembó.
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Tacuarembó'),(SELECT id FROM empresas WHERE nombre='Posada'),'06:45','De Linea','2h 39m',320.0,33,'A-03','MELTAC-4531','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Tacuarembó'),(SELECT id FROM empresas WHERE nombre='Posada'),'13:45','De Linea','2h 39m',320.0,35,'A-04','MELTAC-8592','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Tacuarembó'),(SELECT id FROM empresas WHERE nombre='Posada'),'17:00','De Linea','2h 39m',320.0,35,'A-01','MELTAC-3450','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Tacuarembó'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Posada'),'06:30','De Linea','2h 39m',320.0,32,'A-02','TACMEL-3239','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Tacuarembó'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Posada'),'12:00','De Linea','2h 39m',320.0,35,'A-03','TACMEL-3350','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Tacuarembó'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Posada'),'17:30','De Linea','2h 39m',320.0,41,'A-04','TACMEL-8144','demorado'),
    
    -- Servicios entre Melo y Santa Clara.
    ((SELECT id FROM ciudades WHERE nombre='Santa Clara'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Unitur'),'07:40','De Linea','1h 28m',220.0,39,'A-01','SANMEL-8629','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Santa Clara'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Unitur'),'08:45','De Linea','1h 28m',220.0,43,'A-02','SANMEL-3511','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Santa Clara'),(SELECT id FROM empresas WHERE nombre='Unitur'),'17:00','De Linea','1h 28m',220.0,37,'A-03','MELSAN-7792','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Santa Clara'),(SELECT id FROM empresas WHERE nombre='Unitur'),'20:10','De Linea','1h 28m',220.0,40,'A-04','MELSAN-3057','horario'),
    
    -- Servicios entre Melo y Aceguá.
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Aceguá'),(SELECT id FROM empresas WHERE nombre='Unitur'),'10:30','De Linea','26m',120.0,35,'A-01','MELACE-3168','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Aceguá'),(SELECT id FROM empresas WHERE nombre='Unitur'),'12:30','De Linea','26m',120.0,40,'A-02','MELACE-5070','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Aceguá'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Unitur'),'15:30','De Linea','26m',120.0,36,'A-03','ACEMEL-9587','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Aceguá'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Unitur'),'19:30','De Linea','26m',120.0,40,'A-04','ACEMEL-1748','embarcando'),
    
    --Servicios entre Melo y Rio Branco.
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Rio Branco'),(SELECT id FROM empresas WHERE nombre='Unitur'),'11:00','De Linea','1h 19m',200.0,35,'A-01','MELRIO-8172','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Rio Branco'),(SELECT id FROM empresas WHERE nombre='Unitur'),'10:00','De Linea','1h 19m',200.0,39,'A-02','MELRIO-3043','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Rio Branco'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Unitur'),'17:30','De Linea','1h 19m',200.0,33,'A-03','RIOMEL-5093','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Rio Branco'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Unitur'),'23:30','De Linea','1h 19m',200.0,38,'A-04','RIOMEL-8632','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Rio Branco'),(SELECT id FROM empresas WHERE nombre='Decatur'),'06:00','De Linea','1h 19m',200.0,32,'A-01','MELRIO-7443','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Rio Branco'),(SELECT id FROM empresas WHERE nombre='Decatur'),'07:00','De Linea','1h 19m',200.0,36,'A-02','MELRIO-5089','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Rio Branco'),(SELECT id FROM empresas WHERE nombre='Decatur'),'10:30','De Linea','1h 19m',200.0,44,'A-03','MELRIO-9809','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Rio Branco'),(SELECT id FROM empresas WHERE nombre='Decatur'),'12:00','De Linea','1h 19m',200.0,32,'A-04','MELRIO-4755','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Rio Branco'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Decatur'),'09:00','De Linea','1h 19m',200.0,43,'A-01','RIOMEL-3106','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Rio Branco'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Decatur'),'12:15','De Linea','1h 19m',200.0,35,'A-02','RIOMEL-9035','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Rio Branco'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Decatur'),'15:00','De Linea','1h 19m',200.0,41,'A-03','RIOMEL-5602','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Rio Branco'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Decatur'),'17:00','De Linea','1h 19m',200.0,44,'A-04','RIOMEL-4057','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Lago Merín'),(SELECT id FROM empresas WHERE nombre='Decatur'),'07:00','De Linea','53m',160.0,36,'A-01','MELLAG-1867','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Lago Merín'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Decatur'),'11:00','De Linea','53m',160.0,42,'A-02','LAGMEL-4430','horario'),
    
    --Servicio entre Melo y Fraile Muerto
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Fraile Muerto'),(SELECT id FROM empresas WHERE nombre='Decatur'),'06:00','De Linea','26m',120.0,40,'A-03','MELFRA-5015','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Tacuarembó'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Decatur'),'19:00','De Linea','2h 39m',320.0,39,'A-04','TACMEL-5792','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Aceguá'),(SELECT id FROM empresas WHERE nombre='Decatur'),'06:45','De Linea','26m',120.0,37,'A-01','MELACE-9277','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Aceguá'),(SELECT id FROM empresas WHERE nombre='Decatur'),'11:30','De Linea','26m',120.0,43,'A-02','MELACE-4374','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Aceguá'),(SELECT id FROM empresas WHERE nombre='Decatur'),'16:00','De Linea','26m',120.0,34,'A-03','MELACE-3389','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Aceguá'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Decatur'),'08:30','De Linea','26m',120.0,34,'A-04','ACEMEL-9771','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Aceguá'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Decatur'),'14:30','De Linea','26m',120.0,34,'A-01','ACEMEL-4557','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Aceguá'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Decatur'),'18:30','De Linea','26m',120.0,37,'A-02','ACEMEL-2447','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Montevideo'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'00:30','De Linea','5h 44m',610.0,42,'A-03','MELMON-3785','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Montevideo'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'06:00','De Linea','5h 44m',610.0,39,'A-04','MELMON-9685','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Montevideo'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'10:15','De Linea','5h 44m',610.0,36,'A-01','MELMON-6321','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Montevideo'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'14:30','De Linea','5h 44m',610.0,37,'A-02','MELMON-2401','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Montevideo'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'23:45','De Linea','5h 44m',610.0,32,'A-03','MELMON-9228','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Montevideo'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'00:30','De Linea','5h 44m',610.0,38,'A-04','MONMEL-7043','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Montevideo'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'09:00','De Linea','5h 44m',610.0,41,'A-01','MONMEL-8036','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Montevideo'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'14:30','De Linea','5h 44m',610.0,35,'A-02','MONMEL-8750','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Montevideo'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'17:30','De Linea','5h 44m',610.0,36,'A-03','MONMEL-2880','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Montevideo'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'21:30','De Linea','5h 44m',610.0,38,'A-04','MONMEL-7879','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Minas'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'00:30','De Linea','3h 14m',380.0,39,'A-01','MELMIN-9719','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Minas'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'06:00','De Linea','3h 14m',380.0,37,'A-02','MELMIN-8312','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Minas'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'10:15','De Linea','3h 14m',380.0,43,'A-03','MELMIN-9735','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Minas'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'14:30','De Linea','3h 14m',380.0,40,'A-04','MELMIN-2468','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Minas'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'02:20','De Linea','3h 14m',380.0,33,'A-01','MINMEL-6408','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Minas'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'11:10','De Linea','3h 14m',380.0,36,'A-02','MINMEL-2300','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Minas'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'16:40','De Linea','3h 14m',380.0,32,'A-03','MINMEL-8029','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Minas'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'19:15','De Linea','3h 14m',380.0,39,'A-04','MINMEL-6839','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Minas'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'23:30','De Linea','3h 14m',380.0,44,'A-01','MINMEL-8965','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Mariscala'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'00:30','De Linea','2h 39m',320.0,34,'A-02','MELMAR-4738','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Mariscala'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'06:00','De Linea','2h 39m',320.0,37,'A-03','MELMAR-3451','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Mariscala'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'10:15','De Linea','2h 39m',320.0,32,'A-04','MELMAR-8246','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Mariscala'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'14:30','De Linea','2h 39m',320.0,41,'A-01','MELMAR-8654','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Mariscala'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'00:30','De Linea','2h 39m',320.0,33,'A-02','MARMEL-8190','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Mariscala'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'03:10','De Linea','2h 39m',320.0,35,'A-03','MARMEL-7091','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Mariscala'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'11:50','De Linea','2h 39m',320.0,39,'A-04','MARMEL-7080','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Mariscala'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'17:40','De Linea','2h 39m',320.0,33,'A-01','MARMEL-3323','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Mariscala'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'20:05','De Linea','2h 39m',320.0,38,'A-02','MARMEL-1528','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='José Pedro Varela'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'00:30','De Linea','2h 12m',280.0,40,'A-03','MELJOS-4128','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='José Pedro Varela'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'06:00','De Linea','2h 12m',280.0,43,'A-04','MELJOS-7167','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='José Pedro Varela'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'10:15','De Linea','2h 12m',280.0,34,'A-01','MELJOS-6078','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='José Pedro Varela'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'14:30','De Linea','2h 12m',280.0,41,'A-02','MELJOS-4873','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='José Pedro Varela'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'01:30','De Linea','2h 12m',280.0,39,'A-03','JOSMEL-1086','horario'),
    ((SELECT id FROM ciudades WHERE nombre='José Pedro Varela'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'04:10','De Linea','2h 12m',280.0,34,'A-04','JOSMEL-2555','horario'),
    ((SELECT id FROM ciudades WHERE nombre='José Pedro Varela'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'13:00','De Linea','2h 12m',280.0,44,'A-01','JOSMEL-9320','horario'),
    ((SELECT id FROM ciudades WHERE nombre='José Pedro Varela'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'18:50','De Linea','2h 12m',280.0,33,'A-02','JOSMEL-3356','horario'),
    ((SELECT id FROM ciudades WHERE nombre='José Pedro Varela'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'21:00','De Linea','2h 12m',280.0,35,'A-03','JOSMEL-6976','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Treinta y Tres'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'00:30','De Linea','1h 28m',220.0,43,'A-04','MELTRE-1434','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Treinta y Tres'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'06:00','De Linea','1h 28m',220.0,38,'A-01','MELTRE-3511','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Treinta y Tres'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'10:15','De Linea','1h 28m',220.0,44,'A-02','MELTRE-4914','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Treinta y Tres'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'14:30','De Linea','1h 28m',220.0,36,'A-03','MELTRE-5578','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Treinta y Tres'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'21:30','De Linea','1h 28m',220.0,37,'A-04','MELTRE-7927','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Treinta y Tres'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'02:00','De Linea','1h 28m',220.0,43,'A-01','TREMEL-7815','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Treinta y Tres'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'04:45','De Linea','1h 28m',220.0,42,'A-02','TREMEL-9827','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Treinta y Tres'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'13:35','De Linea','1h 28m',220.0,41,'A-03','TREMEL-1541','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Treinta y Tres'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'19:20','De Linea','1h 28m',220.0,39,'A-04','TREMEL-2867','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Treinta y Tres'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'21:40','De Linea','1h 28m',220.0,44,'A-01','TREMEL-8582','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Punta del Este'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'00:30','De Linea','5h 00m',540.0,41,'A-02','MELPUN-5847','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Punta del Este'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Nuñez'),'19:30','De Linea','5h 00m',540.0,35,'A-03','PUNMEL-8511','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Montevideo'),(SELECT id FROM empresas WHERE nombre='Ega'),'02:00','De Linea','5h 44m',610.0,41,'A-04','MELMON-4266','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Montevideo'),(SELECT id FROM empresas WHERE nombre='Ega'),'07:00','De Linea','5h 44m',610.0,36,'A-01','MELMON-5463','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Montevideo'),(SELECT id FROM empresas WHERE nombre='Ega'),'12:30','De Linea','5h 44m',610.0,40,'A-02','MELMON-3159','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Montevideo'),(SELECT id FROM empresas WHERE nombre='Ega'),'17:00','De Linea','5h 44m',610.0,40,'A-03','MELMON-7778','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Montevideo'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Ega'),'04:00','De Linea','5h 44m',610.0,41,'A-04','MONMEL-4491','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Montevideo'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Ega'),'13:30','De Linea','5h 44m',610.0,37,'A-01','MONMEL-4487','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Montevideo'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Ega'),'18:30','De Linea','5h 44m',610.0,40,'A-02','MONMEL-3000','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Montevideo'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Ega'),'23:00','De Linea','5h 44m',610.0,32,'A-03','MONMEL-6180','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Pando'),(SELECT id FROM empresas WHERE nombre='Ega'),'02:00','De Linea','5h 18m',570.0,37,'A-04','MELPAN-3703','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Pando'),(SELECT id FROM empresas WHERE nombre='Ega'),'07:00','De Linea','5h 18m',570.0,32,'A-01','MELPAN-4254','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Pando'),(SELECT id FROM empresas WHERE nombre='Ega'),'12:30','De Linea','5h 18m',570.0,39,'A-02','MELPAN-9026','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Pando'),(SELECT id FROM empresas WHERE nombre='Ega'),'17:00','De Linea','5h 18m',570.0,35,'A-03','MELPAN-8943','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Pando'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Ega'),'00:15','De Linea','5h 18m',570.0,42,'A-04','PANMEL-4547','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Pando'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Ega'),'04:45','De Linea','5h 18m',570.0,42,'A-01','PANMEL-9439','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Pando'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Ega'),'14:15','De Linea','5h 18m',570.0,40,'A-02','PANMEL-5449','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Pando'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Ega'),'19:15','De Linea','5h 18m',570.0,42,'A-03','PANMEL-9591','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Minas'),(SELECT id FROM empresas WHERE nombre='Ega'),'02:00','De Linea','3h 14m',380.0,39,'A-04','MELMIN-6310','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Minas'),(SELECT id FROM empresas WHERE nombre='Ega'),'07:00','De Linea','3h 14m',380.0,39,'A-01','MELMIN-5009','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Minas'),(SELECT id FROM empresas WHERE nombre='Ega'),'12:30','De Linea','3h 14m',380.0,36,'A-02','MELMIN-3204','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Minas'),(SELECT id FROM empresas WHERE nombre='Ega'),'17:00','De Linea','3h 14m',380.0,43,'A-03','MELMIN-1807','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Minas'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Ega'),'01:25','De Linea','3h 14m',380.0,37,'A-04','MINMEL-6884','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Minas'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Ega'),'05:45','De Linea','3h 14m',380.0,34,'A-01','MINMEL-4428','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Minas'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Ega'),'15:30','De Linea','3h 14m',380.0,39,'A-02','MINMEL-2738','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Minas'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Ega'),'20:35','De Linea','3h 14m',380.0,41,'A-03','MINMEL-9122','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Mariscala'),(SELECT id FROM empresas WHERE nombre='Ega'),'02:00','De Linea','2h 39m',320.0,41,'A-04','MELMAR-2591','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Mariscala'),(SELECT id FROM empresas WHERE nombre='Ega'),'07:00','De Linea','2h 39m',320.0,41,'A-01','MELMAR-7766','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Mariscala'),(SELECT id FROM empresas WHERE nombre='Ega'),'12:30','De Linea','2h 39m',320.0,44,'A-02','MELMAR-9278','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Mariscala'),(SELECT id FROM empresas WHERE nombre='Ega'),'17:00','De Linea','2h 39m',320.0,41,'A-03','MELMAR-9953','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Mariscala'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Ega'),'02:15','De Linea','2h 39m',320.0,33,'A-04','MARMEL-1080','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Mariscala'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Ega'),'06:35','De Linea','2h 39m',320.0,42,'A-01','MARMEL-2480','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Mariscala'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Ega'),'16:30','De Linea','2h 39m',320.0,40,'A-02','MARMEL-4847','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Mariscala'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Ega'),'21:30','De Linea','2h 39m',320.0,33,'A-03','MARMEL-4509','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='José Pedro Varela'),(SELECT id FROM empresas WHERE nombre='Ega'),'02:00','De Linea','2h 12m',280.0,41,'A-04','MELJOS-7565','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='José Pedro Varela'),(SELECT id FROM empresas WHERE nombre='Ega'),'07:00','De Linea','2h 12m',280.0,36,'A-01','MELJOS-4458','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='José Pedro Varela'),(SELECT id FROM empresas WHERE nombre='Ega'),'12:30','De Linea','2h 12m',280.0,35,'A-02','MELJOS-4734','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='José Pedro Varela'),(SELECT id FROM empresas WHERE nombre='Ega'),'17:00','De Linea','2h 12m',280.0,40,'A-03','MELJOS-2131','horario'),
    ((SELECT id FROM ciudades WHERE nombre='José Pedro Varela'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Ega'),'03:06','De Linea','2h 12m',280.0,42,'A-04','JOSMEL-5183','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='José Pedro Varela'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Ega'),'07:35','De Linea','2h 12m',280.0,36,'A-01','JOSMEL-3138','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='José Pedro Varela'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Ega'),'17:35','De Linea','2h 12m',280.0,40,'A-02','JOSMEL-8261','horario'),
    ((SELECT id FROM ciudades WHERE nombre='José Pedro Varela'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Ega'),'22:30','De Linea','2h 12m',280.0,36,'A-03','JOSMEL-9977','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Treinta y Tres'),(SELECT id FROM empresas WHERE nombre='Ega'),'02:00','De Linea','1h 28m',220.0,43,'A-04','MELTRE-5642','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Treinta y Tres'),(SELECT id FROM empresas WHERE nombre='Ega'),'07:00','De Linea','1h 28m',220.0,38,'A-01','MELTRE-5243','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Treinta y Tres'),(SELECT id FROM empresas WHERE nombre='Ega'),'12:30','De Linea','1h 28m',220.0,41,'A-02','MELTRE-3011','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Treinta y Tres'),(SELECT id FROM empresas WHERE nombre='Ega'),'17:00','De Linea','1h 28m',220.0,37,'A-03','MELTRE-4942','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Treinta y Tres'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Ega'),'03:30','De Linea','1h 28m',220.0,38,'A-04','TREMEL-9907','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Treinta y Tres'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Ega'),'08:05','De Linea','1h 28m',220.0,41,'A-01','TREMEL-1796','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Treinta y Tres'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Ega'),'17:35','De Linea','1h 28m',220.0,39,'A-02','TREMEL-2682','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Treinta y Tres'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Ega'),'22:30','De Linea','1h 28m',220.0,37,'A-03','TREMEL-3691','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Montevideo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'13:30','De Linea','5h 44m',610.0,44,'A-04','MELMON-3839','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Montevideo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'02:15','De Linea','5h 44m',610.0,37,'A-01','MELMON-1257','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Montevideo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'18:00','De Linea','5h 44m',610.0,38,'A-02','MELMON-9799','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Montevideo'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'14:30','De Linea','5h 44m',610.0,32,'A-03','MONMEL-4117','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Montevideo'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'05:00','De Linea','5h 44m',610.0,36,'A-04','MONMEL-2263','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Montevideo'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'20:30','De Linea','5h 44m',610.0,44,'A-01','MONMEL-8243','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='San Ramón'),(SELECT id FROM empresas WHERE nombre='Turismar'),'13:30','De Linea','4h 25m',480.0,40,'A-02','MELSAN-5609','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='San Ramón'),(SELECT id FROM empresas WHERE nombre='Turismar'),'02:15','De Linea','4h 25m',480.0,43,'A-03','MELSAN-5055','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='San Ramón'),(SELECT id FROM empresas WHERE nombre='Turismar'),'18:00','De Linea','4h 25m',480.0,32,'A-04','MELSAN-2289','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='San Ramón'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'16:05','De Linea','4h 25m',480.0,35,'A-01','SANMEL-1179','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='San Ramón'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'06:30','De Linea','4h 25m',480.0,34,'A-02','SANMEL-3663','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='San Ramón'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'22:00','De Linea','4h 25m',480.0,32,'A-03','SANMEL-6207','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Casupá'),(SELECT id FROM empresas WHERE nombre='Turismar'),'13:30','De Linea','4h 07m',460.0,36,'A-04','MELCAS-5040','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Casupá'),(SELECT id FROM empresas WHERE nombre='Turismar'),'02:15','De Linea','4h 07m',460.0,32,'A-01','MELCAS-5952','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Casupá'),(SELECT id FROM empresas WHERE nombre='Turismar'),'18:00','De Linea','4h 07m',460.0,37,'A-02','MELCAS-3028','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Casupá'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'16:45','De Linea','4h 07m',460.0,33,'A-03','CASMEL-7889','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Casupá'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'07:10','De Linea','4h 07m',460.0,37,'A-04','CASMEL-8542','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Casupá'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'22:40','De Linea','4h 07m',460.0,39,'A-01','CASMEL-2791','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Cerro Colorado'),(SELECT id FROM empresas WHERE nombre='Turismar'),'13:30','De Linea','2h 04m',270.0,43,'A-02','MELCER-6783','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Cerro Colorado'),(SELECT id FROM empresas WHERE nombre='Turismar'),'02:15','De Linea','2h 04m',270.0,35,'A-03','MELCER-2130','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Cerro Colorado'),(SELECT id FROM empresas WHERE nombre='Turismar'),'18:00','De Linea','2h 04m',270.0,35,'A-04','MELCER-5856','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Cerro Colorado'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'17:20','De Linea','2h 04m',270.0,42,'A-01','CERMEL-7144','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Cerro Colorado'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'07:35','De Linea','2h 04m',270.0,36,'A-02','CERMEL-4986','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Cerro Colorado'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'23:05','De Linea','2h 04m',270.0,39,'A-03','CERMEL-3180','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Batlle y Ordóñez'),(SELECT id FROM empresas WHERE nombre='Turismar'),'13:30','De Linea','2h 12m',280.0,42,'A-04','MELBAT-4019','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Batlle y Ordóñez'),(SELECT id FROM empresas WHERE nombre='Turismar'),'02:15','De Linea','2h 12m',280.0,39,'A-01','MELBAT-7157','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Batlle y Ordóñez'),(SELECT id FROM empresas WHERE nombre='Turismar'),'18:00','De Linea','2h 12m',280.0,37,'A-02','MELBAT-4934','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Batlle y Ordóñez'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'18:15','De Linea','2h 12m',280.0,43,'A-03','BATMEL-8112','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Batlle y Ordóñez'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'08:30','De Linea','2h 12m',280.0,43,'A-04','BATMEL-6575','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Batlle y Ordóñez'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'00:05','De Linea','2h 12m',280.0,32,'A-01','BATMEL-3317','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Cerro Chato'),(SELECT id FROM empresas WHERE nombre='Turismar'),'13:30','De Linea','1h 55m',260.0,32,'A-02','MELCER-9479','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Cerro Chato'),(SELECT id FROM empresas WHERE nombre='Turismar'),'02:15','De Linea','1h 55m',260.0,36,'A-03','MELCER-4115','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Cerro Chato'),(SELECT id FROM empresas WHERE nombre='Turismar'),'18:00','De Linea','1h 55m',260.0,39,'A-04','MELCER-6541','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Cerro Chato'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'18:55','De Linea','1h 55m',260.0,40,'A-01','CERMEL-8348','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Cerro Chato'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'09:10','De Linea','1h 55m',260.0,43,'A-02','CERMEL-8609','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Cerro Chato'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'00:35','De Linea','1h 55m',260.0,32,'A-03','CERMEL-7668','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Santa Clara'),(SELECT id FROM empresas WHERE nombre='Turismar'),'13:30','De Linea','1h 28m',220.0,43,'A-04','MELSAN-4281','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Santa Clara'),(SELECT id FROM empresas WHERE nombre='Turismar'),'02:15','De Linea','1h 28m',220.0,37,'A-01','MELSAN-2595','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Santa Clara'),(SELECT id FROM empresas WHERE nombre='Turismar'),'18:00','De Linea','1h 28m',220.0,32,'A-02','MELSAN-2866','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Santa Clara'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'19:25','De Linea','1h 28m',220.0,33,'A-03','SANMEL-6705','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Santa Clara'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'09:35','De Linea','1h 28m',220.0,34,'A-04','SANMEL-6489','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Santa Clara'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'00:55','De Linea','1h 28m',220.0,36,'A-01','SANMEL-3322','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Tupambaé'),(SELECT id FROM empresas WHERE nombre='Turismar'),'13:30','De Linea','53m',160.0,41,'A-02','MELTUP-5639','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Tupambaé'),(SELECT id FROM empresas WHERE nombre='Turismar'),'02:15','De Linea','53m',160.0,35,'A-03','MELTUP-3224','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Tupambaé'),(SELECT id FROM empresas WHERE nombre='Turismar'),'18:00','De Linea','53m',160.0,42,'A-04','MELTUP-7326','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Tupambaé'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'19:45','De Linea','53m',160.0,34,'A-01','TUPMEL-5507','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Tupambaé'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'10:00','De Linea','53m',160.0,36,'A-02','TUPMEL-6771','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Tupambaé'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'01:25','De Linea','53m',160.0,43,'A-03','TUPMEL-4912','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Fraile Muerto'),(SELECT id FROM empresas WHERE nombre='Turismar'),'13:30','De Linea','26m',120.0,37,'A-04','MELFRA-5094','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Fraile Muerto'),(SELECT id FROM empresas WHERE nombre='Turismar'),'02:15','De Linea','26m',120.0,33,'A-01','MELFRA-2866','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Fraile Muerto'),(SELECT id FROM empresas WHERE nombre='Turismar'),'18:00','De Linea','26m',120.0,36,'A-02','MELFRA-2219','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Fraile Muerto'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'20:25','De Linea','26m',120.0,37,'A-03','FRAMEL-9414','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Fraile Muerto'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'10:35','De Linea','26m',120.0,43,'A-04','FRAMEL-5604','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Fraile Muerto'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'02:00','De Linea','26m',120.0,43,'A-01','FRAMEL-5849','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Montevideo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'13:30','Directo Domingo','5h 44m',610.0,39,'A-02','MELMON-5298','embarcando'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Montevideo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'18:00','Directo Domingo','5h 44m',610.0,36,'A-03','MELMON-6186','horario'),
    ((SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM ciudades WHERE nombre='Montevideo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'02:15','Directo Lunes','5h 44m',610.0,43,'A-04','MELMON-8874','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Montevideo'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'14:30','Directo Viernes','5h 44m',610.0,38,'A-01','MONMEL-2464','demorado'),
    ((SELECT id FROM ciudades WHERE nombre='Montevideo'),(SELECT id FROM ciudades WHERE nombre='Melo'),(SELECT id FROM empresas WHERE nombre='Turismar'),'20:30','Directo Viernes','5h 44m',610.0,36,'A-02','MONMEL-6811','horario');

-- Usuarios de prueba (cambiar contraseñas en un entorno real).
-- Admin:   admin@terminal.com   / admin123
-- Cliente: cliente@ejemplo.com  / cliente123
INSERT INTO usuarios (nombre, apellido, email, password_hash, rol) VALUES
    ('Admin', 'Terminal', 'admin@terminal.com', '$2y$12$wU6LMu.SDhYvfijWxfptKeCTiTTUJraNZWUDynEwFVrgCM7eSxH4S', 'admin'),
    ('Cliente', 'De Prueba', 'cliente@ejemplo.com', '$2y$12$msY/pEnsL.NTLy.bnmxLIuMv9Gr/fdMLeyBHOfPZtzeQClCYyJZxe', 'cliente');
