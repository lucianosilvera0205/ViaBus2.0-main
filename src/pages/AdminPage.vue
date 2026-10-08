<!-- Panel de administrador: alta, edición y baja de viajes (ruta /admin, solo rol admin). -->
<template>

  <MainLayout>

    <!-- SUPERIOR -->
    <div class="superior">
      <div>
        <h1>PANEL DE ADMINISTRADOR</h1>
        <p>Gestioná los viajes que se ofrecen en la terminal</p>
      </div>
      <button class="btn-nuevo" @click="abrirFormularioNuevo">
        <q-icon name="add" size="18px" />
        NUEVO VIAJE
      </button>
    </div>

    <p v-if="errorGeneral" class="error-msg">{{ errorGeneral }}</p>

    <!-- ===================== FORMULARIO (alta / edición) ===================== -->
    <div v-if="formularioAbierto" class="panel-formulario">

      <h2>{{ editando ? 'EDITAR VIAJE' : 'NUEVO VIAJE' }}</h2>

      <div class="formulario">

        <!-- Origen/destino/empresa solo se pueden definir al crear el viaje -->
        <div class="campo">
          <label>ORIGEN</label>
          <select v-model="form.origen" :disabled="editando">
            <option v-for="c in ciudades" :key="c" :value="c">{{ c }}</option>
          </select>
        </div>

        <div class="campo">
          <label>DESTINO</label>
          <select v-model="form.destino" :disabled="editando">
            <option v-for="c in ciudades" :key="c" :value="c">{{ c }}</option>
          </select>
        </div>

        <div class="campo">
          <label>EMPRESA</label>
          <select v-model="form.empresa" :disabled="editando">
            <option v-for="e in empresas" :key="e.id" :value="e.nombre">{{ e.nombre }}</option>
          </select>
        </div>

        <div class="campo">
          <label>HORA</label>
          <input type="time" v-model="form.hora" />
        </div>

        <div class="campo">
          <label>TIPO</label>
          <input type="text" v-model="form.tipo" placeholder="De Linea" />
        </div>

        <div class="campo">
          <label>DURACIÓN</label>
          <input type="text" v-model="form.duracion" placeholder="5h 44m" />
        </div>

        <div class="campo">
          <label>PRECIO</label>
          <input type="number" v-model.number="form.precio" min="0" step="10" />
        </div>

        <div class="campo">
          <label>ASIENTOS</label>
          <input type="number" v-model.number="form.asientos" min="1" />
        </div>

        <div class="campo">
          <label>BUS</label>
          <input type="text" v-model="form.bus" placeholder="MELMON-1234" />
        </div>

      </div>

      <p v-if="errorFormulario" class="error-msg">{{ errorFormulario }}</p>

      <div class="acciones">
        <button class="btn-volver" @click="cerrarFormulario">Cancelar</button>
        <button class="btn-siguiente" :disabled="guardando" @click="guardar">
          {{ guardando ? 'Guardando...' : (editando ? 'Guardar cambios' : 'Crear viaje') }}
        </button>
      </div>

    </div>

    <!-- ===================== LISTADO DE VIAJES ===================== -->
    <h2 class="titulo-lista">VIAJES ACTIVOS</h2>

    <p v-if="cargando" class="sin-resultados">Cargando viajes...</p>
    <p v-else-if="servicios.length === 0" class="sin-resultados">No hay viajes cargados todavía.</p>

    <div v-else class="tabla">

      <div class="tabla-header">
        <div>Origen → Destino</div>
        <div>Empresa</div>
        <div>Hora</div>
        <div>Tipo</div>
        <div>Precio</div>
        <div>Estado</div>
        <div>Acciones</div>
      </div>

      <div v-for="s in servicios" :key="s.id" class="tabla-fila">
        <div>{{ s.origen }} → {{ s.destino }}</div>
        <div>{{ s.empresa }}</div>
        <div>{{ s.hora }}</div>
        <div>{{ s.tipo }}</div>
        <div>${{ s.precio }}</div>
        <div><StatusBadge :tipo="s.estado" /></div>
        <div class="fila-acciones">
          <button class="btn-icono" title="Editar" @click="abrirFormularioEdicion(s)">
            <q-icon name="edit" size="16px" />
          </button>
          <button class="btn-icono btn-icono-borrar" title="Desactivar" @click="borrar(s)">
            <q-icon name="delete" size="16px" />
          </button>
        </div>
      </div>

    </div>

  </MainLayout>

</template>

<script setup>
import { ref, onMounted } from 'vue'
import MainLayout from '../layouts/MainLayout.vue'
import StatusBadge from '../components/common/StatusBadge.vue'
import {
  getTodosServicios,
  getCiudades,
  getEmpresas,
  crearServicio,
  actualizarServicio,
  eliminarServicio
} from '../services/api'

const servicios = ref([])
const ciudades = ref([])
const empresas = ref([])
const cargando = ref(false)
const errorGeneral = ref('')

async function cargarTodo() {
  cargando.value = true
  errorGeneral.value = ''
  try {
    const [listaServicios, listaCiudades, listaEmpresas] = await Promise.all([
      getTodosServicios(),
      getCiudades(),
      getEmpresas()
    ])
    servicios.value = listaServicios
    ciudades.value = listaCiudades.map(c => c.nombre)
    empresas.value = listaEmpresas
  } catch (e) {
    errorGeneral.value = e.message
  } finally {
    cargando.value = false
  }
}

onMounted(cargarTodo)

// ---- Formulario (alta / edición) ----
const formularioAbierto = ref(false)
const editando = ref(null) // null = alta | id del servicio si se está editando
const guardando = ref(false)
const errorFormulario = ref('')

function formularioVacio() {
  return {
    origen: ciudades.value[0] || '',
    destino: ciudades.value[1] || '',
    empresa: empresas.value[0]?.nombre || '',
    hora: '',
    tipo: 'De Linea',
    duracion: '',
    precio: null,
    asientos: 40,
    bus: ''
  }
}

const form = ref(formularioVacio())

function abrirFormularioNuevo() {
  editando.value = null
  errorFormulario.value = ''
  form.value = formularioVacio()
  formularioAbierto.value = true
}

function abrirFormularioEdicion(servicio) {
  editando.value = servicio.id
  errorFormulario.value = ''
  form.value = {
    origen: servicio.origen,
    destino: servicio.destino,
    empresa: servicio.empresa,
    hora: servicio.hora,
    tipo: servicio.tipo,
    duracion: servicio.duracion,
    precio: servicio.precio,
    asientos: servicio.asientos,
    bus: servicio.bus
}

  formularioAbierto.value = true
}

function cerrarFormulario() {
  formularioAbierto.value = false
}

async function guardar() {
  if (!form.value.hora || !form.value.tipo) {
    errorFormulario.value = 'Hora y tipo son obligatorios'
    return
  }

  guardando.value = true
  errorFormulario.value = ''
  try {
    if (editando.value) {
      // Al editar solo se pueden cambiar hora/tipo/duración/precio/asientos/andén/bus/estado
      const { hora, tipo, duracion, precio, asientos, bus } = form.value
      await actualizarServicio(editando.value, { hora, tipo, duracion, precio, asientos, bus})
    } else {
      if (!form.value.origen || !form.value.destino || !form.value.empresa) {
        errorFormulario.value = 'Origen, destino y empresa son obligatorios'
        guardando.value = false
        return
      }
      await crearServicio(form.value)
    }
    formularioAbierto.value = false
    await cargarTodo()
  } catch (e) {
    errorFormulario.value = e.message
  } finally {
    guardando.value = false
  }
}

async function borrar(servicio) {
  if (!confirm(`¿Desactivar el viaje ${servicio.origen} → ${servicio.destino} (${servicio.hora})?`)) return
  try {
    await eliminarServicio(servicio.id)
    await cargarTodo()
  } catch (e) {
    errorGeneral.value = e.message
  }
}
</script>

<style scoped>

.superior{
  display:flex;
  justify-content:space-between;
  align-items:flex-end;
  padding-bottom:20px;
  border-bottom:1px solid #1a2138;
  margin-bottom:30px;
}

h1{
  font-size:38px;
  letter-spacing:3px;
  color:white;
}

.superior p{
  color:#7b8198;
  margin-top:8px;
  font-size:13px;
  letter-spacing:1px;
}

.btn-nuevo{
  background:#f4b400;
  color:black;
  border:none;
  padding:12px 22px;
  font-weight:bold;
  font-size:13px;
  letter-spacing:1px;
  cursor:pointer;
  display:flex;
  align-items:center;
  gap:8px;
  border-radius:4px;
  transition:0.2s;
}

.btn-nuevo:hover{
  background:#e0a300;
}

/* FORMULARIO */

.panel-formulario{
  border:1px solid #1a2138;
  border-radius:6px;
  padding:25px;
  margin-bottom:35px;
  background:#0a0f22;
}

h2{
  color:white;
  font-size:16px;
  letter-spacing:2px;
  margin-bottom:25px;
}

.titulo-lista{
  margin-top:10px;
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
  min-width:160px;
}

.campo select:disabled{
  opacity:0.5;
  cursor:not-allowed;
}

.acciones{
  display:flex;
  gap:15px;
  margin-top:25px;
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
}

.btn-siguiente:disabled{
  opacity:0.4;
  cursor:not-allowed;
}

.btn-siguiente:not(:disabled):hover{
  background:#e0a300;
}

/* TABLA */

.tabla{
  border:1px solid #1a2138;
  border-radius:6px;
  overflow:hidden;
}

.tabla-header,
.tabla-fila{
  display:grid;
  grid-template-columns:1.6fr 1fr 0.7fr 1fr 0.7fr 1fr 0.8fr;
  align-items:center;
  padding:14px 20px;
  gap:10px;
}

.tabla-header{
  background:#0f1629;
  color:#7b8198;
  font-size:11px;
  letter-spacing:1px;
}

.tabla-fila{
  border-top:1px solid #1a2138;
  color:white;
  font-size:13px;
}

.fila-acciones{
  display:flex;
  gap:8px;
}

.btn-icono{
  background:transparent;
  border:1px solid #1a2138;
  color:#7b8198;
  width:30px;
  height:30px;
  border-radius:4px;
  cursor:pointer;
  display:flex;
  align-items:center;
  justify-content:center;
  transition:0.2s;
}

.btn-icono:hover{
  color:white;
  border-color:#7b8198;
}

.btn-icono-borrar:hover{
  color:#ff6b6b;
  border-color:#ff6b6b;
}

/* ESTADOS / ERRORES */

.error-msg{
  color:#ff6b6b;
  font-size:13px;
  margin-top:15px;
  margin-bottom: 15px;
  letter-spacing:0.5px;
}

.sin-resultados{
  color:#7b8198;
  font-size:13px;
  margin-bottom:20px;
  letter-spacing:0.5px;
}

@media (max-width: 900px) {
  .superior {
    flex-direction: column;
    align-items: flex-start;
    gap: 15px;
  }

  h1 {
    font-size: 26px;
  }

  .formulario {
    flex-direction: column;
    align-items: stretch;
  }

  .campo select,
  .campo input {
    min-width: 0;
    width: 100%;
  }

  /* La tabla no se apila (rompería las columnas de datos): se hace
     scrollable horizontalmente para no desbordar la pantalla. */
  .tabla {
    overflow-x: auto;
  }

  .tabla-header,
  .tabla-fila {
    grid-template-columns: 160px 120px 70px 100px 80px 110px 90px;
    min-width: 700px;
  }
}

</style>
