'use strict'

import Scale from '~/assets/js/Scale.js'

/* eslint-disable */
export default class {
  constructor () {
    this.xScale = new Scale()
    this.yScale = new Scale()
    return this
  }

  input (v) { // Set input range
    this.domain = v
    this.xScale.range([0, v.length - 1])
    return this
  }

  output (x, y) { // Set output range
    this.range = { x: x, y: y }
    this.xScale.domain([0, x - 1])
    this.yScale.range([1, y])
    return this
  }

  getXneighbors (v) { // private
    return [Math.floor(v), Math.ceil(v)]
  }

  getXneighborsValues (v) { // private
    return [this.domain[v[0]], this.domain[v[1]]]
  }

  getXvalue (p, n, v) { // private
    const x = p
    const x1 = n[0]
    const x2 = n[1]
    const y1 = v[0]
    const y2 = v[1]
    if (x1 === x2) {
      return y1
    }
    if (y1 === y2) {
      return y1
    }
    const m = (y2 - y1) / (x2 - x1)
    return m * (x - x1) + y1
  }

  getXValues () {
    const arr = []

    for (let i = 0; i < this.range.x; i++) {
      const position = this.xScale.map(i)
      const neighbors = this.getXneighbors(position)
      const values = this.getXneighborsValues(neighbors)
      const value = this.getXvalue(position, neighbors, values)
      arr.push(value)
    }

    return arr
  }

  getYValues (arr) {
    const domainMin = Math.min(...arr)
    const domainMax = Math.max(...arr)

    this.yScale.domain([domainMin, domainMax])

    return arr.map(n => {
      return Math.round(this.yScale.map(n))
    })
  }

  get () { // Map input value to output range
    const xs = this.getXValues()

    const ys = this.getYValues(xs)

    return ys
  }
}
/* eslint-enable */
