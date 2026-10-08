<!-- Página de información general y empresas de transporte (ruta /info). Antes: Paginainfo.vue -->
<template>

  <MainLayout>

    <!-- SUPERIOR -->
    <div class="superior">
      <div>
        <h1>INFORMACIÓN GENERAL</h1>
        <p>Todo sobre la Terminal de Ómnibus de Melo y las empresas que operan en ella</p>
      </div>
    </div>

    <!-- EMPRESAS -->
    <h2 class="seccion-titulo">EMPRESAS QUE OPERAN EN LA TERMINAL</h2>
    <p class="seccion-hint">Hacé click en el logo de una empresa para ver su información completa</p>

    <CompanyList />

    <!-- INFO PRACTICA -->
    <h2 class="seccion-titulo">INFORMACIÓN PRÁCTICA</h2>

    <div class="info-grid">

      <div class="info-card">
        <q-icon name="schedule" size="26px" color="amber" />
        <h3>Horario de atención</h3>
        <p>Lunes a domingo, de 06:00 a 23:00</p>
      </div>

      <div class="info-card">
        <q-icon name="place" size="26px" color="amber" />
        <h3>Ubicación</h3>
        <p>Terminal de Ómnibus de Melo, Cerro Largo</p>
      </div>

      <div class="info-card">
        <q-icon name="call" size="26px" color="amber" />
        <h3>Contacto</h3>
        <p>+598 XXXX XXXX · info@viabus.uy</p>
      </div>

      <div class="info-card">
        <q-icon name="hail" size="26px" color="amber" />
        <h3>Servicios en la terminal</h3>
        <p>Sala de espera, baños, cafetería, wifi gratuito</p>
      </div>

    </div>

  </MainLayout>

</template>

<script setup>

import MainLayout from '../layouts/MainLayout.vue'
import CompanyList from '../components/company/CompanyList.vue'

</script>

<style scoped>

.superior {
  padding-bottom: 20px;
  border-bottom: 1px solid #1a2138;
  margin-bottom: 30px;
}

h1 {
  font-size: 45px;
  letter-spacing: 3px;
  color: white;
}

.superior p {
  color: #7b8198;
  margin-top: 8px;
  font-size: 13px;
  letter-spacing: 1px;
}

.seccion-titulo {
  color: white;
  font-size: 16px;
  letter-spacing: 3px;
  margin: 40px 0 6px;
}

.seccion-hint {
  color: #7b8198;
  font-size: 12px;
  letter-spacing: 1px;
  margin-bottom: 20px;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
}

.info-card {
  background: #0f1629;
  border: 1px solid #1a2138;
  border-radius: 10px;
  padding: 24px 20px;
  text-align: center;
  transition: transform 0.25s, border-color 0.25s;
}

.info-card:hover {
  transform: translateY(-5px);
  border-color: rgba(244, 180, 0, 0.4);
}

.info-card h3 {
  color: white;
  font-size: 14px;
  letter-spacing: 1px;
  margin: 14px 0 8px;
}

.info-card p {
  color: #7b8198;
  font-size: 13px;
  line-height: 1.5;
}

@media (max-width: 900px) {
  .info-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 600px) {
  .info-grid {
    grid-template-columns: 1fr;
  }
}

</style>
