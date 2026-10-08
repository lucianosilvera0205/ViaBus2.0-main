<!-- Banner principal con imagen de fondo del home. Antes: BloqueSuperior.vue -->
<template>

  <div class="superior">

    <div class="overlay">

      <h1>
        Bienvenido a ViaBus
      </h1>

      <p>
        La nueva experiencia digital para la Terminal de Melo, Cerro Largo.
      </p>

    </div>

  </div>

</template>

<style scoped>

.superior {
  height: 400px;
  border-radius: 12px;
  overflow: hidden;
  background-image: url('src/assets/terminal2.jpg');
  background-size: cover;
  background-position: center top;
  position: relative;
}

.overlay {
  background: linear-gradient(to top, rgba(11,16,35,0.97) 0%, rgba(11,16,35,0.4) 50%, transparent 100%);
  width: 100%;
  height: 100%;
  padding: 35px 45px;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  gap: 10px;
}

.badge {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  background: rgba(244,180,0,0.12);
  border: 1px solid rgba(244,180,0,0.35);
  color: #f4b400;
  font-size: 11px;
  letter-spacing: 3px;
  padding: 6px 14px;
  border-radius: 3px;
  width: fit-content;
}

h1 {
  font-size: 72px;
  color: white;
  font-weight: 900;
  letter-spacing: 5px;
  line-height: 1;
  text-shadow: 0 2px 20px rgba(0,0,0,0.6);
}

.linea-decorativa {
  width: 60px;
  height: 3px;
  background: #f4b400;
  border-radius: 2px;
}

p {
  color: #c8cce0;
  font-size: 14px;
  letter-spacing: 2px;
}

@media (max-width: 700px) {
  .superior {
    height: 320px;
  }

  .overlay {
    padding: 20px;
  }

  h1 {
    font-size: 36px;
    letter-spacing: 2px;
  }

  p {
    font-size: 13px;
    letter-spacing: 1px;
  }
}
</style>
