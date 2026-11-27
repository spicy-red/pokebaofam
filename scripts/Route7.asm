Route7_Script:
	jp EnableAutoTextBoxDrawing

Route7_TextPointers:
	def_text_pointers
	dw_const Route7UndergroundPathSignText, TEXT_ROUTE7_UNDERGROUND_PATH_SIGN
	dw_const Route7FishingPondSignText,     TEXT_ROUTE7_FISHING_POND_SIGN ; bfe - new for fishing pond

Route7UndergroundPathSignText:
	text_far _Route7UndergroundPathSignText
	text_end

Route7FishingPondSignText: ; bfe - new for fishing pond
	text_far _Route7FishingPondSignText
	text_end
