﻿// Decompiled by Serious. Credits to Scoba for his original tool, Cerberus, which I heavily upgraded to support remaining features, other games, and other platforms.
#using scripts\codescripts\struct;
#using scripts\shared\aat_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\scoreevents_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\trigger_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_devgui;
#using scripts\zm\_zm_net;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;

#namespace zm_ai_raz;

/*
	Name: __init__sytem__
	Namespace: zm_ai_raz
	Checksum: 0x4B28842D
	Offset: 0x550
	Size: 0x3C
	Parameters: 0
	Flags: AutoExec
*/
function autoexec __init__sytem__()
{
	system::register("zm_ai_raz", &__init__, &__main__, undefined);
}

/*
	Name: __init__
	Namespace: zm_ai_raz
	Checksum: 0x7EC096DF
	Offset: 0x598
	Size: 0x14
	Parameters: 0
	Flags: Linked
*/
function __init__()
{
	init();
}

/*
	Name: __main__
	Namespace: zm_ai_raz
	Checksum: 0x56529FB6
	Offset: 0x5B8
	Size: 0x44
	Parameters: 0
	Flags: Linked
*/
function __main__()
{
	register_clientfields();
	/#
		execdevgui("");
		thread function_fbcfe4b6();
	#/
}

/*
	Name: register_clientfields
	Namespace: zm_ai_raz
	Checksum: 0x99EC1590
	Offset: 0x608
	Size: 0x4
	Parameters: 0
	Flags: Linked
*/
function register_clientfields()
{
}

/*
	Name: init
	Namespace: zm_ai_raz
	Checksum: 0x978ED1D9
	Offset: 0x618
	Size: 0x1EC
	Parameters: 0
	Flags: Linked
*/
function init()
{
	zm::register_player_damage_callback(&function_94372a17);
	level.b_raz_enabled = 1;
	level.b_raz_rounds_enabled = 0;
	level.n_raz_round_count = 1;
	level.var_b9ce6312 = 0;
	level.a_sp_raz = [];
	level.n_raz_health = 5500;
	zm_score::register_score_event("death_raz", &function_6fdcefe3);
	level flag::init("raz_round");
	level flag::init("raz_round_in_progress");
	level thread aat::register_immunity("zm_aat_blast_furnace", "raz", 1, 1, 1);
	level thread aat::register_immunity("zm_aat_dead_wire", "raz", 1, 1, 1);
	level thread aat::register_immunity("zm_aat_fire_works", "raz", 1, 1, 1);
	level thread aat::register_immunity("zm_aat_thunder_wall", "raz", 1, 1, 1);
	level thread aat::register_immunity("zm_aat_turned", "raz", 1, 1, 1);
	raz_spawner_init();
	level thread function_ff9b21c4();
}

/*
	Name: function_6fdcefe3
	Namespace: zm_ai_raz
	Checksum: 0x26F0E4FF
	Offset: 0x810
	Size: 0x124
	Parameters: 5
	Flags: Linked
*/
function function_6fdcefe3(str_event, str_mod, str_hit_location, var_48d0b2fe, w_damage_weapon)
{
	if(str_event === "death_raz")
	{
		n_player_points = zm_score::get_zombie_death_player_points();
		n_bonus_points = self zm_score::player_add_points_kill_bonus(str_mod, str_hit_location, w_damage_weapon);
		n_player_points = (n_player_points + n_bonus_points) * 2;
		if(str_mod == "MOD_GRENADE" || str_mod == "MOD_GRENADE_SPLASH")
		{
			self zm_stats::increment_client_stat("grenade_kills");
			self zm_stats::increment_player_stat("grenade_kills");
		}
		scoreevents::processscoreevent("kill_raz", self, undefined, w_damage_weapon);
		return n_player_points;
	}
	return 0;
}

/*
	Name: enable_raz_rounds
	Namespace: zm_ai_raz
	Checksum: 0x128A22B3
	Offset: 0x940
	Size: 0x44
	Parameters: 0
	Flags: None
*/
function enable_raz_rounds()
{
	level.b_raz_rounds_enabled = 1;
	if(!isdefined(level.func_raz_round_track_override))
	{
		level.func_raz_round_track_override = &raz_round_tracker;
	}
	level thread [[level.func_raz_round_track_override]]();
}

/*
	Name: raz_spawner_init
	Namespace: zm_ai_raz
	Checksum: 0x7F78B32B
	Offset: 0x990
	Size: 0x11A
	Parameters: 0
	Flags: Linked
*/
function raz_spawner_init()
{
	level.a_sp_raz = getentarray("zombie_raz_spawner", "script_noteworthy");
	if(level.a_sp_raz.size == 0)
	{
		/#
			assertmsg("");
		#/
		return;
	}
	foreach(sp_raz in level.a_sp_raz)
	{
		sp_raz.is_enabled = 1;
		sp_raz.script_forcespawn = 1;
		sp_raz spawner::add_spawn_function(&raz_init);
	}
}

/*
	Name: function_ff9b21c4
	Namespace: zm_ai_raz
	Checksum: 0x9B33BF7A
	Offset: 0xAB8
	Size: 0x50
	Parameters: 0
	Flags: Linked
*/
function function_ff9b21c4()
{
	/#
		level waittill("start_of_round");
		raz_health_increase();
	#/
	while(true)
	{
		level waittill("between_round_over");
		raz_health_increase();
	}
}

/*
	Name: raz_round_tracker
	Namespace: zm_ai_raz
	Checksum: 0x7D2B7D3A
	Offset: 0xB10
	Size: 0x240
	Parameters: 0
	Flags: Linked
*/
function raz_round_tracker()
{
	level.n_raz_round_count = 1;
	level.n_next_raz_round = randomintrange(5, 8);
	/#
		if(getdvarint("") > 0)
		{
			level.n_next_raz_round = 5;
		}
	#/
	old_spawn_func = level.round_spawn_func;
	old_wait_func = level.round_wait_func;
	while(true)
	{
		level waittill("between_round_over");
		/#
			if(getdvarint("") > 0)
			{
				level.n_next_raz_round = level.round_number;
			}
		#/
		if(level.round_number == level.n_next_raz_round)
		{
			level.sndmusicspecialround = 1;
			old_spawn_func = level.round_spawn_func;
			old_wait_func = level.round_wait_func;
			raz_round_start();
			level.round_spawn_func = &raz_round_spawning;
			level.round_wait_func = &raz_round_wait_func;
			if(isdefined(level.zm_custom_get_next_raz_round))
			{
				level.n_next_raz_round = [[level.zm_custom_get_next_raz_round]]();
			}
			else
			{
				level.n_next_raz_round = level.n_next_raz_round + randomintrange(5, 8);
			}
			/#
				getplayers()[0] iprintln("" + level.n_next_raz_round);
			#/
		}
		else if(level flag::get("raz_round"))
		{
			raz_round_stop();
			level.round_spawn_func = old_spawn_func;
			level.round_wait_func = old_wait_func;
			level.n_raz_round_count++;
		}
	}
}

/*
	Name: raz_round_start
	Namespace: zm_ai_raz
	Checksum: 0xED463214
	Offset: 0xD58
	Size: 0x7C
	Parameters: 0
	Flags: Linked
*/
function raz_round_start()
{
	level flag::set("raz_round");
	level flag::set("special_round");
	level.var_b9ce6312 = 1;
	level notify("raz_round_starting");
	level thread zm_audio::sndmusicsystem_playstate("raz_start");
}

/*
	Name: raz_round_stop
	Namespace: zm_ai_raz
	Checksum: 0x8C6D8007
	Offset: 0xDE0
	Size: 0x5E
	Parameters: 0
	Flags: Linked
*/
function raz_round_stop()
{
	level flag::clear("raz_round");
	level flag::clear("special_round");
	level.var_b9ce6312 = 0;
	level notify("raz_round_ending");
}

/*
	Name: raz_round_spawning
	Namespace: zm_ai_raz
	Checksum: 0xED2E6C48
	Offset: 0xE48
	Size: 0x2C0
	Parameters: 0
	Flags: Linked
*/
function raz_round_spawning()
{
	level endon("intermission");
	level endon("raz_round");
	level.a_e_raz_targets = getplayers();
	for(i = 0; i < level.a_e_raz_targets.size; i++)
	{
		level.a_e_raz_targets[i].hunted_by = 0;
	}
	level endon("restart_round");
	/#
		level endon("kill_round");
		if(getdvarint("") == 2 || getdvarint("") >= 4)
		{
			return;
		}
	#/
	if(level.intermission)
	{
		return;
	}
	array::thread_all(level.players, &play_raz_round);
	n_wave_count = get_raz_spawn_total();
	raz_health_increase();
	level.zombie_total = int(n_wave_count);
	/#
		if(getdvarstring("") != "" && getdvarint("") > 0)
		{
			level.zombie_total = getdvarint("");
			setdvar("", 0);
		}
	#/
	wait(1);
	wait(6);
	n_raz_alive = 0;
	level flag::set("raz_round_in_progress");
	level endon("last_ai_down");
	level thread raz_round_aftermath();
	while(true)
	{
		while(level.zombie_total > 0)
		{
			if(isdefined(level.bzm_worldpaused) && level.bzm_worldpaused)
			{
				util::wait_network_frame();
				continue;
			}
			spawn_raz();
			util::wait_network_frame();
		}
		util::wait_network_frame();
	}
}

/*
	Name: function_665a13cd
	Namespace: zm_ai_raz
	Checksum: 0xBB36E861
	Offset: 0x1110
	Size: 0xA0
	Parameters: 2
	Flags: Linked
*/
function function_665a13cd(spawner, s_spot)
{
	raz_ai = zombie_utility::spawn_zombie(level.a_sp_raz[0], "raz", s_spot);
	if(isdefined(raz_ai))
	{
		raz_ai.check_point_in_enabled_zone = &zm_utility::check_point_in_playable_area;
		raz_ai thread zombie_utility::round_spawn_failsafe();
		raz_ai thread function_b8671cc0(s_spot);
	}
	return raz_ai;
}

/*
	Name: function_b8671cc0
	Namespace: zm_ai_raz
	Checksum: 0x73307D7D
	Offset: 0x11B8
	Size: 0x48
	Parameters: 1
	Flags: Linked
*/
function function_b8671cc0(s_spot)
{
	if(isdefined(level.var_71ab2462))
	{
		self thread [[level.var_71ab2462]](s_spot);
	}
	if(isdefined(level.var_ae95a175))
	{
		self thread [[level.var_ae95a175]]();
	}
}

/*
	Name: spawn_raz
	Namespace: zm_ai_raz
	Checksum: 0x937CFA31
	Offset: 0x1208
	Size: 0x204
	Parameters: 0
	Flags: Linked
*/
function spawn_raz()
{
	while(!can_spawn_raz())
	{
		wait(0.1);
	}
	s_spawn_loc = undefined;
	e_favorite_enemy = get_favorite_enemy();
	if(!isdefined(e_favorite_enemy))
	{
		wait(randomfloatrange(0.3333333, 0.6666667));
		return;
	}
	if(isdefined(level.func_raz_spawn))
	{
		s_spawn_loc = [[level.func_raz_spawn]](e_favorite_enemy);
	}
	else
	{
		/#
			iprintlnbold("");
		#/
		if(level.zm_loc_types[""].size == 0)
		{
		}
		s_spawn_loc = array::random(level.zm_loc_types["raz_location"]);
	}
	if(!isdefined(s_spawn_loc))
	{
		wait(randomfloatrange(0.3333333, 0.6666667));
		return;
	}
	ai = function_665a13cd(level.a_sp_raz[0]);
	if(isdefined(ai))
	{
		ai thread function_b8671cc0(s_spawn_loc);
		ai forceteleport(s_spawn_loc.origin, s_spawn_loc.angles);
		if(isdefined(e_favorite_enemy))
		{
			ai.favoriteenemy = e_favorite_enemy;
			ai.favoriteenemy.hunted_by++;
		}
		level.zombie_total--;
		waiting_for_next_raz_spawn();
	}
}

/*
	Name: get_raz_spawn_total
	Namespace: zm_ai_raz
	Checksum: 0x9A8FF8B
	Offset: 0x1418
	Size: 0x86
	Parameters: 0
	Flags: Linked
*/
function get_raz_spawn_total()
{
	switch(level.players.size)
	{
		case 1:
		{
			n_wave_count = 6;
			break;
		}
		case 2:
		{
			n_wave_count = 10;
			break;
		}
		case 3:
		{
			n_wave_count = 14;
			break;
		}
		case 4:
		default:
		{
			n_wave_count = 16;
			break;
		}
	}
	return n_wave_count;
}

/*
	Name: raz_round_wait_func
	Namespace: zm_ai_raz
	Checksum: 0x1E8870C6
	Offset: 0x14A8
	Size: 0x88
	Parameters: 0
	Flags: Linked
*/
function raz_round_wait_func()
{
	level endon("restart_round");
	/#
		level endon("kill_round");
	#/
	if(level flag::get("raz_round"))
	{
		level flag::wait_till("raz_round_in_progress");
		level flag::wait_till_clear("raz_round_in_progress");
	}
	level.sndmusicspecialround = 0;
}

/*
	Name: get_current_raz_count
	Namespace: zm_ai_raz
	Checksum: 0xF4B64643
	Offset: 0x1538
	Size: 0xD6
	Parameters: 0
	Flags: Linked
*/
function get_current_raz_count()
{
	a_ai_raz = getentarray("zombie_raz", "targetname");
	n_raz_alive = a_ai_raz.size;
	foreach(ai_raz in a_ai_raz)
	{
		if(!isalive(ai_raz))
		{
			n_raz_alive--;
		}
	}
	return n_raz_alive;
}

/*
	Name: function_bcbbda54
	Namespace: zm_ai_raz
	Checksum: 0xCDA1BF95
	Offset: 0x1618
	Size: 0x62
	Parameters: 0
	Flags: Linked
*/
function function_bcbbda54()
{
	switch(level.players.size)
	{
		case 1:
		{
			return 2;
			break;
		}
		case 2:
		{
			return 3;
			break;
		}
		case 3:
		{
			return 4;
			break;
		}
		case 4:
		{
			return 4;
			break;
		}
	}
}

/*
	Name: can_spawn_raz
	Namespace: zm_ai_raz
	Checksum: 0x2E506707
	Offset: 0x1688
	Size: 0x78
	Parameters: 0
	Flags: Linked
*/
function can_spawn_raz()
{
	n_raz_alive = get_current_raz_count();
	var_f0ab435a = function_bcbbda54();
	if(n_raz_alive >= var_f0ab435a || !level flag::get("spawn_zombies"))
	{
		return false;
	}
	return true;
}

/*
	Name: waiting_for_next_raz_spawn
	Namespace: zm_ai_raz
	Checksum: 0x262D82DB
	Offset: 0x1708
	Size: 0x88
	Parameters: 0
	Flags: Linked
*/
function waiting_for_next_raz_spawn()
{
	switch(level.players.size)
	{
		case 1:
		{
			n_default_wait = 2.25;
			break;
		}
		case 2:
		{
			n_default_wait = 1.75;
			break;
		}
		case 3:
		{
			n_default_wait = 1.25;
			break;
		}
		default:
		{
			n_default_wait = 0.75;
			break;
		}
	}
	wait(n_default_wait);
}

/*
	Name: raz_round_aftermath
	Namespace: zm_ai_raz
	Checksum: 0x1B0A7EB7
	Offset: 0x1798
	Size: 0x134
	Parameters: 0
	Flags: Linked
*/
function raz_round_aftermath()
{
	level waittill("last_ai_down", e_enemy_ai);
	level thread zm_audio::sndmusicsystem_playstate("raz_over");
	if(isdefined(level.zm_override_ai_aftermath_powerup_drop))
	{
		[[level.zm_override_ai_aftermath_powerup_drop]](e_enemy_ai, level.var_6a6f912a);
	}
	else
	{
		var_4a50cb2a = level.var_6a6f912a;
		trace = groundtrace(var_4a50cb2a + vectorscale((0, 0, 1), 100), var_4a50cb2a + (vectorscale((0, 0, -1), 1000)), 0, undefined);
		var_4a50cb2a = trace["position"];
		if(isdefined(var_4a50cb2a))
		{
			level thread zm_powerups::specific_powerup_drop("full_ammo", var_4a50cb2a);
		}
	}
	wait(2);
	level.sndmusicspecialround = 0;
	wait(6);
	level flag::clear("raz_round_in_progress");
}

/*
	Name: get_favorite_enemy
	Namespace: zm_ai_raz
	Checksum: 0x9189E45F
	Offset: 0x18D8
	Size: 0x150
	Parameters: 0
	Flags: Linked
*/
function get_favorite_enemy()
{
	a_e_raz_targets = getplayers();
	e_least_hunted = undefined;
	foreach(e_target in a_e_raz_targets)
	{
		if(!isdefined(e_target.hunted_by))
		{
			e_target.hunted_by = 0;
		}
		if(!zm_utility::is_player_valid(e_target))
		{
			continue;
		}
		if(isdefined(level.var_3fded92e) && ![[level.var_3fded92e]](e_target))
		{
			continue;
		}
		if(!isdefined(e_least_hunted))
		{
			e_least_hunted = e_target;
			continue;
		}
		if(e_target.hunted_by < e_least_hunted.hunted_by)
		{
			e_least_hunted = e_target;
		}
	}
	return e_least_hunted;
}

/*
	Name: raz_health_increase
	Namespace: zm_ai_raz
	Checksum: 0x50AF8ECE
	Offset: 0x1A30
	Size: 0x11C
	Parameters: 0
	Flags: Linked
*/
function raz_health_increase()
{
	level.n_raz_health = 5500 + (level.round_number * 100);
	if(level.n_raz_health < 5500)
	{
		level.n_raz_health = 5500;
	}
	else if(level.n_raz_health > 15000)
	{
		level.n_raz_health = 15000;
	}
	level.n_raz_health = int(level.n_raz_health * (1 + (0.15 * (level.players.size - 1))));
	level.razgunhealth = level.n_raz_health * 0.15;
	level.razhelmethealth = level.n_raz_health * 0.3;
	level.razleftshoulderarmorhealth = level.n_raz_health * 0.25;
	level.razchestarmorhealth = level.n_raz_health * 0.4;
	level.razthigharmorhealth = level.n_raz_health * 0.25;
}

/*
	Name: play_raz_round
	Namespace: zm_ai_raz
	Checksum: 0x164C9D33
	Offset: 0x1B58
	Size: 0xB4
	Parameters: 0
	Flags: Linked
*/
function play_raz_round()
{
	self playlocalsound("zmb_raz_round_start");
	variation_count = 5;
	wait(4.5);
	players = getplayers();
	num = randomintrange(0, players.size);
	players[num] zm_audio::create_and_play_dialog("general", "raz_spawn");
}

/*
	Name: raz_init
	Namespace: zm_ai_raz
	Checksum: 0x4B0DD4EC
	Offset: 0x1C18
	Size: 0x2B0
	Parameters: 0
	Flags: Linked
*/
function raz_init()
{
	self.targetname = "zombie_raz";
	self.script_noteworthy = undefined;
	self.animname = "zombie_raz";
	self.allowdeath = 1;
	self.allowpain = 1;
	self.force_gib = 1;
	self.is_zombie = 1;
	self.gibbed = 0;
	self.head_gibbed = 0;
	self.default_goalheight = 40;
	self.ignore_inert = 1;
	self.lightning_chain_immune = 1;
	self.holdfire = 1;
	self.grenadeawareness = 0;
	self.badplaceawareness = 0;
	self.ignoresuppression = 1;
	self.suppressionthreshold = 1;
	self.nododgemove = 1;
	self.dontshootwhilemoving = 1;
	self.pathenemylookahead = 0;
	self.chatinitialized = 0;
	self.missinglegs = 0;
	self.team = level.zombie_team;
	self.sword_kill_power = 4;
	self.instakill_func = &function_a59f11f9;
	self thread zombie_utility::zombie_eye_glow();
	if(isdefined(level.var_c7da0559))
	{
		self.func_custom_cleanup_check = level.var_c7da0559;
	}
	self.maxhealth = level.n_raz_health;
	if(isdefined(level.a_zombie_respawn_health[self.archetype]) && level.a_zombie_respawn_health[self.archetype].size > 0)
	{
		self.health = level.a_zombie_respawn_health[self.archetype][0];
		arrayremovevalue(level.a_zombie_respawn_health[self.archetype], level.a_zombie_respawn_health[self.archetype][0]);
	}
	else
	{
		self.health = self.maxhealth;
	}
	self thread raz_death();
	level thread zm_spawner::zombie_death_event(self);
	self thread zm_spawner::enemy_death_detection();
	self zm_spawner::zombie_history(("zombie_raz_spawn_init -> Spawned = ") + self.origin);
	if(isdefined(level.achievement_monitor_func))
	{
		self thread [[level.achievement_monitor_func]]();
	}
}

/*
	Name: raz_death
	Namespace: zm_ai_raz
	Checksum: 0x39F6A300
	Offset: 0x1ED0
	Size: 0x1F4
	Parameters: 0
	Flags: Linked
*/
function raz_death()
{
	self waittill("death", attacker);
	self thread zombie_utility::zombie_eye_glow_stop();
	if(get_current_raz_count() == 0 && level.zombie_total == 0)
	{
		if(!isdefined(level.zm_ai_round_over) || [[level.zm_ai_round_over]]())
		{
			level.var_6a6f912a = self.origin;
			level notify("last_ai_down", self);
		}
	}
	if(isplayer(attacker))
	{
		if(!(isdefined(self.deathpoints_already_given) && self.deathpoints_already_given))
		{
			attacker zm_score::player_add_points("death_raz", self.damagemod, self.damagelocation);
		}
		if(isdefined(level.hero_power_update))
		{
			[[level.hero_power_update]](attacker, self);
		}
		attacker zm_audio::create_and_play_dialog("kill", "raz");
		attacker zm_stats::increment_client_stat("zraz_killed");
		attacker zm_stats::increment_player_stat("zraz_killed");
	}
	if(isdefined(attacker) && isai(attacker))
	{
		attacker notify("killed", self);
	}
	if(isdefined(self))
	{
		self stoploopsound();
		self thread raz_explode_fx(self.origin);
	}
}

/*
	Name: raz_explode_fx
	Namespace: zm_ai_raz
	Checksum: 0x7B764799
	Offset: 0x20D0
	Size: 0xC
	Parameters: 1
	Flags: Linked
*/
function raz_explode_fx(origin)
{
}

/*
	Name: zombie_setup_attack_properties_raz
	Namespace: zm_ai_raz
	Checksum: 0xF9B73238
	Offset: 0x20E8
	Size: 0x54
	Parameters: 0
	Flags: None
*/
function zombie_setup_attack_properties_raz()
{
	self zm_spawner::zombie_history("zombie_setup_attack_properties()");
	self.ignoreall = 0;
	self.meleeattackdist = 64;
	self.disablearrivals = 1;
	self.disableexits = 1;
}

/*
	Name: stop_raz_sound_on_death
	Namespace: zm_ai_raz
	Checksum: 0xB82979D6
	Offset: 0x2148
	Size: 0x24
	Parameters: 0
	Flags: None
*/
function stop_raz_sound_on_death()
{
	self waittill("death");
	self stopsounds();
}

/*
	Name: special_raz_spawn
	Namespace: zm_ai_raz
	Checksum: 0x35FFAC78
	Offset: 0x2178
	Size: 0x2AC
	Parameters: 4
	Flags: Linked
*/
function special_raz_spawn(n_to_spawn = 1, func_on_spawned, b_force_spawn = 0, var_b7959229 = undefined)
{
	n_spawned = 0;
	while(n_spawned < n_to_spawn)
	{
		if(!b_force_spawn && !can_spawn_raz())
		{
			return n_spawned;
		}
		players = getplayers();
		e_favorite_enemy = get_favorite_enemy();
		if(isdefined(var_b7959229))
		{
			s_spawn_loc = var_b7959229;
		}
		else
		{
			if(isdefined(level.raz_spawn_func))
			{
				s_spawn_loc = [[level.raz_spawn_func]](level.a_sp_raz, e_favorite_enemy);
			}
			else if(level.zm_loc_types["raz_location"].size > 0)
			{
				s_spawn_loc = array::random(level.zm_loc_types["raz_location"]);
			}
		}
		if(!isdefined(s_spawn_loc))
		{
			return 0;
		}
		ai = function_665a13cd(level.a_sp_raz[0]);
		if(isdefined(ai))
		{
			ai forceteleport(s_spawn_loc.origin, s_spawn_loc.angles);
			ai.script_string = s_spawn_loc.script_string;
			ai.find_flesh_struct_string = ai.script_string;
			if(isdefined(e_favorite_enemy))
			{
				ai.favoriteenemy = e_favorite_enemy;
				ai.favoriteenemy.hunted_by++;
			}
			n_spawned++;
			if(isdefined(func_on_spawned))
			{
				ai thread [[func_on_spawned]]();
			}
			playsoundatposition("zmb_raz_spawn", s_spawn_loc.origin);
		}
		waiting_for_next_raz_spawn();
	}
	return 1;
}

/*
	Name: function_175052a7
	Namespace: zm_ai_raz
	Checksum: 0x4529FDD9
	Offset: 0x2430
	Size: 0x50
	Parameters: 0
	Flags: None
*/
function function_175052a7()
{
	self endon("death");
	while(true)
	{
		self playsound("zmb_hellhound_vocals_amb");
		wait(randomfloatrange(3, 6));
	}
}

/*
	Name: raz_thundergun_knockdown
	Namespace: zm_ai_raz
	Checksum: 0x652F53AC
	Offset: 0x2488
	Size: 0x8C
	Parameters: 2
	Flags: None
*/
function raz_thundergun_knockdown(player, gib)
{
	self endon("death");
	damage = int(self.maxhealth * 0.5);
	self dodamage(damage, player.origin, player, undefined, "none", "MOD_UNKNOWN");
}

/*
	Name: function_94372a17
	Namespace: zm_ai_raz
	Checksum: 0xD5DD9AD7
	Offset: 0x2520
	Size: 0x192
	Parameters: 10
	Flags: Linked
*/
function function_94372a17(inflictor, attacker, damage, dflags, mod, weapon, point, dir, hitloc, offsettime)
{
	player = self;
	if(isdefined(attacker) && attacker.archetype === "raz" && mod === "MOD_PROJECTILE_SPLASH" && isdefined(weapon) && issubstr("raz_melee", weapon.name))
	{
		dist_sq = distancesquared(attacker.origin, player.origin);
		var_bfa346a2 = 16384;
		damage_ratio = 1 - (dist_sq / var_bfa346a2);
		damage_gradient = 35;
		damage = damage_gradient * damage_ratio;
		damage = int(damage);
		damage = damage + 15;
		return damage;
	}
	return -1;
}

/*
	Name: function_a59f11f9
	Namespace: zm_ai_raz
	Checksum: 0x9F3DB170
	Offset: 0x26C0
	Size: 0xDA
	Parameters: 3
	Flags: Linked
*/
function function_a59f11f9(e_player, var_3ca8546d, var_9908b5f4)
{
	if(var_9908b5f4 == "right_arm_lower" || var_9908b5f4 == "right_hand")
	{
		return true;
	}
	if(var_9908b5f4 == "right_arm_upper" && self.razhasgunattached == 1)
	{
		self.razgunhealth = 1;
		self dodamage(1, e_player.origin, e_player, e_player, "right_arm_upper");
		return true;
	}
	if(isdefined(self.last_damage_hit_armor) && self.last_damage_hit_armor)
	{
		return true;
	}
	return false;
}

/*
	Name: function_fbcfe4b6
	Namespace: zm_ai_raz
	Checksum: 0x74C14E5E
	Offset: 0x27A8
	Size: 0x44
	Parameters: 0
	Flags: Linked
*/
function function_fbcfe4b6()
{
	/#
		level flag::wait_till("");
		zm_devgui::add_custom_devgui_callback(&function_3626e3d1);
	#/
}

/*
	Name: function_3626e3d1
	Namespace: zm_ai_raz
	Checksum: 0x3154A13F
	Offset: 0x27F8
	Size: 0xCE
	Parameters: 1
	Flags: Linked
*/
function function_3626e3d1(cmd)
{
	/#
		switch(cmd)
		{
			case "":
			{
				function_39a724b1();
				break;
			}
			case "":
			{
				function_9a80ee5f();
				break;
			}
			case "":
			{
				function_e115a394(getdvarint(""));
				break;
			}
			case "":
			{
				function_70864ef2(getdvarint(""));
				break;
			}
		}
	#/
}

/*
	Name: function_39a724b1
	Namespace: zm_ai_raz
	Checksum: 0xF3A15BA5
	Offset: 0x28D0
	Size: 0x1D0
	Parameters: 0
	Flags: Linked
*/
function function_39a724b1()
{
	/#
		player = level.players[0];
		v_direction = player getplayerangles();
		v_direction = anglestoforward(v_direction) * 8000;
		eye = player geteye();
		trace = bullettrace(eye, eye + v_direction, 0, undefined);
		var_feba5c63 = positionquery_source_navigation(trace[""], 128, 256, 128, 20);
		s_spot = spawnstruct();
		if(isdefined(var_feba5c63) && var_feba5c63.data.size > 0)
		{
			s_spot.origin = var_feba5c63.data[0].origin;
		}
		else
		{
			s_spot.origin = player.origin;
		}
		s_spot.angles = (0, player.angles[1] - 180, 0);
		special_raz_spawn(1, undefined, 1, s_spot);
		return true;
	#/
}

/*
	Name: function_9a80ee5f
	Namespace: zm_ai_raz
	Checksum: 0x71388C7F
	Offset: 0x2AB0
	Size: 0x3A
	Parameters: 0
	Flags: Linked
*/
function function_9a80ee5f()
{
	/#
		if(!(isdefined(level.b_raz_ignore_mangler_cooldown) && level.b_raz_ignore_mangler_cooldown))
		{
			level.b_raz_ignore_mangler_cooldown = 1;
		}
		else
		{
			level.b_raz_ignore_mangler_cooldown = undefined;
		}
	#/
}

/*
	Name: function_e115a394
	Namespace: zm_ai_raz
	Checksum: 0xF8B90C2A
	Offset: 0x2AF8
	Size: 0xA0
	Parameters: 1
	Flags: Linked
*/
function function_e115a394(n_raz)
{
	/#
		if(!isdefined(level.b_raz_enabled) || !level.b_raz_enabled)
		{
			return;
		}
		if(!isdefined(level.b_raz_rounds_enabled) || !level.b_raz_rounds_enabled)
		{
			return;
		}
		if(!isdefined(level.a_sp_raz) || level.a_sp_raz.size < 1)
		{
			return;
		}
		function_d8afb0d4(n_raz);
		level.n_next_raz_round = level.round_number + 1;
	#/
}

/*
	Name: function_70864ef2
	Namespace: zm_ai_raz
	Checksum: 0xAD68602B
	Offset: 0x2BA0
	Size: 0x4C
	Parameters: 1
	Flags: Linked
*/
function function_70864ef2(n_raz)
{
	/#
		if(isdefined(level.n_next_raz_round))
		{
			function_d8afb0d4(n_raz);
			zm_devgui::zombie_devgui_goto_round(level.n_next_raz_round);
		}
	#/
}

/*
	Name: function_d8afb0d4
	Namespace: zm_ai_raz
	Checksum: 0x6CE71BE8
	Offset: 0x2BF8
	Size: 0x6C
	Parameters: 1
	Flags: Linked
*/
function function_d8afb0d4(n_raz)
{
	/#
		if(isdefined(n_raz) && n_raz > 0)
		{
			setdvar("", n_raz);
		}
		else
		{
			setdvar("", "");
		}
	#/
}

