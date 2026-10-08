<!-- Página de reserva de pasajes: búsqueda -> selección de servicio -> asiento -> confirmación (ruta /comprar). Antes: PaginaBoton2.vue -->
<template>

  <MainLayout>

      <!-- SUPERIOR -->
      <div class="superior">
        <div>
          <h1>RESERVA DE PASAJES</h1>
          <p>Elegí tu servicio, fecha, asiento y destino</p>
        </div>
      </div>

      <!-- STEPPER ( paso a paso )-->
      <div class="stepper">
        <div
          v-for="(paso, i) in pasos"
          :key="i"
          class="paso"
          :class="{ activo: pasoActual === i, completado: pasoActual > i }"
        >
          <span class="numero">{{ i + 1 }}</span>
          <span class="label">{{ paso }}</span>
          <span v-if="i < pasos.length - 1" class="linea" />
        </div>
      </div>

      <!-- PASO 1: BUSQUEDA -->
      <div v-if="pasoActual === 0" class="paso-content">

        <h2>BUSCAR SERVICIOS</h2>

        <div class="formulario">

          <div class="campo">
            <label>ORIGEN</label>
            <select v-model="busqueda.origen" disabled>
              <option value="Melo">Melo</option>
            </select>
          </div>

          <div class="campo">
            <label>DESTINO</label>
            <select v-model="busqueda.destino">
              <option v-for="c in ciudades" :key="c" :value="c">{{ c }}</option>
            </select>
          </div>

          <div class="campo">
            <label>FECHA DE VIAJE</label>
            <input type="date" v-model="busqueda.fecha" />
          </div>

          <button class="btn-buscar" :disabled="buscando" @click="buscar">
            <q-icon name="search" size="18px" />
            {{ buscando ? 'BUSCANDO...' : 'BUSCAR' }}
          </button>

        </div>

        <p v-if="errorCiudades || errorBusqueda" class="error-msg">{{ errorCiudades || errorBusqueda }}</p>

      </div>

      <!-- PASO 2: RESULTADOS -->
      <div v-if="pasoActual === 1" class="paso-content">

        <h2>SELECCIONAR SERVICIO</h2>

        <p v-if="!buscando && serviciosFiltrados.length === 0" class="sin-resultados">
          No se encontraron servicios para ese origen y destino.
        </p>

        <div class="resultados">

          <div
            v-for="s in serviciosFiltrados"
            :key="s.id"
            class="resultado-fila"
            :class="{ seleccionado: servicioSeleccionado?.id === s.id }"
            @click="servicioSeleccionado = s"
            @dblclick="seleccionarYBajarAlBoton(s)"
          >
            <div class="res-hora">{{ s.hora }}</div>
            <div class="res-info">
              <span class="res-empresa">{{ s.empresa }}</span>
              <span class="res-tipo">{{ s.tipo }}</span>
            </div>
            <div class="res-duracion">{{ s.duracion }}</div>
            <div class="res-precio">{{ s.precio }}</div>
            <div class="res-estado">
              <span class="badge-disponible">{{ s.asientos }} asientos</span>
            </div>
          </div>

        </div>

        <div class="acciones">
          <button class="btn-volver" @click="pasoActual = 0">Volver</button>
          <button ref="botonContinuarServicio" class="btn-siguiente" :disabled="!servicioSeleccionado" @click="pasoActual = 2">
            Continuar
          </button>
        </div>

      </div>

      <!-- PASO 3: ASIENTOS -->
<div v-if="pasoActual === 2" class="paso-content">

  <h2>SELECCIONAR ASIENTO</h2>

  <p v-if="cargandoAsientos" class="sin-resultados">Cargando disponibilidad de asientos...</p>

  <div class="asientos-grid">

    <div
      v-for="asiento in asientos"
      :key="asiento.numero"
      class="asiento"
      :class="{
        ocupado: asiento.ocupado,
        seleccionado: asientoSeleccionado === asiento.numero
      }"
      @click="seleccionarAsiento(asiento)"
      @dblclick="seleccionarAsientoyBajarAlBoton(asiento)"

    >
      {{ asiento.numero }}
    </div>

  </div>

  <div class="acciones">
    <button class="btn-volver" @click="pasoActual--">
      Volver
    </button>

    <button
      ref="botonContinuarServicio"
      class="btn-siguiente"
      :disabled="!asientoSeleccionado"
      @click="pasoActual++"
    >
      Continuar
    </button>
  </div>

</div>

<!-- PASO 4: DATOS DEL PASAJERO -->
<div v-if="pasoActual === 3" class="paso-content">

  <h2>DATOS DEL PASAJERO</h2>

  <div class="formulario">

    <div class="campo">
      <label>NOMBRE</label>
      <input type="text" v-model="pasajero.nombre" />
    </div>

    <div class="campo">
      <label>APELLIDO</label>
      <input type="text" v-model="pasajero.apellido" />
    </div>

    <div class="campo">
      <label>DOCUMENTO (CI)</label>
      <input type="text" v-model="pasajero.documento" />
    </div>

    <div class="campo">
      <label>EMAIL</label>
      <input type="email" v-model="pasajero.email" />
    </div>

    <div class="campo">
      <label>TELÉFONO</label>
      <input type="text" v-model="pasajero.telefono" />
    </div>

  </div>

  <p v-if="errorPasajero" class="error-msg">{{ errorPasajero }}</p>

  <div class="acciones">
    <button class="btn-volver" @click="pasoActual--">Volver</button>
    <button class="btn-siguiente" :disabled="!pasajeroValido" @click="pasoActual++">
      Continuar
    </button>
  </div>

</div>

<!-- PASO 5: PAGO -->
<div v-if="pasoActual === 4" class="paso-content">

  <PaymentStep
    :resumen="resumenPago"
    :fase="fasePago"
    :mensaje-error="mensajeErrorPago"
    @volver="pasoActual--"
    @pagar="iniciarPago"
    @reintentar="iniciarPago"
  />

  <!-- Botón temporal para debug (avanza al paso 6) -->
<button
  v-if="debugMode"
  class="btn-debug"
  @click="forzarConfirmacion"
>
  ⏩ Avanzar a Confirmación
</button>

</div>

<!-- PASO 6: CONFIRMACIÓN -->
<div v-if="pasoActual === 5" class="paso-content">
  <div class="placeholder-paso">
    <q-icon name="check_circle" size="48px" color="positive" />
    <h2>¡RESERVA CONFIRMADA!</h2>
    <p v-if="reservaCreada">
      Reserva N° {{ reservaCreada.id }} — {{ servicioSeleccionado?.origen }} → {{ servicioSeleccionado?.destino }},
      asiento {{ asientoSeleccionado }}, total ${{ reservaCreada.total }}
    </p>

    <button class="btn-siguiente" @click="reiniciar">Hacer otra reserva</button>

      <div style="display: flex; gap: 15px; justify-content: center; margin-top: 20px; flex-wrap: wrap;">
       <canvas ref="qrCanvas" style="background: white; padding: 10px; border-radius: 8px;" />
      </div>
      <div style="display: flex; gap: 15px; justify-content: center; margin-top: 15px; flex-wrap: wrap;">
        <button class="btn-secundario" @click="descargarQR">📥 Descargar QR</button>
        <button class="btn-secundario" @click="reenviarCorreo">📧 Reenviar QR al correo</button>
      </div>
  </div>
</div>

  </MainLayout>

</template>

<script setup>
import { ref, computed, watch, onMounted, nextTick } from 'vue'
import { useQuasar } from 'quasar'
import QRcode from 'qrcode'
import { useRoute, useRouter } from 'vue-router'
import MainLayout from '../layouts/MainLayout.vue'
import PaymentStep from '../components/reservation/PaymentStep.vue'
import { useAuth } from '../services/auth'
import {
  getCiudades,
  buscarServicios,
  getAsientosOcupados,
  crearReserva,
  crearPreferenciaPago,
  getEstadoPago
} from '../services/api'

const { usuario, isAuthenticated } = useAuth()

const pasos = ['Búsqueda', 'Servicio', 'Asiento', 'Pasajero', 'Pago', 'Confirmación']
const pasoActual = ref(0)

// ---- Ciudades (desde el backend) ----
const ciudades = ref([])
const cargandoCiudades = ref(false)
const errorCiudades = ref('')

async function cargarCiudades() {
  cargandoCiudades.value = true
  errorCiudades.value = ''
  try {
    const data = await getCiudades()
    ciudades.value = data.map(c => c.nombre)
  } catch (e) {
    errorCiudades.value = e.message
  } finally {
    cargandoCiudades.value = false
  }
}

onMounted(cargarCiudades)

const busqueda = ref({
  origen: 'Melo',
  destino: 'Montevideo',
  fecha: new Date().toISOString().slice(0, 10)
})

const servicioSeleccionado = ref(null)
const botonContinuarServicio = ref(null)

function subiralPaso(paso) {
  pasoActual.value = paso
  nextTick(() => {
    window.scrollTo({ top: 0, behavior: 'smooth' })
  })
}


function seleccionarAsientoyBajarAlBoton(asiento) {
  asientoSeleccionado.value = asiento.numero
  nextTick(() => {
    if (botonContinuarServicio.value) {
      botonContinuarServicio.value.scrollIntoView({ behavior: 'smooth', block: 'center' })
    }
  })
}

function seleccionarYBajarAlBoton(servicio) {
  servicioSeleccionado.value = servicio
  nextTick(() => {
    if (botonContinuarServicio.value) {
      botonContinuarServicio.value.scrollIntoView({ behavior: 'smooth', block: 'center' })
    }
  })
}

// ---- Búsqueda de servicios (desde el backend) ----
const serviciosFiltrados = ref([])
const buscando = ref(false)
const errorBusqueda = ref('')

async function buscar() {
  servicioSeleccionado.value = null
  buscando.value = true
  errorBusqueda.value = ''
  try {
    serviciosFiltrados.value = await buscarServicios(busqueda.value.origen, busqueda.value.destino)
    pasoActual.value = 1
  } catch (e) {
    errorBusqueda.value = e.message
  } finally {
    buscando.value = false
  }
}

// ---- Asientos (según el servicio elegido + ocupados reales del backend) ----
const asientoSeleccionado = ref(null)
const asientosOcupados = ref([])
const cargandoAsientos = ref(false)

const asientos = computed(() => {
  const total = Number(servicioSeleccionado.value?.asientos) || 40
  return Array.from({ length: total }, (_, i) => {
    const numero = i + 1
    return { numero, ocupado: asientosOcupados.value.includes(numero) }
  })
})

async function cargarAsientosOcupados() {
  if (!servicioSeleccionado.value) return
  cargandoAsientos.value = true
  try {
    const data = await getAsientosOcupados(servicioSeleccionado.value.id, busqueda.value.fecha)
    asientosOcupados.value = data.asientos_ocupados || []
  } catch {
    asientosOcupados.value = []
  } finally {
    cargandoAsientos.value = false
  }
}

// Cada vez que se entra al paso de asientos con un servicio elegido, se
// consultan los asientos ya reservados para esa fecha.
watch(pasoActual, (nuevo) => {
  if (nuevo === 2) {
    asientoSeleccionado.value = null
    cargarAsientosOcupados()
  }
})

watch(pasoActual, async () => {
  await nextTick()
  const contenido = document.querySelector('.superior')
  contenido?.scrollIntoView({ behavior: 'smooth', block: 'start' })
})

function seleccionarAsiento(asiento) {
  if (asiento.ocupado) return
  asientoSeleccionado.value = asiento.numero
}

// ---- Datos del pasajero ----
const pasajero = ref({
  nombre: '',
  apellido: '',
  documento: '',
  email: '',
  telefono: ''
})

const errorPasajero = ref('')

const pasajeroValido = computed(() =>
  pasajero.value.nombre.trim() &&
  pasajero.value.apellido.trim() &&
  pasajero.value.documento.trim()
)

// ---- Pago (Mercado Pago) ----
const route = useRoute()
const router = useRouter()

// La búsqueda, la selección de servicio/asiento y los datos del pasajero
// funcionan sin sesión. Recién acá, al llegar al paso de pago, se exige
// haber iniciado sesión (si no, se manda a /login y se vuelve a /comprar).
watch(pasoActual, (nuevo) => {
  if (nuevo === 4 && !isAuthenticated.value) {
    router.push({ path: '/login', query: { redirect: '/comprar' } })
  }
})

const reservaCreada = ref(null)

const fasePago = ref('resumen') // resumen | procesando | verificando | pendiente | rechazado | error
const mensajeErrorPago = ref('')

const resumenPago = computed(() => ({
  origen: servicioSeleccionado.value?.origen,
  destino: servicioSeleccionado.value?.destino,
  fecha: busqueda.value.fecha,
  hora: servicioSeleccionado.value?.hora,
  empresa: servicioSeleccionado.value?.empresa,
  asiento: asientoSeleccionado.value,
  total: reservaCreada.value?.total ?? servicioSeleccionado.value?.precio
}))

// El usuario tocó "Pagar con Mercado Pago" (o "Reintentar" tras un error/rechazo).
async function iniciarPago() {
  if (!servicioSeleccionado.value || !asientoSeleccionado.value) return

  fasePago.value = 'procesando'
  mensajeErrorPago.value = ''

  try {
    // 1. Crear la reserva si todavía no existe (si es un reintento, se reutiliza).
    if (!reservaCreada.value) {
      const data = await crearReserva({
        servicio_id: servicioSeleccionado.value.id,
        fecha_viaje: busqueda.value.fecha,
        asiento: asientoSeleccionado.value,
        total: servicioSeleccionado.value.precio,
        pasajero: pasajero.value,
        usuario_id: usuario.value?.id
      })
      reservaCreada.value = data
    }

    // 2. Crear la preferencia de pago en Mercado Pago para esa reserva.
    const preferencia = await crearPreferenciaPago(reservaCreada.value.id)

    // 3. Redirigir al checkout de Mercado Pago. Al terminar (pague, cancele
    //    o quede pendiente), Mercado Pago devuelve al usuario a esta misma
    //    página con ?reserva_id=... en la URL (ver onMounted más abajo).
    window.location.href = preferencia.init_point

  } catch (e) {
    fasePago.value = 'error'
    mensajeErrorPago.value = e.message
  }
}

const $q = useQuasar()
// El usuario acaba de volver de Mercado Pago: consultamos el estado real
// en nuestro backend (no los parámetros que agrega Mercado Pago a la URL,
// esos son solo para la UX; la verdad la tiene el webhook).
async function verificarPago(reservaId) {
  pasoActual.value = 4
  fasePago.value = 'verificando'

  try {
    const pago = await getEstadoPago(reservaId)
    reservaCreada.value = { id: reservaId, total: pago.monto }

    if (pago.estado === 'pagado') {
      pasoActual.value = 5
    } else if (pago.estado === 'rechazado' || pago.estado === 'cancelado') {
      fasePago.value = 'rechazado'
    } else {
      // 'pendiente': todavía no llegó (o no llegará) el webhook de Mercado Pago.
      fasePago.value = 'pendiente'
    }
  } catch (e) {
    fasePago.value = 'error'
    mensajeErrorPago.value = e.message
  }
}

onMounted(() => {
  if (route.query.reserva_id) {
    const reservaId = Number(route.query.reserva_id)
    verificarPago(reservaId)
    // Se limpia la URL para que un refresco de página no vuelva a disparar
    // la verificación con datos que ya podrían haber cambiado.
    router.replace({ path: '/comprar' })
  }
})

function reiniciar() {
  pasoActual.value = 0
  servicioSeleccionado.value = null
  asientoSeleccionado.value = null
  asientosOcupados.value = []
  reservaCreada.value = null
  fasePago.value = 'resumen'
  mensajeErrorPago.value = ''
  pasajero.value = { nombre: '', apellido: '', documento: '', email: '', telefono: '' }
}

// Función temporal para simular pago exitoso y pasar directamente a confirmación
async function simularPagoExitoso() {
  if (!servicioSeleccionado.value || !asientoSeleccionado.value) {
    alert('Debes seleccionar servicio y asiento primero.');
    return;
  }

  // Si no hay reserva, crear una simulada (sin pasar por Mercado Pago)
  if (!reservaCreada.value) {
    try {
      const data = await crearReserva({
        servicio_id: servicioSeleccionado.value.id,
        fecha_viaje: busqueda.value.fecha,
        asiento: asientoSeleccionado.value,
        total: servicioSeleccionado.value.precio,
        pasajero: pasajero.value,
        usuario_id: usuario.value?.id
      });
      reservaCreada.value = data;
    } catch (e) {
      console.error('Error creando reserva simulada:', e);
      alert('Error al crear reserva simulada.');
      return;
    }
  }

  // Forzar paso a confirmación (paso 6)
  pasoActual.value = 5;
}

const qrCanvas = ref(null)

watch([pasoActual, reservaCreada], async ([nuevoPaso, reserva]) => {
  if (nuevoPaso === 5 && reserva && servicioSeleccionado.value) {
    await nextTick() // espera a que el canvas esté en el DOM
    if (qrCanvas.value) {
      try {
        const texto = `Reserva N° ${reserva.id} - ${servicioSeleccionado.value.origen} → ${servicioSeleccionado.value.destino}, ${busqueda.value.fecha}, asiento ${asientoSeleccionado.value}, total $${reserva.total}`
        await QRcode.toCanvas(qrCanvas.value, texto, { width: 200 })

        // Enviar el QR por correo al pasajero
        const qrBase64 = qrCanvas.value.toDataURL('image/png')
        await enviarQRPorCorreo(reserva.id, pasajero.value.email, qrBase64)
      } catch (err) {
        console.error('Error generando QR:', err)
      }
    }
  }
})

// Modo debug (puedes ponerlo en true para pruebas)
const debugMode = ref(true)

// Función para forzar el paso de confirmación
function forzarConfirmacion() {
  if (!servicioSeleccionado.value) {
    // Si no hay servicio, creamos uno ficticio para poder probar
    servicioSeleccionado.value = {
      id: 999,
      origen: 'Melo',
      destino: 'Montevideo',
      hora: '08:00',
      empresa: 'COPSA',
      tipo: 'Semicama',
      duracion: '6h',
      precio: 1200,
      asientos: 40
    }
    busqueda.value.origen = 'Melo'
    busqueda.value.destino = 'Montevideo'
    busqueda.value.fecha = new Date().toISOString().slice(0, 10)
  }
  if (!asientoSeleccionado.value) {
    asientoSeleccionado.value = 1
  }
  if (!reservaCreada.value) {
    // Creamos una reserva ficticia
    reservaCreada.value = {
      id: Date.now(),
      total: servicioSeleccionado.value.precio
    }
  }
  pasoActual.value = 5
}

// Función para enviar el QR por correo con mejor manejo
async function enviarQRPorCorreo(reservaId, email, qrBase64) {
  if (!email) {
    $q?.notify?.({
      type: 'warning',
      message: 'No hay email registrado para enviar el QR.'
    })
    return false
  }

  try {
    const response = await fetch(`/api/reservas/enviar-qr.php?reserva_id=${reservaId}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ email, qrBase64 })
      }
    )

    if (!response.ok) {
      const errorText = await response.text()
      throw new Error(errorText || 'Error del servidor')
    }

    const data = await response.json()

    $q?.notify?.({
      type: 'positive',
      message: '✅ QR enviado a tu correo electrónico.'
    })

    return true

  } catch (error) {

    console.error(
      'Error enviando QR por correo:',
      error
    )

    $q?.notify?.({
      type: 'negative',
      message: '❌ No se pudo enviar el QR. Puedes descargarlo manualmente.'
    })

    return false
  }
}



// Función para descargar el QR como imagen
function descargarQR() {
  if (!qrCanvas.value) return
  const link = document.createElement('a')
  link.download = `reserva-${reservaCreada.value?.id || 'qr'}.png`
  link.href = qrCanvas.value.toDataURL('image/png')
  link.click()
}

// Función para reenviar (desde el botón)
async function reenviarCorreo() {
  if (!reservaCreada.value) return
  if (!qrCanvas.value) return
  const qrBase64 = qrCanvas.value.toDataURL('image/png')
  await enviarQRPorCorreo(reservaCreada.value.id, pasajero.value.email, qrBase64)
}


</script>

<style scoped>
/* parte de los asientos */

.asientos-grid {
  display: grid;
  grid-template-columns: 70px 70px 30px 70px 70px;
  gap: 15px;
  justify-content: center;
}

.asiento {
  width: 70px;
  height: 70px;
  border-radius: 12px;
  background: #ececec;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  font-weight: bold;
  transition: 0.2s;
  border: 2px solid transparent;
}

.asiento:hover {
  transform: scale(1.05);
}

.asiento.ocupado {
  background: #ff6b6b;
  color: white;
  cursor: not-allowed;
}

.asiento.seleccionado {
  background: #2ecc71;
  color: white;
  border-color: #27ae60;
}

/* saltar la columna del pasillo */
.asiento:nth-child(4n + 3) { grid-column: 4; }
.asiento:nth-child(4n + 4) { grid-column: 5; }

/*fin */

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

/* STEPPER */

.stepper{
  display:flex;
  align-items:center;
  margin-bottom:35px;
  gap:0;
}

.paso{
  display:flex;
  align-items:center;
  gap:8px;
}

.numero{
  width:25px;
  height:20px;
  border:2px solid #1a2138;
  border-radius:3px;
  display:flex;
  align-items:center;
  justify-content:center;
  font-size:13px;
  color:#7b8198;
  font-weight:bold;
}

.paso.activo .numero{
  background:#f4b400;
  border-color:#f4b400;
  color:black;
}

.paso.completado .numero{
  background:#00ff99;
  border-color:#00ff99;
  color:black;
}

.label{
  color:#7b8198;
  font-size:12px;
  letter-spacing:1px;
}

.paso.activo .label{
  color:white;
}

.linea{
  display:block;
  width:50px;
  height:1px;
  background:#1a2138;
  margin:0 12px;
}

/* FORMULARIO */

h2{
  color:white;
  font-size:16px;
  letter-spacing:2px;
  margin-bottom:25px;
}

.formulario{
  display:flex;
  gap:15px;
  align-items:flex-end;
  flex-wrap:wrap;
}

.campo{
  display:flex;
  flex-direction:column;
  gap:8px;
}

.campo label{
  color:#7b8198;
  font-size:11px;
  letter-spacing:2px;
}

.campo select,
.campo input{
  background:#0f1629;
  border:1px solid #1a2138;
  color:white;
  padding:12px 15px;
  border-radius:4px;
  font-size:14px;
  min-width:200px;
  cursor:pointer;
}

.btn-buscar{
  background:#f4b400;
  color:black;
  border:none;
  padding:12px 28px;
  font-weight:bold;
  font-size:13px;
  letter-spacing:2px;
  cursor:pointer;
  display:flex;
  align-items:center;
  gap:8px;
  border-radius:4px;
  transition:0.2s;
}

.btn-buscar:hover{
  background:#e0a300;
}

/* RESULTADOS */

.resultados{
  display:flex;
  flex-direction:column;
  gap:0;
  border:1px solid #1a2138;
  border-radius:6px;
  overflow:hidden;
  margin-bottom:20px;
}

.resultado-fila{
  display:grid;
  grid-template-columns:80px 200px 1fr 120px 140px;
  align-items:center;
  padding:20px 25px;
  border-bottom:1px solid #1a2138;
  cursor:pointer;
  transition:0.2s;
  gap:15px;
}

.resultado-fila:last-child{
  border-bottom:none;
}

.resultado-fila:hover{
  background:#0f1629;
}

.resultado-fila.seleccionado{
  background:#0f1629;
  border-left:3px solid #f4b400;
}

.res-hora{
  color:#f4b400;
  font-size:22px;
  font-weight:bold;
}

.res-empresa{
  display:block;
  color:white;
  font-size:15px;
  font-weight:600;
}

.res-tipo{
  display:block;
  color:#7b8198;
  font-size:12px;
  margin-top:3px;
  letter-spacing:1px;
}

.res-duracion{
  color:#7b8198;
  font-size:13px;
}

.res-precio{
  color:#00ffd0;
  font-size:20px;
  font-weight:bold;
}

.badge-disponible{
  background:#1a2138;
  color:#00ff99;
  padding:5px 10px;
  border-radius:3px;
  font-size:12px;
  border:1px solid #00ff99;
}

/* ACCIONES */

.acciones{
  display:flex;
  gap:15px;
  padding: 0% 20px;
}

.btn-volver{
  background:transparent;
  border:1px solid #1a2138;
  color:#7b8198;
  padding:12px 25px;
  cursor:pointer;
  font-size:13px;
  letter-spacing:1px;
  border-radius:4px;
  transition:0.2s;
  margin-top : 10px;
}

.btn-volver:hover{
  border-color:#7b8198;
  color:white;
}

.btn-siguiente{
  background:#f4b400;
  border:none;
  color:black;
  padding:12px 30px;
  cursor:pointer;
  font-size:13px;
  font-weight:bold;
  letter-spacing:1px;
  border-radius:4px;
  transition:0.2s;
  margin-top : 10px;
}

.btn-siguiente:disabled{
  opacity:0.4;
  cursor:not-allowed;
}

.btn-siguiente:not(:disabled):hover{
  background:#e0a300;
}

/* PLACEHOLDER */

.placeholder-paso{
  text-align:center;
  padding:60px;
  color:#7b8198;
}

.placeholder-paso h2{
  color:white;
  font-size:25px;
  margin:20px 0 10px;
}

/* ESTADOS / ERRORES */

.error-msg{
  color:#ff6b6b;
  font-size:13px;
  margin-top:15px;
  letter-spacing:0.5px;
}

.sin-resultados{
  color:#7b8198;
  font-size:13px;
  margin-bottom:20px;
  letter-spacing:0.5px;
}

/* RESUMEN DE PAGO */

.resumen-reserva{
  border:1px solid #1a2138;
  border-radius:6px;
  overflow:hidden;
  margin-bottom:25px;
  max-width:480px;
}

.resumen-fila{
  display:flex;
  justify-content:space-between;
  padding:14px 20px;
  border-bottom:1px solid #1a2138;
  font-size:13px;
}

.resumen-fila:last-child{
  border-bottom:none;
}

.resumen-fila span{
  color:#7b8198;
  letter-spacing:1px;
}

.resumen-fila strong{
  color:white;
}

.resumen-total{
  background:#0f1629;
}

.resumen-total strong{
  color:#00ffd0;
  font-size:18px;
}

@media (max-width: 700px) {
  .asiento {
    margin-left: 6px;
    width: 57px;
    height: 57px;
    font-size: 14px;
  }

  .stepper {
    overflow-x: auto;
    padding-bottom: 5px;
  }

  /* En mobile no entra el texto de cada paso: se deja solo el número
     circular (más compacto) y una línea más corta como conector. */
  .label {
    display: none;
  }

  .linea {
    width: 20px;
    margin: 0 5px;
  }

  .campo select,
  .campo input {
    min-width: 0;
    width: 100%;
  }

  .formulario {
    flex-direction: column;
    align-items: stretch;
  }

  .resultado-fila {
    grid-template-columns: 1fr;
    gap: 6px;
    text-align: left;
  }
}

/* Botón debug flotante */
.btn-debug {
  position: fixed;
  bottom: 30px;
  right: 30px;
  background: #ff6b35;
  color: white;
  border: none;
  padding: 14px 24px;
  border-radius: 50px;
  font-weight: bold;
  font-size: 14px;
  cursor: pointer;
  box-shadow: 0 4px 12px rgba(255, 107, 53, 0.4);
  z-index: 999;
  transition: 0.2s;
}
.btn-debug:hover {
  transform: scale(1.05);
  background: #e55a2b;
}

</style>
