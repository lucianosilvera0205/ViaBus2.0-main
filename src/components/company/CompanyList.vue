<!--
  Grilla de logos de las empresas de transporte. Cada logo es un enlace a
  su ficha completa (CompanyDetailPage, ruta /empresas/:id). Antes,
  BloqueEmpresas.vue mostraba el logo + la descripción larga acá mismo;
  ahora la descripción, el contacto y las rutas viven en la ficha propia
  de cada empresa, y acá solo queda la vidriera con el indicador de que
  es clickeable.
-->
<template>
  <div class="empresas">

    <p v-if="cargando" class="estado-msg">Cargando empresas...</p>
    <p v-else-if="error" class="estado-msg error">{{ error }}</p>
    <p v-else-if="empresas.length === 0" class="estado-msg">No hay empresas registradas.</p>

    <router-link
      v-for="e in empresas"
      :key="e.id"
      :to="`/empresas/${e.id}`"
      class="tarjeta-empresa"
    >
      <q-img
        v-if="logoDe(e)"
        class="empresa-logo"
        :src="logoDe(e)"
        :alt="e.nombre"
      />
      <div v-else class="empresa-logo empresa-logo--placeholder">{{ e.nombre }}</div>

      <div class="overlay">
        <q-icon name="info" size="22px" />
        <span>Click para más información</span>
      </div>
    </router-link>

  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getEmpresas } from '../../services/api'

// Resuelve estáticamente todas las imágenes de la carpeta assets/empresas
// para poder referenciarlas dinámicamente según el campo "logo" que llega
// del backend (nombre de archivo).
const logos = import.meta.glob('../../assets/empresas/*', { eager: true, import: 'default' })

function logoDe(empresa) {
  if (!empresa.logo) return null
  const entry = Object.entries(logos).find(([path]) => path.endsWith('/' + empresa.logo))
  return entry ? entry[1] : null
}

const empresas = ref([])
const cargando = ref(false)
const error = ref('')

async function cargarEmpresas() {
  cargando.value = true
  error.value = ''
  try {
    empresas.value = await getEmpresas()
  } catch (e) {
    error.value = e.message
  } finally {
    cargando.value = false
  }
}

onMounted(cargarEmpresas)
</script>

<style scoped>
.empresas {
  display: flex;
  flex-wrap: wrap;
  width: 100%;
  justify-content: center;
  gap: 20px;
  margin-top: 10px;
  margin-bottom: 10px;
}

.estado-msg {
  width: 100%;
  text-align: center;
  color: #7b8198;
  font-size: 13px;
  letter-spacing: 1px;
}

.estado-msg.error {
  color: #ff6b6b;
}

.tarjeta-empresa {
  position: relative;
  background: #ffffff;
  border: 1px solid #1a2138;
  border-radius: 8px;
  width: 220px;
  height: 140px;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  cursor: pointer;
  text-decoration: none;
  transition: border-color 0.25s, transform 0.25s, box-shadow 0.25s;
}

.tarjeta-empresa:hover {
  border-color: #f4b400;
  transform: translateY(-6px);
  box-shadow: 0 12px 30px rgba(0, 0, 0, 0.4);
}

.empresa-logo {
  width: 100%;
  height: 100%;
  object-fit: contain;
  padding: 24px;
}

.empresa-logo--placeholder {
  display: flex;
  align-items: center;
  justify-content: center;
  color: #7b8198;
  font-weight: bold;
  letter-spacing: 1px;
  text-align: center;
  padding: 10px;
}

/* Indicador de que el logo es interactivo: aparece al pasar el mouse */
.overlay {
  position: absolute;
  inset: 0;
  background: rgba(11, 16, 35, 0.92);
  color: white;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  font-size: 11px;
  font-weight: bold;
  letter-spacing: 1px;
  text-align: center;
  opacity: 0;
  transition: opacity 0.25s;
}

.overlay :deep(.q-icon) {
  color: #f4b400;
}

.tarjeta-empresa:hover .overlay {
  opacity: 1;
}

/* En pantallas táctiles (sin hover real) se muestra siempre una pista sutil */
@media (hover: none) {
  .overlay {
    opacity: 1;
    background: linear-gradient(to top, rgba(11, 16, 35, 0.85), transparent 60%);
    justify-content: flex-end;
    padding-bottom: 10px;
  }
}
</style>
