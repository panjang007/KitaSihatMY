<script setup>
</script>

<template>
    <div class="flex flex-col h-72 border rounded-md bg-blue-200">
        <h1 class="font-medium mt-6 text-2xl text-center">Emergency Request</h1>
        <div class="overflow-scroll overflow-x-hidden">
            <div v-for="index in 10" class="bg-gray-300 p-2 rounded-md flex flex-col m-2">
                <h1>Emergency {{ index }}</h1>
                <p> Date: 12/1/2024 Time: 12:00 PM <br> User Details: <br> Name: Abu Zharr Luqman <br> Address: Lot 4252,
                    Taman Impian, Kampung Padang Landak,
                    22000, Jerteh <br>
                </p>
                <div class="w-full flex gap-1 justify-end">
                    <button class=" bg-red-500 p-1.5 rounded-md">Reject</button>
                    <button class="  bg-zinc-300 p-1.5 rounded-md">Approve</button>
                </div>
            </div>
        </div>
    </div>
</template>