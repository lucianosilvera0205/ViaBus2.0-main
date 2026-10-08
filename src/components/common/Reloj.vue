<!-- Muestra la hora actual y se actualiza cada segundo. Antes: BloqueTableroHora.vue -->
<template>
  <span class="hora">{{ hora }}</span>
</template>

<script setup>

// Importa las funciones necesarias de Vue
// ref: crea una variable reactiva
// onMounted: ejecuta código cuando el componente se monta
// onUnmounted: ejecuta código antes de destruir el componente
import { ref, onMounted, onUnmounted } from 'vue'

// Creamos una variable "hora" tipo ref donde se almacenará la hora actual
const hora = ref('')

// Creamos una variable "intervalo" que guardará el identificador del intervalo
// para poder detenerlo cuando el componente se destruya
let intervalo = null

// Se ejecuta cuando el componente se agrega al DOM
onMounted(() => {

  // Muestra la hora actual apenas carga el componente
  hora.value = new Date().toLocaleTimeString()

  // Actualiza la hora cada segundo usando la variable
  // anteriormente creada
  intervalo = setInterval(() => {
    hora.value = new Date().toLocaleTimeString()
  }, 1000)
})

// Se ejecuta cuando el componente se elimina del DOM
onUnmounted(() => {
  // Detiene el intervalo para evitar consumo innecesario de memoria
  if (intervalo) clearInterval(intervalo)
})

</script>

<!-- 
Diccionario de términos:

Variable Reactiva (ref):
Una variable reactiva es un tipo especial de variable que, al
cambiar su valor, notifica y actualiza automáticamente a todos los
elementos del código o de la interfaz de usuario que dependen de ella.

DOM:
El DOM (Document Object Model) o Modelo de Objetos del Documento
es una interfaz de programación que representa la estructura de una página web 
en la memoria del navegador. Transforma el código HTML estático en un árbol 
jerárquico de objetos dinámico que los lenguajes de programación (principalmente 
JavaScript) pueden leer, modificar y actualizar en tiempo real.

-->
