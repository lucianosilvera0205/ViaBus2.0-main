<!--
  Página 404 (cualquier ruta no reconocida). Antes: ErrorNotFound.vue.

  Se corrigieron dos atributos rotos del original ("background:#0b1023;"
  escritos como si fueran un atributo HTML en vez de un estilo, así que
  no hacían nada) y se conectó el botón "Ir al inicio", que no tenía
  ninguna acción asociada.
-->
<template>
  <div class="fullscreen flex flex-center column bg-blue-1">

    <q-icon
      name="error_outline"
      size="120px"
      style="color:#0b1528;"
    />

    <div class="text-h1 text-weight-bold text-negative">
      404
    </div>

    <div class="text-h5 q-mb-md">
      El servidor funciona, pero la página exacta que buscas ya no existe o escribiste mal la dirección.
    </div>

    <q-btn
      to="/terminal"
      icon="home"
      label="Ir al inicio"
      color="primary"
    />

  </div>
</template>

<script setup>
</script>

<style scoped>
.text-h1 {
  font-size: 8rem;
}
</style>
