<script setup>
</script>

<template>
    <div class="flex flex-col border h-72 rounded-md bg-blue-200">
        <h1 class="font-medium mt-6 text-2xl text-center">Support Ticket</h1>
        <div class="flex flex-col overflow-scroll overflow-x-hidden m-2">
            <ul class="flex flex-col gap-1">
                <li class=" bg-zinc-200 p-2 rounded-md hover:bg-zinc-300 active:bg-blue-100" v-for="index in 10"
                    :key="index">Ticket {{ index }}</li>
            </ul>
        </div>
    </div>
</template>