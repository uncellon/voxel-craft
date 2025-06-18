@tool

class_name Block
extends RefCounted

################################################################################
# Static variables                                                             #
################################################################################

# This constants is static variables due to the issue:
# https://github.com/godotengine/godot/issues/85557

static var VERTICES = [
	Vector3i(0, 0, 0),
	Vector3i(1, 0, 0),
	Vector3i(0, 1, 0),
	Vector3i(1, 1, 0),
	Vector3i(0, 0, 1),
	Vector3i(1, 0, 1),
	Vector3i(0, 1, 1),
	Vector3i(1, 1, 1),
]

# Faces vertices painting order
static var TOP_FACE    = [2, 3, 7, 6]
static var BOTTOM_FACE = [0, 4, 5, 1]
static var LEFT_FACE   = [6, 4, 0, 2]
static var RIGHT_FACE  = [3, 1, 5, 7]
static var FRONT_FACE  = [7, 5, 4, 6]
static var BACK_FACE   = [2, 0, 1, 3]
