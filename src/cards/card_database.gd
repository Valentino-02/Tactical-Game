extends Resource

## unit info [type, name, cost, health if_archer, if_cavalry, damage, defence, min_range, max_range, movement, ability]
## structure info [type, name, cost, health, ability]
## weapon info [type, name, cost, ability]

## if_archer or if_cavalry should have a value of 0 if false, and 1 if true. if max_range is set to 0, then the unit only has a min_range

const UNITS := {
	"infantry": 
		["unit", "infantry", 2, 12, 0, 0, 4, 1, 1, 1, 2, null],
	"archer": 
		["unit", "archer", 2, 10, 1, 1, 3, 0, 2, 4, 4, null],
}

const STRUCTURES := {
	"first_aid_tent":
		["structure", "first_aid_tent", 2, 4, null],
	"palisade":
		["structure", "palisade", 1, 6, null],
}

const WEAPONS := {
	"horse":
		["weapon", "horse", 1, null],
	"zweihander":
		["weapon", "zweihander", 1, null],
}

