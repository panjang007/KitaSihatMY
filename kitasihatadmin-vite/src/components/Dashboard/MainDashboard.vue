<script setup>
import AppointmentRequestPanel from './AppointmentRequestPanel.vue';
import EmergencyRequestPanel from './EmergencyRequestPanel.vue';
import RegisteredUsersPanel from './RegisteredUsersPanel.vue';
import SupportTicketPanel from './SupportTicketPanel.vue';

</script>

<template>
    <section class="grid grid-cols-2 gap-3">

        <RegisteredUsersPanel />
        <SupportTicketPanel />
        <EmergencyRequestPanel />
        <AppointmentRequestPanel />




    </section>
</template>