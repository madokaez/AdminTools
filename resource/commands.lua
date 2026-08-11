script_author('alfantasyz // modded: madoka')
local encoding = require 'encoding'
encoding.default = 'CP1251'
local u8 = encoding.UTF8

cmd_massive = {
	
	-- ## Команды для выдачи бана ## --	
	["oh"] = {
	cmd = "/iban",
	reason = "запрет.описание хелпера",
	time = 3,	
	},
	["ooh"] = {
	cmd = "/ioffban",
	reason = "запрет.описание хелпера",
	time = 3,
	},
	["nb"] = {
	cmd = "/iban",
	reason = "запрет.название бизнеса",
	time = 3,
	},
	["onb"] = {
	cmd = "/ioffban",
	reason = "запрет.название бизнеса",
	time = 3,
	},
	["ng"] = {
	cmd = "/iban",
	reason = "запрет.название банды",
	time = 7,
	},
	["ong"] = {
	cmd = "/ioffban",
	reason = "запрет.название банды",
	time = 7,
	},
	
	
	["bch"] = {
	cmd = "/iban",
	reason = "cheat",
	time = 7,
	},
	["obch"] = {
	cmd = "/ioffban",
	reason = "cheat",
	time = 7,
	},
	
	
	
	["otp"] = {
	cmd = "/iban",
	reason = "отказ от проверки",
	time = 7,
	},
	["ootp"] = {
	cmd = "/ioffban",
	reason = "отказ от проверки",
	time = 7,
	},
	
	
	
	["bsn"] = {
	cmd = "/ban",
	reason = "смените ник",
	time = 7,
	},	
	["osn"] = {
	cmd = "/iban",
	reason = "отказ смены ника",
	time = 7,
	},
	["oosn"] = {
	cmd = "/ioffban",
	reason = "отказ смены ника",
	time = 7,
	},	
	
	["bsnp"] = {
	cmd = "/ban",
	reason = "смените ник(плагиат)",
	time = 7,
	},	
	["osnp"] = {
	cmd = "/ban",
	reason = "отказ смены ника (плагиат)",
	time = 7,
	},
	["oosnp"] = {
	cmd = "/ioffban",
	reason = "отказ смены ника (плагиат)",
	time = 7,
	},
	
	
	
	["bsd"] = {
	cmd = "/iban",
	reason = "слив данных",
	time = 7,
	},
	["obsd"] = {
	cmd = "/ioffban",
	reason = "слив данных",
	time = 7,
	},
	
	
	
	["dvs"] = {
	cmd = "/iban",
	reason = "до выяснений",
	time = 7,
	},
	["odvs"] = {
	cmd = "/ioffban",
	reason = "до выяснений",
	time = 7,
	},	
	
	
	
	["obm"] = {
	cmd = "/siban",
	reason = "обман",
	time = 30,
	},
	["oobm"] = {
	cmd = "/ioffban",
	reason = "обман",
	time = 30,
	},
	
	
	
	["brk"] = {
	cmd = "/siban",
	reason = "реклама",
	time = 999,
	},
	["obrk"] = {
	cmd = "/ioffban",
	reason = "реклама",
	time = 999,
	},
	
	
	
	["op"] = {
	cmd = "/siban",
	reason = "оск.проекта",
	time = 30,
	},
	["oop"] = {
	cmd = "/ioffban",
	reason = "оск.проекта",
	time = 30,
	},
	
	
	
	["nst"] = {
	cmd = "/siban",
	reason = "накрутка статы",
	time = 999,
	},
	["onst"] = {
	cmd = "/ioffban",
	reason = "накрутка статы",
	time = 999,
	},
	
	
	
	["rb"] = {
	cmd = "/siban",
	reason = "ракбот",
	time = 999,
	},
	["orb"] = {
	cmd = "/ioffban",
	reason = "ракбот",
	time = 999,
	},
	
	
	
	["chsp"] = {
	cmd = "/siban",
	reason = "чсп",
	time = 999,
	},
	["ochsp"] = {
	cmd = "/ioffban",
	reason = "чсп",
	time = 999,
	},
	
	
	
	["rbv"] = {
	cmd = "/sban",
	reason = "раздача баганой валюты",
	time = 999,
	},
	["orbv"] = {
	cmd = "/offban",
	reason = "раздача баганой валюты",
	time = 999,
	},
	
	
	
	["psk"] = {
	cmd = "/siban",
	reason = "песок",
	time = 999,
	},
	["opsk"] = {
	cmd = "/ioffban",
	reason = "песок",
	time = 999,
	},
	
	
	
	-- ["sbg"] = {
	-- cmd = "/siban",
	-- reason = "багоюз",
	-- time = 999,
	-- },
	-- ["osbg"] = {
	-- cmd = "/offban",
	-- reason = "багоюз",
	-- time = 999,
	-- },
	-- ["sbgi"] = {
	-- cmd = "/ioffban",
	-- reason = "багоюз",
	-- time = 999,
	-- },
	
	
	
	["szr"] = {
	cmd = "/siban",
	reason = "сделка за реал руб",
	time = 999,
	},
	["oszr"] = {
	cmd = "/ioffban",
	reason = "сделка за реал руб",
	time = 999,
	},
	
	
	
	["ppv"] = {
	cmd = "/siban",
	reason = "ппв",
	time = 999,
	},
	["oppv"] = {
	cmd = "/ioffban",
	reason = "ппв",
	time = 999,
	},
	
	
	
	["sla"] = {
	cmd = "/siban",
	reason = "слив адм",
	time = 999,
	},
	["osla"] = {
	cmd = "/ioffban",
	reason = "слив адм",
	time = 999,
	},
	-- ## Команды для выдачи бана ## --
	
	
	-- ## Команды для выдачи мута ## --
	
	["fs"] = {
	cmd = "/mute",
	reason = "флуд/спам",
	time = 120,
	multi = true,
	},
	["ofs"] = {
	cmd = "/muteakk",
	reason = "флуд/спам",
	time = 120,
	},	
	
	["of"] = {
	cmd = "/rmute",
	reason = "оффтоп",
	time = 120,
	multi = true,
	},
	["oof"] = {
	cmd = "/rmuteakk",
	reason = "оффтоп",
	time = 120,
	}, 	
	
	
	
	["po"] = {
	cmd = "/mute",
	reason = "попрошайка",
	time = 120,
	multi = true,
	},
	["opo"] = {
	cmd = "/muteakk",
	reason = "попрошайка",
	time = 120,
	},
	
	["rpo"] = {
	cmd = "/rmute",
	reason = "попрошайка",
	time = 120,
	multi = true,
	},
	["orpo"] = {
	cmd = "/muteakk",
	reason = "попрошайка",
	time = 120,
	},	
	
	
	
	-- ["nd"] = {
	-- cmd = "/mute",
	-- reason = "неадекват",
	-- time = 600,
	-- },
	-- ["ond"] = {
	-- cmd = "/muteakk",
	-- reason = "неадекват",
	-- time = 600,
	-- },
	
	-- ["rnd"] = {
	-- cmd = "/rmute",
	-- reason = "неадекват",
	-- time = 600,
	-- },
	-- ["ornd"] = {
	-- cmd = "/rmuteakk",
	-- reason = "неадекват",
	-- time = 600,
	-- },	
	
	
	
	["m"] = {
	cmd = "/mute",
	reason = "мат",
	time = 300,
	},
	["om"] = {
	cmd = "/muteakk",
	reason = "мат",
	time = 300,
	},
	
	["rm"] = {
	cmd = "/rmute",
	reason = "мат",
	time = 300,
	},
	["orm"] = {
	cmd = "/rmuteakk",
	reason = "мат",
	time = 300,
	},	
	
	
	
	["ou"] = {
	cmd = "/mute",
	reason = "оск/униж",
	time = 400,
	},
	["oou"] = {
	cmd = "/muteakk",
	reason = "оск/униж",
	time = 400,
	},
	
	["rou"] = {
	cmd = "/rmute",
	reason = "оск/униж",
	time = 400,
	},
	["orou"] = {
	cmd = "/rmuteakk",
	reason = "оск/униж",
	time = 400,
	},	
	
	
	
	["zs"] = {
	cmd = "/mute",
	reason = "злоуп.симв",
	time = 600,
	},	
	["ozs"] = {
	cmd = "/muteakk",
	reason = "злоуп.симв",
	time = 600,
	},
	
	["rzs"] = {
	cmd = "/rmute",
	reason = "злоуп.симв",
	time = 600,
	},
	["orzs"] = {
	cmd = "/rmuteakk",
	reason = "злоуп.симв",
	time = 600,
	},
	
	
	
	["mrk"] = {
	cmd = "/mute",
	reason = "реклама",
	time = 600,
	},
	["omrk"] = {
	cmd = "/muteakk",
	reason = "реклама",
	time = 600,
	},
	
	["rrk"] = {
	cmd = "/rmute",
	reason = "реклама",
	time = 600,
	},
	["orrk"] = {
	cmd = "/rmuteakk",
	reason = "реклама",
	time = 600,
	},	
	
	
	
	["up"] = {
	cmd = "/mute",
	reason = "упом.стор.проектов",
	time = 600,
	},
	["oup"] = {
	cmd = "/muteakk",
	reason = "упом.стор.проектов",
	time = 600,
	},
	
	["rup"] = {
	cmd = "/rmute",
	reason = "упом.стор.проектов",
	time = 600,
	},
	["orup"] = {
	cmd = "/rmuteakk",
	reason = "упом.стор.проектов",
	time = 600,
	},	
	
	
	
	["ka"] = {
	cmd = "/mute",
	reason = "клевета на адм",
	time = 2000,
	},
	["oka"] = {
	cmd = "/muteakk",
	reason = "клевета на адм",
	time = 2000,
	},
	
	["rka"] = {
	cmd = "/rmute",
	reason = "клевета на адм",
	time = 2000,
	},
	["orka"] = {
	cmd = "/rmuteakk",
	reason = "клевета на адм",
	time = 2000,
	},	
	
	
	
	["oa"] = {
	cmd = "/mute",
	reason = "оск/униж адм",
	time = 2500,
	},
	["ooa"] = {
	cmd = "/muteakk",
	reason = "оск/униж адм",
	time = 2500,
	},
	
	["roa"] = {
	cmd = "/rmute",
	reason = "оск/униж адм",
	time = 2500,
	},
	["oroa"] = {
	cmd = "/rmuteakk",
	reason = "оск/униж адм",
	time = 2500,
	},	
	
	
	
	["vsa"] = {
	cmd = "/mute",
	reason = "выдача себя за адм",
	time = 2500,
	},
	["ovsa"] = {
	cmd = "/muteakk",
	reason = "выдача себя за адм",
	time = 2500,
	},
	
	["rvsa"] = {
	cmd = "/rmute",
	reason = "выдача себя за адм",
	time = 2500,
	},
	["orvsa"] = {
	cmd = "/rmuteakk",
	reason = "выдача себя за адм",
	time = 2500,
	},	
	
	
	
	["di"] = {
	cmd = "/mute",
	reason = "дезинфа",
	time = 3000,
	},
	["odi"] = {
	cmd = "/muteakk",
	reason = "дезинфа",
	time = 3000,
	},
	
	["rdi"] = {
	cmd = "/rmute",
	reason = "дезинфа",
	time = 3000,
	},
	["ordi"] = {
	cmd = "/rmuteakk",
	reason = "дезинфа",
	time = 3000,
	},
	
	
	
	["or"] = {
	cmd = "/mute",
	reason = "оск/упом род",
	time = 5000,
	},
	["oor"] = {
	cmd = "/muteakk",
	reason = "оск/упом род",
	time = 5000,
	},
	
	["ror"] = {
	cmd = "/rmute",
	reason = "оск/упом род",
	time = 5000,
	},
	["oror"] = {
	cmd = "/rmuteakk",
	reason = "оск/упом род",
	time = 5000,
	},	
	
	
	
	
	["rz"] = {
	cmd = "/mute",
	reason = "розжиг",
	time = 5000,
	},
	["orz"] = {
	cmd = "/muteakk",
	reason = "розжиг",
	time = 5000,
	},
	
	["rrz"] = {
	cmd = "/rmute",
	reason = "розжиг",
	time = 5000,
	},
	["orrz"] = {
	cmd = "/rmuteakk",
	reason = "розжиг",
	time = 5000,
	},

	
	
	
	["msd"] = {
	cmd = "/mute",
	reason = "слив данных",
	time = 5000,
	},
	["omsd"] = {
	cmd = "/muteakk",
	reason = "слив данных",
	time = 5000,
	},
	
	["rsd"] = {
	cmd = "/rmute",
	reason = "слив данных",
	time = 5000,
	},
	["orsd"] = {
	cmd = "/rmuteakk",
	reason = "слив данных",
	time = 5000,
	},	
	
	
	
	
	["prv"] = {
	cmd = "/mute",
	reason = "провокация",
	time = 3000,
	},
	["oprv"] = {
	cmd = "/muteakk",
	reason = "провокация",
	time = 3000,
	},
	
	["rprv"] = {
	cmd = "/rmute",
	reason = "провокация",
	time = 3000,
	},
	["orprv"] = {
	cmd = "/rmuteakk",
	reason = "провокация",
	time = 3000,
	},
	-- ## Команды для выдачи мута ## --
	
	
	-- ## Команды для выдачи джайла ## --
	
	["sk"] = {
	cmd = "/jail",
	reason = "спавнкилл",
	time = 300,
	multi = true,
	},
	["osk"] = {
	cmd = "/jailakk",
	reason = "спавнкилл",
	time = 300,
	},	
	
	
	
	["dz"] = {
	cmd = "/jail",
	reason = "дм/дб в зз",
	time = 300,
	multi = true,
	},
	["odz"] = {
	cmd = "/jailakk",
	reason = "дм/дб в зз",
	time = 300,
	},
	
	
	
	["ct"] = {
	cmd = "/jail",
	reason = "помеха /trade",
	time = 300,
	multi = true,
	},
	
	
	
	["npm"] = {
	cmd = "/jail",
	reason = "нарушение правил мп",
	time = 300,
	multi = true,
	},
	["onpm"] = {
	cmd = "/jailakk",
	reason = "нарушение правил мп",
	time = 300,
	},
	
	
	
	["jbg"] = {
	cmd = "/jail",
	reason = "багоюз",
	time = 300,
	},		
	["ojbg"] = {
	cmd = "/jailakk",
	reason = "багоюз",
	time = 300,
	},		
	
	
	
	["npgw"] = {
	cmd = "/jail",
	reason = "нарушение правил гв",
	time = 600,
	},
	["onpgw"] = {
	cmd = "/jailakk",
	reason = "нарушение правил гв",
	time = 600,
	},		
	
	
	
	["jch"] = {
	cmd = "/jail",
	reason = "cheat",
	time = 900,
	multi = true,
	},
	["ojch"] = {
	cmd = "/jailakk",
	reason = "cheat",
	time = 900,
	},	
	
	
	
	["dbk"] = {
	cmd = "/jail",
	reason = "дб зз ковш",
	time = 900,
	},
	["odbk"] = {
	cmd = "/jailakk",
	reason = "дб зз ковш",
	time = 900,
	},
	
	
	
	["sm"] = {
	cmd = "/jail",
	reason = "срыв мп",
	time = 3000,
	},
	["osm"] = {
	cmd = "/jailakk",
	reason = "срыв мп",
	time = 3000,
	},
	
	
	
	["jch3"] = {
	cmd = "/jail",
	reason = "CHEAT",
	time = 3000,
	},
	["ojch3"] = {
	cmd = "/jailakk",
	reason = "CHEAT",
	time = 3000,
	},
	
	
	
	["zv"] = {
	cmd = "/jail",
	reason = "злоуп.вип",
	time = 3000,
	},
	["ozv"] = {
	cmd = "/jailakk",
	reason = "злоуп.вип",
	time = 3000,
	},
	
	
	
	["sp"] = {
	cmd = "/jail",
	reason = "серьёзная помеха",
	time = 3000,
	},
	["osp"] = {
	cmd = "/jailakk",
	reason = "серьёзная помеха",
	time = 3000,
	},
	-- ## Команды для выдачи джайла ## --
	
	-- ## Команды для выдачи кика ## --
	
	["dj"] = {
	cmd = "/kick",
	reason = "дм джайл",
	},
	["sn"] = {
	cmd = "/kick",
	reason = "смените ник",
	},
	["snp"] = {
	cmd = "/kick",
	reason = "смените ник (плагиат)",
	},
	["aa"] = {
	cmd = "/kick",
	reason = "афк /арена",
	},
	["pb"] = {
	cmd = "/kick",
	reason = "помеха /barrage",
	},
	}
	-- ## Команды для выдачи бана ## --
	cmd_massive2 = {
	
	["bchr"] = {
	cmd = "/iban",
	reason = "cheat ранее",
	time = 7,
	},
	
	
	
	["bsdr"] = {
	cmd = "/iban",
	reason = "слив данных ранее",
	time = 7,
	},
	
	
	
	["obmr"] = {
	cmd = "/siban",
	reason = "обман ранее",
	time = 30,
	},
	
	
	
	["brkr"] = {
	cmd = "/siban",
	reason = "реклама ранее",
	time = 999,
	},
	
	
	
	["opr"] = {
	cmd = "/siban",
	reason = "оск.проекта ранее",
	time = 30,
	},
	
	
	
	["rbvr"] = {
	cmd = "/sban",
	reason = "раздача баганой валюты ранее",
	time = 999,
	},
	
	
	
	["szrr"] = {
	cmd = "/siban",
	reason = "сделка за реал руб ранее",
	time = 999,
	},
	
	
	
	-- ## Команды для выдачи мута ## --
	["fsr"] = {
	cmd = "/mute",
	reason = "флуд/спам ранее",
	time = 120,
	},	
	-- ["ofr"] = {
	-- cmd = "/rmute",
	-- reason = "оффтоп ранее",
	-- time = 120,
	-- },
	
	
	
	["por"] = {
	cmd = "/mute",
	reason = "попрошайка ранее",
	time = 120,
	},
	-- ["rpor"] = {
	-- cmd = "/rmute",
	-- reason = "попрошайка ранее",
	-- time = 120,
	-- },
	
	
	
	["mr"] = {
	cmd = "/mute",
	reason = "мат ранее",
	time = 300,
	},
	-- ["rmr"] = {
	-- cmd = "/rmute",
	-- reason = "мат ранее",
	-- time = 300,
	-- },
	
	
	
	["our"] = {
	cmd = "/mute",
	reason = "оск/униж ранее",
	time = 400,
	},
	-- ["rour"] = {
	-- cmd = "/rmute",
	-- reason = "оск/униж ранее",
	-- time = 400,
	-- },
	
	
	
	["ndr"] = {
	cmd = "/mute",
	reason = "неадекват ранее",
	time = 600,
	},
	-- ["rndr"] = {
	-- cmd = "/rmute",
	-- reason = "неадекват ранее",
	-- time = 600,
	-- },
	
	
	["zsr"] = {
	cmd = "/mute",
	reason = "злоуп.симв ранее",
	time = 600,
	},
	-- ["rzsr"] = {
	-- cmd = "/rmute",
	-- reason = "злоуп.симв ранее",
	-- time = 600,
	-- },  	
	
	
	
	["upr"] = {
	cmd = "/mute",
	reason = "упом.стор.проектов ранее",
	time = 600,
	},
	-- ["rupr"] = {
	-- cmd = "/rmute",
	-- reason = "упом.стор.проектов ранее",
	-- time = 600,
	-- },
	
	
	
	
	["mrkr"] = {
	cmd = "/mute",
	reason = "реклама ранее",
	time = 600,
	},
	-- ["rrkr"] = {
	-- cmd = "/rmute",
	-- reason = "реклама ранее",
	-- time = 600,
	-- },	
	
	
	
	["kar"] = {
	cmd = "/mute",
	reason = "клевета на адм ранее",
	time = 2000,
	},
	-- ["rkar"] = {
	-- cmd = "/rmute",
	-- reason = "клевета на адм ранее",
	-- time = 2000,
	-- },
	
	
	
	["oar"] = {
	cmd = "/mute",
	reason = "оск/униж адм ранее",
	time = 2500,
	},
	-- ["roar"] = {
	-- cmd = "/rmute",
	-- reason = "оск/униж адм ранее",
	-- time = 2500,
	-- },	
	
	
	
	["vsar"] = {
	cmd = "/mute",
	reason = "выдача себя за адм ранее",
	time = 2500,
	},
	-- ["rvsar"] = {
	-- cmd = "/rmute",
	-- reason = "выдача себя за адм ранее",
	-- time = 2500,
	-- },
	
	
	
	["dir"] = {
	cmd = "/mute",
	reason = "дезинфа ранее",
	time = 3000,
	},
	-- ["dir"] = {
	-- cmd = "/rmute",
	-- reason = "дезинфа ранее",
	-- time = 3000,
	-- },
	
	
	
	["orr"] = {
	cmd = "/mute",
	reason = "оск/упом род ранее",
	time = 5000,
	},
	-- ["rorr"] = {
	-- cmd = "/rmute",
	-- reason = "оск/упом род ранее",
	-- time = 5000,
	-- },
	
	
	
	["rzr"] = {
	cmd = "/mute",
	reason = "розжиг ранее",
	time = 5000,
	},
	-- ["rrzr"] = {
	-- cmd = "/rmute",
	-- reason = "розжиг ранее",
	-- time = 5000,
	-- },
	
	
	
	["msdr"] = {
	cmd = "/mute",
	reason = "слив данных ранее",
	time = 5000,
	},
	
	
	
	["prvr"] = {
	cmd = "/mute",
	reason = "провокация ранее",
	time = 3000,
	},
	-- ["rprvr"] = {
	-- cmd = "/rmute",
	-- reason = "провокация ранее",
	-- time = 5000,
	-- },
	
	
	
	
	-- ## Команды для выдачи джайла ## --
	["skr"] = {
	cmd = "/jail",
	reason = "спавнкилл ранее",
	time = 300,
	},
	
	
	
	["jbgr"] = {
	cmd = "/jail",
	reason = "багоюз ранее",
	time = 300,
	},
	
	
	
	["dzr"] = {
	cmd = "/jail",
	reason = "дм/дб в зз ранее",
	time = 300,
	},
	
	
	
	["npgwr"] = {
	cmd = "/jail",
	reason = "нарушение правил гв ранее",
	time = 600,
	},
	
	
	
	["dbkr"] = {
	cmd = "/jail",
	reason = "дб зз ковш ранее",
	time = 900,
	},
	
	
	
	["jchr"] = {
	cmd = "/jail",
	reason = "cheat ранее",
	time = 900,
	},
	
	
	
	["jchr3"] = {
	cmd = "/jail",
	reason = "CHEAT ранее",
	time = 3000,
	},	
	
	
	
	["zvr"] = {
	cmd = "/jail",
	reason = "злоуп.вип ранее",
	time = 3000,
	},
	
	
	
	["jbg3r"] = {
	cmd = "/jail",
	reason = "багоюз ранее",
	time = 3000,
	},
	
	
	
	["spr"] = {
	cmd = "/jail",
	reason = "серьёзная помеха ранее",
	time = 3000,
	},
	
	-- ## Команды для выдачи бана ## --
	
	
	["ohf"] = {
	cmd = "/iban",
	reason = "запрет.описание хелпера(forum)",
	time = 3,	
	},
	["oohf"] = {
	cmd = "/ioffban",
	reason = "запрет.описание хелпера(forum)",
	time = 3,
	},
	["nbf"] = {
	cmd = "/iban",
	reason = "запрет.название бизнеса(forum)",
	time = 3,
	},
	["onbf"] = {
	cmd = "/ioffban",
	reason = "запрет.название бизнеса(forum)",
	time = 3,
	},
	["ngf"] = {
	cmd = "/iban",
	reason = "запрет.название банды(forum)",
	time = 7,
	},
	["ongf"] = {
	cmd = "/ioffban",
	reason = "запрет.название банды(forum)",
	time = 7,
	},
	
	
	
	["bchf"] = {
	cmd = "/iban",
	reason = "cheat(forum)",
	time = 7,
	},
	["obchf"] = {
	cmd = "/ioffban",
	reason = "cheat(forum)",
	time = 7,
	},
	
	
	
	["bsdf"] = {
	cmd = "/iban",
	reason = "слив данных(forum)",
	time = 7,
	},
	["obsdf"] = {
	cmd = "/ioffban",
	reason = "слив данных(forum)",
	time = 7,
	},	
	
	
	
	["otpf"] = {
	cmd = "/iban",
	reason = "отказ от проверки(forum)",
	time = 30,
	},
	["ootpf"] = {
	cmd = "/ioffban",
	reason = "отказ от проверки(forum)",
	time = 30,
	},
	
	
	
	["obmf"] = {
	cmd = "/siban",
	reason = "обман(forum)",
	time = 30,
	},
	["oobmf"] = {
	cmd = "/ioffban",
	reason = "обман(forum)",
	time = 30,
	},		
	
	
	
	["brkf"] = {
	cmd = "/siban",
	reason = "реклама(forum)",
	time = 999,
	},
	["obrkf"] = {
	cmd = "/ioffban",
	reason = "реклама(forum)",
	time = 999,
	},
	
	
	
	["opf"] = {
	cmd = "/siban",
	reason = "оск.проекта(forum)",
	time = 30,
	},
	["oopf"] = {
	cmd = "/ioffban",
	reason = "оск.проекта(forum)",
	time = 30,
	},
	
	
	
	["rbvf"] = {
	cmd = "/sban",
	reason = "раздача баганой валюты(forum)",
	time = 999,
	},
	["orbvf"] = {
	cmd = "/offban",
	reason = "раздача баганой валюты(forum)",
	time = 999,
	},
	
	
	-- ["sbgf"] = {
	-- cmd = "/siban",
	-- reason = "багоюз(forum)",
	-- time = 999,
	-- },
	-- ["osbgf"] = {
	-- cmd = "/offban",
	-- reason = "багоюз(forum)",
	-- time = 999,
	-- },
	-- ["sbgif"] = {
	-- cmd = "/ioffban",
	-- reason = "багоюз(forum)",
	-- time = 999,
	-- },
	
	
	["szrf"] = {
	cmd = "/siban",
	reason = "сделка за реал руб(forum)",
	time = 999,
	},
	["oszrf"] = {
	cmd = "/ioffban",
	reason = "сделка за реал руб(forum)",
	time = 999,
	},	
	
	-- ## Команды для выдачи мута ## --
	
	["fsf"] = {
	cmd = "/mute",
	reason = "флуд/спам(forum)",
	time = 120,
	},
	["ofsf"] = {
	cmd = "/muteakk",
	reason = "флуд/спам(forum)",
	time = 120,
	},
	["pof"] = {
	cmd = "/mute",
	reason = "попрошайка(forum)",
	time = 120,
	},
	["opof"] = {
	cmd = "/muteakk",
	reason = "попрошайка(forum)",
	time = 120,
	},
	["mf"] = {
	cmd = "/mute",
	reason = "мат(forum)",
	time = 300,
	},
	["omf"] = {
	cmd = "/muteakk",
	reason = "мат(forum)",
	time = 300,
	},
	["ouf"] = {
	cmd = "/mute",
	reason = "оск/униж(forum)",
	time = 400,
	},
	["oouf"] = {
	cmd = "/muteakk",
	reason = "оск/униж(forum)",
	time = 400,
	},
	["ndf"] = {
	cmd = "/mute",
	reason = "неадекват(forum)",
	time = 600,
	},
	["ondf"] = {
	cmd = "/muteakk",
	reason = "неадекват(forum)",
	time = 600,
	},
	["zsf"] = {
	cmd = "/mute",
	reason = "злоуп.симв(forum)",
	time = 600,
	},	
	["ozsf"] = {
	cmd = "/muteakk",
	reason = "злоуп.симв(forum)",
	time = 600,
	},	
	["mrkf"] = {
	cmd = "/mute",
	reason = "реклама(forum)",
	time = 600,
	},
	["omrkf"] = {
	cmd = "/muteakk",
	reason = "реклама(forum)",
	time = 600,
	},
	["upf"] = {
	cmd = "/mute",
	reason = "упом.стор.проектов(forum)",
	time = 600,
	},
	["oupf"] = {
	cmd = "/muteakk",
	reason = "упом.стор.проектов(forum)",
	time = 600,
	},
	["kaf"] = {
	cmd = "/mute",
	reason = "клевета на адм(forum)",
	time = 2000,
	},
	["okaf"] = {
	cmd = "/muteakk",
	reason = "клевета на адм(forum)",
	time = 2000,
	},
	["vsaf"] = {
	cmd = "/mute",
	reason = "выдача себя за адм(forum)",
	time = 2500,
	},
	["ovsaf"] = {
	cmd = "/muteakk",
	reason = "выдача себя за адм(forum)",
	time = 2500,
	},
	["oaf"] = {
	cmd = "/mute",
	reason = "оск/униж адм(forum)",
	time = 2500,
	},
	["ooaf"] = {
	cmd = "/muteakk",
	reason = "оск/униж адм(forum)",
	time = 2500,
	},
	["orf"] = {
	cmd = "/mute",
	reason = "оск/упом род(forum)",
	time = 5000,
	},
	["oorf"] = {
	cmd = "/muteakk",
	reason = "оск/упом род(forum)",
	time = 5000,
	},
	["rzf"] = {
	cmd = "/mute",
	reason = "розжиг(forum)",
	time = 5000,
	},
	["orzf"] = {
	cmd = "/muteakk",
	reason = "розжиг(forum)",
	time = 5000,
	},
	["msdf"] = {
	cmd = "/mute",
	reason = "слив данных(forum)",
	time = 5000,
	},
	["omsdf"] = {
	cmd = "/muteakk",
	reason = "слив данных(forum)",
	time = 5000,
	},
	["prvf"] = {
	cmd = "/mute",
	reason = "провокация(forum)",
	time = 3000,
	},
	["oprvf"] = {
	cmd = "/muteakk",
	reason = "провокация(forum)",
	time = 3000,
	},
	
	-- ## Команды для выдачи джайла ## --
	
	["skf"] = {
	cmd = "/jail",
	reason = "спавнкилл(forum)",
	time = 300,
	},
	["oskf"] = {
	cmd = "/jailakk",
	reason = "спавнкилл(forum)",
	time = 300,
	},
	["dzf"] = {
	cmd = "/jail",
	reason = "дм/дб в зз(forum)",
	time = 300,
	},
	["odzf"] = {
	cmd = "/jailakk",
	reason = "дм/дб в зз(forum)",
	time = 300,
	},
	["jbgf"] = {
	cmd = "/jail",
	reason = "багоюз(forum)",
	time = 300,
	},
	["ojbgf"] = {
	cmd = "/jailakk",
	reason = "багоюз(forum)",
	time = 300,
	},
	["npgwf"] = {
	cmd = "/jail",
	reason = "нарушение правил гв(forum)",
	time = 600,
	},
	["onpgwf"] = {
	cmd = "/jailakk",
	reason = "нарушение правил гв(forum)",
	time = 600,
	},
	["jchf"] = {
	cmd = "/jail",
	reason = "cheat(forum)",
	time = 900,
	},
	["ojchf"] = {
	cmd = "/jailakk",
	reason = "cheat(forum)",
	time = 900,
	},
	["dbkf"] = {
	cmd = "/jail",
	reason = "дб зз ковш(forum)",
	time = 900,
	},
	["odbkf"] = {
	cmd = "/jailakk",
	reason = "дб зз ковш(forum)",
	time = 900,
	},
	["zvf"] = {
	cmd = "/jail",
	reason = "злоуп.вип(forum)",
	time = 3000,
	},
	["ozvf"] = {
	cmd = "/jailakk",
	reason = "злоуп.вип(forum)",
	time = 3000,
	},
	["spf"] = {
	cmd = "/jail",
	reason = "серьёзная помеха(forum)",
	time = 3000,
	},
	["ospf"] = {
	cmd = "/jailakk",
	reason = "серьёзная помеха(forum)",
	time = 3000,
	},
}

cmd_helper_others = {
	["amp"] = {
		reason = " - Запуск системы мероприятий",
	},
	["co"] = {
		reason = " [NICK] - Записать игрока в список проверки на вход",
	},
	["uj"] = {
	    reason = " [ID] - Разджайлить игрока",
	},
	["ouj"] = {
	    reason = " [NICK] - Разджайлить игрока в оффлайне",
	},
	["um"] = {
	    reason = " [ID] - Размутить игрока",
	},
	["oum"] = {
	    reason = " [NICK] - Размутить игрока в оффлайне",
	},
	["urm"] = {
	    reason = " [ID] - Размутить репорт игроку",
	},
	["ourm"] = {
	    reason = " [NICK] - Размутить репорт игроку в оффлайне",
	},
	["ub"] = {
	    reason = " [NICK] - Разбанить аккаунт и IP игроку",
	},	
	["ubi"] = {
	    reason = " [IP] - Разбанить IP игроку",
	},
	["akill"] = {
	    reason = " [ID] - Убить игрока",
	},
	["as"] = {
	    reason = " [ID] - Заспавнить игрока",
	},
	["asall"] = {
	    reason = " - Заспавнить всех в зоне стрима",
	},
	["akill"] = {
	    reason = " [ID] - Убить игрока",
	},
	["stw"] = {
		reason = " [ID] - Выдача минигана",
	},
	["gh"] = { 
		reason = " [ID] - Телепортация игрока к себе",
	},
	["sl"] = {
		reason = " [ID] - Слапнуть игрока",
	},
	["bob"] = {
		reason = " [ID] [Дни] - Забанить за обход",
	},
	["obob"] = {
		reason = " [NICK] [Дни] - Забанить за обход(оффлайне)",
	},
	["rob"] = {
		reason = " [ID] [Секунды] - Мут репорт за обход",
	},
	["mob"] = {
		reason = " [ID] [Секунды] - Мут за обход ",
	},
	["job"] = {
		reason = " [ID] [Секунды] - Джайл за обход ",
	},
	["sv"] = {
		reason = " [Радиус] - Заспавнить машины в определеном радиусе",
	},
	["chgn /chgn2"] = {
		reason = " [ID] - Изменить название банды 1/2 // 2/2",
	},
	["chgnp /chgnp2"] = {
		reason = " [ID] - Изменить название плагиат банды 1/2 // 2/2",
	},
	["chvn"] = {
		reason = " [ID] - Изменить название VIP",
	},
	["vnp"] = {
		reason = " [ID] - Вызвать игрока на проверку",
	},
	["fz"] = {
		reason = " [ID] - Заморозить игрока",
	},
	["v"] = {
		reason = " [ID] [КОЛ-ВО] - Выдать VIP выговор игроку",
	},
	["ov"] = {
		reason = " [NICK] [КОЛ-ВО] - Выдать VIP выговор игроку в оффлайне",
	},
	["iwepall"] = {
		reason = " Проверка всех на WeaponHack",
	},
}

cmd_helper_answers = {
	["frmj"] = {
		reason = " Подайте жалобу на форуме - [forumrds.ru]",
	},
	["nr"] = {
	    reason = " Начал(а) работу по вашей жалобе",
	},
	["nn"] = {
	    reason = " Не вижу нарушений от игрока",
	},
	["al"] = {
	    reason = " /alogin",
	},
}


cmdLabels = {
	['/mute'] = {'Mute', u8' [ID игрока] - '},
	['/rmute'] = {'Report Mute', u8' [ID игрока] - '},
	['/ban'] = {'Ban', u8' [ID игрока] - '},
	['/iban'] = {'Ban+IP', u8' [ID игрока] - '},
	['/sban'] = {'Ban', u8' [ID игрока] - '},
	['/siban'] = {'Ban+IP', u8' [ID игрока] - '},
	['/jail'] = {'Jail', u8' [ID игрока] - '},
	['/kick'] = {'Kick', u8' [ID игрока] - '},
	['/muteakk'] = {'Mute OffLine', u8' [NICK игрока] - '},
	['/rmuteakk']= {'Report Mute OffLine',u8' [NICK игрока] - '},
	['/jailakk'] = {'Jail OffLine', u8' [NICK игрока] - '},
	['/offban']  = {'Ban OffLine', u8' [NICK игрока] - '},
	['/ioffban'] = {'Ban+IP OffLine', u8' [NICK игрока] - '},
}

CMDBAN = 
"/oh [ID] - запрет.описание хелпера \n/ooh [NICK] - запрет.описание хелпера (оффлайн) \n/ohf [ID] - запрет.описание хелпера (forum) \n/oohf [NICK] - запрет.описание хелпера (forum) (оффлайн) \n \n" ..
"/nb [ID] - запрет.название бизнеса \n/onb [NICK] - запрет.название бизнеса (оффлайн) \n/nbf [ID] - запрет.название бизнеса (forum) \n/onbf [NICK] - запрет.название бизнеса (forum) (оффлайн) \n \n" ..
"/ng [ID] - запрет.название банды \n/ong [NICK] - запрет.название банды (оффлайн) \n/ngf [ID] - запрет.название банды (forum) \n/ongf [NICK] - запрет.название банды (forum) (оффлайн) \n \n" ..
"/bch [ID] - читы \n/obch [NICK] - читы (оффлайн) \n/bchf [ID] - читы (forum) \n/obchf [NICK] - читы (forum) (оффлайн) \n/bchr [ID] - читы ранее \n \n" ..
"/otp [ID] - отказ от проверки \n/ootp [NICK] - отказ от проверки (оффлайн) \n/otpf [ID] - отказ от проверки (forum) \n/ootpf [NICK] - отказ от проверки (forum) (оффлайн) \n \n" ..
"/bsn - смените ник \n/osn [ID] - отказ смены ника \n/oosn [NICK] - отказ смены ника (оффлайн) \n \n" ..
"/bsnp - смените ник (плагиат) \n/osnp [ID] - отказ смены ника (плагиат) \n/oosnp [NICK] - отказ смены ника (плагиат) (оффлайн) \n \n" ..
"/bsd [ID] - слив данных \n/obsd [NICK] - слив данных (оффлайн) \n/bsdf [ID] - слив данных (forum) \n/obsdf [NICK] - слив данных (forum) (оффлайн) \n/bsdr [ID] - слив данных ранее \n \n" ..
"/dvs [ID] - до выяснений \n/odvs [NICK] - до выяснений (оффлайн) \n \n" ..
"/obm [ID] - обман \n/oobm [NICK] - обман (оффлайн) \n/obmf [ID] - обман (forum) \n/oobmf [NICK] - обман (forum) (оффлайн) \n/obmr [ID] - обман ранее \n \n" ..
"/brk [ID] - реклама \n/obrk [NICK] - реклама (оффлайн) \n/brkf [ID] - реклама (forum) \n/obrkf [NICK] - реклама (forum) (оффлайн) \n/brkr [ID] - реклама ранее \n \n" ..
"/op [ID] - оск.проекта \n/oop [NICK] - оск.проекта (оффлайн) \n/opf [ID] - оск.проекта (forum) \n/oopf [NICK] - оск.проекта (forum) (оффлайн) \n/opr [ID] - оск.проекта ранее \n \n" ..
"/nst [ID] - накрутка статы \n/onst [NICK] - накрутка статы (оффлайн) \n \n" ..
"/rb [ID] - ракбот \n/orb [NICK] - ракбот (оффлайн) \n \n" ..
"/chsp [ID] - чсп \n/ochsp [NICK] - чсп (оффлайн) \n \n" ..
"/rbv [ID] - раздача баганой валюты \n/orbv [NICK] - раздача баганой валюты (оффлайн) \n/rbvf [ID] - раздача баганой валюты (forum) \n/orbvf [NICK] - раздача баганой валюты (forum) (оффлайн) \n/rbvr [ID] - раздача баганой валюты ранее \n \n" ..
"/psk [ID] - песок \n/opsk [NICK] - песок (оффлайн) \n \n" ..
"/szr [ID] - сделка за реал руб \n/oszr [NICK] - сделка за реал руб (оффлайн) \n/szrf [ID] - сделка за реал руб (forum) \n/oszrf [NICK] - сделка за реал руб (forum) (оффлайн) \n/szrr [ID] - сделка за реал руб ранее \n \n" ..
"/ppv [ID] - ппв \n/oppv [NICK] - ппв (оффлайн) \n \n" ..
"/sla [ID] - слив адм \n/osla [NICK] - слив адм (оффлайн)"
CMDJAIL = 
"/sk [ID] - спавнкилл \n/osk [NICK] - спавнкилл (оффлайн) \n/skf [ID] - спавнкилл (forum) \n/oskf [NICK] - спавнкилл (forum) (оффлайн) \n/skr [ID] - спавнкилл ранее \n \n" ..
"/dz [ID] - дм/дб в зз \n/odz [NICK] - дм/дб в зз (оффлайн) \n/dzf [ID] - дм/дб в зз (forum) \n/odzf [NICK] - дм/дб в зз (forum) (оффлайн) \n/dzr [ID] - дм/дб в зз ранее \n \n" ..
"/ct [NICK] - кар/трейд \n \n" ..
"/npm [ID] - нарушение правил мп \n/onpm [NICK] - нарушение правил мп (оффлайн) \n \n" ..
"/jbg [ID] - багоюз \n/ojbg [NICK] - багоюз (оффлайн) \n/jbgf [ID] - багоюз (forum) \n/ojbgf [NICK] - багоюз (forum) (оффлайн) \n/jbgr [ID] - багоюз ранее \n \n" ..
"/npgw [ID] - нарушение правил гв \n/onpgw [NICK] - нарушение правил гв (оффлайн) \n/npgwf [ID] - нарушение правил гв (forum) \n/onpgwf [NICK] - нарушение правил гв (forum) (оффлайн) \n/npgwr [ID] - нарушение правил гв ранее \n \n" ..
"/jch [ID] - чит 900 \n/ojch [NICK] - чит 900 (оффлайн) \n/jchf [ID] - чит 900 (forum) \n/ojchf [NICK] - чит 900 (forum) (оффлайн) \n/jchr [ID] - чит 900 ранее \n \n" ..
"/dbk [ID] - дб зз ковш \n/odbk [NICK] - дб зз ковш (оффлайн) \n/dbkf [ID] - дб зз ковш (forum) \n/odbkf [NICK] - дб зз ковш (forum) (оффлайн) \n/dbkr [ID] - дб зз ковш ранее \n \n" ..
"/js [ID] - сбив \n/ojs [NICK] - сбив (оффлайн) \n/jsf [ID] - сбив (forum) \n/ojsf [NICK] - сбив (forum) (оффлайн) \n/jsr [ID] - сбив ранее \n \n" ..
"/sm [ID] - срыв мп \n/osm [NICK] - срыв мп (оффлайн) \n \n" ..
"/jch3 [ID] - чит 3000 \n/ojch3 [NICK] - чит 3000 (оффлайн) \n/jchr3 [ID] - чит 3000 ранее \n \n" ..
"/zv [ID] - злоуп.вип \n/ozv [NICK] - злоуп.вип (оффлайн) \n/zvf [ID] - злоуп.вип (forum) \n/ozvf [NICK] - злоуп.вип (forum) (оффлайн) \n/zvr [ID] - злоуп.вип ранее \n \n" ..
"/sp [ID] - серьёзная помеха \n/osp [NICK] - серьёзная помеха (оффлайн) \n/spf [ID] - серьёзная помеха (forum) \n/ospf [NICK] - серьёзная помеха (forum) (оффлайн) \n/spr [ID] - серьёзная помеха ранее \n \n" ..
"/jbg3r [NICK] - багоюз ранее"
CMDMUTE = 
"/fs [ID] - флуд/спам \n/ofs [NICK] - флуд/спам (оффлайн) \n/fsf [ID] - флуд/спам (forum) \n/ofsf [NICK] - флуд/спам (forum) (оффлайн) \n/fsr [ID] - флуд/спам ранее \n \n" ..
"/of [ID] - оффтоп (репорт) \n/oof [NICK] - оффтоп (оффлайн) (репорт) \n \n" ..
"/po [ID] - попрошайка \n/opo [NICK] - попрошайка (оффлайн) \n/rpo [ID] - попрошайка (репорт) \n/orpo [NICK] - попрошайка (оффлайн) (репорт) \n/pof [ID] - попрошайка (forum) \n/opof [NICK] - попрошайка (forum) (оффлайн) \n/por [ID] - попрошайка ранее \n \n" ..
"/m [ID] - мат \n/om [NICK] - мат (оффлайн) \n/rm [ID] - мат (репорт) \n/orm [NICK] - мат (оффлайн) (репорт) \n/mf [ID] - мат (forum) \n/omf [NICK] - мат (forum) (оффлайн) \n/mr [ID] - мат ранее \n \n" ..
"/ou [ID] - оск/униж \n/oou [NICK] - оск/униж (оффлайн) \n/rou [ID] - оск/униж (репорт) \n/orou [NICK] - оск/униж (оффлайн) (репорт) \n/ouf [ID] - оск/униж (forum) \n/oouf [NICK] - оск/униж (forum) (оффлайн) \n/our [ID] - оск/униж ранее \n \n" ..
"/zs [ID] - злоуп.симв \n/ozs [NICK] - злоуп.симв (оффлайн) \n/rzs [ID] - злоуп.симв (репорт) \n/orzs [NICK] - злоуп.симв (оффлайн) (репорт) \n/zsf [ID] - злоуп.симв (forum) \n/ozsf [NICK] - злоуп.симв (forum) (оффлайн) \n/zsr [ID] - злоуп.симв ранее \n \n" ..
"/mrk [ID] - реклама \n/omrk [NICK] - реклама (оффлайн) \n/rrk [ID] - реклама (репорт) \n/orrk [NICK] - реклама (оффлайн) (репорт) \n/mrkf [ID] - реклама (forum) \n/omrkf [NICK] - реклама (forum) (оффлайн) \n/mrkr [ID] - реклама ранее \n \n" ..
"/up [ID] - упом.стор.проектов \n/oup [NICK] - упом.стор.проектов (оффлайн) \n/rup [ID] - упом.стор.проектов (репорт) \n/orup [NICK] - упом.стор.проектов (оффлайн) (репорт) \n/upf [ID] - упом.стор.проектов (forum) \n/oupf [NICK] - упом.стор.проектов (forum) (оффлайн) \n/upr [ID] - упом.стор.проектов ранее \n \n" ..
"/ka [ID] - клевета на адм \n/oka [NICK] - клевета на адм (оффлайн) \n/rka [ID] - клевета на адм (репорт) \n/orka [NICK] - клевета на адм (оффлайн) (репорт) \n/kaf [ID] - клевета на адм (forum) \n/okaf [NICK] - клевета на адм (forum) (оффлайн) \n/kar [ID] - клевета на адм ранее \n \n" ..
"/oa [ID] - оск/униж адм \n/ooa [NICK] - оск/униж адм (оффлайн) \n/roa [ID] - оск/униж адм (репорт) \n/oroa [NICK] - оск/униж адм (оффлайн) (репорт) \n/oaf [ID] - оск/униж адм (forum) \n/ooaf [NICK] - оск/униж адм (forum) (оффлайн) \n/oar [ID] - оск/униж адм ранее \n \n" ..
"/vsa [ID] - выдача себя за адм \n/ovsa [NICK] - выдача себя за адм (оффлайн) \n/rvsa [ID] - выдача себя за адм (репорт) \n/orvsa [NICK] - выдача себя за адм (оффлайн) (репорт) \n/vsaf [ID] - выдача себя за адм (forum) \n/ovsaf [NICK] - выдача себя за адм (forum) (оффлайн) \n/vsar [ID] - выдача себя за адм ранее \n \n" ..
"/di [ID] - дезинфа \n/odi [NICK] - дезинфа (оффлайн) \n/rdi [ID] - дезинфа (репорт) \n/ordi [NICK] - дезинфа (оффлайн) (репорт) \n/dir [ID] - дезинфа ранее \n \n" ..
"/or [ID] - оск/упом род \n/oor [NICK] - оск/упом род (оффлайн) \n/ror [ID] - оск/упом род (репорт) \n/oror [NICK] - оск/упом род (оффлайн) (репорт) \n/orf [ID] - оск/упом род (forum) \n/oorf [NICK] - оск/упом род (forum) (оффлайн) \n/orr [ID] - оск/упом род ранее \n \n" ..
"/rz [ID] - розжиг \n/orz [NICK] - розжиг (оффлайн) \n/rrz [ID] - розжиг (репорт) \n/orrz [NICK] - розжиг (оффлайн) (репорт) \n/rzf [ID] - розжиг (forum) \n/orzf [NICK] - розжиг (forum) (оффлайн) \n/rzr [ID] - розжиг ранее \n \n" ..
"/msd [ID] - слив данных \n/omsd [NICK] - слив данных (оффлайн) \n/rsd [ID] - слив данных (репорт) \n/orsd [NICK] - слив данных (оффлайн) (репорт) \n/msdf [ID] - слив данных (forum) \n/omsdf [NICK] - слив данных (forum) (оффлайн) \n/msdr [ID] - слив данных ранее \n \n" ..
"/prv [ID] - провокация \n/oprv [NICK] - провокация (оффлайн) \n/rprv [ID] - провокация (репорт) \n/orprv [NICK] - провокация (оффлайн) (репорт) \n/prvf [ID] - провокация (forum) \n/oprvf [NICK] - провокация (forum) (оффлайн) \n/prvr [ID] - провокация ранее \n \n"
CMDKICK = 
"/dj [ID] - дм джайл \n/sn [ID] - смените ник \n/snp [ID] - смените ник(плагиат) \n/aa [ID] - АФК арена \n/pb [ID] - помеха /barrage"
CMDAT = 
"/amp - запуск системы мероприятий \n/co [NICK] - запись игрока в список проверки на вход \n" ..
"/uj [ID] - разджайлить игрока \n/ouj [NICK] - разджайлить игрока (оффлайн) \n" ..
"/um [ID] - размутить игрока \n/oum [NICK] - размутить игрока (оффлайн) \n" ..
"/urm [ID] - размутить репорт игроку \n/ourm [NICK] - размутить репорт игроку (оффлайн) \n" ..
"/ub [NICK] - разбанить аккаунт и IP игроку \n/ubi [IP] - разбанить IP игроку \n" ..
"/as [ID] - заспавнить игрока \n/asall - заспавнить всех в зоне стрима \n/akill [ID] - убить игрока \n" ..
"/stw [ID] - выдача минигана \n/gh [ID] - телепортация игрока к себе \n/sl [ID] - слапнуть игрока \n" ..
"/bob [ID] [Дни] - забанить за обход \n" ..
"/rob [ID] [Секунды] - мут репорт за обход \n/mob [ID] [Секунды] - мут за обход \n/job [ID] [Секунды] - джайл за обход \n" ..
"/sv [Радиус] - заспавнить машины в определенном радиусе \n" ..
"/chgn || /chgn2 [ID GANG] - изменить название банды 1/2 2/2 \n" ..
"/chgnp || /chgnp2 [ID GANG] - изменить название плагиат банды 1/2 2/2 \n" ..
"/chvn [ID] - изменить название VIP \n/vnp [ID] - вызвать игрока на проверку \n" ..
"/fz [ID] - заморозить игрока \n" ..
"/v [ID] [КОЛ-ВО] - выдать VIP выговор игроку \n/ov [NICK] [КОЛ-ВО] - выдать VIP выговор игроку (оффлайн)"