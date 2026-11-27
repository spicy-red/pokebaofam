_CeladonMartRoofLittleGirlImThirstyText::
	text "N'ai soif!"
	line "Ne veux boire!"
	prompt ; bfe - was 'done'

_CeladonMartRoofLittleGirlGiveHerADrinkText:: ; bfe - simplified
	text "Lui offrir"
	line "une boisson?" ; bfe - was "Quelle boisson lui offrir?"
	done

_CeladonMartRoofLittleGirlYayFreshWaterText::
	text "Ouais ouais!"

	para "De l'EAU FRAICHE!" ; bfe - was "DE L'EAU!"

	para "C'est cool!"

	para "Tiens...c'est"
	line "pour toi!@"
	text_end

_CeladonMartRoofLittleGirlTM13ExplanationText::
	text_start

	para "@"
	text_ram wStringBuffer
	text ":"
	line "LASER GLACE!"

	para "Cette attaque"
	line "pourra geler"
	cont "l'ennemi!@"
	text_end

_CeladonMartRoofLittleGirlYaySodaPopText::
	text "Ouaiiis!"

	para "Du SODA COOL!"

	para "Merciiii!"

	para "Tiens, prends ça!@"
	text_end

_CeladonMartRoofLittleGirlTM48ExplanationText::
	text_start

	para "@"
	text_ram wStringBuffer
	text ":"
	line "EBOULEMENT!"

	para "Cette attaque"
	line "peut faire peur"
	cont "à l'ennemi!@"
	text_end

_CeladonMartRoofLittleGirlYayLemonadeText::
	text "Ouaiiis!"

	para "D'la LIMONADE!"

	para "Top top top!"

	para "V'là pour toi!@"
	text_end

_CeladonMartRoofLittleGirlTM49ExplanationText::
	text_start

	para "CT49..." ; bfe - oubli de traduction "TM49"
	line "TRIPLATTAQUE!"

	para "Cette attaque" ; 
	text_end

_CeladonMartRoofLittleGirlReceivedTMText::
	text "<PLAYER> reçoit"
	line "@"
	text_ram wStringBuffer
	text "!@"
	text_end

_CeladonMartRoofLittleGirlNoRoomText::
	text "Plus de place!@"
	text_end

_CeladonMartRoofLittleGirlImNotThirstyText::
	text "Heu..."
	line "Non merci."
	cont "A pu soif!@"
	text_end

_CeladonMartRoofSuperNerdText::
	text "Ma soeur est"
	line "dresseur. Tu le"
	cont "crois, ça?"

	para "Mais c'est une"
	line "p'tite peste!"
	cont "Elle m'agace!"
	done

_CeladonMartRoofCurrentFloorSignText::
	text "DERNIER ETAGE:"
	line "DISTRIBUTEURS"
	done

_VendingMachineText1::
	text "Un distributeur!"
	line "Que choisir?"
	prompt

_VendingMachineText4::
	text "Oups! Pas assez"
	line "d'argent!"
	done

_VendingMachineText5::
	text "Et hop!"
	line "@"
	text_ram wStringBuffer
	text "!"
	done

_VendingMachineText6::
	text "L'inventaire est"
	line "plein!"
	done

_VendingMachineText7::
	text "Pas soif!"
	done

_VendingMachineWrongSideText:: ; bfe - new
	text "Mauvais côté!"
	done
