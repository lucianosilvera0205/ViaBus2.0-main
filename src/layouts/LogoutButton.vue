<!-- Botón "cerrar sesión" del sidebar. Antes: BotonCerrarSesion.vue -->
<template>

  <button class="logout-button" @click="cerrarSesion">
    <q-icon name="logout" size="16px" />
    <span>CERRAR SESIÓN</span>
  </button>

</template>

<script setup>

import { useRouter } from 'vue-router'
import { useAuth } from '../services/auth'

const router = useRouter()
const { cerrarSesion: cerrarSesionAuth } = useAuth()

function cerrarSesion() {
  cerrarSesionAuth()
  router.push('/terminal')
}

</script>

<style scoped>

.logout-button{
  width:100%;
  padding:14px 25px;
  background:transparent;
  border:none;
  border-top:1px solid #1a2138;
  color:#7b8198;
  cursor:pointer;
  display:flex;
  align-items:center;
  gap:10px;
  font-size:12px;
  letter-spacing:2px;
  transition:0.3s;
}

.logout-button:hover{
  color:white;
  background:#1a2138;
}

</style>
