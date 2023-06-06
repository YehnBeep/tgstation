#define MAX_FLAVOR_LEN 2048 // NON-MODULE CHANGES

/datum/preference/multiline_text
	abstract_type = /datum/preference/multiline_text
	can_randomize = FALSE

/datum/preference/multiline_text/deserialize(input, datum/preferences/preferences)
	return STRIP_HTML_SIMPLE("[input]", MAX_FLAVOR_LEN)

/datum/preference/multiline_text/serialize(input)
	return STRIP_HTML_SIMPLE(input, MAX_FLAVOR_LEN)

/datum/preference/multiline_text/is_valid(value)
	return istext(value) && !isnull(STRIP_HTML_SIMPLE(value, MAX_FLAVOR_LEN))

/datum/preference/multiline_text/create_default_value()
	return null

/datum/preference/multiline_text/flavor_datum
	abstract_type = /datum/preference/multiline_text/flavor_datum
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	priority = PREFERENCE_PRIORITY_NAME_MODIFICATIONS

/datum/preference/multiline_text/flavor_datum/apply_to_human(mob/living/carbon/human/target, value)
	if(!value)
		return

	// Doesn't need to apply to the dummy
	if(istype(target, /mob/living/carbon/human/dummy))
		return

	return target.linked_flavor || add_or_get_mob_flavor_text(target)

/datum/preference/multiline_text/flavor_datum/flavor
	savefile_key = "flavor_text"

/datum/preference/multiline_text/flavor_datum/flavor/apply_to_human(mob/living/carbon/human/target, value)
	var/datum/flavor_text/our_flavor = ..()
	our_flavor?.flavor_text = value

/datum/preference/multiline_text/flavor_datum/silicon
	savefile_key = "silicon_text"

/datum/preference/multiline_text/flavor_datum/silicon/apply_to_human(mob/living/carbon/human/target, value)
	var/datum/flavor_text/our_flavor = ..()
	our_flavor?.silicon_text = value

#undef MAX_FLAVOR_LEN
