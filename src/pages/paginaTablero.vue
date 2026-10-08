<!-- Tablero de salidas del día, en tiempo real (ruta /tablero). Antes: PaginaTablero.vue -->
<template>

<!-- Esta pagina esta construida usando unicamente componentes -->
  <MainLayout>

    <tableroTablero />

  </MainLayout>

</template>

<script setup>

// Importamos los componentes
import MainLayout from '../layouts/MainLayout.vue'
import tableroTablero from '../components/tablero/tableroTablero.vue'

</script>
