# ViaBus — Backend PHP + PostgreSQL

Backend REST en PHP para el sistema de reservas de pasajes. Usa
**PostgreSQL** como base de datos.

---

## Estructura

```
viabus-backend/
├── router.php            ← router para el servidor embebido de PHP
├── config/
│   ├── database.php       ← conexión PDO a Postgres (auto-inicializa las tablas)
│   └── helpers.php        ← CORS, JSON, utilidades
├── api/
│   ├── servicios.php      ← CRUD de viajes
│   ├── reservas.php       ← CRUD de reservas + asientos ocupados
│   ├── ciudades.php       ← listado de ciudades
│   ├── empresas.php       ← listado de empresas (con descripción y logo)
│   ├── pasajeros.php      ← CRUD de pasajeros
│   ├── usuarios.php       ← gestión de usuarios
│   ├── auth.php           ← login / registro
│   ├── pagos.php          ← integración Mercado Pago
│   └── tablero.php        ← estado en vivo de salidas
└── sql/
    └── schema.sql         ← tablas + los servicios reales del frontend
```

---

## Qué instalar (una sola vez por máquina)

### 1. PostgreSQL (el servidor de base de datos)

```bash
sudo apt install postgresql postgresql-contrib -y
sudo systemctl enable --now postgresql
```

### 2. La extensión de PHP para conectarse a Postgres

Primero fijate tu versión de PHP:
```bash
php -v
```

Después instalá el paquete correspondiente (cambiando `8.3` por tu versión):
```bash
sudo apt install php8.3-pgsql -y
```

Si tu PHP es muy reciente (por ejemplo 8.5) y `apt` no encuentra el paquete,
puede que tu PHP venga del PPA `ondrej/php` y ese repo no esté agregado
todavía:
```bash
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo apt install php8.5-pgsql -y   # con tu versión real
```

Confirmá que quedó instalada:
```bash
php -m | grep pgsql
```
Tiene que aparecer `pgsql` y `pdo_pgsql`. Si no aparece nada, el backend va
a fallar con `Error de conexión a la base de datos: could not find driver`.

### 3. Crear la base de datos

```bash
sudo -u postgres psql -c "CREATE DATABASE viabus;"
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"
```

`config/database.php` se conecta por defecto a `localhost:5432`, base
`viabus`, usuario `postgres`, contraseña `postgres`. Si tu instalación usa
otros datos, no edites el código: seteá estas variables de entorno antes de
levantar el backend (o en un `.env` que cargues vos):

| Variable | Default |
|----------|---------|
| `DB_HOST` | `127.0.0.1` |
| `DB_PORT` | `5432` |
| `DB_NAME` | `viabus` |
| `DB_USER` | `postgres` |
| `DB_PASS` | `postgres` |

---

## Cómo correrlo

No hace falta correr el esquema a mano: la primera vez que se llama a
cualquier endpoint, `config/database.php` revisa si la tabla `usuarios` ya
existe en Postgres; si no existe, ejecuta `sql/schema.sql` completo (tablas
+ datos de ejemplo) automáticamente.

```bash
php -S localhost:8000 -t viabus-backend viabus-backend/router.php
```

O, más simple, usar el script `dev.sh` de la raíz del proyecto, que levanta
el backend y el frontend juntos (ver el README principal).

### Reiniciar los datos

Si se quiere volver a los datos originales (por ejemplo, después de crear
reservas de prueba), borrar y recrear la base:

```bash
sudo -u postgres psql -c "DROP DATABASE viabus;"
sudo -u postgres psql -c "CREATE DATABASE viabus;"
```

El esquema y los datos de ejemplo se vuelven a cargar solos la próxima vez
que el backend reciba una petición.

---

## Endpoints

### Ciudades
| Método | URL | Descripción |
|--------|-----|-------------|
| GET | `/api/ciudades.php` | Lista todas las ciudades |

### Empresas
| Método | URL | Descripción |
|--------|-----|-------------|
| GET | `/api/empresas.php` | Lista todas las empresas (nombre, logo, descripción) |

### Servicios (viajes)
| Método | URL | Descripción |
|--------|-----|-------------|
| GET | `/api/servicios.php` | Todos los servicios activos |
| GET | `/api/servicios.php?id=5` | Servicio por ID |
| GET | `/api/servicios.php?origen=Melo&destino=Montevideo` | Buscar por ruta |
| POST | `/api/servicios.php` | Crear servicio |
| PUT | `/api/servicios.php?id=5` | Editar servicio |
| DELETE | `/api/servicios.php?id=5` | Desactivar servicio |

#### POST body (crear servicio):
```json
{
  "origen": "Melo",
  "destino": "Montevideo",
  "empresa": "Ega",
  "hora": "07:00",
  "tipo": "De Linea",
  "duracion": "5h 30m",
  "precio": 450.00,
  "asientos": 40,
  "anden": "A-01",
  "bus": "MELMON-1234",
  "estado": "horario"
}
```

### Reservas
| Método | URL | Descripción |
|--------|-----|-------------|
| GET | `/api/reservas.php` | Todas las reservas |
| GET | `/api/reservas.php?id=3` | Reserva por ID |
| GET | `/api/reservas.php?servicio_id=5&fecha=2026-08-15` | Asientos ocupados |
| POST | `/api/reservas.php` | Crear reserva |
| PUT | `/api/reservas.php?id=3` | Cambiar estado |
| DELETE | `/api/reservas.php?id=3` | Cancelar reserva |

#### POST body (crear reserva):
```json
{
  "servicio_id": 5,
  "fecha_viaje": "2026-08-15",
  "asiento": 12,
  "pasajero": {
    "nombre": "Juan",
    "apellido": "García",
    "documento": "12345678",
    "email": "juan@email.com",
    "telefono": "099123456"
  }
}
```
El campo `total` es opcional; si no se envía, se usa el precio del servicio.

#### PUT body (cambiar estado):
```json
{ "estado": "confirmada" }
```
Estados válidos: `pendiente` | `confirmada` | `cancelada`

#### Respuesta asientos ocupados:
```json
{ "asientos_ocupados": [5, 12, 23] }
```

### Pasajeros
| Método | URL | Descripción |
|--------|-----|-------------|
| GET | `/api/pasajeros.php` | Todos los pasajeros |
| GET | `/api/pasajeros.php?id=3` | Por ID |
| GET | `/api/pasajeros.php?documento=12345678` | Por documento (CI) |
| POST | `/api/pasajeros.php` | Crear pasajero |
| PUT | `/api/pasajeros.php?id=3` | Editar pasajero |

---

## Conexión con el frontend

El frontend (Quasar) ya está conectado: usa `src/services/api.js`, que llama
a rutas relativas (`/api/servicios.php`, etc.). En desarrollo, `quasar.config.js`
redirige automáticamente `/api/*` hacia `http://localhost:8000` (ver
`devServer.proxy`), así que no hay que hardcodear ninguna URL.

En producción, hay que publicar la carpeta `viabus-backend/` en el mismo
dominio que el frontend, bajo la ruta `/api`, o ajustar `BASE` en
`src/services/api.js` para que apunte a la URL del backend.

---

## Notas

- Los precios, duraciones, asientos, andenes, buses y estados se calcularon
  a partir de los 214 servicios reales que estaban hardcodeados originalmente
  en el frontend (hoy `src/pages/ReservationPage.vue`), usando distancias
  aproximadas por ruta.
  Son valores realistas para que la app funcione de punta a punta, no datos
  oficiales de las empresas.
- Los borrados son lógicos (campo `activo` / estado `cancelada`), no se
  elimina nada de la base.
- La tabla `reservas` tiene una restricción `UNIQUE` que impide duplicar
  asiento + servicio + fecha.
- El driver de conexión (`pdo_pgsql`) tiene que estar habilitado en el PHP
  de cada máquina — ver la sección de instalación arriba. Si falta, el error
  es `Error de conexión a la base de datos: could not find driver`.