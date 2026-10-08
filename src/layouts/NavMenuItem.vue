<!--
  Ítem de navegación reutilizable para el sidebar.
  Reemplaza a los antiguos Boton1.vue, Boton2.vue, Boton3.vue, Boton4.vue
  y Botoninfo.vue, que eran el mismo enlace repetido 5 veces con distinto
  ícono, texto y ruta.

  Props:
    to           -> ruta de destino (convención de vue-router)
    icono        -> nombre del ícono de Quasar
    etiqueta     -> texto visible
    tamanoIcono  -> tamaño del ícono (algunos botones originales usaban 25px)
    insignia     -> texto del badge normal (ej: "1")
    insigniaProx -> texto del badge "próximamente" (estilo distinto, gris)
-->
<template>

  <router-link :to="to" class="nav-menu-item">

    <q-icon :name="icono" :size="tamanoIcono" />

    <span>{{ etiqueta }}</span>

    <span v-if="insignia" class="badge">{{ insignia }}</span>
    <span v-if="insigniaProx" class="badge-prox">{{ insigniaProx }}</span>

  </router-link>

</template>

<script setup>
defineProps({
  to: { type: String, required: true },
  icono: { type: String, required: true },
  etiqueta: { type: String, required: true },
  tamanoIcono: { type: String, default: '20px' },
  insignia: { type: String, default: '' },
  insigniaProx: { type: String, default: '' }
})
</script>

<style scoped>

.nav-menu-item{
  padding:14px 25px;
  color:white;
  text-decoration:none;
  display:flex;
  align-items:center;
  gap:12px;
  transition:0.3s;
  font-size:14px;
  width:100%;
}

.nav-menu-item:hover{
  background:#1a2138;
  border-left:3px solid #f4b400;
}

.router-link-active{
  background:#1a2138;
  border-left:3px solid #f4b400;
}

.badge{
  margin-left:auto;
  background:#f4b400;
  color:black;
  font-size:11px;
  font-weight:bold;
  padding:2px 7px;
  border-radius:3px;
}

.badge-prox{
  margin-left:auto;
  background:#1a2138;
  color:#7b8198;
  font-size:10px;
  font-weight:bold;
  padding:2px 7px;
  border-radius:3px;
  border:1px solid #2a3148;
  letter-spacing:1px;
}

</style>
