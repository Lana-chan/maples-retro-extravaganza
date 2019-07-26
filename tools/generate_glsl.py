#!/usr/bin/python3

from PIL import Image, ImageColor
import math
import sys
import os

def read_colors(filename):
	color_hash = {}
	i = Image.open(filename)
	img = i.convert('RGB')
	(width, height) = img.size
	for x in range(width):
		for y in range(height):
			# print img.getpixel( (x,y) )
			color_hash[img.getpixel( (x,y) )] = True
	return color_hash.keys()

def generate_glsl(colors):
	output = "vec3 palette[] = vec3[{}](\n".format(len(colors))

	for c in colors:
		r = c[0] / 255.0
		g = c[1] / 255.0
		b = c[2] / 255.0
		output += "	vec3({:.3}, {:.3}, {:.3}),\n".format(r, g, b)

	output += ");"
	return output


if __name__ == "__main__":
	if len(sys.argv) < 2:
		print("usage: generate_clut input_image [output.txt]")
		sys.exit()

	input_image = sys.argv[1]
	output_filename = "{}.txt".format(os.path.splitext(sys.argv[1])[0])
	if len(sys.argv) == 3:
		output_filename = sys.argv[2]

	print("reading colors from {}".format(input_image))
	colors = read_colors(input_image)
	print("number of colors: {}".format(len(colors)))
	
	with open(output_filename, "w") as f:
		f.write(generate_glsl(colors))