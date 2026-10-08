<!-- Encabezado del tablero. Antes: BloqueTableroSuperior.vue -->
<template>
  <div class="superior">

    <!-- IZQUIERDA, texto plano del tablero. -->
    <div>
      <h1>
        TABLERO DE SERVICIOS
      </h1>

      <p>
        Salidas desde Melo · Estado en tiempo real
      </p>
    </div>

    <!-- espacio para poner el reloj en un futuro -->
    <div class="hora-container">


      <span>

      </span>

    </div>

  </div>
</template>

<script setup>


</script>

<style scoped>
.superior{
  display:flex;
  justify-content:space-between;
  align-items:center;
  padding-bottom:20px;
  border-bottom:1px solid #1a2138;
}

h1{
  font-size:55px;
  letter-spacing:3px;
  margin-left:20px;
  color:white;
}

p{
  color:#7b8198;
  margin-top:10px;
  margin-left:20px;
}

.hora-container{
  text-align:right;
}

h2{
  font-size:60px;
  color:#f4b400;
  margin:0;
}

span{
  color:#7b8198;
}
</style>
