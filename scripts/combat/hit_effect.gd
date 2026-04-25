class_name HitEffect
extends Node2D

@onready var particles: GPUParticles2D = $Particles
@onready var flash_rect: ColorRect     = $FlashRect

func play(element: AEnums.ElementType, pos: Vector2) -> void:
	global_position = pos
	var _aether_theme = get_node("/root/AetherTheme")
	var color = _aether_theme.get_element_color(element)
	var glow  = _aether_theme.get_element_glow(element)

	# Parçacık rengi
	var mat = ParticleProcessMaterial.new()
	mat.emission_shape      = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = 5.0
	mat.initial_velocity_min   = 60.0
	mat.initial_velocity_max   = 120.0
	mat.gravity                = Vector3(0, 80, 0)
	mat.scale_min              = 3.0
	mat.scale_max              = 7.0
	mat.color                  = color
	particles.process_material = mat
	particles.amount           = 18
	particles.lifetime         = 0.5
	particles.one_shot         = true
	particles.emitting         = true

	# Flaş
	flash_rect.color     = glow
	flash_rect.visible   = true
	var tween = create_tween()
	tween.tween_property(flash_rect, "modulate:a", 0.0, 0.15)
	tween.tween_callback(func(): flash_rect.visible = false)

	# Efekt bittikten sonra kendini sil
	await get_tree().create_timer(0.8).timeout
	queue_free()
