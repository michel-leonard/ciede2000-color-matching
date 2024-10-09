'use strict'

for (const [[r, g, b], lab] of colors)
	[lab[0], lab[1], lab[2]] = rgb_to_lab(r, g, b)

const binds = {}

const bind = (scope, el, events, func, opts) => {
	binds[scope] ??= []
	for (const ev_name of events.split(' ')) {
		el.addEventListener(ev_name, func, opts)
		binds[scope].push([el, ev_name, func, opts])
	}
}

const unbind = scope => {
	if (scope === undefined)
		for (const idx in binds) {
			for (const [el, ev_name, func, opts] of binds[idx])
				el.removeEventListener(ev_name, func, opts)
			delete binds[idx]
		}
	else {
		const scope_slash = scope + '/'
		for (const idx in binds)
			if (idx.startsWith(scope) && (idx + '/').startsWith(scope_slash)) {
				for (const [el, ev_name, func, opts] of binds[idx])
					el.removeEventListener(ev_name, func, opts)
				delete binds[idx]
			}
	}
}

window.onload = () => {
	const el_drop_zone = document.getElementById('drop-zone')
	const el_main = el_drop_zone.parentElement
	const el_image_canvas = document.getElementById('image-canvas')
	const el_color_picker = document.getElementById('color-picker')
	const el_color_input = document.getElementById('color-input')
	const table_1_inputs = []
	for (let i = 24; i; i -= 12)
		table_1_inputs.push([
			document.getElementById('hex-' + i),
			document.getElementById('rgb-' + i),
			document.getElementById('hsl-' + i),
		])
	const el_color_name = document.getElementById('color-name')
	const table_2_inputs = Array.from(el_main.querySelectorAll(':scope > #params > table > tbody > tr > td > input'))

	const ctx = el_image_canvas.getContext('2d')

	const adjust_picker = () => {
		const rect = el_color_picker.firstElementChild.getBoundingClientRect()
		const doc_height = document.documentElement.clientHeight + (adjust_picker.translateY ?? 0)
		const new_x = Math.max(0, (adjust_picker.translateX ?? 0) - rect.x)
		const new_y = Math.min(0, doc_height - rect.bottom - 22)
		if (new_y !== adjust_picker.translateY || new_x !== adjust_picker.translateX)
			el_color_picker.style.transform = `translate(${adjust_picker.translateX = new_x}px, ${adjust_picker.translateY = new_y}px)`
	}

	const handleFiles = files => {
		const file = files[0]
		if (file && file.type.startsWith('image/')) {
			const img = new Image()
			const reader = new FileReader()

			reader.onload = (event) => {
				img.src = event.target.result
				img.onload = () => {
					if (img.width < 400) {
						const ratio = 800 / img.width
						el_image_canvas.width = Math.round(img.width * ratio)
						el_image_canvas.height = Math.round(img.height * ratio)
						ctx.drawImage(img, 0, 0, el_image_canvas.width, el_image_canvas.height)
					} else {
						el_image_canvas.width = img.width
						el_image_canvas.height = img.height
						ctx.drawImage(img, 0, 0)
					}
					el_image_canvas.style.display = 'block'
					el_color_picker.style.display = 'grid'
					el_main.style.maxWidth = Math.max(800, img.width) + 'px'
					adjust_picker()
				}
			}
			reader.readAsDataURL(file)
		}
	}

	const rgb_to_hex = (r, g, b) => `#${r.toString(16).padStart(2, '0')}${g.toString(16).padStart(2, '0')}${b.toString(16).padStart(2, '0')}`

	const hex_simple = hex => hex.length === 7 && hex[1] === hex[2] && hex[3] === hex[4] && hex[5] === hex[6] ? `#${hex[1]}${hex[3]}${hex[5]}` : hex

	const text_color = (r, g, b) => (r * 299 + g * 587 + b * 114) / 1000 > 140 ? 'black' : 'white'

	const rgh_to_hsl = (r, g, b) => {
		r /= 255
		g /= 255
		b /= 255
		const max = Math.max(r, g, b)
		const min = Math.min(r, g, b)
		let h, s, l = (max + min) * .5

		if (max === min) {
			h = s = 0
		} else {
			const d = max - min
			s = l > 0.5 ? d / (2 - max - min) : d / (max + min)
			switch (max) {
				case r:
					h = (g - b) / d + (g < b ? 6 : 0)
					break
				case g:
					h = (b - r) / d + 2
					break
				case b:
					h = (r - g) / d + 4
					break
			}
			h /= 6
		}
		return [
			Math.round(h * 360),
			Math.round(s * 100),
			Math.round(l * 100),
		]
	}

	const closest_name = (r, g, b) => {
		const [k_l, k_c, k_h] = table_2_inputs.map(e => +e.value)
		const [l_1, a_1, b_1] = rgb_to_lab(r, g, b)
		let calc = Infinity, name = ''
		for (let i = 0; i < colors.length; ++i) {
			const delta = ciede_2000(l_1, a_1, b_1, ...colors[i][1], k_l, k_c, k_h)
			if (delta < calc) {
				calc = delta
				name = colors[i][2]
			}
		}
		return name
	}

	const closest_8 = (r, g, b) => [Math.round(r / 51) * 51, Math.round(g / 51) * 51, Math.round(b / 51) * 51]

	const closest_12 = (...args) => args.map(e => (e >> 4) | (e & 240))

	const closest_16 = (r, g, b) => [
		Math.round(Math.round(r / 255 * 31) * 8.225806451612904),
		Math.round(Math.round(g / 255 * 63) * 4.0476190476190474),
		Math.round(Math.round(b / 255 * 31) * 8.225806451612904),
	]

	const update_colors = (e, rect) => {
		const x = e.clientX - rect.left
		const y = e.clientY - rect.top
		const pixel = ctx.getImageData(x, y, 1, 1).data
		for (let i = 0, r, g, b; i < table_1_inputs.length; ++i) {
			if (i)
				[r, g, b] = closest_12(pixel[0], pixel[1], pixel[2])
			else {
				[r, g, b] = pixel
				el_color_name.textContent = el_color_name.style.backgroundColor = closest_name(r, g, b)
			}
			table_1_inputs[i][1].value = `rgb(${r}, ${g}, ${b})`
			table_1_inputs[i][0].value = hex_simple(rgb_to_hex(r, g, b))
			if (i === 0)
				el_color_input.value = table_1_inputs[i][0].value
			const [h, s, l] = rgh_to_hsl(r, g, b)
			table_1_inputs[i][2].value = `hsl(${h}, ${s}%, ${l}%)`
			const tr = table_1_inputs[i][0].parentElement.parentElement
			tr.style.backgroundColor = table_1_inputs[i][0].value
			tr.style.color = text_color(r, g, b)
		}
	}

	const passive = {passive: true}

	{
		const dropZone = document.body
		bind('os', dropZone, 'dragover', e => e.preventDefault())
		bind('os', dropZone, 'drop', e => e.preventDefault() + handleFiles(e.dataTransfer.files))
		bind('os', dropZone, 'paste', e => handleFiles(e.clipboardData.files), passive)
	}
	bind('os/act', el_image_canvas, 'mousedown', e => {
		const rect = el_image_canvas.getBoundingClientRect()
		update_colors(e, rect)
		bind('os/act/move', el_image_canvas, 'mousemove', e => update_colors(e, rect), passive)
		bind('os/act/move', el_image_canvas, 'mouseup', e => update_colors(e, rect) + unbind('os/act/move'), passive)
		bind('os/act/move', el_image_canvas, 'mouseleave', e => unbind('os/act/move'), passive)
	}, passive)

	const adjust_picker_timed = () => {
		clearTimeout(adjust_picker_timed.timeout)
		adjust_picker_timed.timeout = setTimeout(adjust_picker, 150)
	}

	bind('os', window, 'scroll', adjust_picker_timed, passive)
	bind('os', window, 'resize', adjust_picker_timed, passive)

}
