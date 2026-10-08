<!-- Menú lateral de navegación, presente en todas las páginas dentro de MainLayout. Antes: BloqueSidebar.vue -->
<template>

  <!-- BOTON MENU -->
  <q-btn
    ref="botonRef"
    flat
    round
    dense
    icon="menu"
    @click="emit('update:modelValue', !modelValue)"
    style="
      position: fixed;
      top: 10px;
      left: 10px;
      z-index: 2000;
      color: white;
      background: #0b1023;
    "
  />

  <!-- SIDEBAR -->
  <div
    ref="sidebarRef"
    class="sidebar"
    :class="{ oculta: !modelValue }"
  >

    <!-- LOGO -->
    <div class="logo">
      <q-img
        src="/src/assets/logo1.jpg"
        class="logo-img"
        fit="contain"
      />
    </div>

    <!-- SEPARADOR TERMINAL -->
    <div class="seccion-label">TERMINAL</div>

    <NavMenuItem to="/terminal" icono="house" etiqueta="La Terminal" tamano-icono="25px" />

    <!-- SEPARADOR OPERACIONES -->
    <div class="seccion-label">OPERACIONES</div>

    <NavMenuItem to="/tablero" icono="dashboard" etiqueta="Tablero" />
    <NavMenuItem to="/comprar" icono="receipt" etiqueta="Comprar Pasaje" />
    <NavMenuItem to="/info" icono="menu_book" etiqueta="Info general" tamano-icono="22px" />

    <!-- SEPARADOR ADMINISTRACION: solo visible si el usuario logueado es admin -->
    <template v-if="isAdmin">
      <div class="seccion-label">ADMINISTRACIÓN</div>
      <NavMenuItem to="/admin" icono="admin_panel_settings" etiqueta="Panel Admin" tamano-icono="22px" />
    </template>

    <!-- SEPARADOR MI CUENTA -->
    <div class="seccion-label">MI CUENTA</div>

    <router-link to="/perfil" class="boton-menu">
      <q-icon name="person" size="20px" />
      <span>Mi Perfil</span>
    </router-link>

    <!-- Solo se muestra si todavía no inició sesión -->
    <router-link v-if="!isAuthenticated" to="/login" class="boton-menu">
      <q-icon name="login" size="20px" />
      <span>Iniciar Sesión</span>
    </router-link>

    <!-- SPACER -->
    <div class="spacer" />

    <!-- USUARIO -->
    <div class="usuario">
      <div class="avatar">{{ inicialUsuario }}</div>
      <div class="usuario-info">
        <h3>{{ usuario ? `${usuario.nombre} ${usuario.apellido}` : 'Invitado' }}</h3>
        <p>{{ usuario ? usuario.email : 'No has iniciado sesión' }}</p>
      </div>
    </div>

    <!-- CERRAR SESION -->
    <LogoutButton v-if="isAuthenticated" />

  </div>

</template>

<script setup>

import { computed, ref, onMounted, onUnmounted } from 'vue'
import NavMenuItem from './NavMenuItem.vue'
import LogoutButton from './LogoutButton.vue'
import { useAuth } from '../services/auth'

const props = defineProps({
  modelValue: { type: Boolean, default: false }
})

const emit = defineEmits(['update:modelValue'])

const { usuario, isAuthenticated, isAdmin } = useAuth()

const inicialUsuario = computed(() =>
  usuario.value
    ? usuario.value.nombre.charAt(0).toUpperCase()
    : '?'
)

// Cerrar la sidebar al hacer click afuera (en la página, no en el sidebar
// ni en el botón que la abre/cierra). El botón queda excluido a propósito:
// su propio @click ya maneja el toggle, así que si no lo excluyéramos acá
// se pisarían los dos handlers (abriría y cerraría en el mismo click).
const sidebarRef = ref(null)
const botonRef = ref(null)

function manejarClickAfuera(event) {
  if (!props.modelValue) return

  const sidebarEl = sidebarRef.value
  const botonEl = botonRef.value?.$el ?? botonRef.value

  if (sidebarEl?.contains(event.target)) return
  if (botonEl?.contains(event.target)) return

  emit('update:modelValue', false)
}

onMounted(() => {
  document.addEventListener('click', manejarClickAfuera)
})

onUnmounted(() => {
  document.removeEventListener('click', manejarClickAfuera)
})

</script>

<style scoped>

.sidebar{
  width:260px;
  height:100dvh;
  background:#0b1023;
  border-right:1px solid #1a2138;
  display:flex;
  flex-direction:column;
  position:fixed;
  left:0;
  top:0;
  overflow-y:auto;
  z-index:1000;
  transition:0.3s;
}

/* OCULTAR SIDEBAR */
.oculta{
  transform:translateX(-100%);
}

/* LOGO */
.logo{
  display:flex;
  justify-content:center;
  align-items:center;
  padding:25px 15px;
  border-bottom:1px solid #1a2138;
  margin-bottom:10px;
}

.logo-img{
  width:140px;
  max-width:85%;
}

.seccion-label{
  padding:12px 25px 6px;
  color:#7b8198;
  font-size:10px;
  letter-spacing:2px;
}

.boton-menu{
  padding:14px 25px;
  color:white;
  text-decoration:none;
  display:flex;
  align-items:center;
  gap:12px;
  transition:0.3s;
  font-size:14px;
}

.boton-menu:hover{
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

.spacer{
  flex:1;
}

.usuario{
  padding:15px 20px;
  border-top:1px solid #1a2138;
  display:flex;
  gap:12px;
  align-items:center;
}

.avatar{
  width:38px;
  height:38px;
  background:#f4b400;
  color:black;
  display:flex;
  justify-content:center;
  align-items:center;
  font-weight:bold;
  border-radius:4px;
  flex-shrink:0;
}

.usuario-info h3{
  color:white;
  font-size:13px;
  margin:0;
}

.usuario-info p{
  color:#7b8198;
  font-size:11px;
  margin:0;
}

@media(max-width:700px){

  .sidebar{
    width:85%;
    max-width:280px;
    box-shadow:0 0 30px black;
  }

  .sidebar.oculta{
    transform:translateX(-110%);
  }

  .logo{
    padding:20px 10px;
  }

  .logo-img{
    width:140px;
  }

  .usuario{
    padding:15px;
  }

  .boton-menu{
    font-size:15px;
  }

}

</style>
