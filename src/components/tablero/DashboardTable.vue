<!-- Tabla de servicios (próximos o ya salidos) del tablero. Antes: BloqueTableroTabla.vue -->
<template>

  <div class="tabla">



    <p v-if="cargando" class="estado-msg">Cargando servicios...</p>
    <p v-else-if="servicios.length === 0" class="estado-msg">
      {{ modo === 'proximos' ? 'No quedan más salidas por hoy.' : 'Todavía no salió ningún servicio hoy.' }}
    </p>

    <!-- FILAS -->
    <DashboardTableRow
      v-for="servicio in servicios"
      :key="servicio.id"
      :servicio="servicio"
      :editable="modo === 'proximos'"
      @toggle-demora="$emit('toggle-demora', $event)"
    />

  </div>

</template>

<script setup>

import DashboardTableRow from './DashboardTableRow.vue'

defineProps({
  servicios: { type: Array, default: () => [] },
  modo: { type: String, default: 'proximos' },
  cargando: { type: Boolean, default: false }
})

defineEmits(['toggle-demora'])

</script>

<style scoped>

.tabs-container {
  display: flex;
  gap: 0;
  width: fit-content;
  border-bottom: 1px solid #1a2138;
}

.tab {
  padding: 11px 22px;
  background: transparent;
  border: none;
  color: #7b8198;
  font-size: 10px;
  font-weight: bold;
  letter-spacing: 1.5px;
  cursor: pointer;
  transition: 0.2s;
  border-bottom: 3px solid transparent;
  margin-bottom: -1px;
}

.tab:hover {
  color: white;
}

.tab.activo {
  color: #f4b400;
  border-bottom: 3px solid #f4b400;
}

</style>
