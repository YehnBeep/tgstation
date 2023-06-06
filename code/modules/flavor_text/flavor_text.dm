// -- Flavor text datum stuff. --
/// Global list of all flavor texts we have generated. Associated list of [mob name] to [datum ref]
GLOBAL_LIST_EMPTY(flavor_texts)

/**
 * Gets the mob's flavor text datum from the global associated lists of flavor texts.
 * If no flavor text was found, create a new flavor text datum for [added_mob]
 *
 * Returns a datum instance - either a new flavor text or a flavor text from the global list
 * Returns null if the mob was not living or something goes wrong
 */
/proc/add_or_get_mob_flavor_text(mob/living/added_mob)
	RETURN_TYPE(/datum/flavor_text)

	if(!istype(added_mob))
		return null

	var/datum/flavor_text/found_text = GLOB.flavor_texts[added_mob.real_name]
	if(!found_text)
		found_text = new /datum/flavor_text(added_mob)
		GLOB.flavor_texts[added_mob.real_name] = found_text
		if(added_mob.linked_flavor)
			stack_trace("We just made a new flavor text datum for [added_mob] even though it had flavor text linked already, something is messed up")
		added_mob.linked_flavor = found_text

	return found_text


/// Flavor text define for carbons.
/mob/living
	/// The flavor text linked to our carbon.
	var/datum/flavor_text/linked_flavor

/mob/living/Destroy()
	linked_flavor = null // We should never QDEL flavor text datums.
	return ..()

/// The actual flavor text datum. This should never be qdeleted - just leave it floating in the global list.
/datum/flavor_text
	/// The mob that owns this flavor text.
	var/datum/weakref/owner
	/// The name associated with this flavor text.
	var/name
	/// The species associated with this flavor text.
	var/linked_species

	// Shown on examine
	/// The actual flavor text.
	var/flavor_text
	/// Flavor text shown as a silicon
	var/silicon_text

/datum/flavor_text/New(mob/living/initial_linked_mob)
	owner = WEAKREF(initial_linked_mob)
	name = initial_linked_mob.real_name

	if(issilicon(initial_linked_mob))
		linked_species = "silicon"
	else if(ishuman(initial_linked_mob))
		var/mob/living/carbon/human/human_mob = initial_linked_mob
		linked_species = human_mob.dna?.species?.id
	else
		linked_species = "simple"

/**
 * Get the flavor text formatted.
 *
 * examiner - who's POV we're gettting this flavor text from
 * shorten - whether to cut it off at [EXAMINE_FLAVOR_MAX_DISPLAYED]
 *
 * returns a string
 */
/datum/flavor_text/proc/get_flavor_text(mob/living/carbon/human/examiner, shorten = TRUE)
	var/found_text = flavor_text
	if(linked_species == "silicon")
		found_text = silicon_text

	if(!length(found_text))
		return

	if(shorten && length(found_text) > EXAMINE_FLAVOR_MAX_DISPLAYED)
		found_text = TextPreview(found_text, EXAMINE_FLAVOR_MAX_DISPLAYED)
		found_text += " <a href='?src=[REF(src)];flavor_text=1'>\[More\]</a>"

	if(found_text)
		found_text += "\n"

	return found_text



/**
 * proc that formats stuff for the top level examine.
 *
 * examiner - who's POV we're gettting this flavor text from
 * shorten - whether to cut it off at [EXAMINE_FLAVOR_MAX_DISPLAYED]
 *
 * returns a string
 */
/datum/flavor_text/proc/get_flavor_links(mob/living/carbon/human/examiner, shorten = TRUE)
	if(!examiner)
		CRASH("get_flavor_links() called without an examiner argument - proc is not implemented for a null examiner")

	. = ""

	// Whether or not we would have additional info on `examine_more()`.
	var/list/added_info = list()

	// If the client has flavor text set.
	var/found_flavor_text = get_flavor_text(examiner, shorten)
	if(found_flavor_text)
		. += found_flavor_text
		if(length(found_flavor_text) > EXAMINE_FLAVOR_MAX_DISPLAYED)
			added_info += "longer flavor text"

	if(length(added_info) && shorten)
		. += span_smallnoticeital("This individual may have [english_list(added_info, and_text = " or ", final_comma_text = ",")] available if you [EXAMINE_CLOSER_BOLD].\n")

/datum/flavor_text/Topic(href, href_list)
	. = ..()
	if(href_list["flavor_text"])
		if(flavor_text)
			var/datum/browser/popup = new(usr, "[name]'s flavor text", "[name]'s Flavor Text (expanded)", 500, 200)
			popup.set_content(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", "[name]'s flavor text (expanded)", replacetext(flavor_text, "\n", "<BR>")))
			popup.open()
			return
