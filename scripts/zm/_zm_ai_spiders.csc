﻿// Decompiled by Serious. Credits to Scoba for his original tool, Cerberus, which I heavily upgraded to support remaining features, other games, and other platforms.
#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\fx_shared;
#using scripts\shared\postfx_shared;
#using scripts\shared\system_shared;
#using scripts\shared\vehicle_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_zm;

#namespace zm_ai_spiders;

/*
	Name: __init__sytem__
	Namespace: zm_ai_spiders
	Checksum: 0x74AC68A9
	Offset: 0x580
	Size: 0x3C
	Parameters: 0
	Flags: AutoExec
*/
function autoexec __init__sytem__()
{
	system::register("zm_ai_spiders", &__init__, &__main__, undefined);
}

/*
	Name: __init__
	Namespace: zm_ai_spiders
	Checksum: 0x9231C098
	Offset: 0x5C8
	Size: 0x164
	Parameters: 0
	Flags: Linked
*/
function __init__()
{
	level._effect["spider_round"] = "dlc2/island/fx_spider_round_tell";
	level._effect["spider_web_grenade_stuck"] = "dlc2/island/fx_web_grenade_tell";
	level._effect["spider_web_bgb_tear"] = "dlc2/island/fx_web_bgb_tearing";
	level._effect["spider_web_bgb_tear_complete"] = "dlc2/island/fx_web_bgb_reveal";
	level._effect["spider_web_perk_machine_tear"] = "dlc2/island/fx_web_perk_machine_tearing";
	level._effect["spider_web_perk_machine_tear_complete"] = "dlc2/island/fx_web_perk_machine_reveal";
	level._effect["spider_web_doorbuy_tear"] = "dlc2/island/fx_web_barrier_tearing";
	level._effect["spider_web_doorbuy_tear_complete"] = "dlc2/island/fx_web_barrier_reveal";
	level._effect["spider_web_tear_explosive"] = "dlc2/island/fx_web_impact_rocket";
	register_clientfields();
	vehicle::add_vehicletype_callback("spider", &spider_init);
	visionset_mgr::register_visionset_info("zm_isl_parasite_spider_visionset", 9000, 16, undefined, "zm_isl_parasite_spider");
}

/*
	Name: __main__
	Namespace: zm_ai_spiders
	Checksum: 0x99EC1590
	Offset: 0x738
	Size: 0x4
	Parameters: 0
	Flags: Linked
*/
function __main__()
{
}

/*
	Name: register_clientfields
	Namespace: zm_ai_spiders
	Checksum: 0xF282ED5A
	Offset: 0x748
	Size: 0x264
	Parameters: 0
	Flags: Linked
*/
function register_clientfields()
{
	clientfield::register("toplayer", "spider_round_fx", 9000, 1, "counter", &spider_round_fx, 0, 0);
	clientfield::register("toplayer", "spider_round_ring_fx", 9000, 1, "counter", &spider_round_ring_fx, 0, 0);
	clientfield::register("toplayer", "spider_end_of_round_reset", 9000, 1, "counter", &spider_end_of_round_reset, 0, 0);
	clientfield::register("scriptmover", "set_fade_material", 9000, 1, "int", &set_fade_material, 0, 0);
	clientfield::register("scriptmover", "web_fade_material", 9000, 3, "float", &web_fade_material, 0, 0);
	clientfield::register("missile", "play_grenade_stuck_in_web_fx", 9000, 1, "int", &play_grenade_stuck_in_web_fx, 0, 0);
	clientfield::register("scriptmover", "play_spider_web_tear_fx", 9000, getminbitcountfornum(4), "int", &play_spider_web_tear_fx, 0, 0);
	clientfield::register("scriptmover", "play_spider_web_tear_complete_fx", 9000, getminbitcountfornum(4), "int", &play_spider_web_tear_complete_fx, 0, 0);
}

/*
	Name: spider_init
	Namespace: zm_ai_spiders
	Checksum: 0x5FC1C07B
	Offset: 0x9B8
	Size: 0x2C
	Parameters: 1
	Flags: Linked
*/
function spider_init(localclientnum)
{
	self.str_tag_tesla_death_fx = "J_SpineUpper";
	self.str_tag_tesla_shock_eyes_fx = "J_SpineUpper";
}

/*
	Name: spider_round_fx
	Namespace: zm_ai_spiders
	Checksum: 0xD917F427
	Offset: 0x9F0
	Size: 0x124
	Parameters: 7
	Flags: Linked
*/
function spider_round_fx(n_local_client, n_val_old, n_val_new, b_ent_new, b_initial_snap, str_field, b_demo_jump)
{
	self endon("disconnect");
	setworldfogactivebank(n_local_client, 8);
	if(isspectating(n_local_client))
	{
		return;
	}
	self.var_d5173f21 = playfxoncamera(n_local_client, level._effect["spider_round"]);
	playsound(0, "zmb_spider_round_webup", (0, 0, 0));
	wait(0.016);
	self thread postfx::playpostfxbundle("pstfx_parasite_spider");
	wait(3.5);
	deletefx(n_local_client, self.var_d5173f21);
}

/*
	Name: spider_end_of_round_reset
	Namespace: zm_ai_spiders
	Checksum: 0x3DBFB6EE
	Offset: 0xB20
	Size: 0x64
	Parameters: 7
	Flags: Linked
*/
function spider_end_of_round_reset(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	if(newval == 1)
	{
		setworldfogactivebank(localclientnum, 1);
	}
}

/*
	Name: spider_round_ring_fx
	Namespace: zm_ai_spiders
	Checksum: 0xA444230F
	Offset: 0xB90
	Size: 0x9C
	Parameters: 7
	Flags: Linked
*/
function spider_round_ring_fx(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	self endon("disconnect");
	if(isspectating(localclientnum))
	{
		return;
	}
	self thread postfx::playpostfxbundle("pstfx_ring_loop");
	wait(1.5);
	self postfx::exitpostfxbundle();
}

/*
	Name: function_bea149a5
	Namespace: zm_ai_spiders
	Checksum: 0xEA21B61B
	Offset: 0xC38
	Size: 0x2D4
	Parameters: 7
	Flags: Linked
*/
function function_bea149a5(localclientnum, var_afc7cc94, var_b05b3457, b_on, n_alpha = 1, b_instant = 0, var_c0ce8db2 = 0)
{
	self endon("entityshutdown");
	if(self.b_on === b_on)
	{
		return;
	}
	self.b_on = b_on;
	if(b_instant)
	{
		if(b_on)
		{
			self transition_shader(localclientnum, n_alpha, var_afc7cc94);
		}
		else
		{
			self transition_shader(localclientnum, 0, var_afc7cc94);
		}
		return;
	}
	if(b_on)
	{
		var_24fbb6c6 = 0;
		i = 0;
		while(var_24fbb6c6 <= n_alpha)
		{
			self transition_shader(localclientnum, var_24fbb6c6, var_afc7cc94);
			if(var_c0ce8db2)
			{
				var_24fbb6c6 = sqrt(i);
			}
			else
			{
				var_24fbb6c6 = i;
			}
			wait(0.01);
			i = i + var_b05b3457;
		}
		self.var_bbfa5d7d = n_alpha;
		self transition_shader(localclientnum, n_alpha, var_afc7cc94);
	}
	else
	{
		if(isdefined(self.var_bbfa5d7d))
		{
			var_bbfa5d7d = self.var_bbfa5d7d;
		}
		else
		{
			var_bbfa5d7d = 1;
		}
		var_24fbb6c6 = var_bbfa5d7d;
		i = var_bbfa5d7d;
		while(var_24fbb6c6 >= 0)
		{
			self transition_shader(localclientnum, var_24fbb6c6, var_afc7cc94);
			if(var_c0ce8db2)
			{
				var_24fbb6c6 = sqrt(i);
			}
			else
			{
				var_24fbb6c6 = i;
			}
			wait(0.01);
			i = i - var_b05b3457;
		}
		self transition_shader(localclientnum, 0, var_afc7cc94);
	}
}

/*
	Name: transition_shader
	Namespace: zm_ai_spiders
	Checksum: 0x2589E5E
	Offset: 0xF18
	Size: 0x54
	Parameters: 3
	Flags: Linked
*/
function transition_shader(localclientnum, n_value, var_afc7cc94)
{
	self mapshaderconstant(localclientnum, 0, "scriptVector" + var_afc7cc94, n_value, n_value, 0, 0);
}

/*
	Name: set_fade_material
	Namespace: zm_ai_spiders
	Checksum: 0xD6855BC2
	Offset: 0xF78
	Size: 0x64
	Parameters: 7
	Flags: Linked
*/
function set_fade_material(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	self mapshaderconstant(localclientnum, 0, "scriptVector0", newval, 0, 0, 0);
}

/*
	Name: web_fade_material
	Namespace: zm_ai_spiders
	Checksum: 0x7168E1F
	Offset: 0xFE8
	Size: 0xB4
	Parameters: 7
	Flags: Linked
*/
function web_fade_material(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	var_f2efc20a = 0;
	if(newval <= 0)
	{
		var_f2efc20a = 0;
		var_32ee3d8b = newval;
	}
	else
	{
		var_f2efc20a = 1;
		var_32ee3d8b = newval;
	}
	self thread function_bea149a5(localclientnum, 0, 0.025, var_f2efc20a, var_32ee3d8b);
}

/*
	Name: play_grenade_stuck_in_web_fx
	Namespace: zm_ai_spiders
	Checksum: 0x735967E2
	Offset: 0x10A8
	Size: 0x74
	Parameters: 7
	Flags: Linked
*/
function play_grenade_stuck_in_web_fx(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	if(isdefined(self))
	{
		playfxontag(localclientnum, level._effect["spider_web_grenade_stuck"], self, "tag_origin");
	}
}

/*
	Name: play_spider_web_tear_fx
	Namespace: zm_ai_spiders
	Checksum: 0xEDEEA937
	Offset: 0x1128
	Size: 0x224
	Parameters: 7
	Flags: Linked
*/
function play_spider_web_tear_fx(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	switch(newval)
	{
		case 0:
		{
			if(isdefined(self) && isdefined(self.var_d5eda36c))
			{
				stopfx(localclientnum, self.var_d5eda36c);
				self.var_d5eda36c = undefined;
			}
			if(isdefined(self) && isdefined(self.var_cac11e11))
			{
				self stoploopsound(self.var_cac11e11, 0.5);
				self playsound(0, "zmb_spider_web_tear_stop");
				self.var_cac11e11 = undefined;
			}
			return;
		}
		case 1:
		{
			str_effect = "spider_web_bgb_tear";
			break;
		}
		case 2:
		{
			str_effect = "spider_web_perk_machine_tear";
			break;
		}
		case 3:
		{
			str_effect = "spider_web_doorbuy_tear";
			break;
		}
		default:
		{
			return;
		}
	}
	if(!isdefined(self.var_cac11e11))
	{
		self.var_cac11e11 = self playloopsound("zmb_spider_web_tear_loop", 1);
		self playsound(0, "zmb_spider_web_tear_start");
	}
	if(!isdefined(self.var_d5eda36c))
	{
		self.var_d5eda36c = playfx(localclientnum, level._effect[str_effect], self.origin, anglestoforward(self.angles), anglestoup(self.angles));
	}
}

/*
	Name: play_spider_web_tear_complete_fx
	Namespace: zm_ai_spiders
	Checksum: 0xBE7A484F
	Offset: 0x1358
	Size: 0x11C
	Parameters: 7
	Flags: Linked
*/
function play_spider_web_tear_complete_fx(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	switch(newval)
	{
		case 1:
		{
			str_effect = "spider_web_bgb_tear_complete";
			break;
		}
		case 2:
		{
			str_effect = "spider_web_perk_machine_tear_complete";
			break;
		}
		case 3:
		{
			str_effect = "spider_web_doorbuy_tear_complete";
			break;
		}
		case 4:
		{
			str_effect = "spider_web_tear_explosive";
			break;
		}
		default:
		{
			return;
		}
	}
	playfx(localclientnum, level._effect[str_effect], self.origin, anglestoforward(self.angles), anglestoup(self.angles));
}

