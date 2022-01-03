#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_hud_util;

#include scripts/zm/replaced/_zm;
#include scripts/zm/replaced/_zm_playerhealth;
#include scripts/zm/replaced/_zm_utility;
#include scripts/zm/replaced/_zm_weapons;
#include scripts/zm/replaced/_zm_magicbox;
#include scripts/zm/replaced/_zm_powerups;
#include scripts/zm/replaced/_zm_equipment;
#include scripts/zm/replaced/_zm_ai_basic;

main()
{
	replaceFunc(maps/mp/zombies/_zm::check_quickrevive_for_hotjoin, scripts/zm/replaced/_zm::check_quickrevive_for_hotjoin);
	replaceFunc(maps/mp/zombies/_zm::actor_damage_override, scripts/zm/replaced/_zm::actor_damage_override);
	replaceFunc(maps/mp/zombies/_zm::end_game, scripts/zm/replaced/_zm::end_game);
	replaceFunc(maps/mp/zombies/_zm_playerhealth::playerhealthregen, scripts/zm/replaced/_zm_playerhealth::playerhealthregen);
	replaceFunc(maps/mp/zombies/_zm_utility::track_players_intersection_tracker, scripts/zm/replaced/_zm_utility::track_players_intersection_tracker);
	replaceFunc(maps/mp/zombies/_zm_utility::is_headshot, scripts/zm/replaced/_zm_utility::is_headshot);
	replaceFunc(maps/mp/zombies/_zm_weapons::get_upgraded_ammo_cost, scripts/zm/replaced/_zm_weapons::get_upgraded_ammo_cost);
	replaceFunc(maps/mp/zombies/_zm_weapons::makegrenadedudanddestroy, scripts/zm/replaced/_zm_weapons::makegrenadedudanddestroy);
	replaceFunc(maps/mp/zombies/_zm_magicbox::treasure_chest_move, scripts/zm/replaced/_zm_magicbox::treasure_chest_move);
	replaceFunc(maps/mp/zombies/_zm_magicbox::treasure_chest_timeout, scripts/zm/replaced/_zm_magicbox::treasure_chest_timeout);
	replaceFunc(maps/mp/zombies/_zm_magicbox::timer_til_despawn, scripts/zm/replaced/_zm_magicbox::timer_til_despawn);
	replaceFunc(maps/mp/zombies/_zm_powerups::nuke_powerup, scripts/zm/replaced/_zm_powerups::nuke_powerup);
	replaceFunc(maps/mp/zombies/_zm_equipment::show_equipment_hint, scripts/zm/replaced/_zm_equipment::show_equipment_hint);
	replaceFunc(maps/mp/zombies/_zm_equipment::placed_equipment_think, scripts/zm/replaced/_zm_equipment::placed_equipment_think);
	replaceFunc(maps/mp/zombies/_zm_ai_basic::inert_wakeup, scripts/zm/replaced/_zm_ai_basic::inert_wakeup);
}

init()
{
	level.using_solo_revive = 0;

	setscoreboardcolumns_gametype();
	set_lethal_grenade_init();

	prison_plane_set_need_all_pieces();
	prison_plane_set_pieces_shared();

	level thread onplayerconnect();
	level thread post_all_players_spawned();

	level thread enemy_counter_hud();
	level thread timer_hud();
}

onplayerconnect()
{
	while(true)
	{
		level waittill("connecting", player);
		player thread onplayerspawned();
		player thread onplayerdowned();
	}
}

onplayerspawned()
{
	level endon( "game_ended" );
	self endon( "disconnect" );

	self.initial_spawn = true;

	for(;;)
	{
		self waittill( "spawned_player" );

		if (self.initial_spawn)
		{
			self.initial_spawn = false;

			self.screecher_seen_hint = 1;

			self bank_clear_account_value();
			self weapon_locker_clear_stored_weapondata();

			self tomb_give_shovel();

			self thread health_bar_hud();
			self thread zone_hud();

			self thread fall_velocity_check();

			//self thread remove_fast_melee(); // Removed until melee weapon can be added

			self thread solo_lives_fix();

			self thread give_additional_perks();

			self thread buildable_piece_remove_on_last_stand();

			self thread disable_player_pers_upgrades();

			//self thread disable_sniper_scope_sway(); // Buried does not load the clientfield

			self thread war_machine_explode_on_impact();

			self thread jetgun_fast_cooldown();
			self thread jetgun_fast_spinlerp();
			self thread jetgun_overheated_fix();

			self thread additionalprimaryweapon_save_weapons();
			self thread additionalprimaryweapon_restore_weapons();
			self thread additionalprimaryweapon_indicator();

			self thread tombstone_save_perks();
			self thread tombstone_restore_perks();

			self thread whos_who_spawn_changes();

			self thread electric_cherry_unlimited();

			self thread vulture_disable_stink_while_standing();

			//self thread test();

			//self.score = 1000000;
			//maps/mp/zombies/_zm_perks::give_perk( "specialty_armorvest", 0 );
			//self GiveWeapon("dsr50_zm");
			//self GiveMaxAmmo("dsr50_zm");
		}

		self set_dvars();
		self set_perks();
	}
}

onplayerdowned()
{
	level endon( "game_ended" );
	self endon( "disconnect" );

	while(1)
	{
		self waittill( "entering_last_stand" );

		self.health = self.maxhealth;
	}
}

post_all_players_spawned()
{
	flag_wait( "start_zombie_round_logic" );

	wait 0.05;

	maps/mp/zombies/_zm::register_player_damage_callback( ::player_damage_override );

	level.near_miss = 2; // makes screecher not run away first time on solo
	level.magicbox_timeout = 9;
	level.packapunch_timeout = 12;
	level.equipment_etrap_needs_power = 0;
	level.equipment_turret_needs_power = 0;
	level.equipment_subwoofer_needs_power = 0;
	level.limited_weapons["ray_gun_zm"] = undefined;
	level.zombie_vars["emp_stun_range"] = 420;
	level.zombie_vars["emp_perk_off_time"] = 60;
	level.zombie_vars["slipgun_reslip_rate"] = 0;
	level.zombie_equipment["jetgun_zm"].drop_fn = undefined;
	level.explode_overheated_jetgun = 0;
	level.unbuild_overheated_jetgun = 0;
	level.take_overheated_jetgun = 1;
	level.speed_change_round = undefined;
	level.playersuicideallowed = undefined;
	level.disable_free_perks_before_power = undefined;
	level.custom_random_perk_weights = undefined;
	level.etrap_damage = maps/mp/zombies/_zm::ai_zombie_health( 255 );
	level.slipgun_damage = maps/mp/zombies/_zm::ai_zombie_health( 255 );
	level.tombstone_spawn_func = ::tombstone_spawn;
	level.zombie_last_stand = ::last_stand_pistol_swap;
	level.zombie_last_stand_ammo_return = ::last_stand_restore_pistol_ammo;

	disable_perk_pause();

	disable_carpenter();

	disable_bank();

	wallbuy_increase_trigger_radius();
	wallbuy_decrease_upgraded_ammo_cost();
	wallbuy_location_changes();

	zone_changes();

	screecher_spawner_changes();

	jetgun_remove_forced_weapon_switch();

    town_move_quickrevive_machine();
	town_move_staminup_machine();

	prison_remove_acid_trap_player_spawn();
	prison_tower_trap_changes();

	buried_turn_power_on();
	buried_deleteslothbarricades();

	tomb_challenges_changes();
	tomb_soul_box_changes();

	level thread wallbuy_cost_changes();

	level thread buildbuildables();
	level thread buildcraftables();

	level thread disable_pers_upgrades();

	level thread zombie_health_fix();

	level thread solo_revive_trigger_fix();

	level thread transit_add_tombstone_machine_solo();
	level thread transit_power_local_electric_doors_globally();
	level thread transit_b23r_hint_string_fix();

	level thread town_move_tombstone_machine();

	level thread highrise_solo_revive_fix();

	level thread prison_plane_auto_refuel();

	level thread buried_enable_fountain_transport();
	level thread buried_disable_ghost_free_perk_on_damage();

	level thread wallbuy_dynamic_update();

	level thread tomb_increase_solo_door_prices();
	level thread tomb_remove_shovels_from_map();
	level thread tomb_zombie_blood_dig_changes();

	//level.round_number = 115;
	//level.zombie_move_speed = 105;
	//level.zombie_vars[ "zombie_spawn_delay" ] = 0.08;

	//level.local_doors_stay_open = 1;
	//level.power_local_doors_globally = 1;
}

set_dvars()
{
	self setClientDvar( "player_backSpeedScale", 1 );
	self setClientDvar( "player_strafeSpeedScale", 1 );
	self setClientDvar( "player_sprintStrafeSpeedScale", 1 );

	self setClientDvar( "dtp_post_move_pause", 0 );
	self setClientDvar( "dtp_exhaustion_window", 100 );
	self setClientDvar( "dtp_startup_delay", 100 );

	self setClientDvar( "cg_friendlyNameFadeIn", 0 );
	self setClientDvar( "cg_friendlyNameFadeOut", 250 );
	self setClientDvar( "cg_enemyNameFadeIn", 0 );
	self setClientDvar( "cg_enemyNameFadeOut", 250 );

	self setClientDvar( "player_meleeRange", 64 );
	self setClientDvar( "aim_automelee_enabled", 0 );

	self setClientDvar( "g_friendlyfireDist", 0 );

	self setClientDvar( "r_lodBiasRigid", -1000 );
	self setClientDvar( "r_lodBiasSkinned", -1000 );
}

set_perks()
{
	self setperk( "specialty_unlimitedsprint" );
	self setperk( "specialty_fastmantle" );
}

health_bar_hud()
{
	self endon("disconnect");

	flag_wait( "initial_blackscreen_passed" );

	x = -364;
	y = -70;
	if (level.script == "zm_buried")
	{
		y -= 25;
	}
	else if (level.script == "zm_tomb")
	{
		y -= 60;
	}

	health_bar = self createbar((1, 1, 1), 110, 14);
	health_bar setpoint(undefined, "BOTTOM", x, y);
	health_bar.hidewheninmenu = 1;
	health_bar.bar.hidewheninmenu = 1;
	health_bar.barframe.hidewheninmenu = 1;

	health_bar_text = createfontstring("objective", 1.4);
	health_bar_text setpoint("LEFT", "BOTTOM", x + 60, y);
	health_bar_text.hidewheninmenu = 1;

	while (1)
	{
		if (isDefined(self.e_afterlife_corpse))
		{
			if (health_bar.alpha != 0)
			{
				health_bar.alpha = 0;
				health_bar.bar.alpha = 0;
				health_bar.barframe.alpha = 0;
				health_bar_text.alpha = 0;
			}

			wait 0.05;
			continue;
		}

		if (health_bar.alpha != 1)
		{
			health_bar.alpha = 1;
			health_bar.bar.alpha = 1;
			health_bar.barframe.alpha = 1;
			health_bar_text.alpha = 1;
		}

		health_bar updatebar(self.health / self.maxhealth);
		health_bar_text setvalue(self.health);

		wait 0.05;
	}
}

enemy_counter_hud()
{
	if ( getDvar( "g_gametype" ) == "zgrief" )
	{
		return;
	}

	enemy_counter_hud = newHudElem();
	enemy_counter_hud.alignx = "left";
	enemy_counter_hud.aligny = "top";
	enemy_counter_hud.horzalign = "user_left";
	enemy_counter_hud.vertalign = "user_top";
	enemy_counter_hud.x += 5;
	if (level.script == "zm_tomb")
	{
		enemy_counter_hud.y += 49;
	}
	else
	{
		enemy_counter_hud.y += 2;
	}
	enemy_counter_hud.fontscale = 1.4;
	enemy_counter_hud.alpha = 0;
	enemy_counter_hud.color = ( 1, 1, 1 );
	enemy_counter_hud.hidewheninmenu = 1;
	enemy_counter_hud.label = &"Enemies Remaining: ";

	flag_wait( "initial_blackscreen_passed" );

	enemy_counter_hud.alpha = 1;
	while (1)
	{
		enemies = get_round_enemy_array().size + level.zombie_total;

		if (enemies == 0)
		{
			enemy_counter_hud setText("");
		}
		else
		{
			enemy_counter_hud setValue(enemies);
		}

		wait 0.05;
	}
}

timer_hud()
{

	level thread round_timer_hud();

	timer_hud = newHudElem();
	timer_hud.alignx = "right";
	timer_hud.aligny = "top";
	timer_hud.horzalign = "user_right";
	timer_hud.vertalign = "user_top";
	timer_hud.x -= 5;
	timer_hud.y += 12;
	timer_hud.fontscale = 1.4;
	timer_hud.alpha = 0;
	timer_hud.color = ( 1, 1, 1 );
	timer_hud.hidewheninmenu = 1;
	timer_hud.label = &"Total: ";

	level thread set_time_frozen_on_end_game(timer_hud);

	flag_wait( "initial_blackscreen_passed" );

	timer_hud.alpha = 1;

	if ( getDvar( "g_gametype" ) == "zgrief" )
	{
		set_time_frozen(timer_hud, 0);
	}

	timer_hud setTimerUp(0);
	timer_hud.start_time = int(getTime() / 1000);
}

round_timer_hud()
{
	round_timer_hud = newHudElem();
	round_timer_hud.alignx = "right";
	round_timer_hud.aligny = "top";
	round_timer_hud.horzalign = "user_right";
	round_timer_hud.vertalign = "user_top";
	round_timer_hud.x -= 5;
	round_timer_hud.y += 27;
	round_timer_hud.fontscale = 1.4;
	round_timer_hud.alpha = 0;
	round_timer_hud.color = ( 1, 1, 1 );
	round_timer_hud.hidewheninmenu = 1;
	round_timer_hud.label = &"Round: ";

	level thread set_time_frozen_on_end_game(round_timer_hud);

	flag_wait( "initial_blackscreen_passed" );

	round_timer_hud.alpha = 1;

	if ( getDvar( "g_gametype" ) == "zgrief" )
	{
		set_time_frozen(round_timer_hud, 0);
	}

	while (1)
	{
		round_timer_hud setTimerUp(0);
		round_timer_hud.start_time = int(getTime() / 1000);
		round_timer_hud.end_time = undefined;

		if ( getDvar( "g_gametype" ) == "zgrief" )
		{
			level waittill( "restart_round" );
		}
		else
		{
			level waittill( "end_of_round" );
		}

		round_timer_hud.end_time = int(getTime() / 1000);
		time = round_timer_hud.end_time - round_timer_hud.start_time;

		set_time_frozen(round_timer_hud, time);
	}
}

set_time_frozen_on_end_game(hud)
{
	level waittill("end_game");

	if(!isDefined(hud.end_time))
	{
		hud.end_time = int(getTime() / 1000);
	}

	time = hud.end_time - hud.start_time;

	set_time_frozen(hud, time);
}

set_time_frozen(hud, time)
{
	if ( getDvar( "g_gametype" ) == "zgrief" )
	{
		level endon( "restart_round_start" );
	}
	else
	{
		level endon( "start_of_round" );
	}

	if(time != 0)
	{
		time -= .1; // need to set it below the number or it shows the next number
	}

	while (1)
	{
		if(time == 0)
		{
			hud setTimerUp(time);
		}
		else
		{
			hud setTimer(time);
		}

		wait 0.5;
	}
}

zone_hud()
{
	self endon("disconnect");

	x = 5;
	y = -115;
	if (level.script == "zm_buried")
	{
		y -= 25;
	}
	else if (level.script == "zm_tomb")
	{
		y -= 60;
	}

	zone_hud = newClientHudElem(self);
	zone_hud.alignx = "left";
	zone_hud.aligny = "bottom";
	zone_hud.horzalign = "user_left";
	zone_hud.vertalign = "user_bottom";
	zone_hud.x += x;
	zone_hud.y += y;
	zone_hud.fontscale = 1.4;
	zone_hud.alpha = 0;
	zone_hud.color = ( 1, 1, 1 );
	zone_hud.hidewheninmenu = 1;

	flag_wait( "initial_blackscreen_passed" );

	prev_zone = "";
	while (1)
	{
		zone = self get_zone_name();

		if(prev_zone != zone)
		{
			prev_zone = zone;

			zone_hud fadeovertime(0.25);
			zone_hud.alpha = 0;
			wait 0.25;

			zone_hud settext(zone);

			zone_hud fadeovertime(0.25);
			zone_hud.alpha = 1;
			wait 0.25;

			continue;
		}

		wait 0.05;
	}
}

get_zone_name()
{
	zone = self get_current_zone();
	if (!isDefined(zone))
	{
		return "";
	}

	name = zone;

	if (level.script == "zm_transit")
	{
		if (zone == "zone_pri")
		{
			name = "Bus Depot";
		}
		else if (zone == "zone_pri2")
		{
			name = "Bus Depot Hallway";
		}
		else if (zone == "zone_station_ext")
		{
			name = "Outside Bus Depot";
		}
		else if (zone == "zone_trans_2b")
		{
			name = "Fog After Bus Depot";
		}
		else if (zone == "zone_trans_2")
		{
			name = "Tunnel Entrance";
		}
		else if (zone == "zone_amb_tunnel")
		{
			name = "Tunnel";
		}
		else if (zone == "zone_trans_3")
		{
			name = "Tunnel Exit";
		}
		else if (zone == "zone_roadside_west")
		{
			name = "Outside Diner";
		}
		else if (zone == "zone_gas")
		{
			name = "Gas Station";
		}
		else if (zone == "zone_roadside_east")
		{
			name = "Outside Garage";
		}
		else if (zone == "zone_trans_diner")
		{
			name = "Fog Outside Diner";
		}
		else if (zone == "zone_trans_diner2")
		{
			name = "Fog Outside Garage";
		}
		else if (zone == "zone_gar")
		{
			name = "Garage";
		}
		else if (zone == "zone_din")
		{
			name = "Diner";
		}
		else if (zone == "zone_diner_roof")
		{
			name = "Diner Roof";
		}
		else if (zone == "zone_trans_4")
		{
			name = "Fog After Diner";
		}
		else if (zone == "zone_amb_forest")
		{
			name = "Forest";
		}
		else if (zone == "zone_trans_10")
		{
			name = "Outside Church";
		}
		else if (zone == "zone_town_church")
		{
			name = "Upper South Town";
		}
		else if (zone == "zone_trans_5")
		{
			name = "Fog Before Farm";
		}
		else if (zone == "zone_far")
		{
			name = "Outside Farm";
		}
		else if (zone == "zone_far_ext")
		{
			name = "Farm";
		}
		else if (zone == "zone_brn")
		{
			name = "Barn";
		}
		else if (zone == "zone_farm_house")
		{
			name = "Farmhouse";
		}
		else if (zone == "zone_trans_6")
		{
			name = "Fog After Farm";
		}
		else if (zone == "zone_amb_cornfield")
		{
			name = "Cornfield";
		}
		else if (zone == "zone_cornfield_prototype")
		{
			name = "Nacht";
		}
		else if (zone == "zone_trans_7")
		{
			name = "Upper Fog Before Power";
		}
		else if (zone == "zone_trans_pow_ext1")
		{
			name = "Fog Before Power";
		}
		else if (zone == "zone_pow")
		{
			name = "Outside Power Station";
		}
		else if (zone == "zone_prr")
		{
			name = "Power Station";
		}
		else if (zone == "zone_pcr")
		{
			name = "Power Control Room";
		}
		else if (zone == "zone_pow_warehouse")
		{
			name = "Warehouse";
		}
		else if (zone == "zone_trans_8")
		{
			name = "Fog After Power";
		}
		else if (zone == "zone_amb_power2town")
		{
			name = "Cabin";
		}
		else if (zone == "zone_trans_9")
		{
			name = "Fog Before Town";
		}
		else if (zone == "zone_town_north")
		{
			name = "North Town";
		}
		else if (zone == "zone_tow")
		{
			name = "Center Town";
		}
		else if (zone == "zone_town_east")
		{
			name = "East Town";
		}
		else if (zone == "zone_town_west")
		{
			name = "West Town";
		}
		else if (zone == "zone_town_south")
		{
			name = "South Town";
		}
		else if (zone == "zone_bar")
		{
			name = "Bar";
		}
		else if (zone == "zone_town_barber")
		{
			name = "Bookstore";
		}
		else if (zone == "zone_ban")
		{
			name = "Bank";
		}
		else if (zone == "zone_ban_vault")
		{
			name = "Bank Vault";
		}
		else if (zone == "zone_tbu")
		{
			name = "Below Bank";
		}
		else if (zone == "zone_trans_11")
		{
			name = "Fog After Town";
		}
		else if (zone == "zone_amb_bridge")
		{
			name = "Bridge";
		}
		else if (zone == "zone_trans_1")
		{
			name = "Fog Before Bus Depot";
		}
	}
	else if (level.script == "zm_nuked")
	{
		if (zone == "culdesac_yellow_zone")
		{
			name = "Yellow House Cul-de-sac";
		}
		else if (zone == "culdesac_green_zone")
		{
			name = "Green House Cul-de-sac";
		}
		else if (zone == "truck_zone")
		{
			name = "Truck";
		}
		else if (zone == "openhouse1_f1_zone")
		{
			name = "Green House Downstairs";
		}
		else if (zone == "openhouse1_f2_zone")
		{
			name = "Green House Upstairs";
		}
		else if (zone == "openhouse1_backyard_zone")
		{
			name = "Green House Backyard";
		}
		else if (zone == "openhouse2_f1_zone")
		{
			name = "Yellow House Downstairs";
		}
		else if (zone == "openhouse2_f2_zone")
		{
			name = "Yellow House Upstairs";
		}
		else if (zone == "openhouse2_backyard_zone")
		{
			name = "Yellow House Backyard";
		}
		else if (zone == "ammo_door_zone")
		{
			name = "Yellow House Backyard Door";
		}
	}
	else if (level.script == "zm_highrise")
	{
		if (zone == "zone_green_start")
		{
			name = "Green Highrise Level 3b";
		}
		else if (zone == "zone_green_escape_pod")
		{
			name = "Escape Pod";
		}
		else if (zone == "zone_green_escape_pod_ground")
		{
			name = "Escape Pod Shaft";
		}
		else if (zone == "zone_green_level1")
		{
			name = "Green Highrise Level 3a";
		}
		else if (zone == "zone_green_level2a")
		{
			name = "Green Highrise Level 2a";
		}
		else if (zone == "zone_green_level2b")
		{
			name = "Green Highrise Level 2b";
		}
		else if (zone == "zone_green_level3a")
		{
			name = "Green Highrise Restaurant";
		}
		else if (zone == "zone_green_level3b")
		{
			name = "Green Highrise Level 1a";
		}
		else if (zone == "zone_green_level3c")
		{
			name = "Green Highrise Level 1b";
		}
		else if (zone == "zone_green_level3d")
		{
			name = "Green Highrise Behind Restaurant";
		}
		else if (zone == "zone_orange_level1")
		{
			name = "Upper Orange Highrise Level 2";
		}
		else if (zone == "zone_orange_level2")
		{
			name = "Upper Orange Highrise Level 1";
		}
		else if (zone == "zone_orange_elevator_shaft_top")
		{
			name = "Elevator Shaft Level 3";
		}
		else if (zone == "zone_orange_elevator_shaft_middle_1")
		{
			name = "Elevator Shaft Level 2";
		}
		else if (zone == "zone_orange_elevator_shaft_middle_2")
		{
			name = "Elevator Shaft Level 1";
		}
		else if (zone == "zone_orange_elevator_shaft_bottom")
		{
			name = "Elevator Shaft Bottom";
		}
		else if (zone == "zone_orange_level3a")
		{
			name = "Lower Orange Highrise Level 1a";
		}
		else if (zone == "zone_orange_level3b")
		{
			name = "Lower Orange Highrise Level 1b";
		}
		else if (zone == "zone_blue_level5")
		{
			name = "Lower Blue Highrise Level 1";
		}
		else if (zone == "zone_blue_level4a")
		{
			name = "Lower Blue Highrise Level 2a";
		}
		else if (zone == "zone_blue_level4b")
		{
			name = "Lower Blue Highrise Level 2b";
		}
		else if (zone == "zone_blue_level4c")
		{
			name = "Lower Blue Highrise Level 2c";
		}
		else if (zone == "zone_blue_level2a")
		{
			name = "Upper Blue Highrise Level 1a";
		}
		else if (zone == "zone_blue_level2b")
		{
			name = "Upper Blue Highrise Level 1b";
		}
		else if (zone == "zone_blue_level2c")
		{
			name = "Upper Blue Highrise Level 1c";
		}
		else if (zone == "zone_blue_level2d")
		{
			name = "Upper Blue Highrise Level 1d";
		}
		else if (zone == "zone_blue_level1a")
		{
			name = "Upper Blue Highrise Level 2a";
		}
		else if (zone == "zone_blue_level1b")
		{
			name = "Upper Blue Highrise Level 2b";
		}
		else if (zone == "zone_blue_level1c")
		{
			name = "Upper Blue Highrise Level 2c";
		}
	}
	else if (level.script == "zm_prison")
	{
		if (zone == "zone_start")
		{
			name = "D-Block";
		}
		else if (zone == "zone_library")
		{
			name = "Library";
		}
		else if (zone == "zone_cellblock_west")
		{
			name = "Cellblock 2nd Floor";
		}
		else if (zone == "zone_cellblock_west_gondola")
		{
			name = "Cellblock 3rd Floor";
		}
		else if (zone == "zone_cellblock_west_gondola_dock")
		{
			name = "Cellblock Gondola";
		}
		else if (zone == "zone_cellblock_west_barber")
		{
			name = "Michigan Avenue";
		}
		else if (zone == "zone_cellblock_east")
		{
			name = "Times Square";
		}
		else if (zone == "zone_cafeteria")
		{
			name = "Cafeteria";
		}
		else if (zone == "zone_cafeteria_end")
		{
			name = "Cafeteria End";
		}
		else if (zone == "zone_infirmary")
		{
			name = "Infirmary 1";
		}
		else if (zone == "zone_infirmary_roof")
		{
			name = "Infirmary 2";
		}
		else if (zone == "zone_roof_infirmary")
		{
			name = "Roof 1";
		}
		else if (zone == "zone_roof")
		{
			name = "Roof 2";
		}
		else if (zone == "zone_cellblock_west_warden")
		{
			name = "Sally Port";
		}
		else if (zone == "zone_warden_office")
		{
			name = "Warden's Office";
		}
		else if (zone == "cellblock_shower")
		{
			name = "Showers";
		}
		else if (zone == "zone_citadel_shower")
		{
			name = "Citadel To Showers";
		}
		else if (zone == "zone_citadel")
		{
			name = "Citadel";
		}
		else if (zone == "zone_citadel_warden")
		{
			name = "Citadel To Warden's Office";
		}
		else if (zone == "zone_citadel_stairs")
		{
			name = "Citadel Tunnels";
		}
		else if (zone == "zone_citadel_basement")
		{
			name = "Citadel Basement";
		}
		else if (zone == "zone_citadel_basement_building")
		{
			name = "China Alley";
		}
		else if (zone == "zone_studio")
		{
			name = "Building 64";
		}
		else if (zone == "zone_dock")
		{
			name = "Docks";
		}
		else if (zone == "zone_dock_puzzle")
		{
			name = "Docks Gates";
		}
		else if (zone == "zone_dock_gondola")
		{
			name = "Upper Docks";
		}
		else if (zone == "zone_golden_gate_bridge")
		{
			name = "Golden Gate Bridge";
		}
		else if (zone == "zone_gondola_ride")
		{
			name = "Gondola";
		}
	}
	else if (level.script == "zm_buried")
	{
		if (zone == "zone_start")
		{
			name = "Processing";
		}
		else if (zone == "zone_start_lower")
		{
			name = "Lower Processing";
		}
		else if (zone == "zone_tunnels_center")
		{
			name = "Center Tunnels";
		}
		else if (zone == "zone_tunnels_north")
		{
			name = "Courthouse Tunnels 2";
		}
		else if (zone == "zone_tunnels_north2")
		{
			name = "Courthouse Tunnels 1";
		}
		else if (zone == "zone_tunnels_south")
		{
			name = "Saloon Tunnels 3";
		}
		else if (zone == "zone_tunnels_south2")
		{
			name = "Saloon Tunnels 2";
		}
		else if (zone == "zone_tunnels_south3")
		{
			name = "Saloon Tunnels 1";
		}
		else if (zone == "zone_street_lightwest")
		{
			name = "Outside General Store & Bank";
		}
		else if (zone == "zone_street_lightwest_alley")
		{
			name = "Outside General Store & Bank Alley";
		}
		else if (zone == "zone_morgue_upstairs")
		{
			name = "Morgue";
		}
		else if (zone == "zone_underground_jail")
		{
			name = "Jail Downstairs";
		}
		else if (zone == "zone_underground_jail2")
		{
			name = "Jail Upstairs";
		}
		else if (zone == "zone_general_store")
		{
			name = "General Store";
		}
		else if (zone == "zone_stables")
		{
			name = "Stables";
		}
		else if (zone == "zone_street_darkwest")
		{
			name = "Outside Gunsmith";
		}
		else if (zone == "zone_street_darkwest_nook")
		{
			name = "Outside Gunsmith Nook";
		}
		else if (zone == "zone_gun_store")
		{
			name = "Gunsmith";
		}
		else if (zone == "zone_bank")
		{
			name = "Bank";
		}
		else if (zone == "zone_tunnel_gun2stables")
		{
			name = "Stables To Gunsmith Tunnel 2";
		}
		else if (zone == "zone_tunnel_gun2stables2")
		{
			name = "Stables To Gunsmith Tunnel";
		}
		else if (zone == "zone_street_darkeast")
		{
			name = "Outside Saloon & Toy Store";
		}
		else if (zone == "zone_street_darkeast_nook")
		{
			name = "Outside Saloon & Toy Store Nook";
		}
		else if (zone == "zone_underground_bar")
		{
			name = "Saloon";
		}
		else if (zone == "zone_tunnel_gun2saloon")
		{
			name = "Saloon To Gunsmith Tunnel";
		}
		else if (zone == "zone_toy_store")
		{
			name = "Toy Store Downstairs";
		}
		else if (zone == "zone_toy_store_floor2")
		{
			name = "Toy Store Upstairs";
		}
		else if (zone == "zone_toy_store_tunnel")
		{
			name = "Toy Store Tunnel";
		}
		else if (zone == "zone_candy_store")
		{
			name = "Candy Store Downstairs";
		}
		else if (zone == "zone_candy_store_floor2")
		{
			name = "Candy Store Upstairs";
		}
		else if (zone == "zone_street_lighteast")
		{
			name = "Outside Courthouse & Candy Store";
		}
		else if (zone == "zone_underground_courthouse")
		{
			name = "Courthouse Downstairs";
		}
		else if (zone == "zone_underground_courthouse2")
		{
			name = "Courthouse Upstairs";
		}
		else if (zone == "zone_street_fountain")
		{
			name = "Fountain";
		}
		else if (zone == "zone_church_graveyard")
		{
			name = "Graveyard";
		}
		else if (zone == "zone_church_main")
		{
			name = "Church Downstairs";
		}
		else if (zone == "zone_church_upstairs")
		{
			name = "Church Upstairs";
		}
		else if (zone == "zone_mansion_lawn")
		{
			name = "Mansion Lawn";
		}
		else if (zone == "zone_mansion")
		{
			name = "Mansion";
		}
		else if (zone == "zone_mansion_backyard")
		{
			name = "Mansion Backyard";
		}
		else if (zone == "zone_maze")
		{
			name = "Maze";
		}
		else if (zone == "zone_maze_staircase")
		{
			name = "Maze Staircase";
		}
	}
	else if (level.script == "zm_tomb")
	{
		if (isDefined(self.teleporting) && self.teleporting)
		{
			return "";
		}

		if (zone == "zone_start")
		{
			name = "Lower Laboratory";
		}
		else if (zone == "zone_start_a")
		{
			name = "Upper Laboratory";
		}
		else if (zone == "zone_start_b")
		{
			name = "Generator 1";
		}
		else if (zone == "zone_bunker_1a")
		{
			name = "Generator 3 Bunker 1";
		}
		else if (zone == "zone_fire_stairs")
		{
			name = "Fire Tunnel";
		}
		else if (zone == "zone_bunker_1")
		{
			name = "Generator 3 Bunker 2";
		}
		else if (zone == "zone_bunker_3a")
		{
			name = "Generator 3";
		}
		else if (zone == "zone_bunker_3b")
		{
			name = "Generator 3 Bunker 3";
		}
		else if (zone == "zone_bunker_2a")
		{
			name = "Generator 2 Bunker 1";
		}
		else if (zone == "zone_bunker_2")
		{
			name = "Generator 2 Bunker 2";
		}
		else if (zone == "zone_bunker_4a")
		{
			name = "Generator 2";
		}
		else if (zone == "zone_bunker_4b")
		{
			name = "Generator 2 Bunker 3";
		}
		else if (zone == "zone_bunker_4c")
		{
			name = "Tank Station";
		}
		else if (zone == "zone_bunker_4d")
		{
			name = "Above Tank Station";
		}
		else if (zone == "zone_bunker_tank_c")
		{
			name = "Generator 2 Tank Route 1";
		}
		else if (zone == "zone_bunker_tank_c1")
		{
			name = "Generator 2 Tank Route 2";
		}
		else if (zone == "zone_bunker_4e")
		{
			name = "Generator 2 Tank Route 3";
		}
		else if (zone == "zone_bunker_tank_d")
		{
			name = "Generator 2 Tank Route 4";
		}
		else if (zone == "zone_bunker_tank_d1")
		{
			name = "Generator 2 Tank Route 5";
		}
		else if (zone == "zone_bunker_4f")
		{
			name = "zone_bunker_4f";
		}
		else if (zone == "zone_bunker_5a")
		{
			name = "Workshop Downstairs";
		}
		else if (zone == "zone_bunker_5b")
		{
			name = "Workshop Upstairs";
		}
		else if (zone == "zone_nml_2a")
		{
			name = "No Man's Land Walkway";
		}
		else if (zone == "zone_nml_2")
		{
			name = "No Man's Land Entrance";
		}
		else if (zone == "zone_bunker_tank_e")
		{
			name = "Generator 5 Tank Route 1";
		}
		else if (zone == "zone_bunker_tank_e1")
		{
			name = "Generator 5 Tank Route 2";
		}
		else if (zone == "zone_bunker_tank_e2")
		{
			name = "zone_bunker_tank_e2";
		}
		else if (zone == "zone_bunker_tank_f")
		{
			name = "Generator 5 Tank Route 3";
		}
		else if (zone == "zone_nml_1")
		{
			name = "Generator 5 Tank Route 4";
		}
		else if (zone == "zone_nml_4")
		{
			name = "Generator 5 Tank Route 5";
		}
		else if (zone == "zone_nml_0")
		{
			name = "Generator 5 Left Footstep";
		}
		else if (zone == "zone_nml_5")
		{
			name = "Generator 5 Right Footstep Walkway";
		}
		else if (zone == "zone_nml_farm")
		{
			name = "Generator 5";
		}
		else if (zone == "zone_nml_celllar")
		{
			name = "Generator 5 Cellar";
		}
		else if (zone == "zone_bolt_stairs")
		{
			name = "Lightning Tunnel";
		}
		else if (zone == "zone_nml_3")
		{
			name = "No Man's Land 1st Right Footstep";
		}
		else if (zone == "zone_nml_2b")
		{
			name = "No Man's Land Stairs";
		}
		else if (zone == "zone_nml_6")
		{
			name = "No Man's Land Left Footstep";
		}
		else if (zone == "zone_nml_8")
		{
			name = "No Man's Land 2nd Right Footstep";
		}
		else if (zone == "zone_nml_10a")
		{
			name = "Generator 4 Tank Route 1";
		}
		else if (zone == "zone_nml_10")
		{
			name = "Generator 4 Tank Route 2";
		}
		else if (zone == "zone_nml_7")
		{
			name = "Generator 4 Tank Route 3";
		}
		else if (zone == "zone_bunker_tank_a")
		{
			name = "Generator 4 Tank Route 4";
		}
		else if (zone == "zone_bunker_tank_a1")
		{
			name = "Generator 4 Tank Route 5";
		}
		else if (zone == "zone_bunker_tank_a2")
		{
			name = "zone_bunker_tank_a2";
		}
		else if (zone == "zone_bunker_tank_b")
		{
			name = "Generator 4 Tank Route 6";
		}
		else if (zone == "zone_nml_9")
		{
			name = "Generator 4 Left Footstep";
		}
		else if (zone == "zone_air_stairs")
		{
			name = "Wind Tunnel";
		}
		else if (zone == "zone_nml_11")
		{
			name = "Generator 4";
		}
		else if (zone == "zone_nml_12")
		{
			name = "Generator 4 Right Footstep";
		}
		else if (zone == "zone_nml_16")
		{
			name = "Excavation Site Front Path";
		}
		else if (zone == "zone_nml_17")
		{
			name = "Excavation Site Back Path";
		}
		else if (zone == "zone_nml_18")
		{
			name = "Excavation Site Level 3";
		}
		else if (zone == "zone_nml_19")
		{
			name = "Excavation Site Level 2";
		}
		else if (zone == "ug_bottom_zone")
		{
			name = "Excavation Site Level 1";
		}
		else if (zone == "zone_nml_13")
		{
			name = "Generator 5 To Generator 6 Path";
		}
		else if (zone == "zone_nml_14")
		{
			name = "Generator 4 To Generator 6 Path";
		}
		else if (zone == "zone_nml_15")
		{
			name = "Generator 6 Entrance";
		}
		else if (zone == "zone_village_0")
		{
			name = "Generator 6 Left Footstep";
		}
		else if (zone == "zone_village_5")
		{
			name = "Generator 6 Tank Route 1";
		}
		else if (zone == "zone_village_5a")
		{
			name = "Generator 6 Tank Route 2";
		}
		else if (zone == "zone_village_5b")
		{
			name = "Generator 6 Tank Route 3";
		}
		else if (zone == "zone_village_1")
		{
			name = "Generator 6 Tank Route 4";
		}
		else if (zone == "zone_village_4b")
		{
			name = "Generator 6 Tank Route 5";
		}
		else if (zone == "zone_village_4a")
		{
			name = "Generator 6 Tank Route 6";
		}
		else if (zone == "zone_village_4")
		{
			name = "Generator 6 Tank Route 7";
		}
		else if (zone == "zone_village_2")
		{
			name = "Church";
		}
		else if (zone == "zone_village_3")
		{
			name = "Generator 6 Right Footstep";
		}
		else if (zone == "zone_village_3a")
		{
			name = "Generator 6";
		}
		else if (zone == "zone_ice_stairs")
		{
			name = "Ice Tunnel";
		}
		else if (zone == "zone_bunker_6")
		{
			name = "Above Generator 3 Bunker";
		}
		else if (zone == "zone_nml_20")
		{
			name = "Above No Man's Land";
		}
		else if (zone == "zone_village_6")
		{
			name = "Behind Church";
		}
		else if (zone == "zone_chamber_0")
		{
			name = "The Crazy Place Lightning Chamber";
		}
		else if (zone == "zone_chamber_1")
		{
			name = "The Crazy Place Lightning & Ice";
		}
		else if (zone == "zone_chamber_2")
		{
			name = "The Crazy Place Ice Chamber";
		}
		else if (zone == "zone_chamber_3")
		{
			name = "The Crazy Place Fire & Lightning";
		}
		else if (zone == "zone_chamber_4")
		{
			name = "The Crazy Place Center";
		}
		else if (zone == "zone_chamber_5")
		{
			name = "The Crazy Place Ice & Wind";
		}
		else if (zone == "zone_chamber_6")
		{
			name = "The Crazy Place Fire Chamber";
		}
		else if (zone == "zone_chamber_7")
		{
			name = "The Crazy Place Wind & Fire";
		}
		else if (zone == "zone_chamber_8")
		{
			name = "The Crazy Place Wind Chamber";
		}
		else if (zone == "zone_robot_head")
		{
			name = "Robot's Head";
		}
	}

	return name;
}

last_stand_pistol_swap()
{
	if ( self has_powerup_weapon() )
	{
		self.lastactiveweapon = "none";
	}
	if ( !self hasweapon( self.laststandpistol ) )
	{
		self giveweapon( self.laststandpistol );
	}

	ammoclip = weaponclipsize( self.laststandpistol );
	doubleclip = ammoclip * 2;
	if(weapondualwieldweaponname(self.laststandpistol) != "none")
	{
		ammoclip += weaponclipsize(weapondualwieldweaponname(self.laststandpistol));
		doubleclip = ammoclip;
	}

	if ( is_true( self._special_solo_pistol_swap ) ||  self.laststandpistol == level.default_solo_laststandpistol && !self.hadpistol )
	{
		self._special_solo_pistol_swap = 0;
		self.hadpistol = 0;
		self setweaponammostock( self.laststandpistol, doubleclip );
	}
	else if ( flag( "solo_game" ) && self.laststandpistol == level.default_solo_laststandpistol )
	{
		self setweaponammostock(self.laststandpistol, doubleclip);
	}
	else if ( self.laststandpistol == level.default_laststandpistol )
	{
		self setweaponammostock( self.laststandpistol, doubleclip );
	}
	else if ( self.laststandpistol == "ray_gun_zm" || self.laststandpistol == "ray_gun_upgraded_zm" )
	{
		if ( self.stored_weapon_info[ self.laststandpistol ].total_amt >= ammoclip )
		{
			amt = ammoclip - self.stored_weapon_info[self.laststandpistol].clip_amt;
			self setWeaponAmmoStock(self.laststandpistol, amt);
			self.stored_weapon_info[self.laststandpistol].given_amt = amt;
		}
		else
		{
			amt = self.stored_weapon_info[self.laststandpistol].total_amt - self.stored_weapon_info[self.laststandpistol].clip_amt;
			self setWeaponAmmoStock(self.laststandpistol, amt);
			self.stored_weapon_info[self.laststandpistol].given_amt = amt;
		}
	}
	else if ( self.stored_weapon_info[ self.laststandpistol ].total_amt >= (ammoclip + doubleclip) )
	{
		amt = (ammoclip + doubleclip) - (self.stored_weapon_info[self.laststandpistol].clip_amt + self.stored_weapon_info[self.laststandpistol].left_clip_amt);
		self setweaponammostock( self.laststandpistol, amt );
		self.stored_weapon_info[ self.laststandpistol ].given_amt = amt;
	}
	else
	{
		amt = self.stored_weapon_info[self.laststandpistol].total_amt - (self.stored_weapon_info[self.laststandpistol].clip_amt + self.stored_weapon_info[self.laststandpistol].left_clip_amt);
		self setweaponammostock( self.laststandpistol, amt );
		self.stored_weapon_info[ self.laststandpistol ].given_amt = amt;
	}
	self switchtoweapon( self.laststandpistol );
}

last_stand_restore_pistol_ammo()
{
	self.weapon_taken_by_losing_specialty_additionalprimaryweapon = undefined;
	if ( !isDefined( self.stored_weapon_info ) )
	{
		return;
	}
	weapon_inventory = self getweaponslist( 1 );
	weapon_to_restore = getarraykeys( self.stored_weapon_info );
	i = 0;
	while ( i < weapon_inventory.size )
	{
		weapon = weapon_inventory[ i ];
		if(weapon != self.laststandpistol)
		{
			i++;
			continue;
		}
		for ( j = 0; j < weapon_to_restore.size; j++ )
		{
			check_weapon = weapon_to_restore[ j ];
			if ( weapon == check_weapon )
			{
				dual_wield_name = weapondualwieldweaponname( weapon_to_restore[ j ] );
				if ( weapon != level.default_laststandpistol )
				{
					last_clip = self getweaponammoclip( weapon );
					last_left_clip = 0;
					if( "none" != dual_wield_name )
					{
						last_left_clip = self getweaponammoclip( dual_wield_name );
					}
					last_stock = self getweaponammostock( weapon );
					last_total = last_clip + last_left_clip + last_stock;
					used_amt = self.stored_weapon_info[ weapon ].given_amt - last_total;
					if ( used_amt >= self.stored_weapon_info[ weapon ].stock_amt )
					{
						used_amt = used_amt - self.stored_weapon_info[weapon].stock_amt;
						self.stored_weapon_info[ weapon ].stock_amt = 0;
						self.stored_weapon_info[ weapon ].clip_amt = self.stored_weapon_info[ weapon ].clip_amt - used_amt;
						if ( self.stored_weapon_info[ weapon ].clip_amt < 0 )
						{
							self.stored_weapon_info[ weapon ].clip_amt = 0;
						}
					}
					else
					{
						new_stock_amt = self.stored_weapon_info[ weapon ].stock_amt - used_amt;
						if ( new_stock_amt < self.stored_weapon_info[ weapon ].stock_amt )
						{
							self.stored_weapon_info[ weapon ].stock_amt = new_stock_amt;
						}
					}
				}
				self setweaponammostock( weapon_to_restore[ j ], self.stored_weapon_info[weapon_to_restore[ j ] ].stock_amt );
				break;
			}
		}
		i++;
	}
}

setscoreboardcolumns_gametype()
{
	if(getDvar("g_gametype") == "zgrief")
	{
		setscoreboardcolumns("score", "kills", "killsconfirmed", "downs", "revives");
	}
	else
	{
		setscoreboardcolumns("score", "kills", "headshots", "downs", "revives");
	}
}

set_lethal_grenade_init()
{
	if (level.script != "zm_transit" && level.script != "zm_nuked" && level.script != "zm_highrise" && level.script != "zm_tomb")
	{
		return;
	}

	level.zombie_lethal_grenade_player_init = "sticky_grenade_zm";
}


fall_velocity_check()
{
	self endon("disconnect");

	while (1)
	{
		was_on_ground = 1;
		self.fall_velocity = 0;

		while (!self isOnGround())
		{
			was_on_ground = 0;
			vel = self getVelocity();
			self.fall_velocity = vel[2];
			wait 0.05;
		}

		if (!was_on_ground)
		{
			continue;
		}

		wait 0.05;
	}
}

remove_fast_melee()
{
	self endon("disconnect");

	while (1)
	{
		if (self isMeleeing() && self getWeaponAmmoClip(self getCurrentWeapon()) == 0)
		{
			self disableWeaponCycling();

			while (self isMeleeing())
			{
				wait 0.05;
			}

			if (is_player_valid(self) && !self.is_drinking)
			{
				self enableWeaponCycling();
			}

			continue;
		}

		wait 0.05;
	}
}

player_damage_override( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
	if (smeansofdeath == "MOD_FALLING")
	{
		// remove fall damage being based off max health
		ratio = self.maxhealth / 100;
		idamage = int(idamage / ratio);

		// increase fall damage beyond 110
		max_damage = 110;
		if (idamage >= max_damage)
		{
			velocity = abs(self.fall_velocity);
			min_velocity = getDvarInt("bg_fallDamageMinHeight") * 3.25;
			max_velocity = getDvarInt("bg_fallDamageMaxHeight") * 2.5;
			if (self.divetoprone)
			{
				min_velocity = getDvarInt("dtp_fall_damage_min_height") * 4.5;
				max_velocity = getDvarInt("dtp_fall_damage_max_height") * 2.75;
			}

			idamage = int(((velocity - min_velocity) / (max_velocity - min_velocity)) * max_damage);

			if(idamage < max_damage)
			{
				idamage = max_damage;
			}
		}
	}

	return idamage;
}

disable_bank()
{
	for(i = 0; i < level._unitriggers.trigger_stubs.size; i++)
	{
		if(IsDefined(level._unitriggers.trigger_stubs[i].targetname))
		{
			if(level._unitriggers.trigger_stubs[i].targetname == "bank_deposit" || level._unitriggers.trigger_stubs[i].targetname == "bank_withdraw")
			{
				maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( level._unitriggers.trigger_stubs[i] );
			}
		}
	}

	level notify( "stop_bank_teller" );
	bank_teller_dmg_trig = getent( "bank_teller_tazer_trig", "targetname" );
	if(IsDefined(bank_teller_dmg_trig))
	{
		bank_teller_transfer_trig = getent( bank_teller_dmg_trig.target, "targetname" );
		bank_teller_dmg_trig delete();
		bank_teller_transfer_trig delete();
	}
}

bank_clear_account_value()
{
	self.account_value = 0;
	self maps/mp/zombies/_zm_stats::set_map_stat( "depositBox", player.account_value, level.banking_map );
}

disable_weapon_locker()
{
	for(i = 0; i < level._unitriggers.trigger_stubs.size; i++)
	{
		if(IsDefined(level._unitriggers.trigger_stubs[i].targetname))
		{
			if(level._unitriggers.trigger_stubs[i].targetname == "weapon_locker")
			{
				maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( level._unitriggers.trigger_stubs[i] );
			}
		}
	}
}

weapon_locker_clear_stored_weapondata()
{
	if ( level.weapon_locker_online )
	{
		self maps/mp/zombies/_zm_stats::clear_stored_weapondata( level.weapon_locker_map );
	}
	else
	{
		self.stored_weapon_data = undefined;
	}
}

disable_pers_upgrades()
{
	level waittill("initial_disable_player_pers_upgrades");

	level.pers_upgrades_keys = [];
	level.pers_upgrades = [];
}

disable_player_pers_upgrades()
{
	flag_wait( "initial_blackscreen_passed" );

	if (isDefined(self.pers_upgrades_awarded))
	{
		upgrade = getFirstArrayKey(self.pers_upgrades_awarded);
		while (isDefined(upgrade))
		{
			self.pers_upgrades_awarded[upgrade] = 0;
			upgrade = getNextArrayKey(self.pers_upgrades_awarded, upgrade);
		}
	}

	if (isDefined(level.pers_upgrades_keys))
	{
		index = 0;
		while (index < level.pers_upgrades_keys.size)
		{
			str_name = level.pers_upgrades_keys[index];
			stat_index = 0;
			while (stat_index < level.pers_upgrades[str_name].stat_names.size)
			{
				self maps/mp/zombies/_zm_stats::zero_client_stat(level.pers_upgrades[str_name].stat_names[stat_index], 0);
				stat_index++;
			}
			index++;
		}
	}

	level notify("initial_disable_player_pers_upgrades");
}

disable_carpenter()
{
	arrayremoveindex(level.zombie_include_powerups, "carpenter");
	arrayremoveindex(level.zombie_powerups, "carpenter");
	arrayremovevalue(level.zombie_powerup_array, "carpenter");
}

wallbuy_location_changes()
{
	if(!is_classic())
	{
		if(level.scr_zm_map_start_location == "farm")
		{
			if(level.scr_zm_ui_gametype == "zstandard")
			{
				remove_wallbuy("tazer_knuckles_zm");
			}

			add_wallbuy("claymore_zm");
		}

		if(level.scr_zm_map_start_location == "street")
		{
			if(level.scr_zm_ui_gametype == "zgrief")
			{
				add_wallbuy("beretta93r_zm");
				add_wallbuy("m16_zm");
				add_wallbuy("claymore_zm");
				add_wallbuy("bowie_knife_zm");
			}
		}
	}
}

remove_wallbuy( name )
{
	for(i = 0; i < level._unitriggers.trigger_stubs.size; i++)
	{
		if(IsDefined(level._unitriggers.trigger_stubs[i].zombie_weapon_upgrade) && level._unitriggers.trigger_stubs[i].zombie_weapon_upgrade == name)
		{
			maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( level._unitriggers.trigger_stubs[i] );
		}
	}
}

add_wallbuy( name )
{
	struct = undefined;
	spawnable_weapon_spawns = getstructarray( "weapon_upgrade", "targetname" );
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "bowie_upgrade", "targetname" ), 1, 0 );
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "sickle_upgrade", "targetname" ), 1, 0 );
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "tazer_upgrade", "targetname" ), 1, 0 );
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "buildable_wallbuy", "targetname" ), 1, 0 );
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "claymore_purchase", "targetname" ), 1, 0 );
	for(i = 0; i < spawnable_weapon_spawns.size; i++)
	{
		if(IsDefined(spawnable_weapon_spawns[i].zombie_weapon_upgrade) && spawnable_weapon_spawns[i].zombie_weapon_upgrade == name)
		{
			struct = spawnable_weapon_spawns[i];
			break;
		}
	}

	if(!IsDefined(struct))
	{
		return;
	}

	target_struct = getstruct( struct.target, "targetname" );
	unitrigger_stub = spawnstruct();
	unitrigger_stub.origin = struct.origin;
	unitrigger_stub.angles = struct.angles;

	tempmodel = spawn( "script_model", ( 0, 0, 0 ) );
	tempmodel setmodel( target_struct.model );
	tempmodel useweaponhidetags( struct.zombie_weapon_upgrade );
	mins = tempmodel getmins();
	maxs = tempmodel getmaxs();
	absmins = tempmodel getabsmins();
	absmaxs = tempmodel getabsmaxs();
	bounds = absmaxs - absmins;
	tempmodel delete();
	unitrigger_stub.script_length = 64;
	unitrigger_stub.script_width = bounds[1];
	unitrigger_stub.script_height = bounds[2];

	unitrigger_stub.origin -= anglesToRight( unitrigger_stub.angles ) * ( ( bounds[0] * 0.25 ) * 0.4 );
	unitrigger_stub.target = struct.target;
	unitrigger_stub.targetname = struct.targetname;
	unitrigger_stub.cursor_hint = "HINT_NOICON";
	if ( struct.targetname == "weapon_upgrade" )
	{
		unitrigger_stub.cost = maps/mp/zombies/_zm_weapons::get_weapon_cost( struct.zombie_weapon_upgrade );
		if ( isDefined( level.monolingustic_prompt_format ) && !level.monolingustic_prompt_format )
		{
			unitrigger_stub.hint_string = maps/mp/zombies/_zm_weapons::get_weapon_hint( struct.zombie_weapon_upgrade );
			unitrigger_stub.hint_parm1 = unitrigger_stub.cost;
			return;
		}
		else
		{
			unitrigger_stub.hint_parm1 = maps/mp/zombies/_zm_weapons::get_weapon_display_name( struct.zombie_weapon_upgrade );
			if ( isDefined( unitrigger_stub.hint_parm1 ) || unitrigger_stub.hint_parm1 == "" && unitrigger_stub.hint_parm1 == "none" )
			{
				unitrigger_stub.hint_parm1 = "missing weapon name " + struct.zombie_weapon_upgrade;
			}
			unitrigger_stub.hint_parm2 = unitrigger_stub.cost;
			unitrigger_stub.hint_string = &"ZOMBIE_WEAPONCOSTONLY";
		}
	}
	unitrigger_stub.weapon_upgrade = struct.zombie_weapon_upgrade;
	unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
	unitrigger_stub.require_look_at = 1;
	if ( isDefined( struct.require_look_from ) && struct.require_look_from )
	{
		unitrigger_stub.require_look_from = 1;
	}
	unitrigger_stub.zombie_weapon_upgrade = struct.zombie_weapon_upgrade;

	model = spawn_weapon_model( struct.zombie_weapon_upgrade, undefined, target_struct.origin, target_struct.angles );
	model.targetname = struct.target;
	model setmodel( target_struct.model );
	model useweaponhidetags( struct.zombie_weapon_upgrade );
	model hide();

	maps/mp/zombies/_zm_unitrigger::unitrigger_force_per_player_triggers( unitrigger_stub, 1 );
	if ( unitrigger_stub.zombie_weapon_upgrade == "bowie_knife_zm" )
	{
		unitrigger_stub.cost = 3000;
		unitrigger_stub.weapon_name = "bowie_knife_zm";
		unitrigger_stub.vo_dialog_id = "bowie";
		unitrigger_stub.flourish_weapon_name = "zombie_bowie_flourish";
		unitrigger_stub.ballistic_weapon_name = "knife_ballistic_bowie_zm";
		unitrigger_stub.ballistic_upgraded_weapon_name = "knife_ballistic_bowie_upgraded_zm";
		unitrigger_stub.prompt_and_visibility_func = ::bowie_knife_update_prompt;
		maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, maps/mp/zombies/_zm_melee_weapon::melee_weapon_think );

	}
	else if ( unitrigger_stub.zombie_weapon_upgrade == "claymore_zm" )
	{
		model.script_int = -90; // fix for model sliding right to left
		unitrigger_stub.prompt_and_visibility_func = maps/mp/zombies/_zm_weap_claymore::claymore_unitrigger_update_prompt;
		maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, maps/mp/zombies/_zm_weap_claymore::buy_claymores );
	}
	else
	{
		unitrigger_stub.prompt_and_visibility_func = maps/mp/zombies/_zm_weapons::wall_weapon_update_prompt;
		maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, maps/mp/zombies/_zm_weapons::weapon_spawn_think );
	}
	struct.trigger_stub = unitrigger_stub;

	chalk_fx = name + "_fx";
	thread playchalkfx( chalk_fx, struct.origin, struct.angles );
}

playchalkfx( effect, origin, angles )
{
	while ( 1 )
	{
		fx = SpawnFX( level._effect[ effect ], origin, AnglesToForward( angles ), AnglesToUp( angles ) );
		TriggerFX( fx );
		level waittill( "connected", player );
		fx Delete();
	}
}

bowie_knife_update_prompt(player)
{
	if(player get_player_melee_weapon() == self.stub.weapon_name)
	{
		self sethintstring("");
		self setcursorhint("HINT_NOICON");
		return 0;
	}

	self sethintstring(&"ZOMBIE_WEAPON_BOWIE_BUY", self.stub.cost);
	self setcursorhint("HINT_WEAPON", self.stub.weapon_name);
	return 1;
}

wallbuy_cost_changes()
{
	flag_wait( "initial_blackscreen_passed" );

	if (isDefined(level.zombie_weapons["beretta93r_zm"]))
	{
		cost = 900;
		level.zombie_weapons["beretta93r_zm"].cost = cost;
		level.zombie_weapons["beretta93r_zm"].ammo_cost = int(cost / 2);
	}

	if (isDefined(level.zombie_weapons["870mcs_zm"]))
	{
		cost = 1200;
		level.zombie_weapons["870mcs_zm"].cost = cost;
		level.zombie_weapons["870mcs_zm"].ammo_cost = int(cost / 2);
	}

	if (isDefined(level.zombie_weapons["an94_zm"]))
	{
		cost = 1500;
		level.zombie_weapons["an94_zm"].cost = cost;
		level.zombie_weapons["an94_zm"].ammo_cost = int(cost / 2);
	}

	if (isDefined(level.zombie_weapons["thompson_zm"]))
	{
		level.zombie_weapons["thompson_zm"].ammo_cost = 750;
	}
}

wallbuy_increase_trigger_radius()
{
	for(i = 0; i < level._unitriggers.trigger_stubs.size; i++)
	{
		if(IsDefined(level._unitriggers.trigger_stubs[i].zombie_weapon_upgrade))
		{
			level._unitriggers.trigger_stubs[i].script_length = 64;
		}
	}
}

wallbuy_decrease_upgraded_ammo_cost()
{
	for(i = 0; i < level._unitriggers.trigger_stubs.size; i++)
	{
		if(isDefined(level._unitriggers.trigger_stubs[i].trigger_func) && level._unitriggers.trigger_stubs[i].trigger_func == maps/mp/zombies/_zm_weapons::weapon_spawn_think)
		{
			level._unitriggers.trigger_stubs[i].trigger_func = ::weapon_spawn_think;
		}
	}
}

weapon_spawn_think()
{
	cost = maps/mp/zombies/_zm_weapons::get_weapon_cost( self.zombie_weapon_upgrade );
	ammo_cost = maps/mp/zombies/_zm_weapons::get_ammo_cost( self.zombie_weapon_upgrade );
	shared_ammo_weapon = undefined;
	second_endon = undefined;

	is_grenade = 0;
	if(weapontype( self.zombie_weapon_upgrade ) == "grenade")
	{
		is_grenade = 1;
	}

	if ( isDefined( self.stub ) )
	{
		second_endon = "kill_trigger";
		self.first_time_triggered = self.stub.first_time_triggered;
	}

	if ( isDefined( self.stub ) && is_true( self.stub.trigger_per_player ) )
	{
		self thread maps/mp/zombies/_zm_magicbox::decide_hide_show_hint( "stop_hint_logic", second_endon, self.parent_player );
	}
	else
	{
		self thread maps/mp/zombies/_zm_magicbox::decide_hide_show_hint( "stop_hint_logic", second_endon );
	}

	if ( is_grenade )
	{
		self.first_time_triggered = 0;
		hint = maps/mp/zombies/_zm_weapons::get_weapon_hint( self.zombie_weapon_upgrade );
		self sethintstring( hint, cost );
	}
	else if ( !isDefined( self.first_time_triggered ) )
	{
		self.first_time_triggered = 0;
		if ( isDefined( self.stub ) )
		{
			self.stub.first_time_triggered = 0;
		}
	}
	else if ( self.first_time_triggered )
	{
		if ( is_true( level.use_legacy_weapon_prompt_format ) )
		{
			self maps/mp/zombies/_zm_weapons::weapon_set_first_time_hint( cost, maps/mp/zombies/_zm_weapons::get_ammo_cost( self.zombie_weapon_upgrade ) );
		}
	}

	for ( ;; )
	{
		self waittill( "trigger", player );

		if ( !is_player_valid( player ) )
		{
			player thread ignore_triggers( 0.5 );
			continue;
		}

		if ( !player maps/mp/zombies/_zm_magicbox::can_buy_weapon() )
		{
			wait 0.1;
			continue;
		}

		if ( isDefined( self.stub ) && is_true( self.stub.require_look_from ) )
		{
			toplayer = player get_eye() - self.origin;
			forward = -1 * anglesToRight( self.angles );
			dot = vectordot( toplayer, forward );
			if ( dot < 0 )
			{
				continue;
			}
		}

		if ( player has_powerup_weapon() )
		{
			wait 0.1;
			continue;
		}

		player_has_weapon = player maps/mp/zombies/_zm_weapons::has_weapon_or_upgrade( self.zombie_weapon_upgrade );
		if ( !player_has_weapon && is_true( level.weapons_using_ammo_sharing ) )
		{
			shared_ammo_weapon = player maps/mp/zombies/_zm_weapons::get_shared_ammo_weapon( self.zombie_weapon_upgrade );
			if ( isDefined( shared_ammo_weapon ) )
			{
				player_has_weapon = 1;
			}
		}

		if ( is_true( level.pers_upgrade_nube ) )
		{
			player_has_weapon = maps/mp/zombies/_zm_pers_upgrades_functions::pers_nube_should_we_give_raygun( player_has_weapon, player, self.zombie_weapon_upgrade );
		}

		cost = maps/mp/zombies/_zm_weapons::get_weapon_cost( self.zombie_weapon_upgrade );
		if ( player maps/mp/zombies/_zm_pers_upgrades_functions::is_pers_double_points_active() )
		{
			cost = int( cost / 2 );
		}

		if ( !player_has_weapon )
		{
			if ( player.score >= cost )
			{
				if ( self.first_time_triggered == 0 )
				{
					self maps/mp/zombies/_zm_weapons::show_all_weapon_buys( player, cost, ammo_cost, is_grenade );
				}

				player maps/mp/zombies/_zm_score::minus_to_player_score( cost, 1 );
				bbprint( "zombie_uses", "playername %s playerscore %d round %d cost %d name %s x %f y %f z %f type %s", player.name, player.score, level.round_number, cost, self.zombie_weapon_upgrade, self.origin, "weapon" );
				level notify( "weapon_bought", player, self.zombie_weapon_upgrade );

				if ( self.zombie_weapon_upgrade == "riotshield_zm" )
				{
					player maps/mp/zombies/_zm_equipment::equipment_give( "riotshield_zm" );
					if ( isDefined( player.player_shield_reset_health ) )
					{
						player [[ player.player_shield_reset_health ]]();
					}
				}
				else if ( self.zombie_weapon_upgrade == "jetgun_zm" )
				{
					player maps/mp/zombies/_zm_equipment::equipment_give( "jetgun_zm" );
				}
				else if ( is_lethal_grenade( self.zombie_weapon_upgrade ) )
				{
					player takeweapon( player get_player_lethal_grenade() );
					player set_player_lethal_grenade( self.zombie_weapon_upgrade );
				}

				str_weapon = self.zombie_weapon_upgrade;

				if ( is_true( level.pers_upgrade_nube ) )
				{
					str_weapon = maps/mp/zombies/_zm_pers_upgrades_functions::pers_nube_weapon_upgrade_check( player, str_weapon );
				}

				player maps/mp/zombies/_zm_weapons::weapon_give( str_weapon );
				player maps/mp/zombies/_zm_stats::increment_client_stat( "wallbuy_weapons_purchased" );
				player maps/mp/zombies/_zm_stats::increment_player_stat( "wallbuy_weapons_purchased" );
			}
			else
			{
				play_sound_on_ent( "no_purchase" );
				player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "no_money_weapon" );
			}
		}
		else
		{
			str_weapon = self.zombie_weapon_upgrade;

			if ( isDefined( shared_ammo_weapon ) )
			{
				str_weapon = shared_ammo_weapon;
			}

			if ( is_true( level.pers_upgrade_nube ) )
			{
				str_weapon = maps/mp/zombies/_zm_pers_upgrades_functions::pers_nube_weapon_ammo_check( player, str_weapon );
			}

			if ( is_true( self.hacked ) )
			{
				if ( !player maps/mp/zombies/_zm_weapons::has_upgrade( str_weapon ) )
				{
					ammo_cost = maps/mp/zombies/_zm_weapons::get_upgraded_ammo_cost( str_weapon );
				}
				else
				{
					ammo_cost = maps/mp/zombies/_zm_weapons::get_ammo_cost( str_weapon );
				}
			}
			else if ( player maps/mp/zombies/_zm_weapons::has_upgrade( str_weapon ) )
			{
				ammo_cost = maps/mp/zombies/_zm_weapons::get_upgraded_ammo_cost( str_weapon );
			}
			else
			{
				ammo_cost = maps/mp/zombies/_zm_weapons::get_ammo_cost( str_weapon );
			}

			if ( is_true( player.pers_upgrades_awarded[ "nube" ] ) )
			{
				ammo_cost = maps/mp/zombies/_zm_pers_upgrades_functions::pers_nube_override_ammo_cost( player, self.zombie_weapon_upgrade, ammo_cost );
			}

			if ( player maps/mp/zombies/_zm_pers_upgrades_functions::is_pers_double_points_active() )
			{
				ammo_cost = int( ammo_cost / 2 );
			}

			if ( str_weapon == "riotshield_zm" )
			{
				play_sound_on_ent( "no_purchase" );
			}
			else if ( player.score >= ammo_cost )
			{
				if ( self.first_time_triggered == 0 )
				{
					self maps/mp/zombies/_zm_weapons::show_all_weapon_buys( player, cost, ammo_cost, is_grenade );
				}

				if ( player maps/mp/zombies/_zm_weapons::has_upgrade( str_weapon ) )
				{
					player maps/mp/zombies/_zm_stats::increment_client_stat( "upgraded_ammo_purchased" );
					player maps/mp/zombies/_zm_stats::increment_player_stat( "upgraded_ammo_purchased" );
				}
				else
				{
					player maps/mp/zombies/_zm_stats::increment_client_stat( "ammo_purchased" );
					player maps/mp/zombies/_zm_stats::increment_player_stat( "ammo_purchased" );
				}

				if ( str_weapon == "riotshield_zm" )
				{
					if ( isDefined( player.player_shield_reset_health ) )
					{
						ammo_given = player [[ player.player_shield_reset_health ]]();
					}
					else
					{
						ammo_given = 0;
					}
				}
				else if ( player maps/mp/zombies/_zm_weapons::has_upgrade( str_weapon ) )
				{
					ammo_given = player maps/mp/zombies/_zm_weapons::ammo_give( level.zombie_weapons[ str_weapon ].upgrade_name );
				}
				else
				{
					ammo_given = player maps/mp/zombies/_zm_weapons::ammo_give( str_weapon );
				}

				if ( ammo_given )
				{
					player maps/mp/zombies/_zm_score::minus_to_player_score( ammo_cost, 1 );
					bbprint( "zombie_uses", "playername %s playerscore %d round %d cost %d name %s x %f y %f z %f type %s", player.name, player.score, level.round_number, ammo_cost, str_weapon, self.origin, "ammo" );
				}
			}
			else
			{
				play_sound_on_ent( "no_purchase" );

				if ( isDefined( level.custom_generic_deny_vo_func ) )
				{
					player [[ level.custom_generic_deny_vo_func ]]();
				}
				else
				{
					player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "no_money_weapon" );
				}
			}
		}

		if ( isDefined( self.stub ) && isDefined( self.stub.prompt_and_visibility_func ) )
		{
			self [[ self.stub.prompt_and_visibility_func ]]( player );
		}
	}
}

wallbuy_dynamic_update()
{
	if(!(is_classic() && level.scr_zm_map_start_location == "processing"))
	{
		return;
	}

	while (!isDefined(level.built_wallbuys))
	{
		wait 0.5;
	}

	prev_built_wallbuys = 0;

	while (1)
	{
		if (level.built_wallbuys > prev_built_wallbuys)
		{
			prev_built_wallbuys = level.built_wallbuys;
			wallbuy_increase_trigger_radius();
			wallbuy_decrease_upgraded_ammo_cost();
		}

		if (level.built_wallbuys == -100)
		{
			wallbuy_increase_trigger_radius();
			wallbuy_decrease_upgraded_ammo_cost();
			return;
		}

		wait 0.5;
	}
}

disable_perk_pause()
{
	for (i = 0; i < level.powered_items.size; i++)
	{
		item = level.powered_items[i];

		if (IsDefined(item.target) && IsDefined(item.target.targetname) && item.target.targetname == "zombie_vending")
		{
			if (item.target.script_noteworthy != "specialty_weapupgrade")
			{
				item.power_off_func = ::perk_power_off;
			}
		}
	}
}

perk_power_off( origin, radius )
{
	self.target notify( "death" );

	if (flag("solo_game") && isDefined(self.target.script_noteworthy) && self.target.script_noteworthy == "specialty_quickrevive")
	{
		self.target thread solo_revive_trigger_think();
	}
	else
	{
		self.target thread maps/mp/zombies/_zm_perks::vending_trigger_think();
	}

	if ( isDefined( self.target.perk_hum ) )
	{
		self.target.perk_hum delete();
	}
	//maps/mp/zombies/_zm_perks::perk_pause( self.target.script_noteworthy );
	level notify( self.target maps/mp/zombies/_zm_perks::getvendingmachinenotify() + "_off" );
}

buildbuildables()
{
	// need a wait or else some buildables dont build
	wait 1;

	if(is_classic())
	{
		if(level.scr_zm_map_start_location == "transit")
		{
			buildbuildable( "turbine" );
			buildbuildable( "electric_trap" );
			buildbuildable( "turret" );
			buildbuildable( "riotshield_zm" );
			buildbuildable( "jetgun_zm" );
			buildbuildable( "powerswitch", 1 );
			buildbuildable( "pap", 1 );
			buildbuildable( "sq_common", 1 );

			// power switch is not showing up from forced build
			show_powerswitch();
		}
		else if(level.scr_zm_map_start_location == "rooftop")
		{
			buildbuildable( "slipgun_zm" );
			buildbuildable( "springpad_zm" );
			buildbuildable( "sq_common", 1 );
		}
		else if(level.scr_zm_map_start_location == "processing")
		{
			level waittill( "buildables_setup" ); // wait for buildables to randomize
			wait 0.05;

			level.buildables_available = array("subwoofer_zm", "springpad_zm", "headchopper_zm");

			removebuildable( "keys_zm" );
			buildbuildable( "turbine" );
			buildbuildable( "subwoofer_zm" );
			buildbuildable( "springpad_zm" );
			buildbuildable( "headchopper_zm" );
			buildbuildable( "sq_common", 1 );
		}
	}
	else
	{
		if(level.scr_zm_map_start_location == "street")
		{
			flag_wait( "initial_blackscreen_passed" ); // wait for buildables to be built
			wait 1;

			updatebuildables();
			removebuildable( "turbine", 1 );
		}
	}
}

buildbuildable( buildable, craft )
{
	if (!isDefined(craft))
	{
		craft = 0;
	}

	player = get_players()[ 0 ];
	foreach (stub in level.buildable_stubs)
	{
		if ( !isDefined( buildable ) || stub.equipname == buildable )
		{
			if ( isDefined( buildable ) || stub.persistent != 3 )
			{
				equipname = stub get_equipname();
				stub.cost = 1000;
				stub.trigger_hintstring = "Hold ^3[{+activate}]^7 for " + equipname + " [Cost: " + stub.cost + "]";
				stub.trigger_func = ::buildable_place_think;

				if (craft)
				{
					stub maps/mp/zombies/_zm_buildables::buildablestub_finish_build( player );
					stub maps/mp/zombies/_zm_buildables::buildablestub_remove();
					stub.model notsolid();
					stub.model show();
				}
				else
				{
					level.zombie_buildables[stub.equipname].hint = "Hold ^3[{+activate}]^7 to craft " + equipname;
					stub.prompt_and_visibility_func = ::buildabletrigger_update_prompt;
				}

				i = 0;
				foreach (piece in stub.buildablezone.pieces)
				{
					piece maps/mp/zombies/_zm_buildables::piece_unspawn();
					if (!craft && i > 0)
					{
						stub.buildablezone maps/mp/zombies/_zm_buildables::buildable_set_piece_built(piece);
					}
					i++;
				}

				return;
			}
		}
	}
}

get_equipname()
{
	if (self.equipname == "turbine")
	{
		return "Turbine";
	}
	else if (self.equipname == "turret")
	{
		return "Turret";
	}
	else if (self.equipname == "electric_trap")
	{
		return "Electric Trap";
	}
	else if (self.equipname == "riotshield_zm")
	{
		return "Zombie Shield";
	}
	else if (self.equipname == "jetgun_zm")
	{
		return "Jet Gun";
	}
	else if (self.equipname == "slipgun_zm")
	{
		return "Sliquifier";
	}
	else if (self.equipname == "subwoofer_zm")
	{
		return "Subsurface Resonator";
	}
	else if (self.equipname == "springpad_zm")
	{
		return "Trample Steam";
	}
	else if (self.equipname == "headchopper_zm")
	{
		return "Head Chopper";
	}
}

buildable_place_think()
{
	self endon( "kill_trigger" );
	player_built = undefined;
	while ( isDefined( self.stub.built ) && !self.stub.built )
	{
		self waittill( "trigger", player );
		if ( player != self.parent_player )
		{
			continue;
		}
		if ( isDefined( player.screecher_weapon ) )
		{
			continue;
		}
		if ( !is_player_valid( player ) )
		{
			player thread ignore_triggers( 0.5 );
		}
		status = player maps/mp/zombies/_zm_buildables::player_can_build( self.stub.buildablezone );
		if ( !status )
		{
			self.stub.hint_string = "";
			self sethintstring( self.stub.hint_string );
			if ( isDefined( self.stub.oncantuse ) )
			{
				self.stub [[ self.stub.oncantuse ]]( player );
			}
			continue;
		}
		else
		{
			if ( isDefined( self.stub.onbeginuse ) )
			{
				self.stub [[ self.stub.onbeginuse ]]( player );
			}
			result = self maps/mp/zombies/_zm_buildables::buildable_use_hold_think( player );
			team = player.pers[ "team" ];
			if ( isDefined( self.stub.onenduse ) )
			{
				self.stub [[ self.stub.onenduse ]]( team, player, result );
			}
			if ( !result )
			{
				continue;
			}
			if ( isDefined( self.stub.onuse ) )
			{
				self.stub [[ self.stub.onuse ]]( player );
			}
			prompt = player maps/mp/zombies/_zm_buildables::player_build( self.stub.buildablezone );
			player_built = player;
			self.stub.hint_string = prompt;
			self sethintstring( self.stub.hint_string );
		}
	}
	if ( isDefined( player_built ) )
	{
	}
	if ( self.stub.persistent == 0 )
	{
		self.stub maps/mp/zombies/_zm_buildables::buildablestub_remove();
		thread maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( self.stub );
		return;
	}
	if ( self.stub.persistent == 3 )
	{
		maps/mp/zombies/_zm_buildables::stub_unbuild_buildable( self.stub, 1 );
		return;
	}
	if ( self.stub.persistent == 2 )
	{
		if ( isDefined( player_built ) )
		{
			self buildabletrigger_update_prompt( player_built );
		}
		if ( !maps/mp/zombies/_zm_weapons::limited_weapon_below_quota( self.stub.weaponname, undefined ) )
		{
			self.stub.hint_string = &"ZOMBIE_GO_TO_THE_BOX_LIMITED";
			self sethintstring( self.stub.hint_string );
			return;
		}
		if ( isDefined( self.stub.bought ) && self.stub.bought )
		{
			self.stub.hint_string = &"ZOMBIE_GO_TO_THE_BOX";
			self sethintstring( self.stub.hint_string );
			return;
		}
		if ( isDefined( self.stub.model ) )
		{
			self.stub.model notsolid();
			self.stub.model show();
		}
		while ( self.stub.persistent == 2 )
		{
			self waittill( "trigger", player );
			if ( isDefined( player.screecher_weapon ) )
			{
				continue;
			}
			if ( !maps/mp/zombies/_zm_weapons::limited_weapon_below_quota( self.stub.weaponname, undefined ) )
			{
				self.stub.hint_string = &"ZOMBIE_GO_TO_THE_BOX_LIMITED";
				self sethintstring( self.stub.hint_string );
				return;
			}
			if ( isDefined( self.stub.built ) && !self.stub.built )
			{
				self.stub.hint_string = "";
				self sethintstring( self.stub.hint_string );
				return;
			}
			if ( player != self.parent_player )
			{
				continue;
			}
			if ( !is_player_valid( player ) )
			{
				player thread ignore_triggers( 0.5 );
			}

			if (player.score < self.stub.cost)
			{
				self play_sound_on_ent( "no_purchase" );
				continue;
			}

			player maps/mp/zombies/_zm_score::minus_to_player_score( self.stub.cost );
			self play_sound_on_ent( "purchase" );

			self.stub.bought = 1;
			if ( isDefined( self.stub.model ) )
			{
				self.stub.model thread maps/mp/zombies/_zm_buildables::model_fly_away();
			}
			player maps/mp/zombies/_zm_weapons::weapon_give( self.stub.weaponname );
			if ( isDefined( level.zombie_include_buildables[ self.stub.equipname ].onbuyweapon ) )
			{
				self [[ level.zombie_include_buildables[ self.stub.equipname ].onbuyweapon ]]( player );
			}
			if ( !maps/mp/zombies/_zm_weapons::limited_weapon_below_quota( self.stub.weaponname, undefined ) )
			{
				self.stub.hint_string = &"ZOMBIE_GO_TO_THE_BOX_LIMITED";
			}
			else
			{
				self.stub.hint_string = &"ZOMBIE_GO_TO_THE_BOX";
			}
			self sethintstring( self.stub.hint_string );
			player maps/mp/zombies/_zm_buildables::track_buildables_pickedup( self.stub.weaponname );
		}
	}
	else while ( !isDefined( player_built ) || self buildabletrigger_update_prompt( player_built ) )
	{
		if ( isDefined( self.stub.model ) )
		{
			self.stub.model notsolid();
			self.stub.model show();
		}
		while ( self.stub.persistent == 1 )
		{
			self waittill( "trigger", player );
			if ( isDefined( player.screecher_weapon ) )
			{
				continue;
			}
			if ( isDefined( self.stub.built ) && !self.stub.built )
			{
				self.stub.hint_string = "";
				self sethintstring( self.stub.hint_string );
				return;
			}
			if ( player != self.parent_player )
			{
				continue;
			}
			if ( !is_player_valid( player ) )
			{
				player thread ignore_triggers( 0.5 );
			}
			if ( player has_player_equipment( self.stub.weaponname ) )
			{
				continue;
			}
			if (player.score < self.stub.cost)
			{
				self play_sound_on_ent( "no_purchase" );
				continue;
			}
			if ( !maps/mp/zombies/_zm_equipment::is_limited_equipment( self.stub.weaponname ) || !maps/mp/zombies/_zm_equipment::limited_equipment_in_use( self.stub.weaponname ) )
			{
				player maps/mp/zombies/_zm_score::minus_to_player_score( self.stub.cost );
				self play_sound_on_ent( "purchase" );

				player maps/mp/zombies/_zm_equipment::equipment_buy( self.stub.weaponname );
				player giveweapon( self.stub.weaponname );
				player setweaponammoclip( self.stub.weaponname, 1 );
				if ( isDefined( level.zombie_include_buildables[ self.stub.equipname ].onbuyweapon ) )
				{
					self [[ level.zombie_include_buildables[ self.stub.equipname ].onbuyweapon ]]( player );
				}
				if ( self.stub.weaponname != "keys_zm" )
				{
					player setactionslot( 1, "weapon", self.stub.weaponname );
				}
				if ( isDefined( level.zombie_buildables[ self.stub.equipname ].bought ) )
				{
					self.stub.hint_string = level.zombie_buildables[ self.stub.equipname ].bought;
				}
				else
				{
					self.stub.hint_string = "";
				}
				self sethintstring( self.stub.hint_string );
				player maps/mp/zombies/_zm_buildables::track_buildables_pickedup( self.stub.weaponname );
				continue;
			}
			else
			{
				self.stub.hint_string = "";
				self sethintstring( self.stub.hint_string );
			}
		}
	}
}

buildabletrigger_update_prompt( player )
{
	can_use = 0;
	if (isDefined(level.buildablepools))
	{
		can_use = self.stub pooledbuildablestub_update_prompt( player, self );
	}
	else
	{
		can_use = self.stub buildablestub_update_prompt( player, self );
	}

	self sethintstring( self.stub.hint_string );
	if ( isDefined( self.stub.cursor_hint ) )
	{
		if ( self.stub.cursor_hint == "HINT_WEAPON" && isDefined( self.stub.cursor_hint_weapon ) )
		{
			self setcursorhint( self.stub.cursor_hint, self.stub.cursor_hint_weapon );
		}
		else
		{
			self setcursorhint( self.stub.cursor_hint );
		}
	}
	return can_use;
}

buildablestub_update_prompt( player, trigger )
{
	if ( !self maps/mp/zombies/_zm_buildables::anystub_update_prompt( player ) )
	{
		return 0;
	}

	if ( isDefined( self.buildablestub_reject_func ) )
	{
		rval = self [[ self.buildablestub_reject_func ]]( player );
		if ( rval )
		{
			return 0;
		}
	}

	if ( isDefined( self.custom_buildablestub_update_prompt ) && !( self [[ self.custom_buildablestub_update_prompt ]]( player ) ) )
	{
		return 0;
	}

	self.cursor_hint = "HINT_NOICON";
	self.cursor_hint_weapon = undefined;
	if ( isDefined( self.built ) && !self.built )
	{
		slot = self.buildablestruct.buildable_slot;
		piece = self.buildablezone.pieces[0];
		player maps/mp/zombies/_zm_buildables::player_set_buildable_piece(piece, slot);

		if ( !isDefined( player maps/mp/zombies/_zm_buildables::player_get_buildable_piece( slot ) ) )
		{
			if ( isDefined( level.zombie_buildables[ self.equipname ].hint_more ) )
			{
				self.hint_string = level.zombie_buildables[ self.equipname ].hint_more;
			}
			else
			{
				self.hint_string = &"ZOMBIE_BUILD_PIECE_MORE";
			}
			return 0;
		}
		else
		{
			if ( !self.buildablezone maps/mp/zombies/_zm_buildables::buildable_has_piece( player maps/mp/zombies/_zm_buildables::player_get_buildable_piece( slot ) ) )
			{
				if ( isDefined( level.zombie_buildables[ self.equipname ].hint_wrong ) )
				{
					self.hint_string = level.zombie_buildables[ self.equipname ].hint_wrong;
				}
				else
				{
					self.hint_string = &"ZOMBIE_BUILD_PIECE_WRONG";
				}
				return 0;
			}
			else
			{
				if ( isDefined( level.zombie_buildables[ self.equipname ].hint ) )
				{
					self.hint_string = level.zombie_buildables[ self.equipname ].hint;
				}
				else
				{
					self.hint_string = "Missing buildable hint";
				}
			}
		}
	}
	else
	{
		if ( self.persistent == 1 )
		{
			if ( maps/mp/zombies/_zm_equipment::is_limited_equipment( self.weaponname ) && maps/mp/zombies/_zm_equipment::limited_equipment_in_use( self.weaponname ) )
			{
				self.hint_string = &"ZOMBIE_BUILD_PIECE_ONLY_ONE";
				return 0;
			}

			if ( player has_player_equipment( self.weaponname ) )
			{
				self.hint_string = &"ZOMBIE_BUILD_PIECE_HAVE_ONE";
				return 0;
			}

			self.hint_string = self.trigger_hintstring;
		}
		else if ( self.persistent == 2 )
		{
			if ( !maps/mp/zombies/_zm_weapons::limited_weapon_below_quota( self.weaponname, undefined ) )
			{
				self.hint_string = &"ZOMBIE_GO_TO_THE_BOX_LIMITED";
				return 0;
			}
			else
			{
				if ( isDefined( self.bought ) && self.bought )
				{
					self.hint_string = &"ZOMBIE_GO_TO_THE_BOX";
					return 0;
				}
			}
			self.hint_string = self.trigger_hintstring;
		}
		else
		{
			self.hint_string = "";
			return 0;
		}
	}
	return 1;
}

pooledbuildablestub_update_prompt( player, trigger )
{
	if ( !self maps/mp/zombies/_zm_buildables::anystub_update_prompt( player ) )
	{
		return 0;
	}

	if ( isDefined( self.custom_buildablestub_update_prompt ) && !( self [[ self.custom_buildablestub_update_prompt ]]( player ) ) )
	{
		return 0;
	}

	self.cursor_hint = "HINT_NOICON";
	self.cursor_hint_weapon = undefined;
	if ( isDefined( self.built ) && !self.built )
	{
		trigger thread buildablestub_build_succeed();

		if (level.buildables_available.size > 1)
		{
			self thread choose_open_buildable(player);
		}

		slot = self.buildablestruct.buildable_slot;

		if (self.buildables_available_index >= level.buildables_available.size)
		{
			self.buildables_available_index = 0;
		}

		foreach (stub in level.buildable_stubs)
		{
			if (stub.buildablezone.buildable_name == level.buildables_available[self.buildables_available_index])
			{
				piece = stub.buildablezone.pieces[0];
				break;
			}
		}

		player maps/mp/zombies/_zm_buildables::player_set_buildable_piece(piece, slot);

		piece = player maps/mp/zombies/_zm_buildables::player_get_buildable_piece(slot);

		if ( !isDefined( piece ) )
		{
			if ( isDefined( level.zombie_buildables[ self.equipname ].hint_more ) )
			{
				self.hint_string = level.zombie_buildables[ self.equipname ].hint_more;
			}
			else
			{
				self.hint_string = &"ZOMBIE_BUILD_PIECE_MORE";
			}

			if ( isDefined( level.custom_buildable_need_part_vo ) )
			{
				player thread [[ level.custom_buildable_need_part_vo ]]();
			}
			return 0;
		}
		else
		{
			if ( isDefined( self.bound_to_buildable ) && !self.bound_to_buildable.buildablezone maps/mp/zombies/_zm_buildables::buildable_has_piece( piece ) )
			{
				if ( isDefined( level.zombie_buildables[ self.bound_to_buildable.equipname ].hint_wrong ) )
				{
					self.hint_string = level.zombie_buildables[ self.bound_to_buildable.equipname ].hint_wrong;
				}
				else
				{
					self.hint_string = &"ZOMBIE_BUILD_PIECE_WRONG";
				}

				if ( isDefined( level.custom_buildable_wrong_part_vo ) )
				{
					player thread [[ level.custom_buildable_wrong_part_vo ]]();
				}
				return 0;
			}
			else
			{
				if ( !isDefined( self.bound_to_buildable ) && !self.buildable_pool pooledbuildable_has_piece( piece ) )
				{
					if ( isDefined( level.zombie_buildables[ self.equipname ].hint_wrong ) )
					{
						self.hint_string = level.zombie_buildables[ self.equipname ].hint_wrong;
					}
					else
					{
						self.hint_string = &"ZOMBIE_BUILD_PIECE_WRONG";
					}
					return 0;
				}
				else
				{
					if ( isDefined( self.bound_to_buildable ) )
					{
						if ( isDefined( level.zombie_buildables[ piece.buildablename ].hint ) )
						{
							self.hint_string = level.zombie_buildables[ piece.buildablename ].hint;
						}
						else
						{
							self.hint_string = "Missing buildable hint";
						}
					}

					if ( isDefined( level.zombie_buildables[ piece.buildablename ].hint ) )
					{
						self.hint_string = level.zombie_buildables[ piece.buildablename ].hint;
					}
					else
					{
						self.hint_string = "Missing buildable hint";
					}
				}
			}
		}
	}
	else
	{
		return trigger [[ self.original_prompt_and_visibility_func ]]( player );
	}
	return 1;
}

pooledbuildable_has_piece( piece )
{
	return isDefined( self pooledbuildable_stub_for_piece( piece ) );
}

pooledbuildable_stub_for_piece( piece )
{
	foreach (stub in self.stubs)
	{
		if ( !isDefined( stub.bound_to_buildable ) )
		{
			if ( stub.buildablezone maps/mp/zombies/_zm_buildables::buildable_has_piece( piece ) )
			{
				return stub;
			}
		}
	}

	return undefined;
}

choose_open_buildable( player )
{
	self endon( "kill_choose_open_buildable" );

	n_playernum = player getentitynumber();
	b_got_input = 1;
	hinttexthudelem = newclienthudelem( player );
	hinttexthudelem.alignx = "center";
	hinttexthudelem.aligny = "middle";
	hinttexthudelem.horzalign = "center";
	hinttexthudelem.vertalign = "bottom";
	hinttexthudelem.y = -100;
	hinttexthudelem.foreground = 1;
	hinttexthudelem.font = "default";
	hinttexthudelem.fontscale = 1;
	hinttexthudelem.alpha = 1;
	hinttexthudelem.color = ( 1, 1, 1 );
	hinttexthudelem settext( "Press [{+actionslot 1}] or [{+actionslot 2}] to change item" );

	if (!isDefined(self.buildables_available_index))
	{
		self.buildables_available_index = 0;
	}

	while ( isDefined( self.playertrigger[ n_playernum ] ) && !self.built )
	{
		if (!player isTouching(self.playertrigger[n_playernum]))
		{
			hinttexthudelem.alpha = 0;
			wait 0.05;
			continue;
		}

		hinttexthudelem.alpha = 1;

		if ( player actionslotonebuttonpressed() )
		{
			self.buildables_available_index++;
			b_got_input = 1;
		}
		else
		{
			if ( player actionslottwobuttonpressed() )
			{
				self.buildables_available_index--;

				b_got_input = 1;
			}
		}

		if ( self.buildables_available_index >= level.buildables_available.size )
		{
			self.buildables_available_index = 0;
		}
		else
		{
			if ( self.buildables_available_index < 0 )
			{
				self.buildables_available_index = level.buildables_available.size - 1;
			}
		}

		if ( b_got_input )
		{
			piece = undefined;
			foreach (stub in level.buildable_stubs)
			{
				if (stub.buildablezone.buildable_name == level.buildables_available[self.buildables_available_index])
				{
					piece = stub.buildablezone.pieces[0];
					break;
				}
			}
			slot = self.buildablestruct.buildable_slot;
			player maps/mp/zombies/_zm_buildables::player_set_buildable_piece(piece, slot);

			self.equipname = level.buildables_available[self.buildables_available_index];
			self.hint_string = level.zombie_buildables[self.equipname].hint;
			self.playertrigger[n_playernum] sethintstring(self.hint_string);
			b_got_input = 0;
		}

		if ( player is_player_looking_at( self.playertrigger[n_playernum].origin, 0.76 ) )
		{
			hinttexthudelem.alpha = 1;
		}
		else
		{
			hinttexthudelem.alpha = 0;
		}

		wait 0.05;
	}

	hinttexthudelem destroy();
}

buildablestub_build_succeed()
{
	self notify("buildablestub_build_succeed");
	self endon("buildablestub_build_succeed");

	self waittill( "build_succeed" );

	self.stub maps/mp/zombies/_zm_buildables::buildablestub_remove();
	arrayremovevalue(level.buildables_available, self.stub.buildablezone.buildable_name);
	if (level.buildables_available.size == 0)
	{
		foreach (stub in level.buildable_stubs)
		{
			switch(stub.equipname)
			{
				case "turbine":
				case "subwoofer_zm":
				case "springpad_zm":
				case "headchopper_zm":
					maps/mp/zombies/_zm_unitrigger::unregister_unitrigger(stub);
					break;
			}
		}
	}
}

// adds updated hintstring and functionality
updatebuildables()
{
	foreach (stub in level._unitriggers.trigger_stubs)
	{
		if(IsDefined(stub.equipname))
		{
			equipname = stub get_equipname();
			stub.cost = 1000;
			stub.trigger_hintstring = "Hold ^3[{+activate}]^7 for " + equipname + " [Cost: " + stub.cost + "]";
			stub.trigger_func = ::buildable_place_think;
		}
	}
}

removebuildable( buildable, after_built )
{
	if (!isDefined(after_built))
	{
		after_built = 0;
	}

	if (after_built)
	{
		foreach (stub in level._unitriggers.trigger_stubs)
		{
			if(IsDefined(stub.equipname) && stub.equipname == buildable)
			{
				stub.model hide();
				maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( stub );
				return;
			}
		}
	}
	else
	{
		foreach (stub in level.buildable_stubs)
		{
			if ( !isDefined( buildable ) || stub.equipname == buildable )
			{
				if ( isDefined( buildable ) || stub.persistent != 3 )
				{
					stub maps/mp/zombies/_zm_buildables::buildablestub_remove();
					foreach (piece in stub.buildablezone.pieces)
					{
						piece maps/mp/zombies/_zm_buildables::piece_unspawn();
					}
					maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( stub );
					return;
				}
			}
		}
	}
}

buildable_piece_remove_on_last_stand()
{
	self endon( "disconnect" );

	self thread buildable_get_last_piece();

	while (1)
	{
		self waittill("entering_last_stand");

		if (isDefined(self.last_piece))
		{
			self.last_piece maps/mp/zombies/_zm_buildables::piece_unspawn();
		}
	}
}

buildable_get_last_piece()
{
	self endon( "disconnect" );

	while (1)
	{
		if (!self maps/mp/zombies/_zm_laststand::player_is_in_laststand())
		{
			self.last_piece = maps/mp/zombies/_zm_buildables::player_get_buildable_piece(0);
		}

		wait 0.05;
	}
}

// MOTD/Origins style buildables
buildcraftables()
{
	// need a wait or else some buildables dont build
	wait 1;

	if(is_classic())
	{
		if(level.scr_zm_map_start_location == "prison")
		{
			buildcraftable( "alcatraz_shield_zm" );
			buildcraftable( "packasplat" );
			changecraftableoption( 0 );
		}
		else if(level.scr_zm_map_start_location == "tomb")
		{
			buildcraftable( "tomb_shield_zm" );
			buildcraftable( "equip_dieseldrone_zm" );
			takecraftableparts( "gramophone" );
		}
	}
}

changecraftableoption( index )
{
	foreach (craftable in level.a_uts_craftables)
	{
		if (craftable.equipname == "open_table")
		{
			craftable thread setcraftableoption( index );
		}
	}
}

setcraftableoption( index )
{
	self endon("death");

	while (self.a_uts_open_craftables_available.size <= 0)
	{
		wait 0.05;
	}

	if (self.a_uts_open_craftables_available.size > 1)
	{
		self.n_open_craftable_choice = index;
		self.equipname = self.a_uts_open_craftables_available[self.n_open_craftable_choice].equipname;
		self.hint_string = self.a_uts_open_craftables_available[self.n_open_craftable_choice].hint_string;
		foreach (trig in self.playertrigger)
		{
			trig sethintstring( self.hint_string );
		}
	}
}

takecraftableparts( buildable )
{
	player = get_players()[ 0 ];
	foreach (stub in level.zombie_include_craftables)
	{
		if ( stub.name == buildable )
		{
			foreach (piece in stub.a_piecestubs)
			{
				piecespawn = piece.piecespawn;
				if ( isDefined( piecespawn ) )
				{
					player player_take_piece( piecespawn );
				}
			}

			return;
		}
	}
}

buildcraftable( buildable )
{
	player = get_players()[ 0 ];
	foreach (stub in level.a_uts_craftables)
	{
		if ( stub.craftablestub.name == buildable )
		{
			foreach (piece in stub.craftablespawn.a_piecespawns)
			{
				piecespawn = get_craftable_piece( stub.craftablestub.name, piece.piecename );
				if ( isDefined( piecespawn ) )
				{
					player player_take_piece( piecespawn );
				}
			}

			return;
		}
	}
}

get_craftable_piece( str_craftable, str_piece )
{
	foreach (uts_craftable in level.a_uts_craftables)
	{
		if ( uts_craftable.craftablestub.name == str_craftable )
		{
			foreach (piecespawn in uts_craftable.craftablespawn.a_piecespawns)
			{
				if ( piecespawn.piecename == str_piece )
				{
					return piecespawn;
				}
			}
		}
	}
	return undefined;
}

player_take_piece( piecespawn )
{
	piecestub = piecespawn.piecestub;
	damage = piecespawn.damage;

	if ( isDefined( piecestub.onpickup ) )
	{
		piecespawn [[ piecestub.onpickup ]]( self );
	}

	if ( isDefined( piecestub.is_shared ) && piecestub.is_shared )
	{
		if ( isDefined( piecestub.client_field_id ) )
		{
			level setclientfield( piecestub.client_field_id, 1 );
		}
	}
	else
	{
		if ( isDefined( piecestub.client_field_state ) )
		{
			self setclientfieldtoplayer( "craftable", piecestub.client_field_state );
		}
	}

	piecespawn piece_unspawn();
	piecespawn notify( "pickup" );

	if ( isDefined( piecestub.is_shared ) && piecestub.is_shared )
	{
		piecespawn.in_shared_inventory = 1;
	}

	self adddstat( "buildables", piecespawn.craftablename, "pieces_pickedup", 1 );
}

piece_unspawn()
{
	if ( isDefined( self.model ) )
	{
		self.model delete();
	}
	self.model = undefined;
	if ( isDefined( self.unitrigger ) )
	{
		thread maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( self.unitrigger );
	}
	self.unitrigger = undefined;
}

remove_buildable_pieces( buildable_name )
{
	foreach (buildable in level.zombie_include_buildables)
	{
		if(IsDefined(buildable.name) && buildable.name == buildable_name)
		{
			pieces = buildable.buildablepieces;
			for(i = 0; i < pieces.size; i++)
			{
				pieces[i] maps/mp/zombies/_zm_buildables::piece_unspawn();
			}
			return;
		}
	}
}

war_machine_explode_on_impact()
{
	self endon("disconnect");

	while(1)
	{
		self waittill("grenade_launcher_fire", grenade, weapname);

		if(weapname == "m32_zm")
		{
			grenade thread grenade_explode_on_impact();
		}
	}
}

grenade_explode_on_impact()
{
	self endon("death");

	self waittill("grenade_bounce", pos);

	self.origin = pos; // need this or position is slightly off

	self resetmissiledetonationtime(0);
}

jetgun_increase_grind_range()
{
	level.zombies_vars["jetgun_grind_range"] = 256;
}

jetgun_fast_cooldown()
{
	self endon( "disconnect" );

	if ( !maps/mp/zombies/_zm_weapons::is_weapon_included( "jetgun_zm" ) )
	{
		return;
	}

	while ( 1 )
	{
		if (!IsDefined(self.jetgun_heatval))
		{
			wait 0.05;
			continue;
		}

		if ( self getcurrentweapon() == "jetgun_zm" )
		{
			if (self AttackButtonPressed())
			{
				if (self IsMeleeing())
				{
					self.jetgun_heatval += .875; // have to add .025 if holding weapon

					if (self.jetgun_heatval > 100)
					{
						self.jetgun_heatval = 100;
					}

					self setweaponoverheating( self.jetgun_overheating, self.jetgun_heatval );
				}
			}
			else
			{
				self.jetgun_heatval -= .075; // have to add .025 if holding weapon

				if (self.jetgun_heatval < 0)
				{
					self.jetgun_heatval = 0;
				}

				self setweaponoverheating( self.jetgun_overheating, self.jetgun_heatval );
			}
		}
		else
		{
			self.jetgun_heatval -= .1;

			if (self.jetgun_heatval < 0)
			{
				self.jetgun_heatval = 0;
			}
		}

		wait 0.05;
	}
}

jetgun_fast_spinlerp()
{
	self endon( "disconnect" );

	if ( !maps/mp/zombies/_zm_weapons::is_weapon_included( "jetgun_zm" ) )
	{
		return;
	}

	previous_spinlerp = 0;

	while ( 1 )
	{
		if ( self getcurrentweapon() == "jetgun_zm" )
		{
			if (self AttackButtonPressed() && !self IsSwitchingWeapons())
			{
				previous_spinlerp -= 0.0166667;
				if (previous_spinlerp < -1)
				{
					previous_spinlerp = -1;
				}

				if (self IsMeleeing())
				{
					self setcurrentweaponspinlerp(previous_spinlerp / 2);
				}
				else
				{
					self setcurrentweaponspinlerp(previous_spinlerp);
				}
			}
			else
			{
				previous_spinlerp += 0.01;
				if (previous_spinlerp > 0)
				{
					previous_spinlerp = 0;
				}
				self setcurrentweaponspinlerp(0);
			}
		}
		else
		{
			previous_spinlerp = 0;
		}

		wait 0.05;
	}
}

jetgun_overheated_fix()
{
	self endon( "disconnect" );

	if ( !maps/mp/zombies/_zm_weapons::is_weapon_included( "jetgun_zm" ) )
	{
		return;
	}

	while ( 1 )
	{
		self waittill( "jetgun_overheated" );

		weapon_org = self gettagorigin( "tag_weapon" );
		self dodamage( 50, weapon_org );
		self playsound( "wpn_jetgun_explo" );

		wait 0.05;

		self.jetgun_heatval = 100;
		self.jetgun_overheating = 0;
	}
}

jetgun_remove_forced_weapon_switch()
{
	foreach (buildable in level.zombie_include_buildables)
	{
		if(IsDefined(buildable.name) && buildable.name == "jetgun_zm")
		{
			buildable.onbuyweapon = undefined;
			return;
		}
	}
}

give_additional_perks()
{
	self endon( "disconnect" );

	for ( ;; )
	{
		self waittill_any("perk_acquired", "perk_lost");

		if (self HasPerk("specialty_fastreload"))
		{
			self SetPerk("specialty_fastads");
			self SetPerk("specialty_fastweaponswitch");
			self Setperk( "specialty_fasttoss" );
		}
		else
		{
			self UnsetPerk("specialty_fastads");
			self UnsetPerk("specialty_fastweaponswitch");
			self Unsetperk( "specialty_fasttoss" );
		}

		if (self HasPerk("specialty_deadshot"))
		{
			self SetPerk("specialty_stalker");
			self Setperk( "specialty_sprintrecovery" );
		}
		else
		{
			self UnsetPerk("specialty_stalker");
			self Unsetperk( "specialty_sprintrecovery" );
		}

		if (self HasPerk("specialty_longersprint"))
		{
			self Setperk( "specialty_movefaster" );
		}
		else
		{
			self Unsetperk( "specialty_movefaster" );
		}
	}
}

solo_lives_fix()
{
	self endon("disconnect");

	if (!(is_classic() || is_standard()))
	{
		return;
	}

	if (isDefined(level.zombiemode_using_afterlife) && level.zombiemode_using_afterlife)
	{
		return;
	}

	flag_wait( "start_zombie_round_logic" );

	if (!flag("solo_game"))
	{
		return;
	}

	self.lives = 3;
	self.bought_solo_revive = 0;
	saved_lives = self.lives;

	while (1)
	{
		self waittill_any("perk_acquired", "perk_lost", "player_revived");

		if (self hasPerk("specialty_finalstand"))
		{
			// fix for Who's Who giving Quick Revive when player hasn't purchased actual Quick Revive
			if (!self.bought_solo_revive)
			{
				self unsetPerk("specialty_quickrevive");
			}

			self waittill("fake_revive");

			has_revive = 0;
			foreach (perk in self.loadout.perks)
			{
				if (perk == "specialty_quickrevive")
				{
					has_revive = 1;
					break;
				}
			}

			self waittill("chugabud_effects_cleanup");

			still_has_revive = 0;
			foreach (perk in self.perks_active)
			{
				if (perk == "specialty_quickrevive")
				{
					still_has_revive = 1;
					break;
				}
			}

			// fix to remove a solo revive if auto revived from Who's Who due to having Quick Revive
			if (has_revive && !still_has_revive && saved_lives > 0)
			{
				saved_lives--;
			}

			// fix for Who's Who removing solo revives
			self.lives = saved_lives;
		}

		saved_lives = self.lives;

		if (self.perks_active.size < 1)
		{
			self unsetPerk("specialty_quickrevive");
			self.bought_solo_revive = 0;
			continue;
		}

		self setPerk("specialty_quickrevive");

		has_revive = 0;
		foreach (perk in self.perks_active)
		{
			if (perk == "specialty_quickrevive")
			{
				has_revive = 1;
				break;
			}
		}

		self.bought_solo_revive = has_revive;
	}
}

solo_revive_trigger_fix()
{
	if (!(is_classic() || is_standard()))
	{
		return;
	}

	if (isDefined(level.zombiemode_using_afterlife) && level.zombiemode_using_afterlife)
	{
		return;
	}

	flag_wait( "start_zombie_round_logic" );

	if (!flag("solo_game"))
	{
		return;
	}

	if (level.script == "zm_nuked")
	{
		while (!isDefined(level.revive_machine_spawned) || !level.revive_machine_spawned)
		{
			wait 0.05;
		}
	}

	revive_triggers = getentarray("specialty_quickrevive", "script_noteworthy");
	foreach (trig in revive_triggers)
	{
		new_trig = spawn( "trigger_radius_use", trig.origin, 0, 40, 70 );
		new_trig.targetname = trig.targetname;
		new_trig.script_noteworthy = trig.script_noteworthy;
		new_trig triggerignoreteam();
		new_trig.clip = trig.clip;
		new_trig.machine = trig.machine;
		new_trig.bump = trig.bump;
		new_trig.blocker_model = trig.blocker_model;
		new_trig.script_int = trig.script_int;
		new_trig.turn_on_notify = trig.turn_on_notify;
		new_trig.script_sound = trig.script_sound;
		new_trig.script_string = trig.script_string;
		new_trig.script_label = trig.script_label;
		new_trig.target = trig.target;

		if (is_classic() && level.scr_zm_map_start_location == "tomb")
		{
			new_trig.str_zone_name = trig.str_zone_name;
			level.zone_capture.zones[trig.str_zone_name].perk_machines["revive"] = new_trig;
			level.zone_capture.zones[trig.str_zone_name].perk_fx_func = undefined;
		}

		trig delete();

		new_trig thread solo_revive_trigger_think();
		new_trig thread maps/mp/zombies/_zm_perks::electric_perks_dialog();

		powered_on = maps/mp/zombies/_zm_perks::get_perk_machine_start_state( new_trig.script_noteworthy );
		maps/mp/zombies/_zm_power::add_powered_item( maps/mp/zombies/_zm_power::perk_power_on, ::perk_power_off, maps/mp/zombies/_zm_power::perk_range, maps/mp/zombies/_zm_power::cost_low_if_local, 0, powered_on, new_trig );
	}
}

solo_revive_trigger_think()
{
	self endon( "death" );

	wait 0.01;
	perk = self.script_noteworthy;
	solo = 0;
	start_on = 0;
	level.revive_machine_is_solo = 0;

	self sethintstring( &"ZOMBIE_NEED_POWER" );
	self setcursorhint( "HINT_NOICON" );
	self usetriggerrequirelookat();
	cost = 1500;
	self.cost = cost;

	if ( !start_on )
	{
		notify_name = perk + "_power_on";
		level waittill( notify_name );
	}

	if ( !isDefined( level._perkmachinenetworkchoke ) )
	{
		level._perkmachinenetworkchoke = 0;
	}
	else
	{
		level._perkmachinenetworkchoke++;
	}

	i = 0;
	while ( i < level._perkmachinenetworkchoke )
	{
		wait_network_frame();
		i++;
	}

	self thread maps/mp/zombies/_zm_audio::perks_a_cola_jingle_timer();
	self thread check_player_has_solo_revive( perk );
	self sethintstring( &"ZOMBIE_PERK_QUICKREVIVE", cost );

	for ( ;; )
	{
		self waittill( "trigger", player );
		index = maps/mp/zombies/_zm_weapons::get_player_index( player );
		if ( player maps/mp/zombies/_zm_laststand::player_is_in_laststand() || isDefined( player.intermission ) && player.intermission )
		{
			continue;
		}
		else
		{
			if ( player in_revive_trigger() )
			{
				continue;
			}
			else if ( !player maps/mp/zombies/_zm_magicbox::can_buy_weapon() )
			{
				wait 0.1;
				continue;
			}
			else if ( player isthrowinggrenade() )
			{
				wait 0.1;
				continue;
			}
			else if ( player isswitchingweapons() )
			{
				wait 0.1;
				continue;
			}
			else if ( player.is_drinking > 0 )
			{
				wait 0.1;
				continue;
			}
			else if ( player.bought_solo_revive )
			{
				self playsound( "deny" );
				player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "perk_deny", undefined, 1 );
				continue;
			}
			else if ( isDefined( level.custom_perk_validation ) )
			{
				valid = self [[ level.custom_perk_validation ]]( player );
				if ( !valid )
				{
					continue;
				}
			}

			current_cost = cost;
			if ( player maps/mp/zombies/_zm_pers_upgrades_functions::is_pers_double_points_active() )
			{
				current_cost = player maps/mp/zombies/_zm_pers_upgrades_functions::pers_upgrade_double_points_cost( current_cost );
			}

			if ( player.score < current_cost )
			{
				self playsound( "evt_perk_deny" );
				player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "perk_deny", undefined, 0 );
				continue;
			}
			else if ( player.num_perks >= player get_player_perk_purchase_limit() )
			{
				self playsound( "evt_perk_deny" );
				player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "sigh" );
				continue;
			}
			else
			{
				sound = "evt_bottle_dispense";
				playsoundatposition( sound, self.origin );
				player maps/mp/zombies/_zm_score::minus_to_player_score( current_cost, 1 );
				player.perk_purchased = perk;
				self thread maps/mp/zombies/_zm_audio::play_jingle_or_stinger( self.script_label );
				self thread maps/mp/zombies/_zm_perks::vending_trigger_post_think( player, perk );
			}
		}
	}
}

check_player_has_solo_revive( perk )
{
	self endon( "death" );

	dist = 16384;
	while ( 1 )
	{
		players = get_players();
		foreach (player in players)
		{
			if ( distancesquared( player.origin, self.origin ) < dist )
			{
				if ( !player.bought_solo_revive && !player in_revive_trigger() && !is_equipment_that_blocks_purchase( player getcurrentweapon() ) && !player hacker_active() )
				{
					self setinvisibletoplayer( player, 0 );
				}
				else
				{
					self setinvisibletoplayer( player, 1 );
				}
			}
		}

		wait 0.05;
	}
}

highrise_solo_revive_fix()
{
	if (!(is_classic() && level.scr_zm_map_start_location == "rooftop"))
	{
		return;
	}

	flag_wait( "start_zombie_round_logic" );

	if (!flag("solo_game"))
	{
		return;
	}

	flag_wait( "perks_ready" );
	flag_wait( "initial_blackscreen_passed" );
	wait 1;

	revive_elevator = undefined;
	foreach (elevator in level.elevators)
	{
		if (elevator.body.perk_type == "vending_revive")
		{
			revive_elevator = elevator;
			break;
		}
	}

	revive_elevator.body.elevator_stop = 1;
	revive_elevator.body.lock_doors = 1;
	revive_elevator.body perkelevatordoor(0);

	flag_wait( "power_on" );

	revive_elevator.body.elevator_stop = 0;
	revive_elevator.body.lock_doors = 0;
	revive_elevator.body perkelevatordoor(1);
}

perkelevatordoor( set )
{
	self endon( "death" );

	animtime = 1;
	if ( is_true( set ) )
	{
		self.door_state = set;
		self setanim( level.perk_elevators_door_open_state, 1, animtime, 1 );
		wait getanimlength( level.perk_elevators_door_open_state );
	}
	else
	{
		self.door_state = set;
		self setanim( level.perk_elevators_door_close_state, 1, animtime, 1 );
		wait getanimlength( level.perk_elevators_door_close_state );
	}

	self notify( "PerkElevatorDoor" );
}

disable_sniper_scope_sway()
{
	self endon( "disconnect" );

	self.sway_disabled = 0;

	while (1)
	{
		if (!self hasPerk("specialty_deadshot"))
		{
			if (isads(self))
			{
				if (!self.sway_disabled)
				{
					self.sway_disabled = 1;
					self setclientfieldtoplayer( "deadshot_perk", 1 );
				}
			}
			else
			{
				if (self.sway_disabled)
				{
					self.sway_disabled = 0;
					self setclientfieldtoplayer( "deadshot_perk", 0 );
				}
			}
		}

		wait 0.05;
	}
}

tombstone_spawn()
{
	self endon("disconnect");
	self endon("player_revived");

	self waittill("bled_out");

	dc = spawn( "script_model", self.origin + vectorScale( ( 0, 0, 1 ), 40 ) );
	dc.angles = self.angles;
	dc setmodel( "tag_origin" );
	dc_icon = spawn( "script_model", self.origin + vectorScale( ( 0, 0, 1 ), 40 ) );
	dc_icon.angles = self.angles;
	dc_icon setmodel( "ch_tombstone1" );
	dc_icon linkto( dc );
	dc.icon = dc_icon;
	dc.script_noteworthy = "player_tombstone_model";
	dc.player = self;
	self thread maps/mp/zombies/_zm_tombstone::tombstone_clear();
	dc thread maps/mp/zombies/_zm_tombstone::tombstone_wobble();
	dc thread maps/mp/zombies/_zm_tombstone::tombstone_revived( self );
	result = self waittill_any_return( "player_revived", "spawned_player", "disconnect" );
	if ( result == "player_revived" || result == "disconnect" )
	{
		dc notify( "tombstone_timedout" );
		dc_icon unlink();
		dc_icon delete();
		dc delete();
		return;
	}
	dc thread tombstone_timeout();
	dc thread tombstone_grab();
}

tombstone_timeout()
{
	self endon( "tombstone_grabbed" );

	player = self.player;
	result = player waittill_any_return("bled_out", "disconnect");

	if (result != "disconnect")
	{
		player playsoundtoplayer( "zmb_tombstone_timer_out", player );
	}
	self notify( "tombstone_timedout" );
	self.icon unlink();
	self.icon delete();
	self delete();
}

tombstone_grab()
{
	self endon( "tombstone_timedout" );
	wait 1;
	while ( isDefined( self ) )
	{
		players = get_players();
		i = 0;
		while ( i < players.size )
		{
			if ( players[ i ].is_zombie )
			{
				i++;
				continue;
			}
			else
			{
				if ( isDefined( self.player ) && players[ i ] == self.player )
				{
					dist = distance( players[ i ].origin, self.origin );
					if ( dist < 64 )
					{
						playfx( level._effect[ "powerup_grabbed" ], self.origin );
						playfx( level._effect[ "powerup_grabbed_wave" ], self.origin );
						players[ i ] maps/mp/zombies/_zm_tombstone::tombstone_give();
						wait 0.1;
						playsoundatposition( "zmb_tombstone_grab", self.origin );
						self stoploopsound();
						self.icon unlink();
						self.icon delete();
						self delete();
						self notify( "tombstone_grabbed" );
						players[ i ] clientnotify( "dc0" );
						players[ i ] notify( "dance_on_my_grave" );
					}
				}
			}
			i++;
		}
		wait_network_frame();
	}
}

tombstone_save_perks()
{
	self endon("disconnect");

	while (1)
	{
		self waittill_any("perk_acquired", "perk_lost");

		if ( self maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
		{
			continue;
		}

		if (isDefined(self.a_restoring_perks))
		{
			continue;
		}

		if (self hasPerk("specialty_scavenger"))
		{
			if ( isDefined( self.perks_active ) )
			{
				self.a_saved_perks = [];
				self.a_saved_perks = arraycopy( self.perks_active );
			}
			else
			{
				self.a_saved_perks = self maps/mp/zombies/_zm_perks::get_perk_array( 0 );
			}
		}
		else
		{
			self.a_saved_perks = undefined;
		}
	}
}

tombstone_restore_perks()
{
	self endon("disconnect");

	while (1)
	{
		self waittill( "player_revived" );

		discard_tombstone = 0;
		if ( isDefined( self.a_saved_perks ) && self.a_saved_perks.size >= 2 )
		{
			i = 0;
			while ( i < self.a_saved_perks.size )
			{
				perk = self.a_saved_perks[ i ];
				if ( perk == "specialty_scavenger" )
				{
					discard_tombstone = 1;
				}
				i++;
			}

			self.a_restoring_perks = 1;
			size = self.a_saved_perks.size;
			i = 0;
			while ( i < size )
			{
				perk = self.a_saved_perks[ i ];

				if ( perk == "specialty_scavenger" && discard_tombstone == 1 )
				{
					i++;
					continue;
				}

				if ( !(perk == "specialty_quickrevive" && flag("solo_game")) )
				{
					if ( self hasperk( perk ) )
					{
						i++;
						continue;
					}
				}

				self maps/mp/zombies/_zm_perks::give_perk( perk );
				wait_network_frame();
				i++;
			}
			self.a_restoring_perks = undefined;
		}

		self.a_saved_perks = undefined;
	}
}

additionalprimaryweapon_save_weapons()
{
	self endon("disconnect");

	while (1)
	{
		if (!self hasPerk("specialty_additionalprimaryweapon"))
		{
			self waittill("perk_acquired");
			wait 0.05;
		}

		if (self hasPerk("specialty_additionalprimaryweapon"))
		{
			primaries = self getweaponslistprimaries();
			if (primaries.size >= 3)
			{
				weapon = primaries[primaries.size - 1];
				self.a_saved_weapon = maps/mp/zombies/_zm_weapons::get_player_weapondata(self, weapon);
			}
			else
			{
				self.a_saved_weapon = undefined;
			}
		}

		wait 0.05;
	}
}

additionalprimaryweapon_restore_weapons()
{
	self endon("disconnect");

	while (1)
	{
		self waittill("perk_acquired");

		if (isDefined(self.a_saved_weapon) && self hasPerk("specialty_additionalprimaryweapon"))
		{
			pap_triggers = getentarray( "specialty_weapupgrade", "script_noteworthy" );

			give_wep = 1;
			if ( isDefined( self ) && self maps/mp/zombies/_zm_weapons::has_weapon_or_upgrade( self.a_saved_weapon["name"] ) )
			{
				give_wep = 0;
			}
			else if ( !maps/mp/zombies/_zm_weapons::limited_weapon_below_quota( self.a_saved_weapon["name"], self, pap_triggers ) )
			{
				give_wep = 0;
			}
			else if ( !self maps/mp/zombies/_zm_weapons::player_can_use_content( self.a_saved_weapon["name"] ) )
			{
				give_wep = 0;
			}
			else if ( isDefined( level.custom_magic_box_selection_logic ) )
			{
				if ( !( [[ level.custom_magic_box_selection_logic ]]( self.a_saved_weapon["name"], self, pap_triggers ) ) )
				{
					give_wep = 0;
				}
			}
			else if ( isDefined( self ) && isDefined( level.special_weapon_magicbox_check ) )
			{
				give_wep = self [[ level.special_weapon_magicbox_check ]]( self.a_saved_weapon["name"] );
			}

			if (give_wep)
			{
				current_wep = self getCurrentWeapon();
				self maps/mp/zombies/_zm_weapons::weapondata_give(self.a_saved_weapon);
				self switchToWeapon(current_wep);
			}

			self.a_saved_weapon = undefined;
		}
	}
}

additionalprimaryweapon_indicator()
{
	self endon("disconnect");

	additionalprimaryweapon_indicator_hud = newClientHudElem(self);
	additionalprimaryweapon_indicator_hud.alignx = "right";
	additionalprimaryweapon_indicator_hud.aligny = "bottom";
	additionalprimaryweapon_indicator_hud.horzalign = "user_right";
	additionalprimaryweapon_indicator_hud.vertalign = "user_bottom";
	if (level.script == "zm_highrise")
	{
		additionalprimaryweapon_indicator_hud.x -= 100;
		additionalprimaryweapon_indicator_hud.y -= 80;
	}
	else if (level.script == "zm_tomb")
	{
		additionalprimaryweapon_indicator_hud.x -= 75;
		additionalprimaryweapon_indicator_hud.y -= 60;
	}
	else
	{
		additionalprimaryweapon_indicator_hud.x -= 75;
		additionalprimaryweapon_indicator_hud.y -= 80;
	}
	additionalprimaryweapon_indicator_hud.alpha = 0;
	additionalprimaryweapon_indicator_hud.color = ( 1, 1, 1 );
	additionalprimaryweapon_indicator_hud.hidewheninmenu = 1;
	additionalprimaryweapon_indicator_hud setShader("specialty_additionalprimaryweapon_zombies", 24, 24);

	while (1)
	{
		self waittill_any("weapon_change", "specialty_additionalprimaryweapon_stop", "spawned_player");

		if (self hasPerk("specialty_additionalprimaryweapon") && isDefined(self.a_saved_weapon) && self getCurrentWeapon() == self.a_saved_weapon["name"])
		{
			additionalprimaryweapon_indicator_hud fadeOverTime(0.5);
			additionalprimaryweapon_indicator_hud.alpha = 1;
		}
		else
		{
			additionalprimaryweapon_indicator_hud fadeOverTime(0.5);
			additionalprimaryweapon_indicator_hud.alpha = 0;
		}
	}
}

whos_who_spawn_changes()
{
	self endon( "disconnect" );

	while (1)
	{
		self waittill("fake_revive");

		self.pers_upgrades_awarded["revive"] = 1;

		self takeweapon("frag_grenade_zm");
		self takeweapon("claymore_zm");
		self giveweapon("sticky_grenade_zm");
		self setweaponammoclip("sticky_grenade_zm", 2);

		foreach (perk in self.loadout.perks)
		{
			self maps/mp/zombies/_zm_perks::give_perk(perk);
		}

		self waittill("chugabud_effects_cleanup");

		self.pers_upgrades_awarded["revive"] = 0;
	}
}

electric_cherry_unlimited()
{
	self endon( "disconnect" );

	for ( ;; )
	{
		self.consecutive_electric_cherry_attacks = 0;

		wait 0.5;
	}
}

zombie_health_fix()
{
	for ( ;; )
	{
		level waittill( "start_of_round" );

		wait 0.05;

		if(level.zombie_health > 1000000)
		{
			level.zombie_health = 1000000;
		}
	}
}

show_powerswitch()
{
	getent( "powerswitch_p6_zm_buildable_pswitch_hand", "targetname" ) show();
	getent( "powerswitch_p6_zm_buildable_pswitch_body", "targetname" ) show();
	getent( "powerswitch_p6_zm_buildable_pswitch_lever", "targetname" ) show();
}

zone_changes()
{
	if(is_classic())
	{
		if(level.scr_zm_map_start_location == "rooftop")
		{
			// AN94 to Debris
			level.zones[ "zone_orange_level3a" ].adjacent_zones[ "zone_orange_level3b" ].is_connected = 0;

			// Trample Steam to Skyscraper
			level.zones[ "zone_green_level3b" ].adjacent_zones[ "zone_blue_level1c" ] structdelete();
			level.zones[ "zone_green_level3b" ].adjacent_zones[ "zone_blue_level1c" ] = undefined;
		}
	}
	else
	{
		if(level.scr_zm_map_start_location == "farm")
		{
			// Barn to Farm
			flag_set("OnFarm_enter");
		}
	}
}

screecher_spawner_changes()
{
	level.screecher_spawners = getentarray( "screecher_zombie_spawner", "script_noteworthy" );
	array_thread( level.screecher_spawners, ::add_spawn_function, ::screecher_prespawn_decrease_health );
}

screecher_prespawn_decrease_health()
{
	self.player_score = 12;
}

transit_power_local_electric_doors_globally()
{
	if( !(is_classic() && level.scr_zm_map_start_location == "transit") )
	{
		return;
	}

	for ( ;; )
	{
		flag_wait( "power_on" );

		local_power = [];
		zombie_doors = getentarray( "zombie_door", "targetname" );
		for ( i = 0; i < zombie_doors.size; i++ )
		{
			if ( isDefined( zombie_doors[i].script_noteworthy ) && zombie_doors[i].script_noteworthy == "local_electric_door" )
			{
				local_power[local_power.size] = maps/mp/zombies/_zm_power::add_local_power( zombie_doors[i].origin, 16 );
			}
		}

		flag_waitopen( "power_on" );

		for (i = 0; i < local_power.size; i++)
		{
			maps/mp/zombies/_zm_power::end_local_power( local_power[i] );
			local_power[i] = undefined;
		}
	}
}

transit_add_tombstone_machine_solo()
{
	if (!(is_classic() && level.scr_zm_map_start_location == "transit"))
	{
		return;
	}

	if (!flag("solo_game"))
	{
		return;
	}

	perk_struct = undefined;
	structs = getstructarray("zm_perk_machine", "targetname");
	foreach (struct in structs)
	{
		if (IsDefined(struct.script_noteworthy) && IsDefined(struct.script_string))
		{
			if (struct.script_noteworthy == "specialty_scavenger" && IsSubStr(struct.script_string, "zclassic"))
			{
				perk_struct = struct;
				break;
			}
		}
	}

	if(!IsDefined(perk_struct))
	{
		return;
	}

	// spawn new machine
	use_trigger = spawn( "trigger_radius_use", perk_struct.origin + vectorScale( ( 0, 0, 1 ), 30 ), 0, 40, 70 );
	use_trigger.targetname = "zombie_vending";
	use_trigger.script_noteworthy = perk_struct.script_noteworthy;
	use_trigger triggerignoreteam();
	perk_machine = spawn( "script_model", perk_struct.origin );
	perk_machine.angles = perk_struct.angles;
	perk_machine setmodel( perk_struct.model );
	bump_trigger = spawn( "trigger_radius", perk_struct.origin + AnglesToRight(perk_struct.angles) * 32, 0, 35, 32 );
	bump_trigger.script_activated = 1;
	bump_trigger.script_sound = "zmb_perks_bump_bottle";
	bump_trigger.targetname = "audio_bump_trigger";
	bump_trigger thread maps/mp/zombies/_zm_perks::thread_bump_trigger();
	collision = spawn( "script_model", perk_struct.origin, 1 );
	collision.angles = perk_struct.angles;
	collision setmodel( "zm_collision_perks1" );
	collision.script_noteworthy = "clip";
	collision disconnectpaths();
	use_trigger.clip = collision;
	use_trigger.machine = perk_machine;
	use_trigger.bump = bump_trigger;
	if ( isDefined( perk_struct.blocker_model ) )
	{
		use_trigger.blocker_model = perk_struct.blocker_model;
	}
	if ( isDefined( perk_struct.script_int ) )
	{
		perk_machine.script_int = perk_struct.script_int;
	}
	if ( isDefined( perk_struct.turn_on_notify ) )
	{
		perk_machine.turn_on_notify = perk_struct.turn_on_notify;
	}
	use_trigger.script_sound = "mus_perks_tombstone_jingle";
	use_trigger.script_string = "tombstone_perk";
	use_trigger.script_label = "mus_perks_tombstone_sting";
	use_trigger.target = "vending_tombstone";
	perk_machine.script_string = "tombstone_perk";
	perk_machine.targetname = "vending_tombstone";
	bump_trigger.script_string = "tombstone_perk";

	level thread maps/mp/zombies/_zm_perks::turn_tombstone_on();
	use_trigger thread maps/mp/zombies/_zm_perks::vending_trigger_think();
	use_trigger thread maps/mp/zombies/_zm_perks::electric_perks_dialog();

	powered_on = maps/mp/zombies/_zm_perks::get_perk_machine_start_state( use_trigger.script_noteworthy );
	maps/mp/zombies/_zm_power::add_powered_item( maps/mp/zombies/_zm_power::perk_power_on, ::perk_power_off, maps/mp/zombies/_zm_power::perk_range, maps/mp/zombies/_zm_power::cost_low_if_local, 0, powered_on, use_trigger );
}

transit_b23r_hint_string_fix()
{
	flag_wait( "initial_blackscreen_passed" );
	wait 0.05;

	trigs = getentarray("weapon_upgrade", "targetname");
	foreach (trig in trigs)
	{
		if (trig.zombie_weapon_upgrade == "beretta93r_zm")
		{
			hint = maps/mp/zombies/_zm_weapons::get_weapon_hint(trig.zombie_weapon_upgrade);
			cost = level.zombie_weapons[trig.zombie_weapon_upgrade].cost;
			trig sethintstring(hint, cost);
		}
	}
}

town_move_tombstone_machine()
{
	if (!(level.scr_zm_ui_gametype == "zstandard" && level.scr_zm_map_start_location == "town"))
	{
		return;
	}

	perk_struct = undefined;
	structs = getstructarray("zm_perk_machine", "targetname");
	foreach (struct in structs)
	{
		if (IsDefined(struct.script_noteworthy) && IsDefined(struct.script_string))
		{
			if (struct.script_noteworthy == "specialty_scavenger" && IsSubStr(struct.script_string, "zstandard"))
			{
				perk_struct = struct;
				break;
			}
		}
	}

	if(!IsDefined(perk_struct))
	{
		return;
	}

	// delete old machine
	vending_triggers = getentarray( "zombie_vending", "targetname" );
	for (i = 0; i < vending_trigger.size; i++)
	{
		trig = vending_triggers[i];
		if (IsDefined(trig.script_noteworthy) && trig.script_noteworthy == "specialty_scavenger")
		{
			trig.clip delete();
			trig.machine delete();
			trig.bump delete();
			trig delete();
			break;
		}
	}

	// spawn new machine
	origin = (1852, -825, -56);
	angles = (0, 180, 0);
	use_trigger = spawn( "trigger_radius_use", origin + vectorScale( ( 0, 0, 1 ), 30 ), 0, 40, 70 );
	use_trigger.targetname = "zombie_vending";
	use_trigger triggerignoreteam();
	perk_machine = spawn( "script_model", origin );
	perk_machine.angles = angles;
	perk_machine setmodel( perk_struct.model );
	bump_trigger = spawn( "trigger_radius", origin + AnglesToRight(angles) * 32, 0, 35, 32 );
	bump_trigger.script_activated = 1;
	bump_trigger.script_sound = "zmb_perks_bump_bottle";
	bump_trigger.targetname = "audio_bump_trigger";
	bump_trigger thread maps/mp/zombies/_zm_perks::thread_bump_trigger();
	collision = spawn( "script_model", origin, 1 );
	collision.angles = angles;
	collision setmodel( "zm_collision_perks1" );
	collision.script_noteworthy = "clip";
	collision disconnectpaths();
	use_trigger.clip = collision;
	use_trigger.machine = perk_machine;
	use_trigger.bump = bump_trigger;
	if ( isDefined( perk_struct.blocker_model ) )
	{
		use_trigger.blocker_model = perk_struct.blocker_model;
	}
	if ( isDefined( perk_struct.script_int ) )
	{
		perk_machine.script_int = perk_struct.script_int;
	}
	if ( isDefined( perk_struct.turn_on_notify ) )
	{
		perk_machine.turn_on_notify = perk_struct.turn_on_notify;
	}
	use_trigger.script_sound = "mus_perks_tombstone_jingle";
	use_trigger.script_string = "tombstone_perk";
	use_trigger.script_label = "mus_perks_tombstone_sting";
	use_trigger.target = "vending_tombstone";
	perk_machine.script_string = "tombstone_perk";
	perk_machine.targetname = "vending_tombstone";
	bump_trigger.script_string = "tombstone_perk";

	// wait until inital machine is removed
	flag_wait( "initial_blackscreen_passed" );
	wait 0.05;

	// wait until after to set script_noteworthy so new machine isn't removed
	use_trigger.script_noteworthy = perk_struct.script_noteworthy;

	level thread maps/mp/zombies/_zm_perks::turn_tombstone_on();
	use_trigger thread maps/mp/zombies/_zm_perks::vending_trigger_think();
	use_trigger thread maps/mp/zombies/_zm_perks::electric_perks_dialog();

	powered_on = maps/mp/zombies/_zm_perks::get_perk_machine_start_state( use_trigger.script_noteworthy );
	maps/mp/zombies/_zm_power::add_powered_item( maps/mp/zombies/_zm_power::perk_power_on, ::perk_power_off, maps/mp/zombies/_zm_power::perk_range, maps/mp/zombies/_zm_power::cost_low_if_local, 0, powered_on, use_trigger );
}

town_move_quickrevive_machine()
{
	if (!(!is_classic() && level.scr_zm_map_start_location == "town"))
	{
		return;
	}

	perk_struct = undefined;
	perk_location_struct = undefined;
	structs = getstructarray("zm_perk_machine", "targetname");
	foreach (struct in structs)
	{
		if (IsDefined(struct.script_noteworthy) && IsDefined(struct.script_string))
		{
			if (struct.script_noteworthy == "specialty_quickrevive" && IsSubStr(struct.script_string, "zstandard"))
			{
				perk_struct = struct;
			}
			else if (struct.script_noteworthy == "specialty_longersprint" && IsSubStr(struct.script_string, "zstandard"))
			{
				perk_location_struct = struct;
			}
		}
	}

	if(!IsDefined(perk_struct) || !IsDefined(perk_location_struct))
	{
		return;
	}

	// delete old machine
	vending_triggers = getentarray( "zombie_vending", "targetname" );
	for (i = 0; i < vending_trigger.size; i++)
	{
		trig = vending_triggers[i];
		if (IsDefined(trig.script_noteworthy) && trig.script_noteworthy == "specialty_quickrevive")
		{
			trig.clip delete();
			trig.machine delete();
			trig.bump delete();
			trig delete();
			break;
		}
	}

	// spawn new machine
    perk_location_struct.origin += anglesToRight(perk_location_struct.angles) * 4;
	use_trigger = spawn( "trigger_radius_use", perk_location_struct.origin + vectorScale( ( 0, 0, 1 ), 30 ), 0, 40, 70 );
	use_trigger.targetname = "zombie_vending";
	use_trigger.script_noteworthy = perk_struct.script_noteworthy;
	use_trigger triggerignoreteam();
	perk_machine = spawn( "script_model", perk_location_struct.origin );
	perk_machine.angles = perk_location_struct.angles;
	perk_machine setmodel( perk_struct.model );
	bump_trigger = spawn( "trigger_radius", perk_location_struct.origin + AnglesToRight(perk_location_struct.angles) * 32, 0, 35, 32 );
	bump_trigger.script_activated = 1;
	bump_trigger.script_sound = "zmb_perks_bump_bottle";
	bump_trigger.targetname = "audio_bump_trigger";
	bump_trigger thread maps/mp/zombies/_zm_perks::thread_bump_trigger();
	collision = spawn( "script_model", perk_location_struct.origin, 1 );
	collision.angles = perk_location_struct.angles;
	collision setmodel( "zm_collision_perks1" );
	collision.script_noteworthy = "clip";
	collision disconnectpaths();
	use_trigger.clip = collision;
	use_trigger.machine = perk_machine;
	use_trigger.bump = bump_trigger;
	if ( isDefined( perk_struct.blocker_model ) )
	{
		use_trigger.blocker_model = perk_struct.blocker_model;
	}
	if ( isDefined( perk_struct.script_int ) )
	{
		perk_machine.script_int = perk_struct.script_int;
	}
	if ( isDefined( perk_struct.turn_on_notify ) )
	{
		perk_machine.turn_on_notify = perk_struct.turn_on_notify;
	}

	use_trigger.script_sound = "mus_perks_revive_jingle";
	use_trigger.script_string = "revive_perk";
	use_trigger.script_label = "mus_perks_revive_sting";
	use_trigger.target = "vending_revive";
	perk_machine.script_string = "revive_perk";
	perk_machine.targetname = "vending_revive";
	bump_trigger.script_string = "revive_perk";

	level thread maps/mp/zombies/_zm_perks::turn_revive_on();
	use_trigger thread maps/mp/zombies/_zm_perks::vending_trigger_think();
	use_trigger thread maps/mp/zombies/_zm_perks::electric_perks_dialog();

	powered_on = maps/mp/zombies/_zm_perks::get_perk_machine_start_state( use_trigger.script_noteworthy );
	maps/mp/zombies/_zm_power::add_powered_item( maps/mp/zombies/_zm_power::perk_power_on, scripts/zm/_zm_reimagined::perk_power_off, maps/mp/zombies/_zm_power::perk_range, maps/mp/zombies/_zm_power::cost_low_if_local, 0, powered_on, use_trigger );
}

town_move_staminup_machine()
{
	if (!(!is_classic() && level.scr_zm_map_start_location == "town"))
	{
		return;
	}

	perk_struct = undefined;
	structs = getstructarray("zm_perk_machine", "targetname");
	foreach (struct in structs)
	{
		if (IsDefined(struct.script_noteworthy) && IsDefined(struct.script_string))
		{
			if (struct.script_noteworthy == "specialty_longersprint" && IsSubStr(struct.script_string, "zclassic"))
			{
				perk_struct = struct;
				break;
			}
		}
	}

	if(!IsDefined(perk_struct))
	{
		return;
	}

	// delete old machine
	vending_triggers = getentarray( "zombie_vending", "targetname" );
	for (i = 0; i < vending_trigger.size; i++)
	{
		trig = vending_triggers[i];
		if (IsDefined(trig.script_noteworthy) && trig.script_noteworthy == "specialty_longersprint")
		{
			trig.clip delete();
			trig.machine delete();
			trig.bump delete();
			trig delete();
			break;
		}
	}

	// spawn new machine
	use_trigger = spawn( "trigger_radius_use", perk_struct.origin + vectorScale( ( 0, 0, 1 ), 30 ), 0, 40, 70 );
	use_trigger.targetname = "zombie_vending";
	use_trigger.script_noteworthy = perk_struct.script_noteworthy;
	use_trigger triggerignoreteam();
	perk_machine = spawn( "script_model", perk_struct.origin );
	perk_machine.angles = perk_struct.angles;
	perk_machine setmodel( perk_struct.model );
	bump_trigger = spawn( "trigger_radius", perk_struct.origin + AnglesToRight(perk_struct.angles) * 32, 0, 35, 32 );
	bump_trigger.script_activated = 1;
	bump_trigger.script_sound = "zmb_perks_bump_bottle";
	bump_trigger.targetname = "audio_bump_trigger";
	bump_trigger thread maps/mp/zombies/_zm_perks::thread_bump_trigger();
	collision = spawn( "script_model", perk_struct.origin, 1 );
	collision.angles = perk_struct.angles;
	collision setmodel( "zm_collision_perks1" );
	collision.script_noteworthy = "clip";
	collision disconnectpaths();
	use_trigger.clip = collision;
	use_trigger.machine = perk_machine;
	use_trigger.bump = bump_trigger;
	if ( isDefined( perk_struct.blocker_model ) )
	{
		use_trigger.blocker_model = perk_struct.blocker_model;
	}
	if ( isDefined( perk_struct.script_int ) )
	{
		perk_machine.script_int = perk_struct.script_int;
	}
	if ( isDefined( perk_struct.turn_on_notify ) )
	{
		perk_machine.turn_on_notify = perk_struct.turn_on_notify;
	}
	use_trigger.script_sound = "mus_perks_stamin_jingle";
	use_trigger.script_string = "marathon_perk";
	use_trigger.script_label = "mus_perks_stamin_sting";
	use_trigger.target = "vending_marathon";
	perk_machine.script_string = "marathon_perk";
	perk_machine.targetname = "vending_marathon";
	bump_trigger.script_string = "marathon_perk";

	level thread maps/mp/zombies/_zm_perks::turn_marathon_on();
	use_trigger thread maps/mp/zombies/_zm_perks::vending_trigger_think();
	use_trigger thread maps/mp/zombies/_zm_perks::electric_perks_dialog();

	powered_on = maps/mp/zombies/_zm_perks::get_perk_machine_start_state( use_trigger.script_noteworthy );
	maps/mp/zombies/_zm_power::add_powered_item( maps/mp/zombies/_zm_power::perk_power_on, ::perk_power_off, maps/mp/zombies/_zm_power::perk_range, maps/mp/zombies/_zm_power::cost_low_if_local, 0, powered_on, use_trigger );
}

prison_remove_acid_trap_player_spawn()
{
	if(level.script != "zm_prison")
	{
		return;
	}

	spawn_points = maps/mp/gametypes_zm/_zm_gametype::get_player_spawns_for_gametype();
	foreach(spawn_point in spawn_points)
	{
		if(spawn_point.script_noteworthy == "zone_cafeteria")
		{
			spawn_array = getstructarray( spawn_point.target, "targetname" );
			foreach(spawn in spawn_array)
			{
				if(spawn.origin == (2536, 9704, 1360))
				{
					arrayremovevalue(spawn_array, spawn);
					return;
				}
			}
		}
	}
}

prison_plane_set_need_all_pieces()
{
	if(!(is_classic() && level.scr_zm_map_start_location == "prison"))
	{
		return;
	}

	level.zombie_craftablestubs["plane"].need_all_pieces = 1;
	level.zombie_craftablestubs["refuelable_plane"].need_all_pieces = 1;
}

prison_plane_set_pieces_shared()
{
	if(!(is_classic() && level.scr_zm_map_start_location == "prison"))
	{
		return;
	}

	foreach(stub in level.zombie_include_craftables)
	{
		if(stub.name == "plane" || stub.name == "refuelable_plane")
		{
			foreach(piece in stub.a_piecestubs)
			{
				piece.is_shared = 1;
				piece.client_field_state = undefined;
			}
		}
	}
}

prison_plane_auto_refuel()
{
	if(!(is_classic() && level.scr_zm_map_start_location == "prison"))
	{
		return;
	}

	for ( ;; )
	{
		flag_wait( "spawn_fuel_tanks" );

		wait 0.05;

		buildcraftable( "refuelable_plane" );
	}
}

prison_tower_trap_changes()
{
	if(!(is_classic() && level.scr_zm_map_start_location == "prison"))
	{
		return;
	}

	// need to override the original function call
	// this level var is threaded though so it doesn't work
	level.custom_tower_trap_fires_func = ::prison_tower_trap_fires_override;

	trap_trigs = getentarray( "tower_trap_activate_trigger", "targetname" );
	foreach (trig in trap_trigs)
	{
		trig thread prison_tower_trap_trigger_think();
		trig thread prison_tower_upgrade_trigger_think();
	}
}

prison_tower_trap_fires_override( zombies )
{

}

prison_tower_trap_trigger_think()
{
	while (1)
	{
		self waittill("switch_activated");
		self thread prison_activate_tower_trap();
	}
}

prison_activate_tower_trap()
{
	self endon( "tower_trap_off" );

	if ( isDefined( self.upgraded ) )
	{
		self.weapon_name = "tower_trap_upgraded_zm";
		self.tag_to_target = "J_SpineLower";
		self.trap_reload_time = 1.5;
	}
	else
	{
		self.weapon_name = "tower_trap_zm";
		self.tag_to_target = "J_Head";
		self.trap_reload_time = 0.75;
	}

	while ( 1 )
	{
		zombies = getaiarray( level.zombie_team );
		zombies_sorted = [];
		foreach ( zombie in zombies )
		{
			if ( zombie istouching( self.range_trigger ) )
			{
				zombies_sorted[ zombies_sorted.size ] = zombie;
			}
		}

		if ( zombies_sorted.size <= 0 )
		{
			wait_network_frame();
			continue;
		}

		self prison_tower_trap_fires( zombies_sorted );
	}
}

prison_tower_trap_fires( zombies )
{
	self endon( "tower_trap_off" );

	org = getstruct( self.range_trigger.target, "targetname" );
	index = randomintrange( 0, zombies.size );

	while ( isalive( zombies[ index ] ) )
	{
		target = zombies[ index ];
		zombietarget = target gettagorigin( self.tag_to_target );

		if ( sighttracepassed( org.origin, zombietarget, 1, undefined ) )
		{
			self thread prison_tower_trap_magicbullet_think( org, target, zombietarget );
			wait self.trap_reload_time;
			continue;
		}
		else
		{
			arrayremovevalue( zombies, target, 0 );
			wait_network_frame();
			if ( zombies.size <= 0 )
			{
				return;
			}
			else
			{
				index = randomintrange( 0, zombies.size );
			}
		}
	}
}

prison_tower_trap_magicbullet_think( org, target, zombietarget )
{
	bullet = magicbullet( self.weapon_name, org.origin, zombietarget );
	bullet waittill( "death" );

	if ( self.weapon_name == "tower_trap_zm" )
	{
		if ( isDefined( target ) && isDefined( target.animname ) && target.health > 0 && target.animname != "brutus_zombie" )
		{
			if ( !isDefined( target.no_gib ) || !target.no_gib )
			{
				target maps/mp/zombies/_zm_spawner::zombie_head_gib();
			}
			target dodamage( target.health + 1000, target.origin );
		}
	}
	else if ( self.weapon_name == "tower_trap_upgraded_zm" )
	{
		radiusdamage( bullet.origin, 256, level.zombie_health * 1.5, level.zombie_health / 2, self, "MOD_GRENADE_SPLASH", "tower_trap_upgraded_zm" );
	}
}

prison_tower_upgrade_trigger_think()
{
	flag_wait( "initial_blackscreen_passed" );
	flag_wait( "start_zombie_round_logic" );
	wait 0.05;

	while (1)
	{
		level waittill( self.upgrade_trigger.script_string );
		self.upgraded = 1;
		level waittill( "between_round_over" );
		self.upgraded = undefined;
	}
}

buried_turn_power_on()
{
	if(!(is_classic() && level.scr_zm_map_start_location == "processing"))
	{
		return;
	}

	trigger = getent( "use_elec_switch", "targetname" );
	if ( isDefined( trigger ) )
	{
		trigger delete();
	}
	master_switch = getent( "elec_switch", "targetname" );
	if ( isDefined( master_switch ) )
	{
		master_switch notsolid();
		master_switch rotateroll( -90, 0.3 );
		clientnotify( "power_on" );
		flag_set( "power_on" );
	}
}

buried_deleteslothbarricades()
{
	if(!(is_classic() && level.scr_zm_map_start_location == "processing"))
	{
		return;
	}

	sloth_trigs = getentarray( "sloth_barricade", "targetname" );
	foreach (trig in sloth_trigs)
	{
		if ( isDefined( trig.script_flag ) && level flag_exists( trig.script_flag ) )
		{
			flag_set( trig.script_flag );
		}
		parts = getentarray( trig.target, "targetname" );
		array_thread( parts, ::self_delete );
	}

	array_thread( sloth_trigs, ::self_delete );
}

buried_enable_fountain_transport()
{
	if(!(is_classic() && level.scr_zm_map_start_location == "processing"))
	{
		return;
	}

	flag_wait( "initial_blackscreen_passed" );

	wait 1;

	level notify( "courtyard_fountain_open" );
}

buried_disable_ghost_free_perk_on_damage()
{
	if(!(is_classic() && level.scr_zm_map_start_location == "processing"))
	{
		return;
	}

	while (1)
	{
		buried_disable_ghost_free_perk();
	}
}

buried_disable_ghost_free_perk()
{
	level endon( "ghost_round_end" );

	flag_wait( "spawn_ghosts" );

	level waittill_any("ghost_drained_player", "ghost_damaged_player");

	while (!isDefined(level.ghost_round_last_ghost_origin))
	{
		wait 0.05;
	}

	level.ghost_round_last_ghost_origin = undefined;

	flag_waitopen( "spawn_ghosts" );
}

vulture_disable_stink_while_standing()
{
	self endon( "disconnect" );

	if(!(is_classic() && level.scr_zm_map_start_location == "processing"))
	{
		return;
	}

	while(!isDefined(self.perk_vulture))
	{
		wait 0.05;
	}

	while(1)
	{
		if (!self.perk_vulture.active)
		{
			wait 0.05;
			continue;
		}

		self.perk_vulture.is_in_zombie_stink = 1;
		self.perk_vulture.stink_time_entered = undefined;

		b_player_in_zombie_stink = 0;
		a_close_points = arraysort( level.perk_vulture.zombie_stink_array, self.origin, 1, 300 );
		if ( a_close_points.size > 0 )
		{
			b_player_in_zombie_stink = self _is_player_in_zombie_stink( a_close_points );
		}

		if (b_player_in_zombie_stink)
		{
			vel = self GetVelocity();
			magnitude = sqrt((vel[0] * vel[0]) + (vel[1] * vel[1]) + (vel[2] * vel[2]));
			if (magnitude < 125)
			{
				self.perk_vulture.is_in_zombie_stink = 0;

				wait 0.25;

				while (self.vulture_stink_value > 0)
				{
					wait 0.05;
				}
			}
		}

		wait 0.05;
	}
}

_is_player_in_zombie_stink( a_points )
{
	b_is_in_stink = 0;
	i = 0;
	while ( i < a_points.size )
	{
		if ( distancesquared( a_points[ i ].origin, self.origin ) < 4900 )
		{
			b_is_in_stink = 1;
		}
		i++;
	}
	return b_is_in_stink;
}

tomb_increase_solo_door_prices()
{
	if(!(is_classic() && level.scr_zm_map_start_location == "tomb"))
	{
		return;
	}

	flag_wait( "initial_blackscreen_passed" );

	if ( isDefined( level.is_forever_solo_game ) && level.is_forever_solo_game )
	{
		a_door_buys = getentarray( "zombie_door", "targetname" );
		array_thread( a_door_buys, ::door_price_increase_for_solo );
		a_debris_buys = getentarray( "zombie_debris", "targetname" );
		array_thread( a_debris_buys, ::door_price_increase_for_solo );
	}
}

door_price_increase_for_solo()
{
	self.zombie_cost += 250;

	if ( self.targetname == "zombie_door" )
	{
		self set_hint_string( self, "default_buy_door", self.zombie_cost );
	}
	else
	{
		self set_hint_string( self, "default_buy_debris", self.zombie_cost );
	}
}

tomb_remove_shovels_from_map()
{
	if(!(is_classic() && level.scr_zm_map_start_location == "tomb"))
	{
		return;
	}

	flag_wait( "initial_blackscreen_passed" );

	stubs = level._unitriggers.trigger_stubs;
	for(i = 0; i < stubs.size; i++)
	{
		stub = stubs[i];
		if(IsDefined(stub.e_shovel))
		{
			stub.e_shovel delete();
			maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( stub );
		}
	}
}

tomb_give_shovel()
{
	if(!(is_classic() && level.scr_zm_map_start_location == "tomb"))
	{
		return;
	}

	self.dig_vars[ "has_shovel" ] = 1;
	n_player = self getentitynumber() + 1;
	level setclientfield( "shovel_player" + n_player, 1 );
}

tomb_challenges_changes()
{
	if(!(is_classic() && level.scr_zm_map_start_location == "tomb"))
	{
		return;
	}

	level._challenges.a_stats["zc_points_spent"].fp_give_reward = ::tomb_reward_random_perk;
}

tomb_reward_random_perk( player, s_stat )
{
	if (!isDefined(player.tomb_reward_perk))
	{
		player.tomb_reward_perk = player get_random_perk();
	}
	else if (isDefined( self.perk_purchased ) && self.perk_purchased == player.tomb_reward_perk)
	{
		player.tomb_reward_perk = player get_random_perk();
	}
	else if (self hasperk( player.tomb_reward_perk ) || self maps/mp/zombies/_zm_perks::has_perk_paused( player.tomb_reward_perk ))
	{
		player.tomb_reward_perk = player get_random_perk();
	}

	perk = player.tomb_reward_perk;
	if (!isDefined(perk))
	{
		return 0;
	}

	model = get_perk_weapon_model(perk);
	if (!isDefined(model))
	{
		return 0;
	}

	m_reward = spawn( "script_model", self.origin );
	m_reward.angles = self.angles + vectorScale( ( 0, 1, 0 ), 180 );
	m_reward setmodel( model );
	m_reward playsound( "zmb_spawn_powerup" );
	m_reward playloopsound( "zmb_spawn_powerup_loop", 0.5 );
	wait_network_frame();
	if ( !reward_rise_and_grab( m_reward, 50, 2, 2, 10 ) )
	{
		return 0;
	}
	if ( player hasperk( perk ) || player maps/mp/zombies/_zm_perks::has_perk_paused( perk ) )
	{
		m_reward thread bottle_reject_sink( player );
		return 0;
	}
	m_reward stoploopsound( 0.1 );
	player playsound( "zmb_powerup_grabbed" );
	m_reward thread maps/mp/zombies/_zm_perks::vending_trigger_post_think( player, perk );
	m_reward delete();
	player increment_player_perk_purchase_limit();
	player maps/mp/zombies/_zm_stats::increment_client_stat( "tomb_perk_extension", 0 );
	player maps/mp/zombies/_zm_stats::increment_player_stat( "tomb_perk_extension" );
	player thread player_perk_purchase_limit_fix();
	return 1;
}

get_random_perk()
{
	perks = [];
	for (i = 0; i < level._random_perk_machine_perk_list.size; i++)
	{
		perk = level._random_perk_machine_perk_list[ i ];
		if ( isDefined( self.perk_purchased ) && self.perk_purchased == perk )
		{
			continue;
		}
		else
		{
			if ( !self hasperk( perk ) && !self maps/mp/zombies/_zm_perks::has_perk_paused( perk ) )
			{
				perks[ perks.size ] = perk;
			}
		}
	}
	if ( perks.size > 0 )
	{
		perks = array_randomize( perks );
		random_perk = perks[ 0 ];
		return random_perk;
	}
}

get_perk_weapon_model( perk )
{
	switch( perk )
	{
		case "specialty_armorvest":
		case "specialty_armorvest_upgrade":
			weapon = level.machine_assets[ "juggernog" ].weapon;
			break;
		case "specialty_quickrevive":
		case "specialty_quickrevive_upgrade":
			weapon = level.machine_assets[ "revive" ].weapon;
			break;
		case "specialty_fastreload":
		case "specialty_fastreload_upgrade":
			weapon = level.machine_assets[ "speedcola" ].weapon;
			break;
		case "specialty_rof":
		case "specialty_rof_upgrade":
			weapon = level.machine_assets[ "doubletap" ].weapon;
			break;
		case "specialty_longersprint":
		case "specialty_longersprint_upgrade":
			weapon = level.machine_assets[ "marathon" ].weapon;
			break;
		case "specialty_flakjacket":
		case "specialty_flakjacket_upgrade":
			weapon = level.machine_assets[ "divetonuke" ].weapon;
			break;
		case "specialty_deadshot":
		case "specialty_deadshot_upgrade":
			weapon = level.machine_assets[ "deadshot" ].weapon;
			break;
		case "specialty_additionalprimaryweapon":
		case "specialty_additionalprimaryweapon_upgrade":
			weapon = level.machine_assets[ "additionalprimaryweapon" ].weapon;
			break;
		case "specialty_scavenger":
		case "specialty_scavenger_upgrade":
			weapon = level.machine_assets[ "tombstone" ].weapon;
			break;
		case "specialty_finalstand":
		case "specialty_finalstand_upgrade":
			weapon = level.machine_assets[ "whoswho" ].weapon;
			break;
	}
	if ( isDefined( level._custom_perks[ perk ] ) && isDefined( level._custom_perks[ perk ].perk_bottle ) )
	{
		weapon = level._custom_perks[ perk ].perk_bottle;
	}
	return getweaponmodel( weapon );
}

increment_player_perk_purchase_limit()
{
	if ( !isDefined( self.player_perk_purchase_limit ) )
	{
		self.player_perk_purchase_limit = level.perk_purchase_limit;
	}
	self.player_perk_purchase_limit++;
}

player_perk_purchase_limit_fix()
{
	self endon("disconnect");

	while (self.pers[ "tomb_perk_extension" ] < 5)
	{
		wait .5;
	}

	if (self.player_perk_purchase_limit < 9)
	{
		self.player_perk_purchase_limit = 9;
	}
}

reward_rise_and_grab( m_reward, n_z, n_rise_time, n_delay, n_timeout )
{
	m_reward movez( n_z, n_rise_time );
	wait n_rise_time;
	if ( n_timeout > 0 )
	{
		m_reward thread reward_sink( n_delay, n_z, n_timeout + 1 );
	}
	self reward_grab_wait( n_timeout );
	if ( self ent_flag( "reward_timeout" ) )
	{
		return 0;
	}
	return 1;
}

reward_sink( n_delay, n_z, n_time )
{
	if ( isDefined( n_delay ) )
	{
		wait n_delay;
		if ( isDefined( self ) )
		{
			self movez( n_z * -1, n_time );
		}
	}
}

reward_grab_wait( n_timeout )
{
	if ( !isDefined( n_timeout ) )
	{
		n_timeout = 10;
	}
	self ent_flag_clear( "reward_timeout" );
	self ent_flag_set( "waiting_for_grab" );
	self endon( "waiting_for_grab" );
	if ( n_timeout > 0 )
	{
		wait n_timeout;
		self ent_flag_set( "reward_timeout" );
		self ent_flag_clear( "waiting_for_grab" );
	}
	else
	{
		self ent_flag_waitopen( "waiting_for_grab" );
	}
}

bottle_reject_sink( player )
{
	n_time = 1;
	player playlocalsound( level.zmb_laugh_alias );
	self thread reward_sink( 0, 61, n_time );
	wait n_time;
	self delete();
}

tomb_zombie_blood_dig_changes()
{
	if(!(is_classic() && level.scr_zm_map_start_location == "tomb"))
	{
		return;
	}

	while (1)
	{
		for (i = 0; i < level.a_zombie_blood_entities.size; i++)
		{
			ent = level.a_zombie_blood_entities[i];
			if (IsDefined(ent.e_unique_player))
			{
				if (!isDefined(ent.e_unique_player.initial_zombie_blood_dig))
				{
					ent.e_unique_player.initial_zombie_blood_dig = 0;
				}

				ent.e_unique_player.initial_zombie_blood_dig++;
				if (ent.e_unique_player.initial_zombie_blood_dig <= 2)
				{
					ent setvisibletoplayer(ent.e_unique_player);
				}
				else
				{
					ent thread set_visible_after_rounds(ent.e_unique_player, 3);
				}

				arrayremovevalue(level.a_zombie_blood_entities, ent);
			}
		}

		wait .5;
	}
}

set_visible_after_rounds(player, num)
{
	for (i = 0; i < num; i++)
	{
		level waittill( "end_of_round" );
	}

	self setvisibletoplayer(player);
}

tomb_soul_box_changes()
{
	if(!(is_classic() && level.scr_zm_map_start_location == "tomb"))
	{
		return;
	}

	a_boxes = getentarray( "foot_box", "script_noteworthy" );
	array_thread( a_boxes, ::tomb_soul_box_decrease_kill_requirement );
}

tomb_soul_box_decrease_kill_requirement()
{
	self endon( "box_finished" );

	while (1)
	{
		self waittill( "soul_absorbed" );

		wait 0.05;

		self.n_souls_absorbed += 10;

		self waittill( "robot_foot_stomp" );
	}
}

test()
{
	while(1)
	{
		wait 1;
	}
}