; Elite Baos: short lines, with space for battle-engine name prefixes.
_BattleHallReceptionistNeedSixMonText::
	text "Welcome to the"
	line "Elite Bao Hall!"
	para "Bring a full"
	line "team of six"
	cont "#MON."
	done

_BattleHallReceptionistTeamReadyText::
	text "Welcome to the"
	line "Elite Bao Hall!"
	para "20 battles:"
	para "10 APPRENTICES"
	line "10 ELITE BAOS."
	para "APPRENTICES:"
	line "Level 100."
	para "ELITE BAOS:"
	line "Level 130."
	para "APPRENTICE,"
	line "then BAO."
	para "No healing."
	line "No items."
	para "Use the PC to"
	line "swap the team."
	para "SAVE to pause."
	para "Leave or lose:"
	line "your run ends."
	done

_BattleHallReceptionistWhatABattleText::
	text "All 20 beaten!"
	line "Well done!"
	done

_EliteBao1BattleText::
	text "BAO SNOOPY:"
	line "Yo!"
	cont "I was first"
	cont "to beat ODO!"
	done

_EliteBao1DefeatedText::
	text_start
	line "Not bad!"
	para "APPRENTICE"
	line "is next."
	done

_EliteBao2BattleText::
	text "FILLER2:"
	line "Glub!"
	cont "FILLER BAO!"
	done

_EliteBao2DefeatedText::
	text_start
	line "Washed up!"
	para "APPRENTICE"
	line "is next."
	done

_EliteBao3BattleText::
	text "FILLER3:"
	line "Burn!"
	cont "FIRE BAO!"
	done

_EliteBao3DefeatedText::
	text_start
	line "Burnt out!"
	para "APPRENTICE"
	line "is next."
	done

_EliteBao4BattleText::
	text "FILLER4:"
	line "My vines"
	cont "will bind you!"
	done

_EliteBao4DefeatedText::
	text_start
	line "Wilted!"
	para "APPRENTICE"
	line "is next."
	done

_EliteBao5BattleText::
	text "FILLER5:"
	line "ZAP!"
	cont "ELECTRIC BAO!"
	done

_EliteBao5DefeatedText::
	text_start
	line "Power off!"
	para "APPRENTICE"
	line "is next."
	done

_EliteBao6BattleText::
	text "FILLER6:"
	line "I see you."
	cont "PSYCHIC BAO!"
	done

_EliteBao6DefeatedText::
	text_start
	line "Mind blown!"
	para "APPRENTICE"
	line "is next."
	done

_EliteBao7BattleText::
	text "FILLER7:"
	line "Solid as rock!"
	cont "GROUND BAO!"
	done

_EliteBao7DefeatedText::
	text_start
	line "Eroded!"
	para "APPRENTICE"
	line "is next."
	done

_EliteBao8BattleText::
	text "FILLER8:"
	line "Whoosh!"
	cont "FLYING BAO!"
	done

_EliteBao8DefeatedText::
	text_start
	line "Grounded!"
	para "APPRENTICE"
	line "is next."
	done

_EliteBao9BattleText::
	text "FILLER9:"
	line "ROAR!"
	cont "DRAGON BAO!"
	done

_EliteBao9DefeatedText::
	text_start
	line "Defeated!"
	para "APPRENTICE"
	line "is next."
	done

_EliteBao10BattleText::
	text "FILLER10:"
	line "Legends await!"
	cont "Do your best!"
	done

_EliteBao10DefeatedText::
	text_start
	line "Legends fell!"
	para "ELITE BAOS"
	line "all beaten!"
	done

_EliteBaoWantsToFightText::
	text "ELITE BAO @"
	text_ram wTrainerName + 4 ; personal name after "BAO "
	text_start
	line "wants to fight!"
	prompt

_BattleHallTrainerWinText::
	text_ram wTrainerName
	text ": ..."
	prompt

_BattleHallExitPromptText::
	text "Leave now?"
	line "Your progress"
	cont "will reset."
	prompt

_ApprenticeBattleText::
	text "APPRENTICE:"
	line "Face me first!"
	done

_ApprenticeDefeatedText::
	text_start
	line "Not bad!"
	para "An ELITE BAO"
	line "awaits you!"
	done
