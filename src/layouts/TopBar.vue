<!-- Barra superior con accesos, buen dia-->

<template>
    <div v-if="mostrar" class="topbar">
        <router-link to="/login" class="topbar-btn topbar-btn--outline">
            <q-icon name="login" size="18px" />
            <span>Iniciar sesión</span>
        </router-link>
        <router-link to="/login?modo=registro" class="topbar-btn topbar-btn--solido">
            <q-icon name="person_add" size="18px" />
            <span>Registrarse</span>
        </router-link>
    </div>
</template>
<script setup>

import { computed } from 'vue';
import { useRoute } from 'vue-router';
import { useAuth } from '../services/auth';

const { isAuthenticated } = useAuth();
const route = useRoute();
const mostrar = computed(() => !isAuthenticated.value && route.path !== '/login' && route.path !== '/registro');
// no se muestra si ya se inicio sesion o si se esta en la pagina de login o registro ya que ahi los botones ya estan presentes, inecesario mostrarlos de nuevo.

</script>


<style scoped>

.topbar{
    height: 56px;
    display: flex;
    align-items: center;
    justify-content: flex-end;
    gap: 12px;
    padding: 0 24px;
    margin: -40px -40px 30px -40px;
    width: calc(100% + 80px);
    border-bottom: 1px solid #1a2138;
}

@media (max-width: 700px) {
    .topbar{
        margin: -10px -10px 20px -10px;
        width: calc(100% + 20px);

    }
}

.topbar-btn{
    padding: 8px 18px;
    border-radius: 6px;
    gap: 6px;
    display: flex;
    align-items: center;
    font-size: 14px;
    font-weight: 600;
    text-decoration: none;
    transition: opacity 0.2s;
}

.topbar-btn:hover{
    opacity: 0.8;
}

.topbar-btn--outline{
    color: #fab400;
    border: 1px solid #fab400;
    background: transparent;
}

.topbar-btn--solido{
    color: #0b1023;
    background: #f4b400;
}
</style>