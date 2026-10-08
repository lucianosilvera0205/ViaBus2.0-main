import { createRouter, createWebHistory } from 'vue-router'
import { useAuth } from '../services/auth'

// SE LLAMAN A LAS PAGINAS

import HomePage from '../pages/HomePage.vue'
import ReservationPage from '../pages/ReservationPage.vue'
import DashboardPage from '../pages/paginaTablero.vue'
import ProfilePage from '../pages/ProfilePage.vue'
import CompaniesPage from '../pages/CompaniesPage.vue'
import LoginPage from '../pages/LoginPage.vue'
import NotFoundPage from '../pages/NotFoundPage.vue'
import CompanyDetailPage from '../pages/CompanyDetailPage.vue'
import AdminPage from '../pages/AdminPage.vue'

const routes = [

  // REDIRIGE / a terminal
  {
    path: '/',
    redirect: '/terminal'
  },

  // LA TERMINAL (home)
  {
    path: '/terminal',
    component: HomePage
  },

  // TABLERO
  {
    path: '/tablero',
    component: DashboardPage
  },

  // INFO / EMPRESAS
  {
    path: '/info',
    component: CompaniesPage
  },

  // FICHA DE UNA EMPRESA, INDIVIDUALMENTE 
  {
    path: '/empresas/:id',
    component: CompanyDetailPage
  },
  // COMPRAR PASAJE
  {
    path: '/comprar',
    component: ReservationPage
  },

  // MI PERFIL — requiere estar logueado (cualquier rol)
  {
    path: '/perfil',
    component: ProfilePage,
    meta: { requiresAuth: true }
  },

  // INICIO DE SESION
  {
    path: '/login',
    component: LoginPage
  },

  // PANEL DE ADMINISTRADOR (gestión de viajes) — requiere sesión con rol admin
  {
    path: '/admin',
    component: AdminPage,
    meta: { requiresAdmin: true }
  },

  // ERROR 404
  {
    path: '/:catchAll(.*)*',
    component: NotFoundPage
  }

]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// Protege /admin (requiere rol admin) y /perfil (requiere cualquier sesión).
// Sin sesión se manda a /login (guardando a dónde quería ir); con sesión
// pero sin ser admin en una ruta de admin, se manda al inicio.
router.beforeEach((to) => {
  if (to.meta.requiresAdmin || to.meta.requiresAuth) {
    const { isAuthenticated, isAdmin } = useAuth()

    if (!isAuthenticated.value) {
      return { path: '/login', query: { redirect: to.fullPath } }
    }
    if (to.meta.requiresAdmin && !isAdmin.value) {
      return { path: '/terminal' }
    }
  }
})

export default router
