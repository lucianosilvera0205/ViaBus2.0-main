<!-- Fila de la tabla de servicios del tablero. Antes: BloqueTableroFila.vue -->
<template>

  <div class="fila">

  <!-- HORA -->
  <div class="col-hora">
    <span class="subtitulo">HORA</span>
    <span class="hora-servicio">{{ servicio.hora }}</span>
  </div>

  <!-- DESTINO -->
  <div class="col-destino">
    <span class="subtitulo">DESTINO</span>
    <span class="destino">{{ servicio.destino }}</span>
  </div>

  <!-- ANDEN -->
  <div class="col-anden">
    <span class="subtitulo">ANDEN</span>
    <span class="anden">{{ servicio.anden || '—' }}</span>
  </div>

  <!-- N° BUS -->
  <div class="col-bus">
    <span class="subtitulo">N° BUS</span>
    <span class="bus">{{ servicio.bus }}</span>
  </div>

  <!-- EMPRESA -->
  <div class="col-empresa">
    <span class="subtitulo">EMPRESA</span>
    <span class="empresa">{{ servicio.empresa }}</span>
  </div>

  <!-- TIPO -->
  <div class="col-tipo">
    <span class="subtitulo">TIPO</span>
    <span class="tipo">{{ servicio.tipo }}</span>
  </div>

  <!-- ESTADO -->
  <div class="col-estado">
    <div>
      <span class="subtitulo">ESTADO</span>
      <StatusBadge :tipo="servicio.estado" />
    </div>

    <button
      v-if="editable"
      class="btn-demora"
      :class="{ activo: servicio.demorado }"
      :title="servicio.demorado ? 'Quitar demora' : 'Marcar demora'"
      @click="$emit('toggle-demora', { id: servicio.id, demorado: !servicio.demorado })"
    >
      <q-icon name="schedule" size="14px" />
    </button>
  </div>

</div>



</template>

<script setup>

import StatusBadge from '../common/StatusBadge.vue'

defineProps({
  servicio: Object,
  editable: { type: Boolean, default: false }
})

defineEmits(['toggle-demora'])

</script>

<style scoped>

.fila {
  display: grid;
  grid-template-columns: 80px 140px 80px 120px 100px 120px 1fr;
  align-items: center;
  padding: 20px 25px;
  border-bottom: 1px solid #1a2138;
  transition: 0.2s;
  gap: 0;
}

.fila > div {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 5px;
}

/* SUBTÍTULOS */
.subtitulo {
  color: #7b8198;
  font-size: 10px;
  font-weight: bold;
  letter-spacing: 1px;
}

/* VALORES */

.hora-servicio {
  color: #f4b400;
  font-size: 18px;
  font-weight: bold;
  letter-spacing: 1px;
}

.destino {
  color: white;
  font-size: 16px;
  font-weight: 600;
}

.anden {
  color: #00ffd0;
  font-size: 22px;
  font-weight: bold;
  letter-spacing: 1px;
}

.bus {
  background: #1a2138;
  color: white;
  padding: 4px 7px;
  border-radius: 3px;
  font-size: 13px;
  font-weight: bold;
  letter-spacing: 1px;
}

.empresa,
.tipo {
  color: #7b8198;
  font-size: 13px;
  letter-spacing: 1px;
}

/* ESTADO */

.col-estado {
  display: flex !important;
  flex-direction: row !important;
  align-items: flex-end !important;
  gap: 10px;
}

.col-estado > div {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

/* BOTÓN DEMORA */

.btn-demora {
  background: transparent;
  border: 1px solid #1a2138;
  color: #7b8198;
  border-radius: 4px;
  width: 26px;
  height: 26px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: 0.2s;
}

.btn-demora:hover {
  border-color: #ff5b5b;
  color: #ff5b5b;
}

.btn-demora.activo {
  background: #ff5b5b;
  border-color: #ff5b5b;
  color: white;
}

@media (max-width: 700px) {
  .fila {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
    padding: 15px;
  }

  .fila span {
    width: 100%;
  }

  .fila b {
    display: inline-block;
    width: 70px;
    color: #7b8198;
    font-size: 9px;
  }
}

</style>
