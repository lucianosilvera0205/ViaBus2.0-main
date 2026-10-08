<!-- Selector de pestañas Próximas/Ya salieron del tablero. Antes: BloqueTableroTabs.vue -->
<template>

  <div class="tabs-container">

    <button
      v-for="tab in tabs"
      :key="tab.key"
      class="tab"
      :class="{ activo: modelValue === tab.key }"
      @click="$emit('update:modelValue', tab.key)"
    >
      {{ tab.label }}
    </button>

  </div>

</template>

<script setup>

defineProps({
  modelValue: String
})

defineEmits(['update:modelValue'])

const tabs = [
  { key: 'proximos', label: 'PRÓXIMAS SALIDAS' },
  { key: 'salidos', label: 'YA SALIERON' }
]

</script>

<style scoped>

.tabs-container{
  display:flex;
  gap:0;
  border-bottom:1px solid #1a2138;
}

.tab{
  padding:14px 28px;
  background:transparent;
  border:none;
  color:#7b8198;
  font-size:12px;
  letter-spacing:2px;
  cursor:pointer;
  transition:0.3s;
  border-bottom:3px solid transparent;
  margin-bottom:-1px;
}

.tab:hover{
  color:white;
}

.tab.activo{
  color:#f4b400;
  border-bottom:3px solid #f4b400;
}

</style>
