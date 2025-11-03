class_name ProjectileManifest
extends Node


const PROJECTILE_MAP: Dictionary[String, Dictionary] = {
	"FIRE_BALL": {
		"total": 10,
		"scene": preload("res://src/projectiles/fire_ball/fire_ball.tscn")
	},
	"FOUNTAIN_FIRE_BALL": {
		"total": 10,
		"scene": preload("res://src/projectiles/fountain_fire_ball/fountain_fire_ball.tscn")
	},
	"BEE": {
		"total": 12,
		"scene": preload("res://src/projectiles/bee/bee.tscn")
	},
	"QUEENS_LOVE": {
		"total": 10,
		"scene": preload("res://src/projectiles/queens_love/queens_love.tscn")
	},
	"FALLING_BEEHIVE": {
		"total": 10,
		"scene": preload("res://src/projectiles/falling_beehive/falling_beehive.tscn")
	},
}
