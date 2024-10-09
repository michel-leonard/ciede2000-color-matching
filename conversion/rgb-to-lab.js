function rgb_to_lab(r, g, b) {
	var xyz = rgb_to_xyz(r, g, b)
	return xyz_to_lab(...xyz)
}
