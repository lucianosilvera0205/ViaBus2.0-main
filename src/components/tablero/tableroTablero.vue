<!-- Orquesta el tablero completo: carga datos, refresca cada 30s y compone header/metricas/tabs/tabla. -->
<template>

  <div class="contenedor-tablero">

    <!-- Encabezado del tablero -->
    <DashboardHeader />

    <!-- Tarjetas con las métricas -->
    <DashboardMetrics :data="tablero" />

    <!-- Mensaje de error en caso de que falle la carga -->
    <p v-if="error" class="tablero-error">{{ error }}</p>

    <!-- Contenedor de pestañas + tabla -->
    <div class="tabla-contenedor">

  <!-- Pestañas para cambiar entre servicios próximos y salidos -->
  <DashboardTabs v-model="tabActivo" />

  <!-- Tabla que muestra los servicios según la pestaña seleccionada -->
  <DashboardTable
    :servicios="serviciosVisibles"
    :modo="tabActivo"
    :cargando="cargando && !tablero"
    @toggle-demora="alternarDemora"
  />

    </div>

  </div>

</template>

<script setup>

// Importa las funciones reactivas, los componentes y el ciclo de vida de Vue
import { ref, computed, onMounted, onUnmounted } from 'vue'
import DashboardHeader from './DashboardHeader.vue'
import DashboardMetrics from './DashboardMetrics.vue'
import DashboardTabs from './DashboardTabs.vue'
import DashboardTable from './DashboardTable.vue'

// Importa las funciones que consumen la API
import { getTablero, marcarDemora } from '../../services/api'

// Creamos una variable "tablero" para almacenar
// toda la información del tablero obtenida desde la API
const tablero = ref(null)

// Creamos una variable "cargando" para indicar si
// se está realizando una petición
const cargando = ref(false)

// Creamos una variable "error" para que
// guarde un posible mensaje de error
const error = ref('')

// Creamos una variable "tabActivo" para que
// guarde la pestaña actualmente seleccionada
const tabActivo = ref('proximos')

// Creamos una variable "intervalo" que guardará
// el identificador del intervalo
let intervalo = null

// Obtiene los datos del tablero desde la API
async function cargarTablero() {

  // Activa el indicador de carga
  cargando.value = true

  try {

    // Solicita la información del tablero
    tablero.value = await getTablero()

    // Limpia errores anteriores
    error.value = ''

  } catch (e) {

    // Guarda el mensaje de error si ocurre algún problema
    error.value = e.message

  } finally {

    // Finaliza el estado de carga
    cargando.value = false
  }
}

// Creamos una variable "serviciosVisibles"
// que calcule qué lista de servicios debe mostrarse
// dependiendo de la pestaña seleccionada
const serviciosVisibles = computed(() => {

  // Si aún no hay datos, devuelve un arreglo vacío
  if (!tablero.value) return []

  // Devuelve los servicios correspondientes a la pestaña activa
  return tabActivo.value === 'proximos' ? tablero.value.proximos : tablero.value.salidos
})

// Cambia el estado de demora de un servicio
async function alternarDemora({ id, demorado }) {
  try {

    // Actualiza el estado en la API
    await marcarDemora(id, demorado)

    // Recarga el tablero para mostrar los cambios
    await cargarTablero()

  } catch (e) {

    // Guarda el error si ocurre algún problema
    error.value = e.message
  }
}

// Se ejecuta cuando el componente aparece en pantalla
onMounted(() => {

  // Carga los datos por primera vez
  cargarTablero()

  // El tablero depende de la hora actual (qué salió, qué está por salir,
  // cuántos andenes están activos), así que se refresca solo cada 30 segundos
  intervalo = setInterval(cargarTablero, 30000)
})

// Se ejecuta cuando el componente se destruye
onUnmounted(() => {

  // Elimina el intervalo para evitar consumo innecesario de recursos
  if (intervalo) clearInterval(intervalo)
})

</script>

<style scoped>

.tabla-contenedor {
  width: 100%;
  border: 1px solid #1a2138;
  border-radius: 6px;
  overflow: hidden;
}

.contenedor-tablero{

  width:100%;
  max-width: 1000px;
  margin: 0 auto;
  display: flex;
  flex-direction:column;

  gap:30px;

}

.tablero-error{
  color:#ff6b6b;
  font-size:13px;
  letter-spacing:0.5px;
}

</style>

<!--
Diccionario de términos:

Variable Reactiva (ref):
Una variable reactiva es un tipo especial de variable que, al
cambiar su valor, notifica y actualiza automáticamente a todos los
elementos del código o de la interfaz de usuario que dependen de ella.

API:
Una API (Application Programming Interface) o Interfaz de Programación de Aplicaciones
es un conjunto de reglas y protocolos que permite que dos aplicaciones de software
se comuniquen e intercambien datos entre sí.

Ciclo de vida de Vue:
En este caso, cuando nos referimos al ciclo de vida nos referimos al de un componente en Vue.
Es el conjunto de etapas por las que pasa un componente desde que se crea hasta que desaparece.
En la parte que se menciona en este codigo es cuando importamos onMounted y onUnmounted que son
las funciones usadas para crear dicho ciclo.

-->
