'use strict'

for (const color of colors)
	color[2] = rgb_to_lab(...color[0])

const binds = { }, passive = {passive: true}

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
	const el_file_input = document.getElementById('file-input')
	const table_1_inputs = []
	for (let i = 24; i; i -= 12)
		table_1_inputs.push([
			document.getElementById('hex-' + i),
			document.getElementById('rgb-' + i),
			document.getElementById('hsl-' + i),
		])
	const el_color_name = document.getElementById('color-name')
	const table_2_head = Array.from(el_main.querySelectorAll(':scope > #params > table > thead > tr > th'))
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
						const ratio = 640 / img.width
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
					el_main.style.maxWidth = Math.max(640, img.width) + 'px'
					adjust_picker()
				}
			}
			reader.readAsDataURL(file)
		}
	}

	const hex_to_rgb = h => [ parseInt(h[1] + h[2], 16), parseInt(h[3] + h[4], 16), parseInt(h[5] + h[6], 16) ]

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
			const [l_2, a_2, b_2] = colors[i][2]
			const delta = ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2, k_l, k_c, k_h)
			if (delta < calc) {
				calc = delta
				name = colors[i][1]
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

	const use_pixel = pixel => {
		if (!use_pixel.last)
			table_2_inputs.map((el, i) => bind('os', el, 'input', () => {
				table_2_head[i].innerHTML = table_2_head[i].innerHTML.replace(/[^a-z]*\)/, ' = ' + el.value + ')')
				use_pixel()
			}, passive))

		pixel ??= use_pixel.last
		use_pixel.last = pixel
		const rgb_24 = [ pixel[0], pixel[1], pixel[2] ]
		const rgb_12 = closest_12(rgb_24[0], rgb_24[1], rgb_24[2])
		const luminance = 0.299 * rgb_24[0] + 0.587 * rgb_24[1] + 0.114 * rgb_24[2]
		table_1_inputs[0][0].parentElement.parentElement.style.color = table_1_inputs[1][0].parentElement.parentElement.style.color = luminance < 128 ? '#fff' : '#000'
		el_color_input.value = table_1_inputs[0][0].value = table_1_inputs[0][0].parentElement.style.backgroundColor = table_1_inputs[0][1].parentElement.style.backgroundColor = table_1_inputs[0][2].parentElement.style.backgroundColor = hex_simple(rgb_to_hex(...rgb_24))
		table_1_inputs[0][1].value = 'rgb(' + rgb_24.join(', ') + ')'
		table_1_inputs[0][2].value = 'hsl(' + rgh_to_hsl(...rgb_24).join('%, ').replace(/%/, '') + '%)'
		el_color_name.textContent = el_color_name.style.backgroundColor = closest_name(...rgb_24)
		table_1_inputs[1][0].value = table_1_inputs[1][0].parentElement.style.backgroundColor = table_1_inputs[1][1].parentElement.style.backgroundColor = table_1_inputs[1][2].parentElement.style.backgroundColor = hex_simple(rgb_to_hex(...rgb_12))
		table_1_inputs[1][1].value = 'rgb(' + rgb_12.join(', ') + ')'
		table_1_inputs[1][2].value = 'hsl(' + rgh_to_hsl(...rgb_12).join('%, ').replace(/%/, '') + '%)'

	}

	const update_colors = (e, rect) => {
		const x = e.clientX - rect.left
		const y = e.clientY - rect.top
		const pixel = ctx.getImageData(x, y, 1, 1).data
		use_pixel(pixel)
	}

	{
		const dropZone = document.body
		bind('os', dropZone, 'dragover', e => e.preventDefault())
		bind('os', dropZone, 'drop', e => e.preventDefault() + handleFiles(e.dataTransfer.files))
		bind('os', dropZone, 'paste', e => handleFiles(e.clipboardData.files), passive)
		const image = 'data:image/jpeg;base64,/9j/4QAYRXhpZgAASUkqAAgAAAAAAAAAAAAAAP/sABFEdWNreQABAAQAAAAeAAD/4QMraHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wLwA8P3hwYWNrZXQgYmVnaW49Iu+7vyIgaWQ9Ilc1TTBNcENlaGlIenJlU3pOVGN6a2M5ZCI/PiA8eDp4bXBtZXRhIHhtbG5zOng9ImFkb2JlOm5zOm1ldGEvIiB4OnhtcHRrPSJBZG9iZSBYTVAgQ29yZSA1LjMtYzAxMSA2Ni4xNDU2NjEsIDIwMTIvMDIvMDYtMTQ6NTY6MjcgICAgICAgICI+IDxyZGY6UkRGIHhtbG5zOnJkZj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+IDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PSIiIHhtbG5zOnhtcD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wLyIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bXA6Q3JlYXRvclRvb2w9IkFkb2JlIFBob3Rvc2hvcCBDUzYgKFdpbmRvd3MpIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOjE4RDkyNzE5MURDNzExRjBCODdBQTBCNUYyRUYwRkE0IiB4bXBNTTpEb2N1bWVudElEPSJ4bXAuZGlkOjE4RDkyNzFBMURDNzExRjBCODdBQTBCNUYyRUYwRkE0Ij4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6MThEOTI3MTcxREM3MTFGMEI4N0FBMEI1RjJFRjBGQTQiIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6MThEOTI3MTgxREM3MTFGMEI4N0FBMEI1RjJFRjBGQTQiLz4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz7/7gAhQWRvYmUAZMAAAAABAwAQAwIDBgAACWoAAA9+AAAnR//bAIQA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'
		fetch(image).then(res => res.blob())
		.then(blob => handleFiles([ new File([blob], "Université de Franche-Comté",{ type: "image/jpeg" }) ]))
		bind('os', el_drop_zone, 'click', () => el_file_input.click(), passive)
		bind('os', el_file_input, 'change', e => handleFiles(e.target.files), passive)
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
	bind('os', el_color_input, 'input', () => use_pixel(hex_to_rgb(el_color_input.value)), passive)

	use_pixel([ Math.floor(Math.random() * 255.0), Math.floor(Math.random() * 255.0), Math.floor(Math.random() * 255.0) ])
}
