// Cliente simple para el backend PHP de ViaBus.
// En desarrollo, Quasar redirige /api/* -> http://localhost:8000 (ver quasar.config.js).
// En producción, el backend debe publicarse en la misma URL base bajo /api.

const BASE = '/api'

async function request(path, options = {}) {
  const res = await fetch(`${BASE}/${path}`, {
    headers: { 'Content-Type': 'application/json' },
    ...options
  })

  let data = null
  try {
    data = await res.json()
  } catch {
    data = null
  }

  if (!res.ok) {
    const message = data?.error || `Error ${res.status} al comunicarse con el servidor`
    throw new Error(message)
  }

  return data
}

// ---- Autenticación ----
export function login(email, password) {
  return request('auth.php?action=login', {
    method: 'POST',
    body: JSON.stringify({ email, password })
  })
}

export function registrarse(payload) {
  return request('auth.php?action=register', {
    method: 'POST',
    body: JSON.stringify(payload)
  })
}

// ---- Ciudades ----
export function getCiudades() {
  return request('ciudades.php')
}

// ---- Empresas ----
export function getEmpresas() {
  return request('empresas.php')
}

// Ficha completa de una empresa (descripción, contacto y rutas que opera).
export function getEmpresa(id) {
  return request(`empresas.php?id=${id}`)
}

// ---- Servicios ----
export function buscarServicios(origen, destino) {
  const params = new URLSearchParams({ origen, destino })
  return request(`servicios.php?${params}`)
}

export function getTodosServicios() {
  return request('servicios.php')
}

export function getServicio(id) {
  return request(`servicios.php?id=${id}`)
}

// Crear/editar/desactivar un viaje (uso exclusivo del panel de administrador).
export function crearServicio(payload) {
  return request('servicios.php', {
    method: 'POST',
    body: JSON.stringify(payload)
  })
}

export function actualizarServicio(id, payload) {
  return request(`servicios.php?id=${id}`, {
    method: 'PUT',
    body: JSON.stringify(payload)
  })
}

export function eliminarServicio(id) {
  return request(`servicios.php?id=${id}`, {
    method: 'DELETE'
  })
}

// ---- Reservas ----
export function getAsientosOcupados(servicioId, fecha) {
  const params = new URLSearchParams({ servicio_id: servicioId, fecha })
  return request(`reservas.php?${params}`)
}

export function crearReserva(payload) {
  return request('reservas.php', {
    method: 'POST',
    body: JSON.stringify(payload)
  })
}

// Reservas de un usuario logueado (para "Mi Perfil").
export function getReservasUsuario(usuarioId) {
  return request(`reservas.php?usuario_id=${usuarioId}`)
}

// Cancela una reserva (el backend valida el plazo mínimo antes de la salida).
export function cancelarReserva(id) {
  return request(`reservas.php?id=${id}`, {
    method: 'DELETE'
  })
}

// ---- Perfil de usuario ----
export function actualizarPerfil(id, payload) {
  return request(`usuarios.php?id=${id}`, {
    method: 'PUT',
    body: JSON.stringify(payload)
  })
}

export function cambiarPassword(id, payload) {
  return request(`usuarios.php?id=${id}&action=password`, {
    method: 'PUT',
    body: JSON.stringify(payload)
  })
}

// ---- Pasajeros ----
export function buscarPasajeroPorDocumento(documento) {
  return request(`pasajeros.php?documento=${encodeURIComponent(documento)}`)
}

// ---- Tablero (salidas del día) ----
export function getTablero() {
  return request('tablero.php')
}

export function marcarDemora(servicioId, demorado) {
  return request(`tablero.php?servicio_id=${servicioId}`, {
    method: 'PUT',
    body: JSON.stringify({ demorado })
  })
}

// ---- Pagos (Mercado Pago) ----

// Crea la preferencia de pago para una reserva ya existente.
// Devuelve { preference_id, init_point } — init_point es la URL de
// checkout a la que hay que redirigir al usuario.
export function crearPreferenciaPago(reservaId) {
  return request('pagos.php?action=crear-preferencia', {
    method: 'POST',
    body: JSON.stringify({ reserva_id: reservaId })
  })
}

// Consulta el estado real del pago de una reserva (lo actualiza el
// webhook de Mercado Pago en el backend, no hay que confiar en los
// parámetros que Mercado Pago agrega a la URL de vuelta).
export function getEstadoPago(reservaId) {
  return request(`pagos.php?action=estado&reserva_id=${reservaId}`)
}
