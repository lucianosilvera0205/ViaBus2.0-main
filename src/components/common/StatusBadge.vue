<!-- Insignia de estado de un servicio (en horario / demorado / embarcando / etc). Antes: BloqueTableroEstado.vue -->
<template>

  <span class="estado" :class="clase">
    <span class="punto" v-if="tipo !== 'embarcando' && tipo !== 'programado'" />
    <q-icon v-if="tipo === 'embarcando'" name="play_arrow" size="12px" />
    {{ texto }}
  </span>

</template>

<script setup>

import { computed } from 'vue'

const props = defineProps({
  tipo: String // 'horario' | 'demorado' | 'embarcando' | 'programado' | 'partio'
})

const texto = computed(() => {
  const map = {
    horario: 'EN HORARIO',
    demorado: 'DEMORADO',
    embarcando: 'EMBARCANDO',
    programado: 'PROGRAMADO',
    partio: 'PARTIÓ'
  }
  return map[props.tipo] || props.tipo
})

const clase = computed(() => props.tipo)

</script>

<style scoped>

.estado{
  display: inline-flex;
  align-items:center;
  gap:6px;
  padding:6px 12px;
  border-radius:3px;
  font-size:11px;
  letter-spacing:1px;
  font-weight:bold;
}

.punto{
  width:7px;
  height:7px;
  border-radius:50%;
}

/* ESTADOS */

.horario{
  border:1px solid #00ff99;
  color:#00ff99;
}
.horario .punto{ background:#00ff99; }

.demorado{
  border:1px solid #ff5b5b;
  color:#ff5b5b;
}
.demorado .punto{ background:#ff5b5b; }

.embarcando{
  border:1px solid #f4b400;
  color:#f4b400;
}

.programado{
  border:1px solid #a855f7;
  color:#a855f7;
}
.programado .punto{ background:#a855f7; }

.partio{
  border:1px solid #7b8198;
  color:#7b8198;
}
.partio .punto{ background:#7b8198; }

</style>
