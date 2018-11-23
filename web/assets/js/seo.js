'use strict'

function get(address, obj) {
	const adr = address.split('.')
	let o = obj
	for (let i = 0; i < adr.length; i++) {
		if (typeof o[adr[i]] === 'undefined') {
			return false
		} else {
			o = o[adr[i]]
		}
	}
	return o
}

module.exports = {
  seo: function (cfg) {
  	const arr = []
  	const tags = [
  		// General
  		[ 'description', 'page.description', 'name' ],
			// OpenGraph
			[ 'og:type', 'page.type', 'property' ],
			[ 'og:title', 'page.title.full', 'property' ],
			[ 'og:description', 'page.description', 'property' ],
			[ 'og:site_name', 'page.title.full', 'property' ],
			// Twitter
			[ 'twitter:card', 'page.card', 'name' ],
			[ 'twitter:site', 'contact.twitter', 'name' ],
			[ 'twitter:creator', 'contact.twitter', 'name' ],
			[ 'twitter:title', 'page.title.full', 'name' ],
			[ 'twitter:description', 'page.description', 'name' ],
			// Others
			[ 'application-name', 'page.title.full', 'property' ]
		]
		tags.forEach(tag => {
			const [attr, key, name] = tag
			const value = get(key, cfg)
			if (value) {
				arr.push( { hid: attr, [name]: attr, content: value })
			}
		})
  	return arr
  }
}
