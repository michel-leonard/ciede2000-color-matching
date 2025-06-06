import random
import sys

def exec_colormath(n):
	import numpy
	def patch_asscalar(a):
		return a.item()
	setattr(numpy, "asscalar", patch_asscalar)
	from colormath.color_objects import LabColor
	from colormath.color_diff import delta_e_cie2000
	for _ in range(n):
		L1 = round(random.uniform(0, 100), 2)
		a1 = round(random.uniform(-128, 127), 2)
		b1 = round(random.uniform(-128, 127), 2)
		L2 = round(random.uniform(0, 100), 2)
		a2 = round(random.uniform(-128, 127), 2)
		b2 = round(random.uniform(-128, 127), 2)
		color1 = LabColor(L1, a1, b1)
		color2 = LabColor(L2, a2, b2)
		delta_e = delta_e_cie2000(color1, color2)
		print(f"{L1:g},{a1:g},{b1:g},{L2:g},{a2:g},{b2:g},{delta_e:.15g}")

if __name__ == "__main__":
	n_iterations = int(sys.argv[1]) if 1 < len(sys.argv) and sys.argv[1].rstrip('0123456789') == '' else 10000
	n_iterations = n_iterations if 0 < n_iterations else 10000
	exec_colormath(n_iterations)
