
<template>
  <q-card
    class="tarjeta"
    :style="{
      '--card-color': color
    }"
  >
    <q-card-section class="contenido">

      <!-- TITULO -->
      <p class="titulo">
        {{ titulo }}
      </p>

      <!-- NUMERO -->
      <h1>
        {{ numero }}
      </h1>

      <!-- SUBTITULO -->
      <span class="subtitulo">
        {{ subtitulo }}
      </span>

    </q-card-section>
  </q-card>
</template>

<script setup>

defineProps({
  titulo: String,
  numero: String,
  subtitulo: String,
  color: String
})

</script>

<style scoped>

.tarjeta{

  position: relative;

  background: #0d1328;

  border: 1px solid rgba(255,255,255,0.07);

  border-radius: 14px;

  color: white;

  overflow: hidden;

  cursor: default;

  transition:
    transform .25s ease,
    box-shadow .25s ease,
    border-color .25s ease,
    background .25s ease;

}

/* Línea superior de color */

.tarjeta::before{

  content:"";

  position:absolute;

  top:0;
  left:0;

  width:100%;
  height:3px;

  background:var(--card-color);

  opacity:.9;

  transition:
    height .25s ease,
    opacity .25s ease;

}

/* Hover */

.tarjeta:hover{

  transform: translateY(-5px);

  background:#101831;

  border-color:rgba(255,255,255,0.14);

  box-shadow:
    0 10px 30px rgba(0,0,0,.28);

}

.tarjeta:hover::before{

  height:4px;

  opacity:1;

}

/* Contenido */

.contenido{

  padding:20px;

}

/* Título */

.titulo{

  margin:0;

  color:#8b92a8;

  font-family:'Inter',sans-serif;

  font-size:11px;

  font-weight:600;

  letter-spacing:2px;

}

/* Número */

h1{

  margin:12px 0 8px;

  color:var(--card-color);

  font-family:'Inter',sans-serif;

  font-size:42px;

  font-weight:700;

  line-height:1;

  letter-spacing:-1px;

  transition:
    transform .25s ease;

}

.tarjeta:hover h1{

  transform:scale(1.03);

}

/* Subtítulo */

.subtitulo{

  color:#9ca3b8;

  font-family:'Inter',sans-serif;

  font-size:12px;

  line-height:1.4;

}

</style>
