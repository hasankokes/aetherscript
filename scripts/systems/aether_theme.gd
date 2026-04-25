extends Node

# Main color palette
const COLOR_BG_DARK       = Color(0.051, 0.067, 0.110)   # #0D1120
const COLOR_BG_MID        = Color(0.102, 0.141, 0.196)   # #1A2432
const COLOR_PURPLE        = Color(0.482, 0.184, 0.745)   # #7B2FBE
const COLOR_PURPLE_DARK   = Color(0.290, 0.082, 0.502)   # #4A1580
const COLOR_GOLD          = Color(0.863, 0.647, 0.063)   # #DCA510
const COLOR_WHITE_SOFT    = Color(0.92, 0.90, 0.98)

# Element colors - main
const COLOR_FIRE          = Color(1.000, 0.227, 0.063)   # #FF3A10
const COLOR_FIRE_GLOW     = Color(1.000, 0.549, 0.000)   # #FF8C00
const COLOR_WATER         = Color(0.063, 0.482, 0.910)   # #107BE8
const COLOR_WATER_GLOW    = Color(0.000, 0.898, 0.831)   # #00E5D4
const COLOR_EARTH         = Color(0.541, 0.416, 0.102)   # #8A6A1A
const COLOR_EARTH_GLOW    = Color(0.831, 0.627, 0.090)   # #D4A017
const COLOR_AIR           = Color(0.690, 0.878, 1.000)   # #B0E0FF
const COLOR_AIR_GLOW      = Color(1.000, 1.000, 1.000)   # #FFFFFF
const COLOR_NEUTRAL       = Color(0.600, 0.600, 0.650)

# Card type colors
const COLOR_ACTION        = Color(0.900, 0.200, 0.200)
const COLOR_MODIFIER      = Color(0.863, 0.647, 0.063)
const COLOR_LOGIC         = Color(0.200, 0.400, 0.900)
const COLOR_CHANNEL       = Color(0.100, 0.800, 0.700)
const COLOR_DELAY         = Color(0.500, 0.500, 0.550)

func get_element_color(element: AEnums.ElementType) -> Color:
	match element:
		AEnums.ElementType.FIRE:    return COLOR_FIRE
		AEnums.ElementType.WATER:   return COLOR_WATER
		AEnums.ElementType.EARTH:   return COLOR_EARTH
		AEnums.ElementType.AIR:     return COLOR_AIR
		_:                               return COLOR_NEUTRAL

func get_element_glow(element: AEnums.ElementType) -> Color:
	match element:
		AEnums.ElementType.FIRE:    return COLOR_FIRE_GLOW
		AEnums.ElementType.WATER:   return COLOR_WATER_GLOW
		AEnums.ElementType.EARTH:   return COLOR_EARTH_GLOW
		AEnums.ElementType.AIR:     return COLOR_AIR_GLOW
		_:                               return COLOR_NEUTRAL

func get_card_type_color(card_type: AEnums.CardType) -> Color:
	match card_type:
		AEnums.CardType.ACTION:   return COLOR_ACTION
		AEnums.CardType.MODIFIER: return COLOR_MODIFIER
		AEnums.CardType.LOGIC:    return COLOR_LOGIC
		AEnums.CardType.CHANNEL:  return COLOR_CHANNEL
		AEnums.CardType.DELAY:    return COLOR_DELAY
		_:                             return COLOR_NEUTRAL
