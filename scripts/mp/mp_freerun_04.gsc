﻿// Decompiled by Serious. Credits to Scoba for his original tool, Cerberus, which I heavily upgraded to support remaining features, other games, and other platforms.
#using scripts\codescripts\struct;
#using scripts\mp\_load;
#using scripts\mp\_util;
#using scripts\mp\mp_freerun_04_fx;
#using scripts\mp\mp_freerun_04_sound;
#using scripts\shared\util_shared;

#namespace mp_freerun_04;

/*
	Name: main
	Namespace: mp_freerun_04
	Checksum: 0x175BF9E0
	Offset: 0x178
	Size: 0xA4
	Parameters: 0
	Flags: Linked
*/
function main()
{
	precache();
	mp_freerun_04_fx::main();
	mp_freerun_04_sound::main();
	load::main();
	setdvar("glassMinVelocityToBreakFromJump", "380");
	setdvar("glassMinVelocityToBreakFromWallRun", "180");
	setdvar("compassmaxrange", "2100");
}

/*
	Name: precache
	Namespace: mp_freerun_04
	Checksum: 0x99EC1590
	Offset: 0x228
	Size: 0x4
	Parameters: 0
	Flags: Linked
*/
function precache()
{
}

