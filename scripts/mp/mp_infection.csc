﻿// Decompiled by Serious. Credits to Scoba for his original tool, Cerberus, which I heavily upgraded to support remaining features, other games, and other platforms.
#using scripts\codescripts\struct;
#using scripts\mp\_load;
#using scripts\mp\_util;
#using scripts\mp\mp_infection_fx;
#using scripts\mp\mp_infection_sound;
#using scripts\shared\util_shared;

#namespace mp_infection;

/*
	Name: main
	Namespace: mp_infection
	Checksum: 0x1BEE8B2B
	Offset: 0x138
	Size: 0x5C
	Parameters: 0
	Flags: Linked
*/
function main()
{
	mp_infection_fx::main();
	mp_infection_sound::main();
	load::main();
	util::waitforclient(0);
	level.endgamexcamname = "ui_cam_endgame_mp_infection";
}

