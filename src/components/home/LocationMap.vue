<!-- Mapa embebido de la ubicación de la terminal. Antes: ZonaMapa.vue -->
<template>
  <!-- se hace el borde del mapa -->

  <div class="zona-mapa">
    <div class="mapa-header">
      <q-icon name="location_on" color="amber" size="18px" />
      <span>UBICACIÓN — Terminal de Ómnibus de Melo</span>
    </div>
    <!-- el mapa en si-->
    <iframe
      width="100%"
      height="340"
      loading="lazy"
      allowfullscreen
      src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d842.509677029048!2d-54.16645404047547!3d-32.36450714151981!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x95092a2eade165a1%3A0x1e32c0958e6a9c9b!2sTerminal%20de%20%C3%93mnibus!5e0!3m2!1ses-419!2suy!4v1787238669327!5m2!1ses-419!2suy"
    />
  </div>
</template>

<style scoped>
.zona-mapa {
  border: 1px solid #1a2138;
  border-radius: 10px;
  overflow: hidden;
  margin-top: 30px;
}

.mapa-header {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 14px 20px;
  background: #0f1629;
  border-bottom: 1px solid #1a2138;
  color: #7b8198;
  font-size: 12px;
  letter-spacing: 2px;
}

iframe {
  display: block;
  border: none;
  filter: grayscale(30%) invert(5%);
}
</style>
