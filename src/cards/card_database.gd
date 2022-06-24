extends Resource

## unit info [type, name, cost, health, is_archer, is_cavalry, damage, defence, min_range, max_range, movement, ability]
## structure info [type, name, cost, health, ability]
## weapon info [type, name, cost, ability]

## is_archer or is_cavalry should have a value of 0 if false, and 1 if true. if max_range is set to 0, then the unit only has a min_range

const UNITS := {
	"militia": 
		["unit", "militia", 2, 10, 0, 0, 4, 0, 1, 1, 2, { "cover": 1,}],
	"archer": 
		["unit", "archer", 2, 6, 1, 0, 3, 0, 2, 4, 2, {}],
	"horseman": 
		["unit", "horseman", 2, 10, 0, 1, 3, 0, 1, 1, 4, {}],
	"hoplite": 
		["unit", "hoplite", 2, 10, 0, 0, 3, 1, 1, 1, 2, {"has_polearm":true}],
	"camel_rider": 
		["unit", "camel_rider", 2, 10, 0, 1, 4, 0, 1, 1, 3, {}],
	"slinger": 
		["unit", "slinger", 2, 8, 0, 0, 2, 0, 1, 3, 2, {}],
	"scout": 
		["unit", "scout", 2, 8, 0, 0, 3, 0, 1, 1, 3, {}],
	
	"crossbowman": 
		["unit", "crossbowman", 3, 8, 1, 0, 5, 0, 1, 3, 2, {}],
	"templar": 
		["unit", "templar", 3, 10, 0, 0, 5, 1, 1, 1, 2, {}],
	"skirmisher": 
		["unit", "skirmisher", 3, 10, 0, 0, 4, 0, 1, 1, 3, { "cover": 1}],
	
	"cataphract": 
		["unit", "cataphract", 4, 10, 0, 1, 4, 2, 1, 1, 3, {}],
	"legionary": 
		["unit", "legionary", 4, 12, 0, 0, 4, 2, 1, 1, 2, {"has_polearm":true}],
	
	"longbowman": 
		["unit", "longbowman", 5, 8, 1, 0, 5, 0, 3, 5, 2, {}],
	"knight": 
		["unit", "knight", 5, 15, 0, 1, 3, 5, 1, 1, 4, {}],
	"name": 
		["unit", "name", 2, 10, 0, 0, 3, 2, 1, 1, 2, {}],
}

const STRUCTURES := {
	"first_aid_tent":
		["structure", "first_aid_tent", 2, 4, {"supplier_range": 3}],
	"palisade":
		["structure", "palisade", 1, 6, {}],
}

# [health, is_archer, is_cavalry, damage, defense, max_range, movement]
const WEAPONS := {
	"horse":
		["weapon", "horse", 1, [2,1,0,1,1,2,3], {"has_pierce": true}, {}],
	"zweihander":
		["weapon", "zweihander", 1, {}],
}

