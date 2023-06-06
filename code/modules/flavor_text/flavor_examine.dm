/// -- Extension of examine, examine_more, and flavortext code. --


/**
 *	Flavor text and Personal Records On Examine INS AND OUTS (implementation by mrmelbert)
 *
 * (Original by mrmelbert, this version has been simplified but is preserved for info on how disguises work)
 *
 *	- Admin ghosts, when examining, are given a list of buttons for all the records of a player.
 *		(This can probably be moved to examine_more if it's too annoying)
 *	- When you examine yourself, you will always see your own flavor text, no matter what.
 *	- When another person examines you, the following happens:
 *		> If your face is covered (by helmet or mask), they will not see your favor text unless you're wearing your ID.
 *		> If you are wearing another player's ID (In disguise as another active player), they will see the other player's flavor instead.
 *		> If you are not wearing another player's ID (if you are unknown, or wearing a non-player's ID), no flavor text will show up as if none were set.
 *		> If you do not have any flavor text, nothing special happens. The examine is normal.
 *
 *	- Flavor text is displayed to other players without any pre-requisites. It displays [EXAMINE_FLAVOR_MAX_DISPLAYED] (65 by default) characters before being trimmed.

 */


/// Mob level examining that happens after the main beef of examine is done
/mob/living/proc/late_examine(mob/user)
	. = list()
	SEND_SIGNAL(src, COMSIG_LIVING_LATE_EXAMINE, user, .)

	// Who's identity are we dealing with? In most cases it's the same as [src], but it could be disguised people, or null.
	var/datum/flavor_text/known_identity = get_visible_flavor(user)
	var/expanded_examine = ""

	if(known_identity)
		expanded_examine += known_identity.get_flavor_links(user)

	if(linked_flavor && user.client?.holder && isAdminObserver(user))
		// Formatted output list of records.
		var/admin_line = ""

		if(linked_flavor.flavor_text)
			admin_line += "<a href='?src=[REF(linked_flavor)];flavor_text=1'>\[FLA\]</a>"

		if(known_identity != linked_flavor)
			admin_line += "\nThey are currently [isnull(known_identity) ? "disguised and have no visible flavor":"visible as the flavor text of [known_identity.name]"]."

		if(admin_line)
			expanded_examine += "ADMIN EXAMINE: [ADMIN_LOOKUPFLW(src)] - [admin_line]\n"

	if(length(expanded_examine))
		expanded_examine = span_info(expanded_examine)
		. += expanded_examine

// This isn't even an extension of examine_more this is the only definition for /human/examine_more, isn't that neat?
/mob/living/examine_more(mob/user)
	. = ..()
	var/datum/flavor_text/known_identity = get_visible_flavor(user)

	if(known_identity)
		. += span_info(known_identity.get_flavor_links(user, FALSE))
	else if(ishuman(src))
		// I hate this istype src but it's easier to handle this here
		// Not all mobs should say "YOU CAN'T MAKE OUT DETAILS OF THIS PERSON"
		. += span_smallnoticeital("You can't make out any details of this individual.\n")
