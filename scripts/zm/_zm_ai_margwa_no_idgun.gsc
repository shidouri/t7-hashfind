﻿// Decompiled by Serious. Credits to Scoba for his original tool, Cerberus, which I heavily upgraded to support remaining features, other games, and other platforms.
#using scripts\codescripts\struct;
#using scripts\shared\aat_shared;
#using scripts\shared\ai\margwa;
#using scripts\shared\ai\systems\animation_state_machine_utility;
#using scripts\shared\ai\systems\behavior_tree_utility;
#using scripts\shared\ai\systems\blackboard;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scoreevents_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm;
#using scripts\zm\_zm_ai_wasp_no_idgun;
#using scripts\zm\_zm_devgui;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weap_idgun;

#namespace zm_ai_margwa;

/*
	Name: init
	Namespace: zm_ai_margwa
	Checksum: 0xD1813175
	Offset: 0x680
	Size: 0x1AC
	Parameters: 0
	Flags: AutoExec
*/
function autoexec init()
{
	function_e84ffe9c();
	level.margwa_spawners = getentarray("zombie_margwa_spawner", "script_noteworthy");
	level.margwa_locations = struct::get_array("margwa_location", "script_noteworthy");
	level thread aat::register_immunity("zm_aat_blast_furnace", "margwa", 0, 1, 1);
	level thread aat::register_immunity("zm_aat_dead_wire", "margwa", 1, 1, 1);
	level thread aat::register_immunity("zm_aat_fire_works", "margwa", 1, 1, 1);
	level thread aat::register_immunity("zm_aat_thunder_wall", "margwa", 0, 1, 1);
	level thread aat::register_immunity("zm_aat_turned", "margwa", 1, 1, 1);
	spawner::add_archetype_spawn_function("margwa", &function_17627e34);
	/#
		execdevgui("");
		thread function_cdd8baf7();
	#/
}

/*
	Name: function_4092fa4d
	Namespace: zm_ai_margwa
	Checksum: 0x5E203923
	Offset: 0x838
	Size: 0x92
	Parameters: 0
	Flags: None
*/
function function_4092fa4d()
{
	wait(20);
	for(i = 0; i < 1; i++)
	{
		margwa_location = arraygetclosest(level.players[0].origin, level.margwa_locations);
		margwa = function_8a0708c2(margwa_location);
		wait(0.5);
	}
}

/*
	Name: function_e84ffe9c
	Namespace: zm_ai_margwa
	Checksum: 0x731BA032
	Offset: 0x8D8
	Size: 0x28C
	Parameters: 0
	Flags: Linked, Private
*/
function private function_e84ffe9c()
{
	behaviortreenetworkutility::registerbehaviortreescriptapi("zmMargwaTargetService", &function_c0fb414e);
	behaviortreenetworkutility::registerbehaviortreescriptapi("zmMargwaTeleportService", &function_5d11b2dc);
	behaviortreenetworkutility::registerbehaviortreescriptapi("zmMargwaZoneService", &function_6cc20647);
	behaviortreenetworkutility::registerbehaviortreescriptapi("zmMargwaPushService", &function_fa29651d);
	behaviortreenetworkutility::registerbehaviortreescriptapi("zmMargwaOctobombService", &function_d59056ec);
	behaviortreenetworkutility::registerbehaviortreescriptapi("zmMargwaVortexService", &function_6312be59);
	behaviortreenetworkutility::registerbehaviortreescriptapi("zmMargwaShouldSmashAttack", &function_cbdc3798);
	behaviortreenetworkutility::registerbehaviortreescriptapi("zmMargwaShouldSwipeAttack", &function_ec97fb1e);
	behaviortreenetworkutility::registerbehaviortreescriptapi("zmMargwaShouldOctobombAttack", &function_f0e8cb2d);
	behaviortreenetworkutility::registerbehaviortreescriptapi("zmMargwaShouldMove", &function_1c88d468);
	behaviortreenetworkutility::registerbehaviortreeaction("zmMargwaSwipeAttackAction", &function_cd380e61, &function_edd2fa77, undefined);
	behaviortreenetworkutility::registerbehaviortreeaction("zmMargwaOctobombAttackAction", &function_9fab0124, &function_c5832338, &function_7b2a3a90);
	behaviortreenetworkutility::registerbehaviortreescriptapi("zmMargwaSmashAttackTerminate", &function_7137a16);
	behaviortreenetworkutility::registerbehaviortreescriptapi("zmMargwaSwipeAttackTerminate", &function_137093c0);
	behaviortreenetworkutility::registerbehaviortreescriptapi("zmMargwaTeleportInTerminate", &function_743b10d2);
}

/*
	Name: function_c0fb414e
	Namespace: zm_ai_margwa
	Checksum: 0xB4449C0
	Offset: 0xB70
	Size: 0x272
	Parameters: 1
	Flags: Linked, Private
*/
function private function_c0fb414e(entity)
{
	if(isdefined(entity.ignoreall) && entity.ignoreall)
	{
		return 0;
	}
	if(isdefined(entity.isteleporting) && entity.isteleporting || (isdefined(entity.needteleportout) && entity.needteleportout))
	{
		return 0;
	}
	if(isdefined(entity.destroy_octobomb))
	{
		return 0;
	}
	if(isdefined(entity.favoriteenemy) && (isdefined(entity.favoriteenemy.b_teleporting) && entity.favoriteenemy.b_teleporting))
	{
		return 0;
	}
	if(isdefined(entity.is_flung) && entity.is_flung)
	{
		return 0;
	}
	entity zombie_utility::run_ignore_player_handler();
	player = zm_utility::get_closest_valid_player(entity.origin, entity.ignore_player);
	entity.favoriteenemy = player;
	if(!isdefined(player))
	{
		zone = zm_utility::get_current_zone();
		if(isdefined(zone))
		{
			wait_locations = level.zones[zone].a_loc_types["wait_location"];
			if(isdefined(wait_locations) && wait_locations.size > 0)
			{
				return entity function_f21a8d83(wait_locations[0].origin, 64, 30);
			}
		}
		entity setgoal(entity.origin);
		return 0;
	}
	return entity function_f21a8d83(entity.favoriteenemy.origin, 64, 30);
}

/*
	Name: function_f21a8d83
	Namespace: zm_ai_margwa
	Checksum: 0xE8841E40
	Offset: 0xDF0
	Size: 0xF6
	Parameters: 3
	Flags: Linked, Private
*/
function private function_f21a8d83(origin, radius, boundarydist)
{
	pos = getclosestpointonnavmesh(origin, 64, 30);
	if(isdefined(pos))
	{
		self setgoal(pos);
		self.var_baa0a16c = pos;
		return true;
	}
	pos = getclosestpointonnavmesh(origin, 2048, 30);
	if(isdefined(pos))
	{
		self setgoal(pos);
		self.var_baa0a16c = pos;
		return true;
	}
	self setgoal(self.origin);
	return false;
}

/*
	Name: function_5d11b2dc
	Namespace: zm_ai_margwa
	Checksum: 0x732A05D2
	Offset: 0xEF0
	Size: 0x31C
	Parameters: 1
	Flags: Linked, Private
*/
function private function_5d11b2dc(entity)
{
	if(isdefined(entity.favoriteenemy))
	{
		if(isdefined(entity.favoriteenemy.on_train) && entity.favoriteenemy.on_train)
		{
			var_d3443466 = [[ level.o_zod_train ]]->get_doors_state();
			if(isdefined(entity.locked_in_train) && entity.locked_in_train && (!(isdefined(var_d3443466) && var_d3443466)))
			{
				return false;
			}
		}
		if(isdefined(entity.favoriteenemy.b_teleporting) && entity.favoriteenemy.b_teleporting)
		{
			return false;
		}
	}
	if(!(isdefined(entity.needteleportout) && entity.needteleportout) && (!(isdefined(entity.isteleporting) && entity.isteleporting)) && isdefined(entity.favoriteenemy))
	{
		var_1dd5ad4d = 0;
		dist_sq = distancesquared(self.favoriteenemy.origin, entity.origin);
		var_9c921a96 = 2250000;
		/#
			var_7a419cfb = getdvarint("") * 12;
			var_9c921a96 = var_7a419cfb * var_7a419cfb;
		#/
		if(dist_sq > var_9c921a96)
		{
			if(isdefined(entity.destroy_octobomb))
			{
				var_1dd5ad4d = 0;
			}
			else
			{
				var_1dd5ad4d = 1;
			}
		}
		else if(isdefined(level.var_785a0d1e))
		{
			if(entity [[level.var_785a0d1e]]())
			{
				var_1dd5ad4d = 1;
			}
		}
		if(var_1dd5ad4d)
		{
			if(isdefined(self.favoriteenemy.zone_name))
			{
				wait_locations = level.zones[self.favoriteenemy.zone_name].a_loc_types["wait_location"];
				if(isdefined(wait_locations) && wait_locations.size > 0)
				{
					wait_locations = array::randomize(wait_locations);
					entity.needteleportout = 1;
					entity.teleportpos = wait_locations[0].origin;
					return true;
				}
			}
		}
	}
	return false;
}

/*
	Name: function_6cc20647
	Namespace: zm_ai_margwa
	Checksum: 0x4209A99
	Offset: 0x1218
	Size: 0xAC
	Parameters: 1
	Flags: Linked, Private
*/
function private function_6cc20647(entity)
{
	if(isdefined(entity.isteleporting) && entity.isteleporting)
	{
		return false;
	}
	if(!isdefined(entity.zone_name))
	{
		entity.zone_name = zm_utility::get_current_zone();
	}
	else
	{
		entity.previous_zone_name = entity.zone_name;
		entity.zone_name = zm_utility::get_current_zone();
	}
	return true;
}

/*
	Name: function_fa29651d
	Namespace: zm_ai_margwa
	Checksum: 0x4904CE62
	Offset: 0x12D0
	Size: 0x226
	Parameters: 1
	Flags: Linked, Private
*/
function private function_fa29651d(entity)
{
	if(entity.zombie_move_speed == "walk")
	{
		return false;
	}
	zombies = zombie_utility::get_round_enemy_array();
	foreach(zombie in zombies)
	{
		distsq = distancesquared(entity.origin, zombie.origin);
		if(distsq < 2304)
		{
			zombie.pushed = 1;
			var_16ce8ab3 = self.origin - zombie.origin;
			var_e1fcfc7c = vectornormalize((var_16ce8ab3[0], var_16ce8ab3[1], 0));
			zombie_right = anglestoright(zombie.angles);
			zombie_right_2d = vectornormalize((zombie_right[0], zombie_right[1], 0));
			dot = vectordot(var_e1fcfc7c, zombie_right_2d);
			if(dot > 0)
			{
				zombie.push_direction = "left";
				continue;
			}
			zombie.push_direction = "right";
		}
	}
}

/*
	Name: function_d59056ec
	Namespace: zm_ai_margwa
	Checksum: 0x3E3918A0
	Offset: 0x1500
	Size: 0x15A
	Parameters: 1
	Flags: Linked, Private
*/
function private function_d59056ec(entity)
{
	if(isdefined(entity.destroy_octobomb))
	{
		entity setgoal(entity.destroy_octobomb.origin);
		return true;
	}
	if(isdefined(level.octobombs))
	{
		foreach(octobomb in level.octobombs)
		{
			if(isdefined(octobomb))
			{
				dist_sq = distancesquared(octobomb.origin, self.origin);
				if(dist_sq < 360000)
				{
					entity.destroy_octobomb = octobomb;
					entity setgoal(octobomb.origin);
					return true;
				}
			}
		}
	}
	return false;
}

/*
	Name: function_604404
	Namespace: zm_ai_margwa
	Checksum: 0xF0613C7D
	Offset: 0x1668
	Size: 0x9E
	Parameters: 1
	Flags: Linked, Private
*/
function private function_604404(entity)
{
	if(isdefined(self.react))
	{
		foreach(react in self.react)
		{
			if(react == entity)
			{
				return true;
			}
		}
	}
	return false;
}

/*
	Name: function_e92d3bb1
	Namespace: zm_ai_margwa
	Checksum: 0xD4441702
	Offset: 0x1710
	Size: 0x3A
	Parameters: 1
	Flags: Linked, Private
*/
function private function_e92d3bb1(entity)
{
	if(!isdefined(self.react))
	{
		self.react = [];
	}
	self.react[self.react.size] = entity;
}

/*
	Name: function_6312be59
	Namespace: zm_ai_margwa
	Checksum: 0xD145242A
	Offset: 0x1758
	Size: 0x1CA
	Parameters: 1
	Flags: Linked
*/
function function_6312be59(entity)
{
	if(!(isdefined(entity.canstun) && entity.canstun))
	{
		return false;
	}
	if(isdefined(level.vortex_manager) && isdefined(level.vortex_manager.a_active_vorticies))
	{
		foreach(vortex in level.vortex_manager.a_active_vorticies)
		{
			if(!vortex function_604404(entity))
			{
				dist_sq = distancesquared(vortex.origin, self.origin);
				if(dist_sq < 9216)
				{
					entity.reactidgun = 1;
					entity.vortex = vortex;
					if(isdefined(vortex.weapon) && idgun::function_9b7ac6a9(vortex.weapon))
					{
						blackboard::setblackboardattribute(entity, "_zombie_damageweapon_type", "packed");
					}
					vortex function_e92d3bb1(entity);
					return true;
				}
			}
		}
	}
	return false;
}

/*
	Name: function_cbdc3798
	Namespace: zm_ai_margwa
	Checksum: 0xAEDA95A6
	Offset: 0x1930
	Size: 0x6A
	Parameters: 1
	Flags: Linked, Private
*/
function private function_cbdc3798(entity)
{
	if(isdefined(entity.destroy_octobomb))
	{
		return 0;
	}
	if(!isdefined(entity.next_attack) || entity.next_attack != 1)
	{
		return 0;
	}
	return margwabehavior::margwashouldsmashattack(entity);
}

/*
	Name: function_ec97fb1e
	Namespace: zm_ai_margwa
	Checksum: 0xF4185C6D
	Offset: 0x19A8
	Size: 0x6A
	Parameters: 1
	Flags: Linked, Private
*/
function private function_ec97fb1e(entity)
{
	if(isdefined(entity.destroy_octobomb))
	{
		return 0;
	}
	if(!isdefined(entity.next_attack) || entity.next_attack != 2)
	{
		return 0;
	}
	return margwabehavior::margwashouldswipeattack(entity);
}

/*
	Name: function_f0e8cb2d
	Namespace: zm_ai_margwa
	Checksum: 0x22BFF3CB
	Offset: 0x1A20
	Size: 0xBE
	Parameters: 1
	Flags: Linked, Private
*/
function private function_f0e8cb2d(entity)
{
	if(!isdefined(entity.destroy_octobomb))
	{
		return false;
	}
	if(distancesquared(entity.origin, entity.destroy_octobomb.origin) > 16384)
	{
		return false;
	}
	yaw = abs(zombie_utility::getyawtospot(entity.destroy_octobomb.origin));
	if(yaw > 45)
	{
		return false;
	}
	return true;
}

/*
	Name: function_1c88d468
	Namespace: zm_ai_margwa
	Checksum: 0x11D9AB96
	Offset: 0x1AE8
	Size: 0xC6
	Parameters: 1
	Flags: Linked, Private
*/
function private function_1c88d468(entity)
{
	if(isdefined(entity.needteleportout) && entity.needteleportout)
	{
		return false;
	}
	if(isdefined(entity.destroy_octobomb))
	{
		if(function_f0e8cb2d(entity))
		{
			return false;
		}
	}
	else
	{
		if(function_ec97fb1e(entity))
		{
			return false;
		}
		if(function_cbdc3798(entity))
		{
			return false;
		}
	}
	if(entity haspath())
	{
		return true;
	}
	return false;
}

/*
	Name: function_9fab0124
	Namespace: zm_ai_margwa
	Checksum: 0x6AE636CA
	Offset: 0x1BB8
	Size: 0x70
	Parameters: 2
	Flags: Linked, Private
*/
function private function_9fab0124(entity, asmstatename)
{
	animationstatenetworkutility::requeststate(entity, asmstatename);
	if(!isdefined(entity.var_41294bba))
	{
		entity.var_41294bba = gettime() + randomintrange(3000, 4000);
	}
	return 5;
}

/*
	Name: function_c5832338
	Namespace: zm_ai_margwa
	Checksum: 0xE7DCE37C
	Offset: 0x1C30
	Size: 0x5E
	Parameters: 2
	Flags: Linked, Private
*/
function private function_c5832338(entity, asmstatename)
{
	if(!isdefined(entity.destroy_octobomb))
	{
		return 4;
	}
	if(isdefined(entity.var_41294bba) && gettime() > entity.var_41294bba)
	{
		return 4;
	}
	return 5;
}

/*
	Name: function_7b2a3a90
	Namespace: zm_ai_margwa
	Checksum: 0x8CB4DDF0
	Offset: 0x1C98
	Size: 0x56
	Parameters: 2
	Flags: Linked, Private
*/
function private function_7b2a3a90(entity, asmstatename)
{
	if(isdefined(entity.destroy_octobomb))
	{
		entity.destroy_octobomb detonate();
	}
	entity.var_41294bba = undefined;
	return 4;
}

/*
	Name: function_cd380e61
	Namespace: zm_ai_margwa
	Checksum: 0x6F78BF81
	Offset: 0x1CF8
	Size: 0x100
	Parameters: 2
	Flags: Linked, Private
*/
function private function_cd380e61(entity, asmstatename)
{
	animationstatenetworkutility::requeststate(entity, asmstatename);
	if(!isdefined(entity.swipe_end_time))
	{
		swipeactionast = entity astsearch(istring(asmstatename));
		swipeactionanimation = animationstatenetworkutility::searchanimationmap(entity, swipeactionast["animation"]);
		swipeactiontime = getanimlength(swipeactionanimation) * 1000;
		entity.swipe_end_time = gettime() + swipeactiontime;
	}
	margwabehavior::margwaswipeattackstart(entity);
	return 5;
}

/*
	Name: function_edd2fa77
	Namespace: zm_ai_margwa
	Checksum: 0x5942851D
	Offset: 0x1E00
	Size: 0x46
	Parameters: 2
	Flags: Linked, Private
*/
function private function_edd2fa77(entity, asmstatename)
{
	if(isdefined(entity.swipe_end_time) && gettime() > entity.swipe_end_time)
	{
		return 4;
	}
	return 5;
}

/*
	Name: function_7137a16
	Namespace: zm_ai_margwa
	Checksum: 0xC3F20E7B
	Offset: 0x1E50
	Size: 0x4C
	Parameters: 1
	Flags: Linked, Private
*/
function private function_7137a16(entity)
{
	entity.swipe_end_time = undefined;
	entity function_941cbfc5();
	margwabehavior::margwasmashattackterminate(entity);
}

/*
	Name: function_137093c0
	Namespace: zm_ai_margwa
	Checksum: 0x27C4910C
	Offset: 0x1EA8
	Size: 0x34
	Parameters: 1
	Flags: Linked, Private
*/
function private function_137093c0(entity)
{
	entity.swipe_end_time = undefined;
	entity function_941cbfc5();
}

/*
	Name: function_743b10d2
	Namespace: zm_ai_margwa
	Checksum: 0x86135A88
	Offset: 0x1EE8
	Size: 0x60
	Parameters: 1
	Flags: Linked, Private
*/
function private function_743b10d2(entity)
{
	margwabehavior::margwateleportinterminate(entity);
	entity.previous_zone_name = entity.zone_name;
	entity.zone_name = zm_utility::get_current_zone();
}

/*
	Name: function_271a21d6
	Namespace: zm_ai_margwa
	Checksum: 0x7E22BE97
	Offset: 0x1F50
	Size: 0x4C
	Parameters: 0
	Flags: Private
*/
function private function_271a21d6()
{
	self endon("death");
	entity.waiting = 1;
	util::wait_network_frame();
	entity.waiting = 0;
}

/*
	Name: function_17627e34
	Namespace: zm_ai_margwa
	Checksum: 0x4367EA6
	Offset: 0x1FA8
	Size: 0xFC
	Parameters: 0
	Flags: Linked, Private
*/
function private function_17627e34()
{
	self.destroyheadcb = &function_1f53b1a2;
	self.bodyfallcb = &margwa_bodyfall;
	self.var_16ec9b37 = &function_a89905c6;
	self.chop_actor_cb = &function_89e37c9b;
	self.var_a3b60c68 = &function_dbd9ba44;
	self.var_de36fc8 = &function_2aa0209c;
	self.smashattackcb = &margwa_smash_attack;
	self.lightning_chain_immune = 1;
	self.ignore_game_over_death = 1;
	self.should_turn = 1;
	self.jawanimenabled = 1;
	self.sword_kill_power = 5;
	self function_941cbfc5();
}

/*
	Name: function_1f53b1a2
	Namespace: zm_ai_margwa
	Checksum: 0x44E796DD
	Offset: 0x20B0
	Size: 0x23C
	Parameters: 2
	Flags: Linked, Private
*/
function private function_1f53b1a2(modelhit, attacker)
{
	if(isplayer(attacker) && (!(isdefined(self.deathpoints_already_given) && self.deathpoints_already_given)) && (!(isdefined(level.var_1f6ca9c8) && level.var_1f6ca9c8)))
	{
		attacker zm_score::player_add_points("bonus_points_powerup", 500);
	}
	right = anglestoright(self.angles);
	spawn_pos = (self.origin + anglestoright(self.angles)) + vectorscale((0, 0, 1), 128);
	var_df9f2e65 = (self.origin - anglestoright(self.angles)) + vectorscale((0, 0, 1), 128);
	loc = spawnstruct();
	loc.origin = spawn_pos;
	loc.angles = self.angles;
	self margwa_head_explosion();
	spawner_override = undefined;
	if(isdefined(level.var_39c0c115))
	{
		spawner_override = level.var_39c0c115;
	}
	zm_ai_wasp::special_wasp_spawn(1, loc, 32, 32, 1, 0, 0, spawner_override);
	if(isdefined(self.var_26f9f957))
	{
		self thread [[self.var_26f9f957]](modelhit, attacker);
	}
	if(isplayer(attacker) && isdefined(level.hero_power_update))
	{
		[[level.hero_power_update]](attacker, self);
	}
	loc struct::delete();
}

/*
	Name: margwa_bodyfall
	Namespace: zm_ai_margwa
	Checksum: 0xA0D59B4C
	Offset: 0x22F8
	Size: 0x174
	Parameters: 0
	Flags: Linked, Private
*/
function private margwa_bodyfall()
{
	power_up_origin = (self.origin + vectorscale(anglestoforward(self.angles), 32)) + vectorscale((0, 0, 1), 16);
	if(isdefined(power_up_origin) && (!(isdefined(self.no_powerups) && self.no_powerups)))
	{
		var_3bd46762 = [];
		foreach(powerup in level.zombie_powerup_array)
		{
			if(powerup == "carpenter")
			{
				continue;
			}
			if(![[level.zombie_powerups[powerup].func_should_drop_with_regular_powerups]]())
			{
				continue;
			}
			var_3bd46762[var_3bd46762.size] = powerup;
		}
		var_3dc91cb3 = array::random(var_3bd46762);
		level thread zm_powerups::specific_powerup_drop(var_3dc91cb3, power_up_origin);
	}
}

/*
	Name: margwa_head_explosion
	Namespace: zm_ai_margwa
	Checksum: 0x3C503D1F
	Offset: 0x2478
	Size: 0xEA
	Parameters: 0
	Flags: Linked, Private
*/
function private margwa_head_explosion()
{
	players = getplayers();
	foreach(player in players)
	{
		distsq = distancesquared(self.origin, player.origin);
		if(distsq < 16384)
		{
			player clientfield::increment_to_player("margwa_head_explosion");
		}
	}
}

/*
	Name: function_8a0708c2
	Namespace: zm_ai_margwa
	Checksum: 0x80B72B0D
	Offset: 0x2570
	Size: 0x2DC
	Parameters: 1
	Flags: Linked
*/
function function_8a0708c2(s_location)
{
	if(isdefined(level.margwa_spawners[0]))
	{
		level.margwa_spawners[0].script_forcespawn = 1;
		ai = zombie_utility::spawn_zombie(level.margwa_spawners[0], "margwa", s_location);
		ai disableaimassist();
		ai.actor_damage_func = &margwaserverutils::margwadamage;
		ai.candamage = 0;
		ai.targetname = "margwa";
		ai.holdfire = 1;
		ai.n_start_health = self.health;
		ai.team = level.zombie_team;
		ai.canstun = 1;
		ai.thundergun_fling_func = &function_7292417a;
		ai.thundergun_knockdown_func = &function_94fd1710;
		ai.var_23340a5d = &function_7292417a;
		ai.var_e1dbd63 = &function_94fd1710;
		e_player = zm_utility::get_closest_player(s_location.origin);
		v_dir = e_player.origin - s_location.origin;
		v_dir = vectornormalize(v_dir);
		v_angles = vectortoangles(v_dir);
		ai forceteleport(s_location.origin, v_angles);
		ai function_551e32b4();
		if(isdefined(level.var_7cef68dc))
		{
			ai thread function_8d578a58();
		}
		ai.ignore_round_robbin_death = 1;
		/#
			ai.ignore_devgui_death = 1;
			ai thread function_618bf323();
		#/
		ai thread function_3d56f587();
		level thread zm_spawner::zombie_death_event(ai);
		return ai;
	}
	return undefined;
}

/*
	Name: function_7292417a
	Namespace: zm_ai_margwa
	Checksum: 0x5E1E5277
	Offset: 0x2858
	Size: 0x58
	Parameters: 2
	Flags: Linked
*/
function function_7292417a(e_player, gib)
{
	self endon("death");
	self function_5ffc5a7b(e_player);
	if(isdefined(self.canstun) && self.canstun)
	{
		self.reactstun = 1;
	}
}

/*
	Name: function_94fd1710
	Namespace: zm_ai_margwa
	Checksum: 0x2D78488D
	Offset: 0x28B8
	Size: 0x60
	Parameters: 2
	Flags: Linked
*/
function function_94fd1710(e_player, gib)
{
	self endon("death");
	self function_5ffc5a7b(e_player, 1);
	if(isdefined(self.canstun) && self.canstun)
	{
		self.reactstun = 1;
	}
}

/*
	Name: function_5ffc5a7b
	Namespace: zm_ai_margwa
	Checksum: 0x1E405C95
	Offset: 0x2920
	Size: 0x1B4
	Parameters: 2
	Flags: Linked
*/
function function_5ffc5a7b(e_player, knockdown = 0)
{
	if(isdefined(self))
	{
		foreach(head in self.head)
		{
			if(head margwaserverutils::margwacandamagehead())
			{
				damage = head.health;
				if(knockdown)
				{
					damage = damage * 0.5;
				}
				head.health = head.health - damage;
				if(isdefined(self.var_5ffc5a7b))
				{
					self [[self.var_5ffc5a7b]](e_player);
				}
				if(head.health <= 0)
				{
					if(self margwaserverutils::margwakillhead(head.model, e_player))
					{
						self.is_kill = 1;
						self kill(self.origin, e_player, e_player, level.weaponzmthundergun);
					}
				}
				return;
			}
		}
	}
}

/*
	Name: function_618bf323
	Namespace: zm_ai_margwa
	Checksum: 0x792CECF0
	Offset: 0x2AE0
	Size: 0x150
	Parameters: 0
	Flags: Linked
*/
function function_618bf323()
{
	self endon("death");
	/#
		while(true)
		{
			if(isdefined(self.debughealth) && self.debughealth)
			{
				if(isdefined(self.head))
				{
					foreach(head in self.head)
					{
						if(head.health > 0)
						{
							head_origin = self gettagorigin(head.tag);
							print3d(head_origin + vectorscale((0, 0, 1), 15), head.health, (0, 0.8, 0.6), 3);
						}
					}
				}
			}
			wait(0.05);
		}
	#/
}

/*
	Name: function_3d56f587
	Namespace: zm_ai_margwa
	Checksum: 0x508025D4
	Offset: 0x2C38
	Size: 0x6C
	Parameters: 0
	Flags: Linked, Private
*/
function private function_3d56f587()
{
	util::wait_network_frame();
	self clientfield::increment("margwa_fx_spawn");
	wait(3);
	self function_26c35525();
	self.candamage = 1;
	self.needspawn = 1;
}

/*
	Name: function_551e32b4
	Namespace: zm_ai_margwa
	Checksum: 0xD191F05F
	Offset: 0x2CB0
	Size: 0x5C
	Parameters: 0
	Flags: Linked, Private
*/
function private function_551e32b4()
{
	self.isfrozen = 1;
	self ghost();
	self notsolid();
	self pathmode("dont move");
}

/*
	Name: function_26c35525
	Namespace: zm_ai_margwa
	Checksum: 0x887D69B3
	Offset: 0x2D18
	Size: 0x5C
	Parameters: 0
	Flags: Linked, Private
*/
function private function_26c35525()
{
	self.isfrozen = 0;
	self show();
	self solid();
	self pathmode("move allowed");
}

/*
	Name: function_8d578a58
	Namespace: zm_ai_margwa
	Checksum: 0x11F3AE35
	Offset: 0x2D80
	Size: 0x124
	Parameters: 0
	Flags: Linked, Private
*/
function private function_8d578a58()
{
	self waittill("death", attacker, mod, weapon);
	foreach(player in level.players)
	{
		if(player.am_i_valid && (!(isdefined(level.var_1f6ca9c8) && level.var_1f6ca9c8)) && (!(isdefined(self.var_2d5d7413) && self.var_2d5d7413)))
		{
			scoreevents::processscoreevent("kill_margwa", player, undefined, undefined);
		}
	}
	level notify(#"hash_1a2d33d7");
	[[level.var_7cef68dc]]();
}

/*
	Name: function_89e37c9b
	Namespace: zm_ai_margwa
	Checksum: 0xBB2F1A44
	Offset: 0x2EB0
	Size: 0x394
	Parameters: 3
	Flags: Linked, Private
*/
function private function_89e37c9b(entity, inflictor, weapon)
{
	if(!(isdefined(entity.candamage) && entity.candamage))
	{
		return false;
	}
	var_ddc770da = [];
	if(isdefined(entity.head))
	{
		foreach(head in entity.head)
		{
			if(head.health > 0 && head.candamage)
			{
				var_ddc770da[var_ddc770da.size] = head;
			}
		}
	}
	if(var_ddc770da.size > 0)
	{
		view_pos = self getweaponmuzzlepoint();
		forward_view_angles = self getweaponforwarddir();
		var_d8748e76 = undefined;
		foreach(head in var_ddc770da)
		{
			head_pos = entity gettagorigin(head.tag);
			var_b01d89e6 = distancesquared(head_pos, view_pos);
			var_ca049230 = vectornormalize(head_pos - view_pos);
			if(!isdefined(var_d8748e76))
			{
				var_d8748e76 = head;
				var_e4facdff = vectordot(forward_view_angles, var_ca049230);
				continue;
			}
			dot = vectordot(forward_view_angles, var_ca049230);
			if(dot > var_e4facdff)
			{
				var_e4facdff = dot;
				var_d8748e76 = head;
			}
		}
		if(isdefined(var_d8748e76))
		{
			var_d8748e76.health = var_d8748e76.health - 1750;
			entity clientfield::increment(var_d8748e76.impactcf);
			if(var_d8748e76.health <= 0)
			{
				if(entity margwaserverutils::margwakillhead(var_d8748e76.model, self))
				{
					entity kill(self.origin, undefined, undefined, weapon);
					return true;
				}
			}
		}
	}
	return false;
}

/*
	Name: function_dbd9ba44
	Namespace: zm_ai_margwa
	Checksum: 0xA43FB472
	Offset: 0x3250
	Size: 0x4C
	Parameters: 2
	Flags: Linked, Private
*/
function private function_dbd9ba44(entity, weapon)
{
	if(isdefined(entity.canstun) && entity.canstun)
	{
		entity.reactstun = 1;
	}
}

/*
	Name: function_aea7f2f4
	Namespace: zm_ai_margwa
	Checksum: 0x65DE3607
	Offset: 0x32A8
	Size: 0x28
	Parameters: 0
	Flags: Private
*/
function private function_aea7f2f4()
{
	if(isdefined(self.canstun) && self.canstun)
	{
		self.reactidgun = 1;
	}
}

/*
	Name: function_2aa0209c
	Namespace: zm_ai_margwa
	Checksum: 0xEEECC064
	Offset: 0x32D8
	Size: 0xDC
	Parameters: 1
	Flags: Linked, Private
*/
function private function_2aa0209c(trap)
{
	if(isdefined(self.isteleporting) && self.isteleporting || (isdefined(self.needteleportout) && self.needteleportout))
	{
		return;
	}
	self.needteleportout = 1;
	pos = self.origin + vectorscale(anglestoforward(self.angles), 200);
	var_47870bac = getclosestpointonnavmesh(pos, 64, 30);
	self.teleportpos = var_47870bac;
	/#
		recordline(self.origin, self.teleportpos);
	#/
}

/*
	Name: margwa_smash_attack
	Namespace: zm_ai_margwa
	Checksum: 0xA97C8922
	Offset: 0x33C0
	Size: 0x12A
	Parameters: 0
	Flags: Linked, Private
*/
function private margwa_smash_attack()
{
	zombies = zombie_utility::get_round_enemy_array();
	foreach(zombie in zombies)
	{
		smashpos = self.origin + vectorscale(anglestoforward(self.angles), 60);
		distsq = distancesquared(smashpos, zombie.origin);
		if(distsq < 20736)
		{
			zombie.knockdown = 1;
			self function_f1358c65(zombie);
		}
	}
}

/*
	Name: function_941cbfc5
	Namespace: zm_ai_margwa
	Checksum: 0x847221CE
	Offset: 0x34F8
	Size: 0x54
	Parameters: 0
	Flags: Linked, Private
*/
function private function_941cbfc5()
{
	r = randomintrange(0, 100);
	if(r < 40)
	{
		self.next_attack = 2;
	}
	else
	{
		self.next_attack = 1;
	}
}

/*
	Name: function_f1358c65
	Namespace: zm_ai_margwa
	Checksum: 0x1B388DD4
	Offset: 0x3558
	Size: 0x27C
	Parameters: 1
	Flags: Linked, Private
*/
function private function_f1358c65(zombie)
{
	var_16ce8ab3 = self.origin - zombie.origin;
	var_e1fcfc7c = vectornormalize((var_16ce8ab3[0], var_16ce8ab3[1], 0));
	zombie_forward = anglestoforward(zombie.angles);
	zombie_forward_2d = vectornormalize((zombie_forward[0], zombie_forward[1], 0));
	zombie_right = anglestoright(zombie.angles);
	zombie_right_2d = vectornormalize((zombie_right[0], zombie_right[1], 0));
	dot = vectordot(var_e1fcfc7c, zombie_forward_2d);
	if(dot >= 0.5)
	{
		zombie.knockdown_direction = "front";
		zombie.getup_direction = "getup_back";
	}
	else
	{
		if(dot < 0.5 && dot > -0.5)
		{
			dot = vectordot(var_e1fcfc7c, zombie_right_2d);
			if(dot > 0)
			{
				zombie.knockdown_direction = "right";
				if(math::cointoss())
				{
					zombie.getup_direction = "getup_back";
				}
				else
				{
					zombie.getup_direction = "getup_belly";
				}
			}
			else
			{
				zombie.knockdown_direction = "left";
				zombie.getup_direction = "getup_belly";
			}
		}
		else
		{
			zombie.knockdown_direction = "back";
			zombie.getup_direction = "getup_belly";
		}
	}
}

/*
	Name: function_cdd8baf7
	Namespace: zm_ai_margwa
	Checksum: 0xD62A50FE
	Offset: 0x37E0
	Size: 0x44
	Parameters: 0
	Flags: Linked, Private
*/
function private function_cdd8baf7()
{
	/#
		level flagsys::wait_till("");
		zm_devgui::add_custom_devgui_callback(&function_a2da506b);
	#/
}

/*
	Name: function_a2da506b
	Namespace: zm_ai_margwa
	Checksum: 0x5D864675
	Offset: 0x3830
	Size: 0x2C6
	Parameters: 1
	Flags: Linked, Private
*/
function private function_a2da506b(cmd)
{
	/#
		players = getplayers();
		var_2c8bf5cd = getentarray("", "");
		margwa = arraygetclosest(getplayers()[0].origin, var_2c8bf5cd);
		switch(cmd)
		{
			case "":
			{
				if(level.margwa_locations.size > 0)
				{
					margwa_location = arraygetclosest(players[0].origin, level.margwa_locations);
				}
				else
				{
					queryresult = positionquery_source_navigation(players[0].origin, 128, 256, 128, 20);
					margwa_location = spawnstruct();
					margwa_location.origin = players[0].origin;
					if(isdefined(queryresult) && queryresult.data.size > 0)
					{
						margwa_location.origin = queryresult.data[0].origin;
					}
				}
				margwa = function_8a0708c2(margwa_location);
				break;
			}
			case "":
			{
				if(isdefined(margwa))
				{
					margwa kill();
				}
				break;
			}
			case "":
			{
				if(isdefined(margwa))
				{
					if(!isdefined(margwa.debughitloc))
					{
						margwa.debughitloc = 1;
					}
					else
					{
						margwa.debughitloc = !margwa.debughitloc;
					}
				}
				break;
			}
			case "":
			{
				if(isdefined(margwa))
				{
					if(!isdefined(margwa.debughealth))
					{
						margwa.debughealth = 1;
					}
					else
					{
						margwa.debughealth = !margwa.debughealth;
					}
				}
				break;
			}
		}
	#/
}

/*
	Name: function_a89905c6
	Namespace: zm_ai_margwa
	Checksum: 0xB9CE3832
	Offset: 0x3B00
	Size: 0xD4
	Parameters: 0
	Flags: Linked, Private
*/
function private function_a89905c6()
{
	/#
		rate = 1;
		if(self.zombie_move_speed == "")
		{
			percent = getdvarint("");
			rate = float(percent / 100);
		}
		else if(self.zombie_move_speed == "")
		{
			percent = getdvarint("");
			rate = float(percent / 100);
		}
		return rate;
	#/
}

