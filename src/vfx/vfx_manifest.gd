class_name VFXManifest
extends Node


const VFX_MAP: Dictionary[String, Dictionary] = {
	"LOVE": {
		"total": 1,
		"scene": preload("res://src/vfx/love/love_vfx.tscn"),
	},
	"IMPACT_DUSTS": {
		"total": 3,
		"scene": preload("res://src/vfx/impact_dusts/imapct_dusts.tscn"),
	},
	"FIRE_BALL_IMPACT": {
		"total": 10,
		"scene": preload("res://src/vfx/fire_ball_impact/fire_ball_impact.tscn"),
	},
	"BLAST": {
		"total": 8,
		"scene": preload("res://src/vfx/blast/blast.tscn"),
	},
	"GREEN_BLAST": {
		"total": 8,
		"scene": preload("res://src/vfx/green_blast/green_blast.tscn"),
	},
	"HONEY_BLAST": {
		"total": 8,
		"scene": preload("res://src/vfx/honey_blast/honey_blast.tscn"),
	},
	"FLESH_BLAST": {
		"total": 8,
		"scene": preload("res://src/vfx/flesh_blast/flesh_blast.tscn"),
	},
	"WALK_DUSTS_1": {
		"total": 3,
		"scene": preload("res://src/vfx/walk_dusts_1/walk_dusts_1.tscn"),
	},
	"WALK_DUSTS_2": {
		"total": 3,
		"scene": preload("res://src/vfx/walk_dusts_2/walk_dusts_2.tscn"),
	},
	"BEEHIVE_SHOOT_TRAILS": {
		"total": 10,
		"scene": preload("res://src/vfx/beehive_shoot_trails/beehive_shoot_trails.tscn"),
	},
}
