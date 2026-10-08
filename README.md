# ViaBus (quasar-project)

Plataforma de gestión de terminal de ómnibus para Melo, Uruguay. Frontend en
Vue 3 + Quasar, backend en PHP + PostgreSQL.

Toda la información que muestra la app (ciudades, empresas, servicios,
asientos disponibles, reservas) sale del backend — no hay datos
hardcodeados en el frontend.

## Qué instalar antes de arrancar (una sola vez por máquina)

1. **Node y pnpm** (o npm) para el frontend.
2. **PHP 8+** con la extensión **`pdo_pgsql`** habilitada.
   Verificar con:
   ```bash
   php -m | grep pgsql
   ```
   Si no aparece nada, instalar el paquete de tu versión de PHP, por ejemplo:
   ```bash
   sudo apt install php8.3-pgsql -y   # cambiar 8.3 por tu versión (php -v)
   ```
3. **PostgreSQL** (el servidor de base de datos en sí):
   ```bash
   sudo apt install postgresql postgresql-contrib -y
   sudo systemctl enable --now postgresql
   ```
4. **Crear la base de datos y el usuario** (una sola vez):
   ```bash
   sudo -u postgres psql -c "CREATE DATABASE viabus;"
   sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"
   ```
   Si usás otro usuario/clave/nombre de base, ver la sección de variables de
   entorno en `viabus-backend/README.md`.

A diferencia de SQLite, **Postgres corre como un servicio** — no es un
archivo que se genera solo. Cada compañero necesita este servidor instalado
y corriendo en su máquina (o, alternativamente, todos apuntando a un mismo
Postgres compartido en red, ajustando las variables de entorno).

## Instalar dependencias del proyecto

```bash
pnpm install
# o
npm install
```

## Levantar todo en desarrollo

```bash
./dev.sh
```

Esto arranca:
- el backend PHP en `http://localhost:8000`
- el frontend de Quasar en `http://localhost:9000`

La primera vez que el backend recibe una petición, `config/database.php`
revisa si las tablas ya existen en Postgres; si no existen, ejecuta
`sql/schema.sql` y carga todos los datos de ejemplo automáticamente. No hay
que correr nada a mano.

El frontend está configurado para redirigir automáticamente las llamadas a
`/api/*` hacia el backend (ver `devServer.proxy` en `quasar.config.js`), así
que no hay que tocar nada más.

### Levantar cada parte por separado

```bash
# Backend
php -S localhost:8000 -t viabus-backend viabus-backend/router.php

# Frontend (en otra terminal)
pnpm dev
```

## Build para producción

```bash
pnpm build
```

Para producción, hay que publicar `viabus-backend/` en el mismo dominio que
el frontend bajo la ruta `/api` (ver `viabus-backend/README.md`).

## Estructura

```
src/
├── assets/              # imágenes, fuentes, hojas de estilo globales
├── components/
│   ├── common/          # piezas reutilizables en cualquier parte de la app
│   │   (NavMenuItem, LogoutButton, StatCard, StatusBadge, LiveClock)
│   ├── layout/           # AppSidebar (el menú lateral fijo)
│   ├── home/             # HeroBanner, StatsSection, QuickActionsGrid, LocationMap
│   ├── company/          # CompanyList
│   └── dashboard/        # DashboardBoard y sus piezas internas (Header, Metrics,
│                          # MetricCard, Tabs, Table, TableRow)
├── layouts/
│   └── MainLayout.vue    # sidebar + área de contenido; lo usan todas las
│                          # páginas salvo NotFoundPage
├── pages/                # una página por ruta (ver tabla de rutas abajo)
├── router/index.js       # definición de rutas
├── services/api.js       # cliente HTTP hacia el backend (un export por endpoint)
└── css/, boot/           # scaffolding estándar de Quasar

viabus-backend/
├── router.php            # router del servidor embebido de PHP
├── config/               # conexión PDO a Postgres (database.php) y helpers de CORS/JSON
├── api/                  # un archivo por recurso (ciudades, empresas,
│                          # servicios, reservas, pasajeros, tablero)
└── sql/schema.sql        # tablas + datos de ejemplo (se ejecuta solo la primera vez)
```

### Rutas actuales

| Ruta | Página | Componente |
|------|--------|------------|
| `/terminal` | Inicio / presentación | `pages/HomePage.vue` |
| `/tablero` | Tablero de salidas en vivo | `pages/DashboardPage.vue` |
| `/comprar` | Reserva de pasajes (multi-paso) | `pages/ReservationPage.vue` |
| `/pagos` | Placeholder de pagos | `pages/PaymentsPage.vue` |
| `/perfil` | Perfil / historial del usuario | `pages/ProfilePage.vue` |
| `/info` | Info general y empresas | `pages/CompaniesPage.vue` |
| `/login` | Inicio de sesión | `pages/LoginPage.vue` |
| `/:catchAll` | 404 | `pages/NotFoundPage.vue` |

### Convención de nombres

- **Páginas** (`src/pages/`): `NombreDescriptivoPage.vue`, PascalCase.
- **Componentes**: PascalCase, nombre = qué hace (`CompanyList`, no `Boton2`).
- **Carpeta de componentes**: por dominio/feature (`home/`, `dashboard/`,
  `company/`), y `common/` solo para piezas realmente genéricas usadas en
  más de un dominio.
- **Variables/props**: en español, igual que el resto del código (backend
  y frontend son consistentemente en español) — lo importante es que sean
  descriptivas, no el idioma.
- **CSS**: clases en `kebab-case` dentro de `<style scoped>` de cada
  componente; evitar estilos globales salvo en `assets/styles/`.

### Cómo agregar una página nueva

1. Crear `src/pages/MiNuevaPage.vue`. Envolver el contenido en `<MainLayout>`
   (a menos que sea una pantalla especial como el 404) para heredar el
   sidebar y el padding estándar.
2. Agregar la ruta en `src/router/index.js`.
3. Si necesita aparecer en el menú, agregar un `<NavMenuItem>` en
   `src/components/layout/AppSidebar.vue`.

### Cómo agregar un endpoint nuevo en el backend

1. Crear `viabus-backend/api/mi_recurso.php`, siguiendo el patrón de los
   existentes: `require '../config/database.php'` y `../config/helpers.php`,
   switch por `$_SERVER['REQUEST_METHOD']`, consultas siempre con PDO
   *prepared statements*.
2. Si el recurso necesita una tabla nueva, agregarla en `sql/schema.sql`. En
   desarrollo, para que se regenere con el esquema nuevo, hay que borrar las
   tablas afectadas en Postgres (o directamente `DROP DATABASE viabus;` /
   `CREATE DATABASE viabus;` de nuevo) y volver a pegarle al backend.
3. Agregar la función correspondiente en `src/services/api.js` (un
   `export function` por operación, mismo estilo que las existentes).

### Cómo agregar una funcionalidad más grande

El proyecto está pensado para poder sumar, sin reorganizar de nuevo:
compra de pasajes real, selección de asientos, historial de reservas,
roles de administrador/empleado/chofer, gestión de empresas/terminales/
horarios, notificaciones y reportes. La convención a seguir:

- Nueva sección de UI → nueva carpeta en `src/components/<dominio>/` +
  su página en `src/pages/`.
- Nuevo recurso de datos → nueva tabla en `schema.sql` + su archivo en
  `viabus-backend/api/` + sus funciones en `services/api.js`.
- No se necesitan patrones adicionales (Singleton, Repository, DI, etc.)
  para esto — cada endpoint PHP ya es, en sí mismo, la capa de acceso a
  datos, y cada componente Vue ya es la unidad de reutilización de UI.

## Nota sobre la base de datos

El proyecto usa **PostgreSQL**. Cada persona que desarrolle necesita tener
un servidor Postgres corriendo localmente (ver la sección de instalación
arriba) — a diferencia de SQLite, no es un archivo que se genera solo, hay
que instalar y arrancar el servicio una vez por máquina. El detalle de la
conexión (host, usuario, contraseña) está en `viabus-backend/README.md`.

## Customizar la configuración

Ver [Configuring quasar.config.js](https://v2.quasar.dev/quasar-cli-vite/quasar-config-js).
