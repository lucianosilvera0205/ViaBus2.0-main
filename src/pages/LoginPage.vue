<!-- Página de inicio de sesión y registro (ruta /login). Antes: PaginaInicioSesion.vue -->
<template>

  <MainLayout>

      <!-- Contenedor del login centrado en la pantalla -->
      <div class="login-page flex flex-center">

        <!-- Contenedor que agrupa las dos tarjetas -->
        <div class="login-container row items-center no-wrap">

          <!-- ===================== TARJETA LOGIN ===================== -->
          <q-card flat class="login-card">

            <!-- Logo -->
            <div class="text-center q-mb-lg">
              <img
                :src="logo"
                alt="Logo"
                class="logo-small"
              >
            </div>

            <!-- Título -->
            <h3 class="title">
              Inicia sesión en
              <span class="brand">ViaBus</span>
            </h3>

            <!-- Campo para ingresar el correo -->
            <q-input
              v-model="loginForm.email"
              outlined
              dark
              type="email"
              label="Correo electrónico"
              color="white"
              class="q-mb-md"
              @keyup.enter="hacerLogin"
            />

            <!-- Campo para ingresar la contraseña -->
            <q-input
              v-model="loginForm.password"
              outlined
              dark
              label="Contraseña"
              type="password"
              color="white"
              @keyup.enter="hacerLogin"
            />

            <p v-if="errorLogin" class="error-msg">{{ errorLogin }}</p>

            <!-- Botón para iniciar sesión -->
            <div class="text-center q-mt-xl">
              <q-btn
                rounded
                outline
                color="white"
                :label="cargandoLogin ? 'Ingresando...' : 'Iniciar Sesión'"
                :disable="cargandoLogin"
                class="login-btn"
                @click="hacerLogin"
              />
            </div>

          </q-card>

          <!-- ===================== TARJETA REGISTRO ===================== -->
          <q-card flat class="register-card">

            <!-- Título -->
            <h4 class="register-title">
              ¿Aún no estás registrado?
            </h4>

            <!-- Logo grande -->
            <img
              :src="logo"
              alt="Logo"
              class="logo-big"
            >

            <!-- Formulario de registro -->
            <div class="registro-form">

              <q-input
                v-model="registerForm.nombre"
                outlined dark dense
                label="Nombre"
                color="white"
                class="q-mb-sm"
              />
              <q-input
                v-model="registerForm.apellido"
                outlined dark dense
                label="Apellido"
                color="white"
                class="q-mb-sm"
              />
              <q-input
                v-model="registerForm.email"
                outlined dark dense
                type="email"
                label="Correo electrónico"
                color="white"
                class="q-mb-sm"
              />
              <q-input
                v-model="registerForm.password"
                outlined dark dense
                type="password"
                label="Contraseña"
                color="white"
                class="q-mb-sm"
              />

              <p v-if="errorRegistro" class="error-msg">{{ errorRegistro }}</p>
              <p v-if="mensajeRegistro" class="ok-msg">{{ mensajeRegistro }}</p>

            </div>

            <!-- Botón para crear una cuenta -->
            <q-btn
              rounded
              outline
              color="white"
              :label="cargandoRegistro ? 'Creando...' : 'Crear cuenta'"
              :disable="cargandoRegistro"
              class="register-btn"
              @click="hacerRegistro"
            />

          </q-card>

        </div>

      </div>

  </MainLayout>

</template>

<script setup>

import { ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import MainLayout from '../layouts/MainLayout.vue'
import logo from '../assets/logo1.jpg'
import { login, registrarse } from '../services/api'
import { useAuth } from '../services/auth'

const route = useRoute()
const router = useRouter()
const { guardarSesion } = useAuth()

// Si llegamos acá desde una ruta protegida (ej. el paso de pago),
// después de loguearnos volvemos a esa misma ruta.
function irLuegoDeAutenticar() {
  const destino = typeof route.query.redirect === 'string' ? route.query.redirect : '/terminal'
  router.push(destino)
}

// ---- Login ----
const loginForm = ref({ email: '', password: '' })
const cargandoLogin = ref(false)
const errorLogin = ref('')

async function hacerLogin() {
  if (!loginForm.value.email || !loginForm.value.password) {
    errorLogin.value = 'Completá correo y contraseña'
    return
  }
  cargandoLogin.value = true
  errorLogin.value = ''
  try {
    const usuario = await login(loginForm.value.email, loginForm.value.password)
    guardarSesion(usuario)
    irLuegoDeAutenticar()
  } catch (e) {
    errorLogin.value = e.message
  } finally {
    cargandoLogin.value = false
  }
}

// ---- Registro ----
const registerForm = ref({ nombre: '', apellido: '', email: '', password: '' })
const cargandoRegistro = ref(false)
const errorRegistro = ref('')
const mensajeRegistro = ref('')

async function hacerRegistro() {
  const { nombre, apellido, email, password } = registerForm.value
  if (!nombre || !apellido || !email || !password) {
    errorRegistro.value = 'Completá todos los campos'
    return
  }
  cargandoRegistro.value = true
  errorRegistro.value = ''
  mensajeRegistro.value = ''
  try {
    const usuario = await registrarse({ nombre, apellido, email, password })
    guardarSesion(usuario)
    mensajeRegistro.value = '¡Cuenta creada! Ingresando...'
    setTimeout(irLuegoDeAutenticar, 600)
  } catch (e) {
    errorRegistro.value = e.message
  } finally {
    cargandoRegistro.value = false
  }
}

</script>

<style scoped>

/* Fondo de la pantalla del login */
.login-page{
  background: #060c22;
  width: 100%;
  min-height: 100vh;

  display: flex;
  justify-content: center; /* Centra horizontalmente */
  align-items: center;     /* Centra verticalmente */
}

/* Contenedor de las tarjetas */
.login-container{
  position: relative;
}

/* Estilos compartidos entre ambas tarjetas */
.login-card,
.register-card{
  background: #0a1028;
  border: 3px solid white;
  border-radius: 30px;
  color: white;
}

/* Tarjeta del login */
.login-card{
  width: 520px;
  padding: 40px;
  position: relative;
  z-index: 2; /* Hace que quede por delante de la otra tarjeta */
}

/* Tarjeta del registro */
.register-card{
  width: 520px;
  padding: 50px;

  /* Desplaza la tarjeta hacia la izquierda para superponerla */
  margin-left: -40px;

  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

/* Título del login */
.title{
  font-size: 2.5rem;
  font-weight: 300;
  margin-bottom: 35px;
}

/* Color del nombre de la aplicación */
.brand{
  color: #f4b400;
  font-weight: bold;
}

/* Tamaño del logo pequeño */
.logo-small{
  width: 120px;
  border-radius: 12px;
}

/* Tamaño del logo grande */
.logo-big{
  width: 140px;
  margin: 20px 0;
  border-radius: 12px;
}

/* Formulario de registro */
.registro-form{
  width: 100%;
}

/* Tamaño de ambos botones */
.login-btn,
.register-btn{
  width: 250px;
  font-size: 1.2rem;
}

.register-btn{
  margin-top: 10px;
}

/* Título de la tarjeta de registro */
.register-title{
  font-size: 1.6rem;
  font-weight: bold;
  text-align: center;
  margin-bottom: 5px;
}

/* Redondea los bordes de los QInput de Quasar */
:deep(.q-field__control){
  border-radius: 18px;
}

/* Mensajes de estado */
.error-msg{
  color: #ff6b6b;
  font-size: 0.85rem;
  margin-top: 12px;
  text-align: center;
}

.ok-msg{
  color: #00ff99;
  font-size: 0.85rem;
  margin-top: 12px;
  text-align: center;
}

@media (max-width: 900px) {
  .login-page {
    padding: 20px 0;
    min-height: auto;
  }

  .login-container {
    flex-direction: column;
    width: 100%;
    max-width: 420px;
  }

  .login-card,
  .register-card {
    width: 100%;
    padding: 30px 25px;
    margin-left: 0;
  }

  .register-card {
    margin-top: -20px;
  }

  .title {
    font-size: 1.8rem;
  }

  .login-btn,
  .register-btn {
    width: 100%;
  }
}

</style>
