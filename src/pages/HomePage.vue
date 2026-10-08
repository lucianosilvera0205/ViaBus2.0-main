<!-- Página de inicio / presentación de la terminal (ruta /terminal). Antes: PaginaBoton3.vue -->
<template>

  <MainLayout>

    <HeroBanner />

    <StatsSection />

    <QuickActionsGrid />

    <LocationMap />

    <PaymentMethodsSection />

  </MainLayout>

</template>

<script setup>

import MainLayout from '../layouts/MainLayout.vue'
import HeroBanner from '../components/home/HeroBanner.vue'
import StatsSection from '../components/home/StatsSection.vue'
import QuickActionsGrid from '../components/home/QuickActionsGrid.vue'
import LocationMap from '../components/home/LocationMap.vue'
import PaymentMethodsSection from '../components/home/PaymentMethodsSection.vue'

</script>

<style scoped>

:deep(.zona-mapa) {
  margin-top: 30px;
}

</style>
