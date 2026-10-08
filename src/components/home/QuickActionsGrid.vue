<!-- Grilla de accesos rápidos (reservar / tablero) en el home. Antes: BloqueGaleria.vue -->
<template>
  <div class="botones">
    <!-- boton del inicio que llevan a la pagina de compra comprar -->
    <a class="boton" href="/comprar">
      <div class="icono-wrap">
        <q-icon name="confirmation_number" size="28px" color="amber" />
      </div>
      <div class="boton-texto">
        <span class="boton-titulo">RESERVAR PASAJE</span>
        <span class="boton-sub">Buscá tu servicio y elegí tu asiento</span>
      </div>
      <q-icon name="arrow_forward" size="20px" class="flecha" />
    </a>

    <!-- boton del inicio que te lleva hacia el tablero -->
    <a class="boton" href="/tablero">
      <div class="icono-wrap">
        <q-icon name="dashboard" size="28px" color="amber" />
      </div>
      <div class="boton-texto">
        <span class="boton-titulo">TABLERO</span>
        <span class="boton-sub">Consultá salidas y llegadas en tiempo real</span>
      </div>
      <q-icon name="arrow_forward" size="20px" class="flecha" />
    </a>

  </div>
</template>

<style scoped>

.botones {
  display: flex;
  gap: 20px;
  margin-top: 30px;
}

.boton {
  display: flex;
  align-items: center;
  gap: 18px;
  width: 50%;
  background: #0f1629;
  border: 1px solid #1a2138;
  border-radius: 10px;
  padding: 24px 28px;
  text-decoration: none;
  position: relative;
  overflow: hidden;
  cursor: pointer;
  transition: transform 0.25s, border-color 0.25s, box-shadow 0.25s;
}

.boton::before {
  content: '';
  position: absolute;
  top: 0; left: 0; right: 0;
  height: 3px;
  background: linear-gradient(90deg, transparent, #f4b400, transparent);
  opacity: 0;
  transition: opacity 0.3s;
}

.boton:hover {
  transform: translateY(-4px);
  border-color: rgba(244,180,0,0.4);
  box-shadow: 0 12px 35px rgba(0,0,0,0.4), 0 0 20px rgba(244,180,0,0.08);
}

.boton:hover::before {
  opacity: 1;
}

.icono-wrap {
  width: 56px;
  height: 56px;
  min-width: 56px;
  background: rgba(244,180,0,0.08);
  border: 1px solid rgba(244,180,0,0.2);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background 0.25s;
}

.boton:hover .icono-wrap {
  background: rgba(244,180,0,0.16);
}

.boton-texto {
  display: flex;
  flex-direction: column;
  gap: 5px;
  flex: 1;
}

.boton-titulo {
  color: white;
  font-size: 14px;
  font-weight: 900;
  letter-spacing: 2px;
}

.boton-sub {
  color: #7b8198;
  font-size: 12px;
  letter-spacing: 0.5px;
}

.flecha {
  color: #7b8198;
  transition: transform 0.25s, color 0.25s;
}

.boton:hover .flecha {
  transform: translateX(4px);
  color: #f4b400;
}

@media (max-width: 700px) {
  .botones {
    flex-direction: column;
    gap: 12px;
  }

  .boton {
    width: 100%;
    padding: 18px 20px;
  }
}
</style>
