// Manejo de sesión del lado del cliente.
//
// El backend no usa tokens ni cookies de sesión (para no meter una capa de
// seguridad completa en un proyecto académico): auth.php simplemente valida
// el email/contraseña contra la tabla `usuarios` y devuelve los datos del
// usuario. Acá guardamos esos datos en localStorage y con eso alcanza para
// mostrar/ocultar cosas en la interfaz y proteger rutas en el router.

import { ref, computed } from 'vue'

const STORAGE_KEY = 'viabus_usuario'

function cargarUsuarioGuardado() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    return raw ? JSON.parse(raw) : null
  } catch {
    return null
  }
}

// Estado compartido entre todos los componentes que llamen a useAuth().
const usuario = ref(cargarUsuarioGuardado())

export function useAuth() {
  const isAuthenticated = computed(() => usuario.value !== null)
  const isAdmin = computed(() => usuario.value?.rol === 'admin')

  function guardarSesion(datosUsuario) {
    usuario.value = datosUsuario
    localStorage.setItem(STORAGE_KEY, JSON.stringify(datosUsuario))
  }

  function cerrarSesion() {
    usuario.value = null
    localStorage.removeItem(STORAGE_KEY)
  }

  return { usuario, isAuthenticated, isAdmin, guardarSesion, cerrarSesion }
}
