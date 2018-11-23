<template>
  <div class="content">
    <Forcegraph />
  </div>
</template>

<script>
  import { mapActions } from 'vuex'
  import Forcegraph from '~/components/Forcegraph.vue'

  export default {
    components: {
      Forcegraph
    },
    methods: {
      ...mapActions([
        'loadDatasets'
      ])
    },
    created: function () {
      this.loadDatasets()
    }
  }
</script>

<style lang="scss" scoped>

</style>
