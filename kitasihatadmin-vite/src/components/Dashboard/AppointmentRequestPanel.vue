<script setup>

</script>

<template>
    <div class="flex flex-col border h-72 rounded-md bg-blue-200">
        <h1 class="font-medium mt-6 text-2xl text-center">Appointment Request</h1>
        <div class="overflow-scroll overflow-x-hidden">

            <div v-for="index in 10" class="bg-gray-300 p-2 rounded-md flex flex-col  m-2">
                <h1>Appointment {{ index }}</h1>
                <p>12/1/2024 5:30PM</p>
                <img
                    src="https://maps.googleapis.com/maps/api/staticmap?center=Berkeley,CA&zoom=13&size=400x400&key=AIzaSyA3kg7YWugGl1lTXmAmaBGPNhDW9pEh5bo&signature=45D4gqkHrzXqD1o0ucV_geljI6A=" />
                <div class="w-full flex gap-1 justify-end">
                    <button class=" bg-red-500 p-1.5 rounded-md">Reject</button>
                    <button class="  bg-zinc-300 p-1.5 rounded-md">Approve</button>
                </div>

            </div>
        </div>

    </div>
</template>