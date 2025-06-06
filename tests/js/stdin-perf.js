const rl = require("readline").createInterface({
	input: process.stdin,
	output: process.stdout,
	terminal: false
})

const t_1 = Date.now()

rl.once("close", () => {
	const t_2 = Date.now()
	const duration_s = (t_2 - t_1) / 1000
	const duration_str = Math.round(duration_s * 100) / 100
	const n_calls = 40960000
	const calls_per_sec = Math.floor(n_calls / duration_s).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
	const n_calls_str = n_calls.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
	const msg = `A total of ${n_calls_str} function calls were executed over ${duration_str} seconds, resulting in a throughput of ${calls_per_sec} calls per second.`
	console.log(msg)
})
