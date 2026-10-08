<!-- Tarjeta de estadística con ícono, usada en la sección de stats del home. Antes: TarjetaEstadistica.vue -->
<template>
  <div class="stat-card">
    <div class="icono-wrap">
      <q-icon :name="icono" size="26px" color="amber" />
    </div>
    <h1>{{ numero }}</h1>
    <p>{{ texto }}</p>
    <div class="linea" />
  </div>
</template>

<script setup>
defineProps({
  numero: String,
  texto: String,
  icono: String
})
</script>

<style scoped>

.stat-card {
  background: #0f1629;
  border: 1px solid #1a2138;
  border-radius: 10px;
  text-align: center;
  padding: 30px 20px 24px;
  cursor: default;
  position: relative;
  overflow: hidden;
  transition: transform 0.25s, border-color 0.25s, box-shadow 0.25s;
}

.stat-card::before {
  content: '';
  position: absolute;
  top: 0; left: 0; right: 0;
  height: 3px;
  background: linear-gradient(90deg, transparent, #f4b400, transparent);
  opacity: 0;
  transition: opacity 0.3s;
}

.stat-card:hover {
  transform: translateY(-5px);
  border-color: rgba(244,180,0,0.4);
  box-shadow: 0 12px 35px rgba(0,0,0,0.4), 0 0 20px rgba(244,180,0,0.08);
}

.stat-card:hover::before {
  opacity: 1;
}

.icono-wrap {
  width: 48px;
  height: 48px;
  background: rgba(244,180,0,0.08);
  border: 1px solid rgba(244,180,0,0.2);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 16px;
  transition: background 0.25s;
}

.stat-card:hover .icono-wrap {
  background: rgba(244,180,0,0.16);
}

h1 {
  color: #f4b400;
  font-size: 44px;
  font-weight: 900;
  line-height: 1;
  margin-bottom: 8px;
}

p {
  font-size: 11px;
  font-weight: bold;
  letter-spacing: 3px;
  color: #7b8198;
}

.linea {
  width: 30px;
  height: 2px;
  background: rgba(244,180,0,0.3);
  border-radius: 2px;
  margin: 14px auto 0;
  transition: width 0.3s, background 0.3s;
}

.stat-card:hover .linea {
  width: 60px;
  background: #f4b400;
}

@media (max-width: 700px) {
  .stat-card {
    padding: 20px 10px 16px;
  }

  h1 {
    font-size: 30px;
  }

  p {
    font-size: 10px;
    letter-spacing: 1.5px;
  }
}
</style>
