<template>
  <v-card class="fill-height">
    <div class="d-flex justify-center align-center fill-height px-6 py-12">
      <span class="title">
        There's nothing here.
        <span @click="engage" class="cursor-pointer primary--text">{{ callToAction }}</span>
      </span>
    </div>
  </v-card>
</template>

<script>
export default {
  props: ["callToAction"],
  methods: {
    engage: function () {
      var vm = this;
      vm.$emit("engage");
    },
  },
};
</script>

<style>
</style>