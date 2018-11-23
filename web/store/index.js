import Vue from 'vue'
import Vuex from 'vuex'
import parse from 'csv-parse'

import axios from 'axios'
import _ from 'lodash'
import { scaleLinear } from 'd3-scale'

const scaleSize = scaleLinear().range([1, 40])

Vue.use(Vuex)

const store = () => new Vuex.Store({
  state: {
    nodes: []
  },
  getters: {
    edges: (state) => {
      const { nodes } = state
      return _.groupBy(_.filter(nodes, 'type'), 'label')
    }
  },
  mutations: {
    SET_NODES (state, data) {
      const nodes = _.map(data, node => {
        const count = parseInt(node.count, 10)
        const x = parseFloat(node.x, 10)
        const y = parseFloat(node.y, 10)
        // console.log(node)
        return {
          label: node.label,
          id: parseInt(node.id, 10),
          count,
          x,
          y,
          type: node.group,
          data: node.data
        }
      })

      const max = _.maxBy(nodes, 'count').count
      scaleSize.domain([1, max])

      console.log('max:', max, scaleSize.range())

      // const user = _.groupBy(_.filter(nodes, 'type'), 'label')
      // console.log(user)

      // console.log('SET NODES', nodes)
      state.nodes = _.map(nodes, node => {
        return {
          ...node,
          r: scaleSize(node.count)
        }
      })
    },
    SET_EDGES (state, data) {
      // console.log('SET EDGES', data)
      state.edges = _.map(data, node => {
        const source = parseInt(node.source, 10)
        const target = parseInt(node.target, 10)
        const value = parseInt(node.weight, 10)
        return {
          source,
          target,
          value
        }
      })
    }
  },
  actions: {
    loadDatasets ({ commit, dispatch }) {
      const nodes = 'http://127.0.0.1:8080/user-nodes.csv'
      // const edges = 'http://127.0.0.1:8080/user-edges.csv'
      dispatch('loadData', { url: nodes, type: 'nodes' })
      // dispatch('loadData', { url: edges, type: 'edges' })
    },
    loadData ({ commit, dispatch }, { url, type }) {
      axios.get(url)
        .then(response => {
          // console.log('success', response, 'query')
          dispatch('parseData', { data: response.data, type })
        })
        .catch(error => {
          console.log('error', error)
        })
    },
    parseData ({ commit }, { data, type }) {
      console.log('parseData', type)
      parse(data, {
        skip_empty_lines: true,
        columns: true
      }, (err, records) => {
        console.log('Error:', err)
        if (type === 'nodes') {
          commit('SET_NODES', records)
        } else if (type === 'edges') {
          commit('SET_EDGES', records)
        }
      })
    }
  }
})

export default store
