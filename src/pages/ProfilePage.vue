<!-- Página de perfil del usuario: datos personales, próximos viajes e historial (ruta /perfil). -->
<template>

  <MainLayout>

    <!-- SUPERIOR -->
    <div class="superior">
      <div>
        <h1>MI PERFIL</h1>
        <p>Reservas · Historial de viajes · Datos personales</p>
      </div>
    </div>

    <!-- CARD USUARIO -->
    <div class="card-usuario">

      <div class="avatar-grande">{{ inicial }}</div>

      <div class="datos-usuario">
        <h2>{{ usuario.nombre }} {{ usuario.apellido }}</h2>
        <p>{{ usuario.email }}</p>
      </div>

      <div class="stats-usuario">
        <div class="stat">
          <span class="stat-numero">{{ viajesTotales }}</span>
          <span class="stat-label">VIAJES TOTALES</span>
        </div>
        <div class="stat">
          <span class="stat-numero verde">${{ totalInvertido }}</span>
          <span class="stat-label">TOTAL INVERTIDO</span>
        </div>
      </div>

      <button class="btn-editar" @click="mostrarEdicion = !mostrarEdicion">
        <q-icon name="edit" size="16px" />
        {{ mostrarEdicion ? 'Cerrar' : 'Editar mis datos' }}
      </button>

    </div>

    <!-- EDICION DE DATOS -->
    <div v-if="mostrarEdicion" class="panel-edicion">

      <div class="columna">
        <h3>DATOS PERSONALES</h3>

        <label>Nombre</label>
        <input type="text" v-model="formDatos.nombre" />

        <label>Apellido</label>
        <input type="text" v-model="formDatos.apellido" />

        <label>Correo electrónico</label>
        <input type="email" v-model="formDatos.email" />

        <p v-if="errorDatos" class="error-msg">{{ errorDatos }}</p>
        <p v-if="okDatos" class="ok-msg">{{ okDatos }}</p>

        <button class="btn-guardar" :disabled="guardandoDatos" @click="guardarDatos">
          {{ guardandoDatos ? 'Guardando...' : 'Guardar cambios' }}
        </button>
      </div>

      <div class="columna">
        <h3>CAMBIAR CONTRASEÑA</h3>

        <label>Contraseña actual</label>
        <input type="password" v-model="formPassword.actual" />

        <label>Contraseña nueva</label>
        <input type="password" v-model="formPassword.nueva" />

        <p v-if="errorPassword" class="error-msg">{{ errorPassword }}</p>
        <p v-if="okPassword" class="ok-msg">{{ okPassword }}</p>

        <button class="btn-guardar" :disabled="guardandoPassword" @click="guardarPassword">
          {{ guardandoPassword ? 'Guardando...' : 'Cambiar contraseña' }}
        </button>
      </div>

    </div>

    <!-- PROXIMOS VIAJES -->
    <h2 class="seccion-titulo">PRÓXIMOS VIAJES</h2>

    <p v-if="cargando" class="sin-resultados">Cargando reservas...</p>
    <p v-else-if="proximos.length === 0" class="sin-resultados">No tenés viajes próximos.</p>

    <div v-else class="pasajes">
      <div v-for="r in proximos" :key="r.id" class="fila-pasaje">

        <div class="codigo">
          <span>#{{ r.id }}</span>
          <span class="metodo-pago">{{ r.fecha_viaje }}</span>
        </div>

        <div class="info-pasaje">
          <span class="ruta">{{ r.origen }} → {{ r.destino }}</span>
          <span class="detalles">
            {{ r.hora }} · Asiento {{ r.asiento }} · Andén {{ r.anden || '-' }}
          </span>
          <span class="detalles">{{ r.empresa }} · Bus {{ r.bus || '-' }}</span>
        </div>

        <div class="estado-precio">
          <span class="badge-estado" :class="r.estado">{{ etiquetaEstado(r) }}</span>
          <span class="precio">${{ r.total }}</span>

          <button
            v-if="r.estado !== 'cancelada'"
            class="btn-cancelar"
            :disabled="!puedeCancelar(r) || cancelando === r.id"
            @click="cancelar(r)"
          >
            {{ cancelando === r.id ? 'Cancelando...' : 'Cancelar' }}
          </button>
          <span v-if="r.estado !== 'cancelada' && !puedeCancelar(r)" class="nota-plazo">
            Ya no se puede cancelar (faltan menos de {{ PLAZO_HORAS }}hs)
          </span>
        </div>

      </div>
    </div>

    <!-- HISTORIAL -->
    <h2 class="seccion-titulo">HISTORIAL DE VIAJES</h2>

    <p v-if="!cargando && historial.length === 0" class="sin-resultados">Todavía no tenés viajes en tu historial.</p>

    <div v-else-if="historial.length" class="pasajes">
      <div v-for="r in historial" :key="r.id" class="fila-pasaje">

        <div class="codigo">
          <span>#{{ r.id }}</span>
          <span class="metodo-pago">{{ r.fecha_viaje }}</span>
        </div>

        <div class="info-pasaje">
          <span class="ruta">{{ r.origen }} → {{ r.destino }}</span>
          <span class="detalles">{{ r.hora }} · Asiento {{ r.asiento }}</span>
          <span class="detalles">{{ r.empresa }} · Bus {{ r.bus || '-' }}</span>
        </div>

        <div class="estado-precio">
          <span class="badge-estado" :class="r.estado === 'cancelada' ? 'cancelada' : 'completado'">
            {{ r.estado === 'cancelada' ? 'CANCELADO' : 'COMPLETADO' }}
          </span>
          <span class="precio">${{ r.total }}</span>
        </div>

      </div>
    </div>

  </MainLayout>

</template>

<script setup>

import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import MainLayout from '../layouts/MainLayout.vue'
import { useAuth } from '../services/auth'
import { getReservasUsuario, cancelarReserva, actualizarPerfil, cambiarPassword } from '../services/api'

const router = useRouter()
const { usuario, guardarSesion } = useAuth()

// El guard del router ya exige sesión para entrar a /perfil, pero por las
// dudas (ej. localStorage borrado a mano) si no hay usuario se manda a login.
if (!usuario.value) {
  router.push('/login')
}

const inicial = computed(() => usuario.value?.nombre?.charAt(0).toUpperCase() || '?')

// ---- Reservas ----
const PLAZO_HORAS = 3
const reservas = ref([])
const cargando = ref(false)

async function cargarReservas() {
  if (!usuario.value) return
  cargando.value = true
  try {
    reservas.value = await getReservasUsuario(usuario.value.id)
  } catch (e) {
    console.error(e)
  } finally {
    cargando.value = false
  }
}

onMounted(cargarReservas)

function fechaSalida(r) {
  return new Date(`${r.fecha_viaje}T${r.hora}`)
}

const proximos = computed(() =>
  reservas.value.filter(r => r.estado === 'cancelada' ? false : fechaSalida(r) >= new Date())
)

const historial = computed(() =>
  reservas.value.filter(r => r.estado === 'cancelada' || fechaSalida(r) < new Date())
)

const viajesTotales = computed(() => reservas.value.filter(r => r.estado !== 'cancelada').length)

const totalInvertido = computed(() =>
  reservas.value
    .filter(r => r.estado !== 'cancelada')
    .reduce((acc, r) => acc + Number(r.total || 0), 0)
)

function puedeCancelar(r) {
  const horasRestantes = (fechaSalida(r).getTime() - Date.now()) / 3_600_000
  return horasRestantes >= PLAZO_HORAS
}

function etiquetaEstado(r) {
  if (r.estado === 'confirmada') return 'CONFIRMADA'
  return 'PENDIENTE'
}

const cancelando = ref(null)

async function cancelar(r) {
  if (!confirm(`¿Cancelar el viaje ${r.origen} → ${r.destino} del ${r.fecha_viaje}?`)) return
  cancelando.value = r.id
  try {
    await cancelarReserva(r.id)
    await cargarReservas()
  } catch (e) {
    alert(e.message)
  } finally {
    cancelando.value = null
  }
}

// ---- Edición de datos personales ----
const mostrarEdicion = ref(false)

const formDatos = ref({
  nombre: usuario.value?.nombre || '',
  apellido: usuario.value?.apellido || '',
  email: usuario.value?.email || ''
})
const guardandoDatos = ref(false)
const errorDatos = ref('')
const okDatos = ref('')

async function guardarDatos() {
  guardandoDatos.value = true
  errorDatos.value = ''
  okDatos.value = ''
  try {
    const actualizado = await actualizarPerfil(usuario.value.id, formDatos.value)
    guardarSesion(actualizado)
    okDatos.value = 'Datos actualizados correctamente'
  } catch (e) {
    errorDatos.value = e.message
  } finally {
    guardandoDatos.value = false
  }
}

// ---- Cambio de contraseña ----
const formPassword = ref({ actual: '', nueva: '' })
const guardandoPassword = ref(false)
const errorPassword = ref('')
const okPassword = ref('')

async function guardarPassword() {
  guardandoPassword.value = true
  errorPassword.value = ''
  okPassword.value = ''
  try {
    await cambiarPassword(usuario.value.id, formPassword.value)
    okPassword.value = 'Contraseña actualizada'
    formPassword.value = { actual: '', nueva: '' }
  } catch (e) {
    errorPassword.value = e.message
  } finally {
    guardandoPassword.value = false
  }
}

</script>

<style scoped>

.superior{
  padding-bottom:20px;
  border-bottom:1px solid #1a2138;
  margin-bottom:30px;
}

h1{
  font-size:45px;
  letter-spacing:3px;
  color:white;
}

.superior p{
  color:#7b8198;
  margin-top:8px;
  font-size:13px;
  letter-spacing:1px;
}

/* CARD USUARIO */

.card-usuario{
  background:#0f1629;
  border:1px solid #1a2138;
  border-top:3px solid #00ffd0;
  border-radius:6px;
  padding:30px;
  display:flex;
  align-items:center;
  gap:25px;
  margin-bottom:20px;
  flex-wrap:wrap;
}

.avatar-grande{
  width:70px;
  height:70px;
  background:#f4b400;
  color:black;
  font-size:28px;
  font-weight:bold;
  display:flex;
  align-items:center;
  justify-content:center;
  border-radius:4px;
  flex-shrink:0;
}

.datos-usuario{
  flex:1;
  min-width:200px;
}

.datos-usuario h2{
  color:white;
  font-size:26px;
  letter-spacing:2px;
  margin:0 0 6px;
}

.datos-usuario p{
  color:#7b8198;
  font-size:13px;
  margin:0;
}

.stats-usuario{
  display:flex;
  gap:50px;
}

.stat{
  text-align:center;
}

.stat-numero{
  display:block;
  color:#f4b400;
  font-size:40px;
  font-weight:bold;
}

.stat-numero.verde{
  color:#f4b400;
}

.stat-label{
  color:#7b8198;
  font-size:11px;
  letter-spacing:1px;
}

.btn-editar{
  background:transparent;
  border:1px solid #1a2138;
  color:#7b8198;
  padding:10px 18px;
  border-radius:4px;
  cursor:pointer;
  display:flex;
  align-items:center;
  gap:8px;
  font-size:13px;
  transition:0.2s;
}

.btn-editar:hover{
  color:white;
  border-color:#7b8198;
}

/* PANEL DE EDICION */

.panel-edicion{
  display:flex;
  gap:25px;
  flex-wrap:wrap;
  border:1px solid #1a2138;
  border-radius:6px;
  padding:25px;
  margin-bottom:35px;
  background:#0a0f22;
}

.columna{
  flex:1;
  min-width:260px;
  display:flex;
  flex-direction:column;
  gap:10px;
}

.columna h3{
  color:white;
  font-size:14px;
  letter-spacing:2px;
  margin-bottom:5px;
}

.columna label{
  color:#7b8198;
  font-size:11px;
  letter-spacing:1px;
}

.columna input{
  background:#0f1629;
  border:1px solid #1a2138;
  color:white;
  padding:12px 15px;
  border-radius:4px;
  font-size:14px;
}

.btn-guardar{
  background:#f4b400;
  border:none;
  color:black;
  padding:12px 20px;
  cursor:pointer;
  font-size:13px;
  font-weight:bold;
  letter-spacing:1px;
  border-radius:4px;
  margin-top:5px;
  transition:0.2s;
}

.btn-guardar:disabled{
  opacity:0.4;
  cursor:not-allowed;
}

.btn-guardar:not(:disabled):hover{
  background:#e0a300;
}

/* PASAJES */

.seccion-titulo{
  color:white;
  font-size:16px;
  letter-spacing:3px;
  margin-bottom:20px;
  margin-top:35px;
}

.pasajes{
  display:flex;
  flex-direction:column;
  gap:0;
  border:1px solid #1a2138;
  border-radius:6px;
  overflow:hidden;
}

.fila-pasaje{
  display:grid;
  grid-template-columns:160px 1fr 220px;
  align-items:center;
  padding:22px 25px;
  border-bottom:1px solid #1a2138;
  gap:20px;
  transition:0.2s;
}

.fila-pasaje:last-child{
  border-bottom:none;
}

.fila-pasaje:hover{
  background:#0f1629;
}

.codigo span:first-child{
  display:block;
  color:#f4b400;
  font-size:18px;
  font-weight:bold;
  letter-spacing:1px;
}

.metodo-pago{
  color:#7b8198;
  font-size:12px;
  margin-top:4px;
}

.ruta{
  display:block;
  color:white;
  font-size:16px;
  font-weight:600;
  margin-bottom:5px;
}

.detalles{
  display:block;
  color:#7b8198;
  font-size:12px;
  margin-top:3px;
}

.estado-precio{
  text-align:right;
}

.badge-estado{
  display:inline-block;
  font-size:11px;
  letter-spacing:1px;
  padding:5px 12px;
  border-radius:3px;
  margin-bottom:8px;
}

.badge-estado.confirmada,
.badge-estado.completado{
  border:1px solid #00ff99;
  color:#00ff99;
}

.badge-estado.pendiente{
  border:1px solid #f4b400;
  color:#f4b400;
}

.badge-estado.cancelada{
  border:1px solid #ff6b6b;
  color:#ff6b6b;
}

.precio{
  display:block;
  color:#f4b400;
  font-size:22px;
  font-weight:bold;
}

.btn-cancelar{
  margin-top:10px;
  background:transparent;
  border:1px solid #ff6b6b;
  color:#ff6b6b;
  padding:6px 14px;
  border-radius:4px;
  cursor:pointer;
  font-size:12px;
  transition:0.2s;
}

.btn-cancelar:disabled{
  opacity:0.35;
  cursor:not-allowed;
}

.btn-cancelar:not(:disabled):hover{
  background:#ff6b6b;
  color:black;
}

.nota-plazo{
  display:block;
  margin-top:8px;
  color:#7b8198;
  font-size:11px;
  max-width:180px;
}

.error-msg{
  color:#ff6b6b;
  font-size:13px;
}

.ok-msg{
  color:#00ff99;
  font-size:13px;
}

.sin-resultados{
  color:#7b8198;
  font-size:13px;
  margin-bottom:20px;
}

@media (max-width: 700px) {
  h1 {
    font-size: 28px;
  }

  .card-usuario {
    padding: 20px;
    text-align: center;
    justify-content: center;
  }

  .stats-usuario {
    width: 100%;
    justify-content: space-around;
    gap: 20px;
  }

  .panel-edicion {
    padding: 18px;
  }

  .fila-pasaje {
    grid-template-columns: 1fr;
    gap: 10px;
    padding: 18px;
  }

  .estado-precio {
    text-align: left;
  }
}

</style>
