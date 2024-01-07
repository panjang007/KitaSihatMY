<script setup>
import MainDashboard from './components/Dashboard/MainDashboard.vue';
import SearchBarPanel from './components/SearchBarPanel.vue';
import NavBarPanel from './components/NavBarPanel.vue';

</script>

<template>
  <div class="flex flex-row">
    <NavBarPanel />


    <div class="flex flex-col m-2">
      <div>
        <SearchBarPanel />
        <MainDashboard />
      </div>
    </div>
  </div>
</template>


