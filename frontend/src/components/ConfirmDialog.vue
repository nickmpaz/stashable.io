<template>
  <div class="text-center">
    <v-dialog v-model="active" persistent width="500">
      <v-card color="secondary" class="px-8" :dark="$vuetify.theme.dark">
        <div class="title py-4">{{ prompt }}</div>
        <div class="d-flex justify-space-between pb-6 pt-2">
          <v-btn width="150" color="success" @click="confirm">{{ confirmMessage }}</v-btn>
          <v-btn width="150" color="error" @click="decline">{{ declineMessage }}</v-btn>
        </div>
      </v-card>
    </v-dialog>
  </div>
</template>

<script>
export default {
  props: ["active", "prompt", "confirmMessage", "declineMessage"],
  methods: {
    confirm: function() {
      var vm = this;
      vm.$emit("confirm");
    },
    decline: function() {
      var vm = this;
      vm.$emit("decline");
    }
  }
};
</script>