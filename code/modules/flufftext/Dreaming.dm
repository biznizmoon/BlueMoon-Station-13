/mob/living/carbon/proc/dream()
	set waitfor = FALSE
	var/list/dream_fragments = list()
	var/list/custom_dream_nouns = list()
	var/fragment = ""

	for(var/obj/item/bedsheet/sheet in loc)
		custom_dream_nouns += sheet.dream_messages

	dream_fragments += "Вижу..."

	//NIGHTMARE
	var/datum/component/mood/mood = src.GetComponent(/datum/component/mood)
	if(prob(mood.sanity-100)&&(mood.sanity < 60)||prob(5))
		var/safefeel
		for(var/obj/item/bedsheet/sheet in loc)
			safefeel++
		if(safefeel && mood.sanity > (40 / safefeel))
			return
		fragment += pick(GLOB.dream_strings)
		if(findtext(fragment, "%A% "))
			fragment = replacetext(fragment, "%ADJECTIVE% ", "")
			fragment = "\a [replacetext(fragment, "%A% ", "")]"
			to_chat(src, "<span class='warning'><b>Тебе приснился ужасный кошмар о [fragment]...</b></span>")
			src.visible_message("<span class='notice'>[src] shakes in their sleep.</span>")
			src.do_jitter_animation() //shake in their sleep.
			fragment = ""
			return

	//Subject
	if(custom_dream_nouns.len && prob(90))
		fragment += pick(custom_dream_nouns)
	else
		fragment += pick(GLOB.dream_strings)

	if(prob(50))
		fragment = replacetext(fragment, "%ADJECTIVE%", pick(GLOB.adjectives))
	else
		fragment = replacetext(fragment, "%ADJECTIVE% ", "")
	if(findtext(fragment, "%A% "))
		fragment = "\a [replacetext(fragment, "%A% ", "")]"
	dream_fragments += fragment

	//Verb
	fragment = ""
	if(prob(50))
		if(prob(35))
			fragment += "[pick(GLOB.adverbs)] "
		fragment += pick(GLOB.ing_verbs)
	else
		fragment += "will "
		fragment += pick(GLOB.verbs)
	dream_fragments += fragment

	if(prob(25))
		dream_sequence(dream_fragments)
		return

	//Object
	fragment = ""
	fragment += pick(GLOB.dream_strings)
	if(prob(50))
		fragment = replacetext(fragment, "%ADJECTIVE%", pick(GLOB.adjectives))
	else
		fragment = replacetext(fragment, "%ADJECTIVE% ", "")
	if(findtext(fragment, "%A% "))
		fragment = "\a [replacetext(fragment, "%A% ", "")]"
	dream_fragments += fragment

	dreaming = TRUE
	dream_sequence(dream_fragments)

/mob/living/carbon/proc/dream_sequence(list/dream_fragments)
	if(stat != UNCONSCIOUS || InCritical())
		dreaming = FALSE
		return
	var/next_message = dream_fragments[1]
	dream_fragments.Cut(1,2)
	to_chat(src, "<span class='notice'><i>... [next_message] ...</i></span>")
	if(LAZYLEN(dream_fragments))
		addtimer(CALLBACK(src, .proc/dream_sequence, dream_fragments), rand(10,30))
	else
		dreaming = FALSE
