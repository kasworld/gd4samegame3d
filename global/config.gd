extends Node

const BallRadius := 0.5

const WorldSize := Vector3(40,22,BallRadius*2)

var tex_array = [
	#preload("res://BallTexture/ball1.tres"),
	#preload("res://BallTexture/ball2.tres"),
	#preload("res://BallTexture/ball3.tres"),
	#preload("res://BallTexture/ball4.tres"),
	#preload("res://BallTexture/ball5.tres"),
	#preload("res://BallTexture/ball6.tres"),
	#preload("res://BallTexture/ball7.tres"),
	#preload("res://BallTexture/ball8.tres"),
	preload("res://BallTexture/ball9.tres"),
	preload("res://BallTexture/ball10.tres"),
	preload("res://BallTexture/ball11.tres"),
	preload("res://BallTexture/ball12.tres"),
	preload("res://BallTexture/ball13.tres"),
	preload("res://BallTexture/ball14.tres"),
	preload("res://BallTexture/ball15.tres"),
]

var tex_array2 = [
	preload("res://earthmoon/earth.tres"),
	preload("res://earthmoon/moon.tres"),
	preload("res://BallTexture/softball.tres"),
	preload("res://BallTexture/tennisball.tres"),
]
