<!-- los recuadros con estadisticas del tablero, todos hacen consultas al backend
 de ahi sacan la infromacion que van a mostrar en pantalla dependiendo de la hora actual-->
<template>

  <div class="metricas">

    <MetricCard
      titulo="EN EMBARQUE"
      :numero="String(data?.andenes_activos ?? 0) + ' / ' + String(data?.andenes_totales ?? 0)"
      subtitulo="Andenes activos (próximos 15 min)"
      color="#f4b400"
    />

    <MetricCard
      titulo="PRÓXIMAS SALIDAS"
      :numero="String(conteo.horario)"
      subtitulo="En horario"
      color="#00ffd0"
    />

    <MetricCard
      titulo="YA SALIERON HOY"
      :numero="String(data?.salidos?.length ?? 0)"
      subtitulo="Servicios completados"
      color="#00ff99"
    />

    <MetricCard
      titulo="CON DEMORA"
      :numero="String(conteo.demorado)"
      subtitulo="Marcados manualmente"
      color="#ff5b5b"
    />

  </div>

</template>

<script setup>

import { computed } from 'vue'
import MetricCard from './MetricCard.vue'

const props = defineProps({
  data: { type: Object, default: null }
})

const conteo = computed(() => {

  const proximos = props.data?.proximos ?? []

  const c = {
    embarcando: 0,
    horario: 0,
    demorado: 0
  }

  for (const s of proximos) {

    if (s.estado === 'embarcando') {
      c.embarcando++
    }

    else if (s.estado === 'demorado') {
      c.demorado++
    }

    else {
      c.horario++
    }

  }

  return c

})

</script>

<style scoped>

.metricas {

  margin-left: 20px;

  display: grid;

  grid-template-columns: repeat(4, 1fr);

  gap: 14px;

  font-family: 'Inter', sans-serif;

}

/* Tablets */

@media (max-width: 1000px) {

  .metricas {

    grid-template-columns: repeat(2, 1fr);

  }

}

/* Celulares */

@media (max-width: 600px) {

  .metricas {

    margin-left: 0;

    grid-template-columns: 1fr;

    gap: 10px;

  }

}

</style>
