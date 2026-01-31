@tool
class_name ItemEnums
extends RefCounted
## Shared enums for the item system.
## Used by ItemDefinition, ItemDatabase, and the editor.
##
## Inventory Forge Plugin by Menkos
## License: MIT


## Item category
enum Category {
	CONSUMABLE,    ## Consumable (potions, food)
	WEAPON,        ## Weapon
	ARMOR,         ## Armor
	ACCESSORY,     ## Accessory (rings, amulets)
	KEY_ITEM,      ## Key/quest item
	MISC,          ## Miscellaneous
}


## Item rarity
enum Rarity {
	COMMON,        ## Common (gray/white)
	UNCOMMON,      ## Uncommon (green)
	RARE,          ## Rare (blue)
	EPIC,          ## Epic (purple)
	LEGENDARY,     ## Legendary (orange/gold)
}


## Equipment slot
enum EquipSlot {
	NONE,          ## Not equippable
	HEAD,          ## Head
	BODY,          ## Body
	HANDS,         ## Hands
	FEET,          ## Feet
	WEAPON,        ## Weapon (main hand)
	SHIELD,        ## Shield (off hand)
	ACCESSORY_1,   ## Accessory slot 1
	ACCESSORY_2,   ## Accessory slot 2
}


## Effect type for consumables
enum EffectType {
	NONE,          ## No effect
	HEAL_HP,       ## Heal HP
	HEAL_MP,       ## Heal MP
	HEAL_BOTH,     ## Heal HP and MP
	BUFF_ATK,      ## Temporary attack buff
	BUFF_DEF,      ## Temporary defense buff
	BUFF_SPD,      ## Temporary speed buff
	CURE_POISON,   ## Cure poison
	CURE_ALL,      ## Cure all negative statuses
	DAMAGE,        ## Deal damage (bombs, etc.)
	TELEPORT,      ## Teleportation
	REVIVE,        ## Revive
}


## Material type for crafting ingredients
enum MaterialType {
	NONE,          ## Not a crafting ingredient
	ORE,           ## Ores and minerals (Iron Ore, Gold Nugget)
	HERB,          ## Plants and herbs (Healing Herb, Mana Flower)
	WOOD,          ## Wood materials (Oak Wood, Mystical Branch)
	LEATHER,       ## Leather and hides (Wolf Pelt, Dragon Scale)
	CLOTH,         ## Fabrics and threads (Silk, Cotton)
	GEM,           ## Precious gems (Ruby, Diamond)
	LIQUID,        ## Liquids and essences (Holy Water, Magic Essence)
	COMPONENT,     ## Crafted components (Iron Bar, Enchanted Crystal)
	FOOD,          ## Food ingredients (Wheat, Milk)
	MAGICAL,       ## Magical reagents (Phoenix Feather, Unicorn Horn)
	MISC,          ## Miscellaneous materials
}


## Passive effect type
enum PassiveType {
	NONE,              ## No passive effect
	LIFESTEAL,         ## Heal on hit (% of damage)
	FIRE_DAMAGE,       ## Bonus fire damage
	ICE_DAMAGE,        ## Bonus ice damage
	LIGHTNING_DAMAGE,  ## Bonus lightning damage
	POISON_DAMAGE,     ## Bonus poison damage
	CRITICAL_CHANCE,   ## Bonus critical hit chance
	CRITICAL_DAMAGE,   ## Bonus critical damage multiplier
	DODGE_CHANCE,      ## Chance to dodge attacks
	BLOCK_CHANCE,      ## Chance to block attacks
	HP_REGEN,          ## HP regeneration per turn
	MP_REGEN,          ## MP regeneration per turn
	FIRE_RESIST,       ## Fire damage resistance
	ICE_RESIST,        ## Ice damage resistance
	LIGHTNING_RESIST,  ## Lightning damage resistance
	POISON_RESIST,     ## Poison damage resistance
	STUN_RESIST,       ## Stun resistance
	THORNS,            ## Reflect damage to attacker
	BONUS_EXP,         ## Bonus experience gain
	BONUS_GOLD,        ## Bonus gold drop
}


## Helper: Gets the translated category name
static func get_category_name(category: Category) -> String:
	match category:
		Category.CONSUMABLE: return "CATEGORY_CONSUMABLE"
		Category.WEAPON: return "CATEGORY_WEAPON"
		Category.ARMOR: return "CATEGORY_ARMOR"
		Category.ACCESSORY: return "CATEGORY_ACCESSORY"
		Category.KEY_ITEM: return "CATEGORY_KEY_ITEM"
		Category.MISC: return "CATEGORY_MISC"
		_: return "CATEGORY_UNKNOWN"


## Helper: Gets the translated rarity name
static func get_rarity_name(rarity: Rarity) -> String:
	match rarity:
		Rarity.COMMON: return "RARITY_COMMON"
		Rarity.UNCOMMON: return "RARITY_UNCOMMON"
		Rarity.RARE: return "RARITY_RARE"
		Rarity.EPIC: return "RARITY_EPIC"
		Rarity.LEGENDARY: return "RARITY_LEGENDARY"
		_: return "RARITY_UNKNOWN"


## Helper: Gets the color associated with rarity
static func get_rarity_color(rarity: Rarity) -> Color:
	match rarity:
		Rarity.COMMON: return Color.WHITE
		Rarity.UNCOMMON: return Color.GREEN
		Rarity.RARE: return Color.DODGER_BLUE
		Rarity.EPIC: return Color.MEDIUM_PURPLE
		Rarity.LEGENDARY: return Color.ORANGE
		_: return Color.WHITE


## Helper: Gets the translated equipment slot name
static func get_equip_slot_name(slot: EquipSlot) -> String:
	match slot:
		EquipSlot.NONE: return "EQUIP_SLOT_NONE"
		EquipSlot.HEAD: return "EQUIP_SLOT_HEAD"
		EquipSlot.BODY: return "EQUIP_SLOT_BODY"
		EquipSlot.HANDS: return "EQUIP_SLOT_HANDS"
		EquipSlot.FEET: return "EQUIP_SLOT_FEET"
		EquipSlot.WEAPON: return "EQUIP_SLOT_WEAPON"
		EquipSlot.SHIELD: return "EQUIP_SLOT_SHIELD"
		EquipSlot.ACCESSORY_1: return "EQUIP_SLOT_ACCESSORY_1"
		EquipSlot.ACCESSORY_2: return "EQUIP_SLOT_ACCESSORY_2"
		_: return "EQUIP_SLOT_UNKNOWN"


## Helper: Gets the translated effect type name
static func get_effect_type_name(effect: EffectType) -> String:
	match effect:
		EffectType.NONE: return "EFFECT_NONE"
		EffectType.HEAL_HP: return "EFFECT_HEAL_HP"
		EffectType.HEAL_MP: return "EFFECT_HEAL_MP"
		EffectType.HEAL_BOTH: return "EFFECT_HEAL_BOTH"
		EffectType.BUFF_ATK: return "EFFECT_BUFF_ATK"
		EffectType.BUFF_DEF: return "EFFECT_BUFF_DEF"
		EffectType.BUFF_SPD: return "EFFECT_BUFF_SPD"
		EffectType.CURE_POISON: return "EFFECT_CURE_POISON"
		EffectType.CURE_ALL: return "EFFECT_CURE_ALL"
		EffectType.DAMAGE: return "EFFECT_DAMAGE"
		EffectType.TELEPORT: return "EFFECT_TELEPORT"
		EffectType.REVIVE: return "EFFECT_REVIVE"
		_: return "EFFECT_UNKNOWN"


## Helper: Gets the translated material type name
static func get_material_type_name(mat_type: MaterialType) -> String:
	match mat_type:
		MaterialType.NONE: return "MATERIAL_NONE"
		MaterialType.ORE: return "MATERIAL_ORE"
		MaterialType.HERB: return "MATERIAL_HERB"
		MaterialType.WOOD: return "MATERIAL_WOOD"
		MaterialType.LEATHER: return "MATERIAL_LEATHER"
		MaterialType.CLOTH: return "MATERIAL_CLOTH"
		MaterialType.GEM: return "MATERIAL_GEM"
		MaterialType.LIQUID: return "MATERIAL_LIQUID"
		MaterialType.COMPONENT: return "MATERIAL_COMPONENT"
		MaterialType.FOOD: return "MATERIAL_FOOD"
		MaterialType.MAGICAL: return "MATERIAL_MAGICAL"
		MaterialType.MISC: return "MATERIAL_MISC"
		_: return "MATERIAL_UNKNOWN"


## Helper: Gets the translated passive type name
static func get_passive_type_name(passive: PassiveType) -> String:
	match passive:
		PassiveType.NONE: return "PASSIVE_NONE"
		PassiveType.LIFESTEAL: return "PASSIVE_LIFESTEAL"
		PassiveType.FIRE_DAMAGE: return "PASSIVE_FIRE_DAMAGE"
		PassiveType.ICE_DAMAGE: return "PASSIVE_ICE_DAMAGE"
		PassiveType.LIGHTNING_DAMAGE: return "PASSIVE_LIGHTNING_DAMAGE"
		PassiveType.POISON_DAMAGE: return "PASSIVE_POISON_DAMAGE"
		PassiveType.CRITICAL_CHANCE: return "PASSIVE_CRITICAL_CHANCE"
		PassiveType.CRITICAL_DAMAGE: return "PASSIVE_CRITICAL_DAMAGE"
		PassiveType.DODGE_CHANCE: return "PASSIVE_DODGE_CHANCE"
		PassiveType.BLOCK_CHANCE: return "PASSIVE_BLOCK_CHANCE"
		PassiveType.HP_REGEN: return "PASSIVE_HP_REGEN"
		PassiveType.MP_REGEN: return "PASSIVE_MP_REGEN"
		PassiveType.FIRE_RESIST: return "PASSIVE_FIRE_RESIST"
		PassiveType.ICE_RESIST: return "PASSIVE_ICE_RESIST"
		PassiveType.LIGHTNING_RESIST: return "PASSIVE_LIGHTNING_RESIST"
		PassiveType.POISON_RESIST: return "PASSIVE_POISON_RESIST"
		PassiveType.STUN_RESIST: return "PASSIVE_STUN_RESIST"
		PassiveType.THORNS: return "PASSIVE_THORNS"
		PassiveType.BONUS_EXP: return "PASSIVE_BONUS_EXP"
		PassiveType.BONUS_GOLD: return "PASSIVE_BONUS_GOLD"
		_: return "PASSIVE_UNKNOWN"


## Helper: Gets display name for passive (non-translated, for editor)
static func get_passive_display_name(passive: PassiveType) -> String:
	match passive:
		PassiveType.NONE: return "None"
		PassiveType.LIFESTEAL: return "Lifesteal"
		PassiveType.FIRE_DAMAGE: return "Fire Damage"
		PassiveType.ICE_DAMAGE: return "Ice Damage"
		PassiveType.LIGHTNING_DAMAGE: return "Lightning Damage"
		PassiveType.POISON_DAMAGE: return "Poison Damage"
		PassiveType.CRITICAL_CHANCE: return "Critical Chance"
		PassiveType.CRITICAL_DAMAGE: return "Critical Damage"
		PassiveType.DODGE_CHANCE: return "Dodge Chance"
		PassiveType.BLOCK_CHANCE: return "Block Chance"
		PassiveType.HP_REGEN: return "HP Regen"
		PassiveType.MP_REGEN: return "MP Regen"
		PassiveType.FIRE_RESIST: return "Fire Resist"
		PassiveType.ICE_RESIST: return "Ice Resist"
		PassiveType.LIGHTNING_RESIST: return "Lightning Resist"
		PassiveType.POISON_RESIST: return "Poison Resist"
		PassiveType.STUN_RESIST: return "Stun Resist"
		PassiveType.THORNS: return "Thorns"
		PassiveType.BONUS_EXP: return "Bonus EXP"
		PassiveType.BONUS_GOLD: return "Bonus Gold"
		_: return "Unknown"
