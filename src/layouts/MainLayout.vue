<!--
  Layout principal de la app: sidebar + área de contenido + footer.
  Se usa en todas las páginas excepto NotFoundPage (pantalla completa sin sidebar).

  El estado "abierto/cerrado" del sidebar vive acá (no en AppSidebar) porque
  es este layout el que necesita reaccionar a ese estado para dejar de
  reservar los 240px de margen cuando el sidebar está oculto. Antes ese
  margen quedaba fijo siempre, así que al cerrar el sidebar quedaba un
  espacio vacío del mismo ancho, sin aprovechar la pantalla.

  La estructura general es en columna (sidebar+contenido arriba, footer
  abajo) para que el footer siempre quede al pie ocupando el 100% del
  ancho, sin importar el estado del sidebar.
-->
<template>
  <div class="layout">

    <div class="layout-body">
      <AppSidebar v-model="sidebarAbierta" />

      <div class="contenido" :class="{ 'contenido--full': !sidebarAbierta }">
        <TopBar />
        <slot />
      </div>
    </div>

    <Appfooter />

  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import AppSidebar from './AppSidebar.vue'
import TopBar from './TopBar.vue'
import Appfooter from './Appfooter.vue'

// En pantallas grandes el sidebar empuja el contenido, así que arranca
// abierto. En pantallas chicas es un panel flotante que se superpone,
// así que arranca cerrado (igual que antes).
const sidebarAbierta = ref(false)

onMounted(() => {
  sidebarAbierta.value = window.innerWidth > 700
})
</script>

<style scoped>

.layout{
  display:flex;
  flex-direction: column;
  background:#0b1023;
  min-height:100dvh;
}

.layout-body{
  display:flex;
  flex: 1;
}

.contenido{
  margin-left:240px;
  width:calc(100% - 240px);
  padding:40px;
  transition: margin-left 0.3s, width 0.3s;
}

/* Sidebar cerrado: el contenido pasa a ocupar el 100% del ancho */
.contenido--full{
  margin-left:0;
  width:100%;
}

@media(max-width:700px){

  .layout{
    display:block;
  }

  .contenido{
    margin-left:0;
    width:100%;
    padding:10px;
    min-height:100vh;
  }

}

</style>
