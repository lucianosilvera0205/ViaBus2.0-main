<!-- Sección de estadísticas (andenes, servicios, pasajeros, años) en el home. Antes: BloqueEstadisticas.vue -->
<template>

  <div class="estadisticas">

    <!--
      TARJETAS DEL INICIO CON INFORMACION
    -->

   <StatCard
      numero="7"
      texto="ANDENES"
      icono="directions_bus" />


    <StatCard
    :numero="totalServicios"
    texto="SERVICIOS"
    icono="route" />

    <StatCard
    numero="12K"
    texto="PASAJEROS"
    icono="people" />

    <StatCard
    numero="45"
    texto="AÑOS"
    icono="history" />

  </div>

</template>

<script setup>

import { ref, onMounted } from 'vue'
import StatCard from '../common/StatCard.vue'
import { getTodosServicios } from '../../services/api'

const totalServicios = ref('...')

onMounted(async () => {
  try {
    const data = await getTodosServicios()
    totalServicios.value = String(data.length)
  } catch {
    totalServicios.value = '—'
  }
})

</script>

<style scoped>

.estadisticas{

  margin-top:40px;

  display:grid;

  grid-template-columns:repeat(4,1fr);

  gap:20px;

}

@media (max-width: 700px) {
  .estadisticas {
    grid-template-columns: repeat(2, 1fr);
    gap: 12px;
    margin-top: 25px;
  }
}

</style>
