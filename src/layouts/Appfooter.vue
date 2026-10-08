<!-- Footer principal de la app. Reutiliza la paleta y el patrón de animación
     (borde superior degradé + elevación) que ya usan StatCard,
     para que quede integrado al resto del sitio. -->
<template>
  <footer class="app-footer">
    <div class="footer-glow" />

    <div class="footer-content">
      <div class="footer-col footer-col--brand">
        <div class="footer-brand">
          <q-icon name="directions_bus" size="26px" color="amber" />
          <span class="brand-text">ViaBus</span>
        </div>
        <p class="footer-desc">
          Gestión de terminal de ómnibus en Melo, Uruguay. Conectamos tu
          ciudad con el resto del país.
        </p>
      </div>

      <div class="footer-col">
        <h6>Enlaces</h6>
        <router-link to="/" class="footer-link">Inicio</router-link>
        <router-link to="/comprar" class="footer-link">Comprar pasaje</router-link>
        <router-link to="/empresas" class="footer-link">Empresas</router-link>
        <router-link to="/tablero" class="footer-link">Tablero</router-link>
      </div>

      <div class="footer-col">
        <h6>Horarios de atención</h6>
        <div class="footer-item">
          <div class="footer-icon-wrap">
            <q-icon name="schedule" size="14px" color="amber" />
          </div>
          <span>Lunes a viernes: 6:00 - 20:00</span>
        </div>
        <div class="footer-item">
          <div class="footer-icon-wrap">
            <q-icon name="schedule" size="14px" color="amber" />
          </div>
          <span>Sábados: 7:00 - 20:00</span>
        </div>
        <div class="footer-item">
          <div class="footer-icon-wrap">
            <q-icon name="schedule" size="14px" color="amber" />
          </div>
          <span>Domingos y feriados: 8:00 - 18:00</span>
        </div>
      </div>

      <div class="footer-col">
        <h6>Contacto</h6>
        <div class="footer-item">
          <div class="footer-icon-wrap">
            <q-icon name="place" size="14px" color="amber" />
          </div>
          <span>Terminal de Melo, Cerro Largo</span>
        </div>
        <div class="footer-item">
          <div class="footer-icon-wrap">
            <q-icon name="mail" size="14px" color="amber" />
          </div>
          <span>contacto@viabus.uy</span>
        </div>
        <div class="footer-item">
          <div class="footer-icon-wrap">
            <q-icon name="phone" size="14px" color="amber" />
          </div>
          <span>+598 000 000</span>
        </div>
      </div>
    </div>

    <div class="footer-divider" />

    <div class="footer-bottom">
      © 2026 ViaBus. Todos los derechos reservados.
    </div>
  </footer>
</template>

<script setup>
</script>

<style scoped>

.app-footer {
  position: relative;
  background: #0b1023;
  color: #e0e0e0;
  padding: 48px 24px 0;
  width: 100%;
  overflow: hidden;
}

/* Misma línea degradé ámbar que StatCard/QuickActionsGrid usan como
   indicador de "sección activa", acá fija arriba del footer para marcar
   la transición entre el contenido y el footer. */
.footer-glow {
  position: absolute;
  top: 0; left: 0; right: 0;
  height: 3px;
  background: linear-gradient(90deg, transparent, #f4b400, transparent);
  opacity: 0.5;
}

.footer-content {
  display: flex;
  flex-wrap: wrap;
  gap: 40px;
  justify-content: space-between;
  max-width: 1200px;
  margin: 0 auto;
}

.footer-col {
  min-width: 180px;
  flex: 1;
}

.footer-col--brand {
  flex: 1.4;
  min-width: 220px;
}

.footer-brand {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
}

.brand-text {
  font-size: 21px;
  font-weight: 900;
  letter-spacing: 0.3px;
  color: #f4b400;
}

.footer-desc {
  font-size: 13px;
  line-height: 1.6;
  color: #7b8198;
  max-width: 280px;
}

.footer-col h6 {
  color: #f4b400;
  font-size: 11px;
  font-weight: bold;
  letter-spacing: 3px;
  text-transform: uppercase;
  margin-bottom: 16px;
}

.footer-link {
  display: block;
  color: #c4c8d4;
  text-decoration: none;
  font-size: 13.5px;
  margin-bottom: 10px;
  width: fit-content;
  transition: color 0.25s, transform 0.25s;
}

.footer-link:hover {
  color: #f4b400;
  transform: translateX(3px);
}

.footer-item {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 13.5px;
  color: #c4c8d4;
  margin-bottom: 12px;
  line-height: 1.4;
}

/* Mismo "icono-wrap" que usan StatCard y QuickActionsGrid, en versión
   chica, para que los íconos del footer se sientan parte del mismo sistema. */
.footer-icon-wrap {
  width: 26px;
  height: 26px;
  min-width: 26px;
  background: rgba(244, 180, 0, 0.08);
  border: 1px solid rgba(244, 180, 0, 0.2);
  border-radius: 7px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background 0.25s;
}

.footer-item:hover .footer-icon-wrap {
  background: rgba(244, 180, 0, 0.16);
}

.footer-divider {
  max-width: 1200px;
  margin: 32px auto 0;
  height: 1px;
  background: linear-gradient(to right, transparent, rgba(244, 180, 0, 0.25), transparent);
}

.footer-bottom {
  text-align: center;
  font-size: 12px;
  color: #7b8198;
  padding: 18px 0;
  letter-spacing: 0.2px;
}

@media (max-width: 700px) {
  .app-footer {
    padding: 32px 16px 0;
  }

  .footer-content {
    gap: 28px;
  }
}

</style>
