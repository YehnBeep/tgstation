// -- Extra human level procc etensions. --
/mob/living/carbon/human/Topic(href, href_list)
	. = ..()
	if(href_list["flavor_text"])
		if(linked_flavor)
			var/datum/browser/popup = new(usr, "[name]'s flavor text", "[name]'s Flavor Text (expanded)", 500, 200)
			popup.set_content(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", "[name]'s flavor text (expanded)", replacetext(linked_flavor.flavor_text, "\n", "<BR>")))
			popup.open()
			return

