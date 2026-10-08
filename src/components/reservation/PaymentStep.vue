<!--
  Paso de pago de la reserva (Mercado Pago).

  Es un componente de presentación: no hace llamadas al backend ni maneja
  la navegación entre pasos, eso lo sigue haciendo ReservationPage.vue
  (que ya es el dueño de "pasoActual", "reservaCreada", etc). Este
  componente solo muestra la fase actual del pago y avisa con eventos
  cuando el usuario quiere pagar, reintentar o volver.

  Props:
    resumen        -> { origen, destino, fecha, hora, empresa, asiento, total }
    fase           -> 'resumen' | 'procesando' | 'verificando' | 'rechazado' | 'pendiente' | 'error'
    mensajeError   -> texto a mostrar cuando fase = 'error' o 'rechazado'

  Eventos:
    volver      -> el usuario quiere ir al paso anterior (solo disponible en fase 'resumen')
    pagar       -> el usuario confirmó que quiere pagar
    reintentar  -> el usuario quiere volver a intentar el pago tras un error/rechazo
-->
<template>

  <div class="paso-pago">

    <!-- FASE: RESUMEN, listo para pagar -->
    <template v-if="fase === 'resumen'">

      <h2>PAGO</h2>

      <div class="resumen-reserva">
        <div class="resumen-fila"><span>Origen</span><strong>{{ resumen.origen }}</strong></div>
        <div class="resumen-fila"><span>Destino</span><strong>{{ resumen.destino }}</strong></div>
        <div class="resumen-fila"><span>Fecha</span><strong>{{ resumen.fecha }}</strong></div>
        <div class="resumen-fila"><span>Hora</span><strong>{{ resumen.hora }}</strong></div>
        <div class="resumen-fila"><span>Empresa</span><strong>{{ resumen.empresa }}</strong></div>
        <div class="resumen-fila"><span>Asiento</span><strong>{{ resumen.asiento }}</strong></div>
        <div class="resumen-fila resumen-total"><span>Total</span><strong>${{ resumen.total }}</strong></div>
      </div>

      <div class="acciones">
        <button class="btn-volver" @click="$emit('volver')">Volver</button>
        <button class="btn-pagar-mp" @click="$emit('pagar')">
          <q-icon name="payment" size="18px" />
          Pagar con Mercado Pago
        </button>
      </div>

    </template>

    <!-- FASE: PROCESANDO (creando la reserva y la preferencia de pago) -->
    <div v-else-if="fase === 'procesando'" class="estado-pago">
      <q-spinner color="amber" size="48px" />
      <h2>Preparando tu pago...</h2>
      <p>Te vamos a redirigir a Mercado Pago en un momento.</p>
    </div>

    <!-- FASE: VERIFICANDO (el usuario acaba de volver de Mercado Pago) -->
    <div v-else-if="fase === 'verificando'" class="estado-pago">
      <q-spinner color="amber" size="48px" />
      <h2>Verificando tu pago...</h2>
      <p>Esto puede tardar unos segundos.</p>
    </div>

    <!-- FASE: PENDIENTE (ej. pago en efectivo, todavía no se acreditó) -->
    <div v-else-if="fase === 'pendiente'" class="estado-pago">
      <q-icon name="hourglass_empty" size="48px" color="warning" />
      <h2>Tu pago está pendiente</h2>
      <p>Mercado Pago todavía no confirmó el pago. Apenas se acredite, tu reserva queda confirmada automáticamente.</p>
      <div class="acciones">
        <button class="btn-volver" @click="$emit('reintentar')">Volver a verificar</button>
      </div>
    </div>

    <!-- FASE: RECHAZADO -->
    <div v-else-if="fase === 'rechazado'" class="estado-pago">
      <q-icon name="error_outline" size="48px" color="negative" />
      <h2>El pago fue rechazado</h2>
      <p>{{ mensajeError || 'Mercado Pago rechazó el pago. Podés intentarlo de nuevo.' }}</p>
      <div class="acciones">
        <button class="btn-pagar-mp" @click="$emit('reintentar')">Reintentar pago</button>
      </div>
    </div>

    <!-- FASE: ERROR (de conexión, backend, etc.) -->
    <div v-else-if="fase === 'error'" class="estado-pago">
      <q-icon name="error_outline" size="48px" color="negative" />
      <h2>No pudimos procesar el pago</h2>
      <p>{{ mensajeError || 'Ocurrió un error inesperado.' }}</p>
      <div class="acciones">
        <button class="btn-pagar-mp" @click="$emit('reintentar')">Reintentar</button>
      </div>
    </div>

  </div>

</template>

<script setup>
defineProps({
  resumen: { type: Object, required: true },
  fase: { type: String, default: 'resumen' },
  mensajeError: { type: String, default: '' }
})

defineEmits(['volver', 'pagar', 'reintentar'])
</script>

<style scoped>

.resumen-reserva{
  border:1px solid #1a2138;
  border-radius:6px;
  overflow:hidden;
  margin-bottom:25px;
  max-width:480px;
}

.resumen-fila{
  display:flex;
  justify-content:space-between;
  padding:14px 20px;
  border-bottom:1px solid #1a2138;
  font-size:13px;
}

.resumen-fila:last-child{
  border-bottom:none;
}

.resumen-fila span{
  color:#7b8198;
  letter-spacing:1px;
}

.resumen-fila strong{
  color:white;
}

.resumen-total{
  background:#0f1629;
}

.resumen-total strong{
  color:#00ffd0;
  font-size:18px;
}

.acciones{
  display:flex;
  gap:12px;
}

.btn-volver{
  padding:12px 24px;
  background:transparent;
  border:1px solid #1a2138;
  color:#7b8198;
  border-radius:6px;
  cursor:pointer;
  font-size:13px;
  letter-spacing:1px;
  transition:0.2s;
}

.btn-volver:hover{
  border-color:#f4b400;
  color:white;
}

.btn-pagar-mp{
  padding:12px 24px;
  background:#00b1ea;
  border:none;
  color:white;
  border-radius:6px;
  cursor:pointer;
  font-size:13px;
  font-weight:bold;
  letter-spacing:1px;
  display:flex;
  align-items:center;
  gap:8px;
  transition:0.2s;
}

.btn-pagar-mp:hover{
  background:#0090c2;
}

/* Estados intermedios (procesando / verificando / pendiente / rechazado / error) */
.estado-pago{
  max-width:480px;
  padding:50px 30px;
  text-align:center;
  background:#0f1629;
  border:1px solid #1a2138;
  border-radius:10px;
}

.estado-pago h2{
  color:white;
  font-size:18px;
  letter-spacing:1px;
  margin:18px 0 10px;
}

.estado-pago p{
  color:#7b8198;
  font-size:13px;
  line-height:1.6;
  margin-bottom:20px;
}

.estado-pago .acciones{
  justify-content:center;
}

</style>
