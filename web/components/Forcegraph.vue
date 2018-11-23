<template>
  <section class="indicators" ref="vis">
    <svg :class="{ vis: true, isVisible }" :width="width + 'px'" :height="height + 'px'">
      <g transform="scale(2 2)">
        <!-- <text :x="width / 2 + 'px'" :y="height / 2 + 'px'">Nodes: {{ nodes.length }}</text>
        <text :x="width / 2 + 'px'" :y="height / 2 + 20 + 'px'">Edges: {{ edges.length }}</text> -->
        <g>
          <circle
            v-for="node in nodesElements"
            :cx="node.x"
            :cy="node.y"
            :r="node.r"
            :class="node.class" />
        </g>
        <g>
          <g v-for="lines in linesElements">
            <g>
              <line
                v-for="line in lines.lines"
                :data="line.test"
                :x1="line.x1"
                :y1="line.y1"
                :x2="line.x2"
                :y2="line.y2"
                :style="{ stroke: line.stroke }"
                :class="{ [lines.class]: true, path: true }" />
            </g>
            <g :class="lines.class">
              <text :x="lines.centerX + 'px'" :y="lines.centerY + 'px'" class="stroke" :text-anchor="lines.anchor">{{ lines.class }}</text>
              <text :x="lines.centerX + 'px'" :y="lines.centerY + 'px'" :text-anchor="lines.anchor">{{ lines.class }}</text>
            </g>
          </g>
        </g>
      </g>
    </svg>
  </section>
</template>

<script>
  import _ from 'lodash'
  import { mapState, mapGetters } from 'vuex'
  import chroma from 'chroma-js'
  // import { forceSimulation, forceLink, forceManyBody, forceCenter } from 'd3-force'

  // const simulation = forceSimulation()
  //   .force('link', forceLink().id(d => { return d.id }).strength(0.01))
  //   .force('charge', forceManyBody().strength(0.01))

  const colors = {
    'adrianactitud': [chroma.mix('614836', 'ffffff', 0.9), '#614836'],
    'tedgrambeau': [chroma.mix('FA423B', 'ffffff', 0.9), '#FA423B'],
    'ecosphere.plus': [chroma.mix('F4B401', 'ffffff', 0.9), '#F4B401'],
    'duniaimaji': [chroma.mix('5C9E31', 'ffffff', 0.9), '#5C9E31'],
    'everydayclimatechange': [chroma.mix('1D3DCC', 'ffffff', 0.9), '#1D3DCC']
  }

  const alignments = {
    'adrianactitud': { anchor: 'end', offset: 20 },
    'tedgrambeau': { anchor: 'end', offset: 50 },
    'everydayclimatechange': { anchor: 'end', offset: 50 },
    'duniaimaji': { anchor: 'end', offset: 35 },
    'ecosphere.plus': { anchor: 'start', offset: -20 }
  }

  export default {
    data: function () {
      return {
        width: 0,
        height: 0,
        isVisible: false,
        nodesElements: [],
        linesElements: false
      }
    },
    computed: {
      ...mapState([
        'nodes'
      ]),
      ...mapGetters([
        'edges'
      ])
    },
    watch: {
      nodes: function () {
        this.update()
      },
      edges: function () {
        this.update()
      }
    },
    methods: {
      update: function () {
        const { nodes, width, height, edges } = this

        const tags = _.filter(nodes, node => {
          return node.type !== 'user'
        })

        const elements = _.map(tags, node => {
          return {
            ...node,
            x: node.x * width,
            y: node.y * height,
            r: 1,
            class: node.type
          }

          // if (node.type === 'tag') {
          //   el['fx'] = node.x * width
          //   el['fy'] = node.y * height
          //   el['x'] = node.x * width
          //   el['y'] = node.y * height
          // } else {
          //   el['x'] = width / 2
          //   el['y'] = height / 2
          // }

          // return el
        })

        const lines = _.map(edges, (points, key) => {
          console.log('points:', key)

          // Bit hacky at the moment to filter points outside of the area of interest
          const less = _.filter(points, point => {
            return point.x > 0 && point.y > 0 && point.x < 0.8 && point.y < 0.8
          })
          // const values = less.map(point => {
          //   return [point.x * width, point.y * height].join(' ')
          // }).join('L')

          const colorScale = chroma.scale(colors[key]).domain([0, less.length - 1]).mode('lab')

          const alignment = alignments[key]

          const centerX = (_.meanBy(less, 'x') || 0) * width - alignment.offset
          const centerY = (_.meanBy(less, 'y') || 0) * height

          const parts = []
          let i
          for (i = 0; i < less.length - 1; i++) {
            const { x: x1, y: y1 } = less[i]
            const { x: x2, y: y2 } = less[i + 1]
            // console.log(x1, x2, y1, y2)
            parts.push({
              x1: x1 * width,
              x2: x2 * width,
              y1: y1 * height,
              y2: y2 * height,
              stroke: colorScale(i)
            })
          }

          console.log('parts', parts)

          // const lines = less.map(point => {
          //   return {
          //     [point.x * width, point.y * height]}
          // })

          // return 'M' + values

          return {
            lines: parts,
            class: key,
            centerX,
            centerY,
            anchor: alignment.anchor
          }
        })

        console.log('lines', lines)

        // if (edges.length && nodes.length) {
        //   // console.log(edges, nodes)
        //   console.log(edges.length, nodes.length, width, height)
        //   simulation.force('center', forceCenter(width / 2, height / 2))

        //   simulation
        //     .nodes(elements)
        //     .stop()

        //   simulation.force('link')
        //     .links(edges)

        //   console.log('in')

        //   for (let i = 0; i < 200; ++i) simulation.tick()
        // }

        // console.log(nodes)

        console.log('out')

        console.log(lines)

        // console.log(elements)

        this.nodesElements = elements
        this.linesElements = lines
      },
      calcSizes: function () {
        const vis = this.$refs.vis
        if (!_.isUndefined(vis)) {
          const ref = vis
          this.height = ref.clientHeight || ref.parentNode.clientHeight
          // this.width = ref.clientWidth || ref.parentNode.clientWidth
          this.width = this.height
          this.isVisible = true
        }
      }
    },
    mounted () {
      this.calcSizes()
      window.addEventListener('resize', this.calcSizes, false)
    }
  }
</script>

<style lang="scss" scoped>
  .vis {
    width: 500vh;
    height: 500vh;
  }

  circle {
    &.tag {
      fill: black;
    }

    &.user {
      fill: red;
    }
  }

  path {
    fill: none;
    stroke-width: 0.4px;

    &.ecosphere.plus {
      stroke: red;
    }

    &.everydayclimatechange {
      stroke: blue;
    }

    &.duniaimaji {
      stroke: green;
    }

    &.tedgrambeau {
      stroke: orange;
    }

    &.adrianactitud {
      stroke: purple;
    }
  }

  line {
    &.path {
      stroke-width: 1.3px;
    }
  }

  text {
    &.stroke {
      stroke: #fff;
      stroke-width: 2;
    }
  }
</style>
