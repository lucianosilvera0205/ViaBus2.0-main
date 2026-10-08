<!--
  Ficha completa de una empresa de transporte (ruta /empresas/:id).

  Es una sola página dinámica para TODAS las empresas (no una página fija
  por empresa) porque son la misma estructura de datos con contenido
  distinto: crear un archivo .vue por empresa significaría duplicar este
  mismo layout 7 veces y volver a tocar 7 archivos cada vez que cambie
  el diseño. Con la ruta dinámica, agregar una empresa nueva no requiere
  tocar ni una línea de frontend: alcanza con un INSERT en la tabla
  "empresas".
-->
<template>

  <MainLayout>

    <router-link to="/info" class="volver">
      <q-icon name="arrow_back" size="16px" />
      Info general
    </router-link>

    <p v-if="cargando" class="estado-msg">Cargando información de la empresa...</p>

    <div v-else-if="error" class="estado-msg error">
      {{ error }}
    </div>

    <template v-else-if="empresa">

      <!-- ENCABEZADO -->
      <div class="encabezado">
        <div class="logo-wrap">
          <q-img v-if="logo" :src="logo" :alt="empresa.nombre" />
          <div v-else class="logo-placeholder">{{ empresa.nombre }}</div>
        </div>

        <div>
          <h1>{{ empresa.nombre }}</h1>
          <p class="subtitulo">Empresa de transporte de pasajeros</p>
        </div>
      </div>

      <div class="grilla">

        <!-- DESCRIPCION -->
        <div class="tarjeta descripcion">
          <h2>SOBRE LA EMPRESA</h2>
          <p>{{ empresa.descripcion || 'Todavía no hay una descripción cargada para esta empresa.' }}</p>

          <router-link to="/comprar" class="btn-comprar">
            <q-icon name="receipt" size="18px" />
            Ver horarios y comprar pasaje
          </router-link>
        </div>

        <!-- CONTACTO -->
        <div class="tarjeta">
          <h2>CONTACTO</h2>

          <div v-if="tieneContacto" class="lista-contacto">
            <a v-if="empresa.telefono" :href="`tel:${empresa.telefono.replace(/\s/g, '')}`" class="fila-contacto">
              <q-icon name="call" size="18px" />
              <span>{{ empresa.telefono }}</span>
            </a>
            <a v-if="empresa.email" :href="`mailto:${empresa.email}`" class="fila-contacto">
              <q-icon name="mail" size="18px" />
              <span>{{ empresa.email }}</span>
            </a>
            <a v-if="empresa.sitio_web" :href="urlSitioWeb" target="_blank" rel="noopener" class="fila-contacto">
              <q-icon name="language" size="18px" />
              <span>{{ empresa.sitio_web }}</span>
            </a>
            <div v-if="empresa.direccion" class="fila-contacto">
              <q-icon name="place" size="18px" />
              <span>{{ empresa.direccion }}</span>
            </div>
          </div>
          <p v-else class="sin-datos">
            Esta empresa todavía no cargó su información de contacto.
          </p>
        </div>

        <!-- RUTAS -->
        <div class="tarjeta rutas">
          <h2>RUTAS QUE OPERA</h2>

          <div v-if="empresa.rutas.length > 0" class="lista-rutas">
            <div v-for="(r, i) in empresa.rutas" :key="i" class="fila-ruta">
              <span class="trayecto">{{ r.origen }} <q-icon name="arrow_forward" size="14px" /> {{ r.destino }}</span>
              <span class="frecuencia">{{ r.frecuencias }} {{ r.frecuencias === 1 ? 'servicio/día' : 'servicios/día' }}</span>
            </div>
          </div>
          <p v-else class="sin-datos">
            Esta empresa no tiene servicios activos en este momento.
          </p>
        </div>

      </div>

    </template>

  </MainLayout>

</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import MainLayout from '../layouts/MainLayout.vue'
import { getEmpresa } from '../services/api'

const logos = import.meta.glob('../assets/empresas/*', { eager: true, import: 'default' })

function logoDe(nombreArchivo) {
  if (!nombreArchivo) return null
  const entry = Object.entries(logos).find(([path]) => path.endsWith('/' + nombreArchivo))
  return entry ? entry[1] : null
}

const route = useRoute()

const empresa = ref(null)
const cargando = ref(false)
const error = ref('')

const logo = computed(() => empresa.value ? logoDe(empresa.value.logo) : null)

const tieneContacto = computed(() => {
  if (!empresa.value) return false
  const e = empresa.value
  return !!(e.telefono || e.email || e.sitio_web || e.direccion)
})

// El sitio_web se guarda como "www.ega.com.uy" (sin protocolo); acá se le
// agrega el https:// para que el link realmente abra la página.
const urlSitioWeb = computed(() => {
  const web = empresa.value?.sitio_web
  if (!web) return ''
  return web.startsWith('http') ? web : `https://${web}`
})

async function cargarEmpresa(id) {
  cargando.value = true
  error.value = ''
  empresa.value = null
  try {
    empresa.value = await getEmpresa(id)
  } catch (e) {
    error.value = e.message
  } finally {
    cargando.value = false
  }
}

onMounted(() => cargarEmpresa(route.params.id))

// Si el usuario navega de una ficha a otra sin recargar la página
// (ej. desde el sidebar), hay que volver a pedir los datos.
watch(() => route.params.id, (nuevoId) => cargarEmpresa(nuevoId))
</script>

<style scoped>

.volver {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  color: #7b8198;
  text-decoration: none;
  font-size: 12px;
  letter-spacing: 1px;
  margin-bottom: 25px;
  transition: color 0.2s;
}

.volver:hover {
  color: #f4b400;
}

.estado-msg {
  color: #7b8198;
  font-size: 13px;
  letter-spacing: 1px;
}

.estado-msg.error {
  color: #ff6b6b;
}

.encabezado {
  display: flex;
  align-items: center;
  gap: 24px;
  margin-bottom: 30px;
  padding-bottom: 25px;
  border-bottom: 1px solid #1a2138;
}

.logo-wrap {
  width: 110px;
  height: 110px;
  background: white;
  border-radius: 10px;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.logo-wrap :deep(img) {
  object-fit: contain;
}

.logo-placeholder {
  color: #0b1023;
  font-weight: bold;
  text-align: center;
  padding: 8px;
  font-size: 12px;
}

.encabezado h1 {
  color: white;
  font-size: 30px;
  letter-spacing: 1px;
}

.subtitulo {
  color: #7b8198;
  font-size: 12px;
  letter-spacing: 1px;
  margin-top: 4px;
}

.grilla {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 20px;
}

.tarjeta {
  background: #0f1629;
  border: 1px solid #1a2138;
  border-radius: 10px;
  padding: 24px;
  grid-column: 2;
}

.tarjeta.descripcion {
  grid-row: 1 / 3;
  grid-column: 1;
}

.tarjeta h2 {
  color: white;
  font-size: 13px;
  letter-spacing: 2px;
  margin-bottom: 16px;
}

.tarjeta.descripcion p {
  color: #b8bfd4;
  font-size: 14px;
  line-height: 1.8;
}

.btn-comprar {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  margin-top: 24px;
  padding: 12px 22px;
  background: #f4b400;
  color: #0b1023;
  text-decoration: none;
  border-radius: 6px;
  font-size: 13px;
  font-weight: bold;
  letter-spacing: 1px;
  transition: background 0.2s;
}

.btn-comprar:hover {
  background: #ffcb2b;
}

.sin-datos {
  color: #7b8198;
  font-size: 13px;
  line-height: 1.6;
}

.lista-contacto {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.fila-contacto {
  display: flex;
  align-items: center;
  gap: 10px;
  color: #b8bfd4;
  font-size: 13px;
  text-decoration: none;
  transition: color 0.2s;
}

a.fila-contacto {
  cursor: pointer;
}

a.fila-contacto:hover {
  color: #f4b400;
}

.fila-contacto .q-icon {
  color: #f4b400;
}

.lista-rutas {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.fila-ruta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 0;
  border-bottom: 1px solid #1a2138;
  font-size: 13px;
}

.fila-ruta:last-child {
  border-bottom: none;
}

.trayecto {
  color: white;
  display: flex;
  align-items: center;
  gap: 6px;
}

.trayecto .q-icon {
  color: #7b8198;
}

.frecuencia {
  color: #7b8198;
  font-size: 11px;
  letter-spacing: 1px;
}

@media (max-width: 900px) {
  .grilla {
    grid-template-columns: 1fr;
  }
  .tarjeta,
  .tarjeta.descripcion {
    grid-column: 1;
    grid-row: auto;
  }
  .encabezado {
    flex-direction: column;
    text-align: center;
  }
}

</style>
