<script setup lang="ts">
const newMessage = ref('');

const { data: messages, execute: loadMessages } = useFetch('/api/messages');
const { execute: addMessage } = useFetch('/api/messages', {
  method: 'POST',
  body: { message: newMessage },
  onResponse: () => {
    newMessage.value = '';
    loadMessages();
  },
  immediate: false,
  watch: false,
});
</script>

<template>
  <div>
    <h1>Messages</h1>

    <form @submit.prevent="addMessage()">
      <input v-model="newMessage" placeholder="Enter your message" />

      <button type="submit">Add Message</button>
    </form>

    <ul>
      <li v-for="message in messages" :key="message.id">
        {{ message.message }}
      </li>
    </ul>
  </div>
</template>
