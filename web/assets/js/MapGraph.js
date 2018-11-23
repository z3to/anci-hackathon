'use strict'

/* eslint-disable */
import Scale from '~/assets/js/Scale.js'

export default class {
  constructor () {
    this.scale = new Scale()
    return this
  }

  domain (v) { // Set input range
    this.domain = v
    this.domainMin = Math.min(...v)
    this.domainMax = Math.max(...v)

    this.scale.domain([this.domainMin, this.domainMax])

    return this
  }

  range (v) { // Set output range
    this.scale.range([1, v])
    return this
  }

  get (v) { // Map input value to output range
    const { domain, scale } = this

    // console.log(v)

    return Math.round(scale.map(v))
  }
}
/* eslint-enable */
