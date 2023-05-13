#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;

#include scripts\zm\replaced\zm_buried_buildables;
#include scripts\zm\replaced\zm_buried_gamemodes;
#include scripts\zm\replaced\zm_buried_power;
#include scripts\zm\replaced\zm_buried_ffotd;
#include scripts\zm\replaced\zm_buried_fountain;
#include scripts\zm\replaced\zm_buried_sq;
#include scripts\zm\replaced\zm_buried_sq_bt;
#include scripts\zm\replaced\zm_buried_sq_ts;
#include scripts\zm\replaced\zm_buried_sq_tpo;
#include scripts\zm\replaced\zm_buried_sq_ip;
#include scripts\zm\replaced\zm_buried_sq_ows;
#include scripts\zm\replaced\zm_buried_distance_tracking;
#include scripts\zm\replaced\_zm_ai_ghost;
#include scripts\zm\replaced\_zm_ai_sloth;
#include scripts\zm\replaced\_zm_buildables_pooled;
#include scripts\zm\replaced\_zm_equip_subwoofer;
#include scripts\zm\replaced\_zm_equip_springpad;
#include scripts\zm\replaced\_zm_equip_headchopper;
#include scripts\zm\replaced\_zm_perk_vulture;
#include scripts\zm\replaced\_zm_weap_slowgun;
#include scripts\zm\replaced\_zm_weap_time_bomb;
#include scripts\zm\replaced\_zm_banking;
#include scripts\zm\replaced\_zm_weapon_locker;
#include scripts\zm\replaced\_zm_sq;

main()
{
	replaceFunc(maps\mp\zm_buried_sq::navcomputer_waitfor_navcard, scripts\zm\replaced\_zm_sq::navcomputer_waitfor_navcard);
	replaceFunc(maps\mp\zm_buried_buildables::watch_cell_open_close, scripts\zm\replaced\zm_buried_buildables::watch_cell_open_close);
	replaceFunc(maps\mp\zm_buried_gamemodes::init, scripts\zm\replaced\zm_buried_gamemodes::init);
	replaceFunc(maps\mp\zm_buried_gamemodes::buildbuildable, scripts\zm\replaced\zm_buried_gamemodes::buildbuildable);
	replaceFunc(maps\mp\zm_buried_power::electric_switch, scripts\zm\replaced\zm_buried_power::electric_switch);
	replaceFunc(maps\mp\zm_buried_ffotd::jail_traversal_fix, scripts\zm\replaced\zm_buried_ffotd::jail_traversal_fix);
	replaceFunc(maps\mp\zm_buried_ffotd::time_bomb_takeaway, scripts\zm\replaced\zm_buried_ffotd::time_bomb_takeaway);
	replaceFunc(maps\mp\zm_buried_ffotd::spawned_life_triggers, scripts\zm\replaced\zm_buried_ffotd::spawned_life_triggers);
	replaceFunc(maps\mp\zm_buried_fountain::transport_player_to_start_zone, scripts\zm\replaced\zm_buried_fountain::transport_player_to_start_zone);
	replaceFunc(maps\mp\zm_buried_sq::sq_metagame, scripts\zm\replaced\zm_buried_sq::sq_metagame);
	replaceFunc(maps\mp\zm_buried_sq::make_richtofen_zombie, scripts\zm\replaced\zm_buried_sq::make_richtofen_zombie);
	replaceFunc(maps\mp\zm_buried_sq::sq_give_player_rewards, scripts\zm\replaced\zm_buried_sq::sq_give_player_rewards);
	replaceFunc(maps\mp\zm_buried_sq::mule_kick_allows_4_weapons, scripts\zm\replaced\zm_buried_sq::mule_kick_allows_4_weapons);
	replaceFunc(maps\mp\zm_buried_sq_bt::stage_vo_watch_gallows, scripts\zm\replaced\zm_buried_sq_bt::stage_vo_watch_gallows);
	replaceFunc(maps\mp\zm_buried_sq_bt::stage_vo_watch_guillotine, scripts\zm\replaced\zm_buried_sq_bt::stage_vo_watch_guillotine);
	replaceFunc(maps\mp\zm_buried_sq_ts::ts_sign_damage_watch, scripts\zm\replaced\zm_buried_sq_ts::ts_sign_damage_watch);
	replaceFunc(maps\mp\zm_buried_sq_tpo::init, scripts\zm\replaced\zm_buried_sq_tpo::init);
	replaceFunc(maps\mp\zm_buried_sq_tpo::promote_to_corpse_model, scripts\zm\replaced\zm_buried_sq_tpo::promote_to_corpse_model);
	replaceFunc(maps\mp\zm_buried_sq_ip::init, scripts\zm\replaced\zm_buried_sq_ip::init);
	replaceFunc(maps\mp\zm_buried_sq_ows::ows_targets_start, scripts\zm\replaced\zm_buried_sq_ows::ows_targets_start);
	replaceFunc(maps\mp\zm_buried_distance_tracking::delete_zombie_noone_looking, scripts\zm\replaced\zm_buried_distance_tracking::delete_zombie_noone_looking);
	replaceFunc(maps\mp\zombies\_zm_ai_ghost::ghost_zone_spawning_think, scripts\zm\replaced\_zm_ai_ghost::ghost_zone_spawning_think);
	replaceFunc(maps\mp\zombies\_zm_ai_ghost::should_last_ghost_drop_powerup, scripts\zm\replaced\_zm_ai_ghost::should_last_ghost_drop_powerup);
	replaceFunc(maps\mp\zombies\_zm_ai_sloth::sloth_init_start_funcs, scripts\zm\replaced\_zm_ai_sloth::sloth_init_start_funcs);
	replaceFunc(maps\mp\zombies\_zm_ai_sloth::sloth_init_update_funcs, scripts\zm\replaced\_zm_ai_sloth::sloth_init_update_funcs);
	replaceFunc(maps\mp\zombies\_zm_ai_sloth::sloth_check_ragdolls, scripts\zm\replaced\_zm_ai_sloth::sloth_check_ragdolls);
	replaceFunc(maps\mp\zombies\_zm_ai_sloth::sloth_ragdoll_zombie, scripts\zm\replaced\_zm_ai_sloth::sloth_ragdoll_zombie);
	replaceFunc(maps\mp\zombies\_zm_buildables_pooled::add_buildable_to_pool, scripts\zm\replaced\_zm_buildables_pooled::add_buildable_to_pool);
	replaceFunc(maps\mp\zombies\_zm_buildables_pooled::randomize_pooled_buildables, scripts\zm\replaced\_zm_buildables_pooled::randomize_pooled_buildables);
	replaceFunc(maps\mp\zombies\_zm_equip_subwoofer::startsubwooferdecay, scripts\zm\replaced\_zm_equip_subwoofer::startsubwooferdecay);
	replaceFunc(maps\mp\zombies\_zm_equip_subwoofer::subwoofer_network_choke, scripts\zm\replaced\_zm_equip_subwoofer::subwoofer_network_choke);
	replaceFunc(maps\mp\zombies\_zm_equip_springpad::springpadthink, scripts\zm\replaced\_zm_equip_springpad::springpadthink);
	replaceFunc(maps\mp\zombies\_zm_equip_headchopper::init_anim_slice_times, scripts\zm\replaced\_zm_equip_headchopper::init_anim_slice_times);
	replaceFunc(maps\mp\zombies\_zm_equip_headchopper::headchopperthink, scripts\zm\replaced\_zm_equip_headchopper::headchopperthink);
	replaceFunc(maps\mp\zombies\_zm_equip_headchopper::setupwatchers, scripts\zm\replaced\_zm_equip_headchopper::setupwatchers);
	replaceFunc(maps\mp\zombies\_zm_perk_vulture::_is_player_in_zombie_stink, scripts\zm\replaced\_zm_perk_vulture::_is_player_in_zombie_stink);
	replaceFunc(maps\mp\zombies\_zm_weap_slowgun::init, scripts\zm\replaced\_zm_weap_slowgun::init);
	replaceFunc(maps\mp\zombies\_zm_weap_slowgun::zombie_paralyzed, scripts\zm\replaced\_zm_weap_slowgun::zombie_paralyzed);
	replaceFunc(maps\mp\zombies\_zm_weap_slowgun::player_slow_for_time, scripts\zm\replaced\_zm_weap_slowgun::player_slow_for_time);
	replaceFunc(maps\mp\zombies\_zm_weap_slowgun::watch_reset_anim_rate, scripts\zm\replaced\_zm_weap_slowgun::watch_reset_anim_rate);
	replaceFunc(maps\mp\zombies\_zm_weap_time_bomb::init_time_bomb, scripts\zm\replaced\_zm_weap_time_bomb::init_time_bomb);
	replaceFunc(maps\mp\zombies\_zm_banking::init, scripts\zm\replaced\_zm_banking::init);
	replaceFunc(maps\mp\zombies\_zm_banking::bank_deposit_box, scripts\zm\replaced\_zm_banking::bank_deposit_box);
	replaceFunc(maps\mp\zombies\_zm_banking::bank_deposit_unitrigger, scripts\zm\replaced\_zm_banking::bank_deposit_unitrigger);
	replaceFunc(maps\mp\zombies\_zm_banking::bank_withdraw_unitrigger, scripts\zm\replaced\_zm_banking::bank_withdraw_unitrigger);
	replaceFunc(maps\mp\zombies\_zm_weapon_locker::triggerweaponslockerisvalidweaponpromptupdate, scripts\zm\replaced\_zm_weapon_locker::triggerweaponslockerisvalidweaponpromptupdate);
}

init()
{
	precachemodel( "collision_wall_128x128x10_standard" );

	level.zombie_init_done = ::zombie_init_done;
	level.special_weapon_magicbox_check = ::buried_special_weapon_magicbox_check;

	if(is_gametype_active("zgrief"))
	{
		level.check_for_valid_spawn_near_team_callback = undefined;
	}

	power_switch_model();
	sloth_barricades_buyable();
	add_jug_collision();

	level thread update_buildable_stubs();
	level thread remove_chalk_draw_points();
	level thread enable_fountain_transport();
	level thread disable_ghost_free_perk_on_damage();
	level thread sloth_trap();
}

zombie_init_done()
{
	self.allowpain = 0;
	self.zombie_path_bad = 0;
	self thread maps\mp\zm_buried_distance_tracking::escaped_zombies_cleanup_init();
	self setphysparams( 15, 0, 48 );
}

buried_special_weapon_magicbox_check(weapon)
{
	if ( weapon == "time_bomb_zm" )
	{
		players = get_players();
		i = 0;
		while ( i < players.size )
		{
			if ( is_player_valid( players[ i ], undefined, 1 ) && players[ i ] is_player_tactical_grenade( weapon ) )
			{
				return 0;
			}
			i++;
		}
	}
	return 1;
}

power_switch_model()
{
	model = spawn( "script_model", (626.36, -401.555, 133.149), 1);
	model.angles = (0, 0, 0);
	model setmodel("collision_clip_32x32x128");
	model disconnectpaths();
	model = spawn( "script_model", (660.36, -401.555, 133.149), 1);
	model.angles = (7, 0, 0);
	model setmodel("collision_clip_32x32x128");
	model disconnectpaths();
	model = spawn( "script_model", (642.556, -411.68, 131.538));
	model.angles = (3, 0, -8);
	model setmodel("p6_zm_bu_victorian_bookshelf");
	model = spawn( "script_model", (642.556, -420.68, 132.838));
	model.angles = (3, 0, -8);
	model setmodel("p6_zm_bu_victorian_bookshelf");
}

sloth_barricades_buyable()
{
	if (!is_gametype_active("zclassic"))
	{
		return;
	}

	sloth_trigs = getentarray( "sloth_barricade", "targetname" );
	foreach (trig in sloth_trigs)
	{
		if (isDefined(trig.script_noteworthy) && trig.script_noteworthy == "courtyard_fountain")
		{
			parts = getentarray( trig.target, "targetname" );
            array_thread( parts, ::self_delete );

			continue;
		}

		debris_trig = spawn( "trigger_box_use", trig.origin, 0, 128, 128, 128 );
		debris_trig.targetname = "zombie_debris";
		debris_trig.target = trig.target;
		debris_trig.script_noteworthy = trig.script_noteworthy;
		debris_trig.script_int = trig.script_int;
		debris_trig.script_flag = trig.script_flag;
		debris_trig.script_location = trig.script_location;

		switch(debris_trig.script_location)
		{
			case "juggernaut_alley":
			case "stables_alley":
			debris_trig.zombie_cost = 750;
			break;

			case "jail":
			case "gunstore":
			case "mansion":
			debris_trig.zombie_cost = 1000;
			break;

			case "candystore_alley":
			case "church":
			debris_trig.zombie_cost = 1250;
			break;

			default:
			debris_trig.zombie_cost = 1000;
			break;
		}

		debris_trig thread sloth_barricade_think();
	}

	maps\mp\zm_buried_gamemodes::deleteslothbarricades(1);
}

sloth_barricade_think()
{
	self sethintstring( &"ZOMBIE_BUTTON_BUY_CLEAR_DEBRIS_COST", self.zombie_cost );
	self setcursorhint( "HINT_NOICON" );

	while (1)
	{
		self waittill( "trigger", who );

		if ( who in_revive_trigger() )
			continue;

		if ( is_player_valid( who ) )
        {
			if ( who.score >= self.zombie_cost )
            {
                who maps\mp\zombies\_zm_score::minus_to_player_score( self.zombie_cost );
            }
            else
            {
                play_sound_at_pos( "no_purchase", self.origin );
                who maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "door_deny" );
                continue;
            }

			self hide();

			if ( isdefined( self.script_flag ) && level flag_exists( self.script_flag ) )
            {
                flag_set( self.script_flag );

                if ( self.script_flag == "jail_door1" )
                    level notify( "jail_barricade_down" );
            }

			pieces = getentarray( self.target, "targetname" );
			pieces[1] sloth_barricade_move();

            if ( isdefined( self.script_int ) )
                exploder( self.script_int );

            foreach ( piece in pieces )
            {
                piece delete();
            }

            self thread maps\mp\zombies\_zm_equip_headchopper::destroyheadchopperstouching( 0 );
            self playsound( "zmb_sloth_barrier_break" );
            level notify( "sloth_breaks_barrier" );

            self delete();

            break;
        }
	}
}

sloth_barricade_move()
{
	self play_sound_on_ent( "debris_move" );
	playsoundatposition( "zmb_lightning_l", self.origin );
	playfx( level._effect["poltergeist"], self.origin );

	num = randomintrange( 3, 5 );
	og_angles = self.angles;
	for ( i = 0; i < num; i++ )
	{
		angles = og_angles + ( -5 + randomfloat( 10 ), -5 + randomfloat( 10 ), -5 + randomfloat( 10 ) );
		time = randomfloatrange( 0.1, 0.4 );
		self rotateto( angles, time );
		wait( time - 0.05 );
	}
}

update_buildable_stubs()
{
	flag_wait( "initial_blackscreen_passed" );

	wait 1;

	foreach (stub in level.buildablepools["buried"].stubs)
	{
		if (isDefined(level.zombie_buildables[stub.equipname]))
		{
			level.zombie_buildables[stub.equipname].bought = "Took " + stub scripts\zm\_zm_reimagined::get_equipment_display_name();
		}
	}
}

remove_chalk_draw_points()
{
	flag_wait( "initial_blackscreen_passed" );

	wait 1;

	foreach (stub in level.buildable_stubs)
	{
		if ( stub.equipname == "chalk" )
		{
			stub.buildablestruct.onuseplantobject = ::onuseplantobject_chalk;
		}
	}
}

onuseplantobject_chalk( entity )
{
    piece = entity maps\mp\zombies\_zm_buildables::player_get_buildable_piece( 1 );

    if ( isdefined( piece ) )
    {
        weapon = piece.script_noteworthy;

        if ( isdefined( weapon ) )
        {
            origin = self.origin;
            angles = self.angles;

            if ( isdefined( level._effect["wallbuy_replace"] ) )
                playfx( level._effect["wallbuy_replace"], origin, anglestoforward( angles ) );

            maps\mp\zombies\_zm_weapons::add_dynamic_wallbuy( weapon, self.target, 1 );

            if ( !isdefined( level.built_wallbuys ) )
                level.built_wallbuys = 0;

            level.built_wallbuys++;

            if ( isplayer( entity ) )
            {
                entity maps\mp\zombies\_zm_stats::increment_client_stat( "buried_wallbuy_placed", 0 );
                entity maps\mp\zombies\_zm_stats::increment_player_stat( "buried_wallbuy_placed" );
                entity maps\mp\zombies\_zm_stats::increment_client_stat( "buried_wallbuy_placed_" + weapon, 0 );
                entity maps\mp\zombies\_zm_stats::increment_player_stat( "buried_wallbuy_placed_" + weapon );
            }

            if ( level.built_wallbuys >= 6 )
            {
                level.built_wallbuys = -100;
            }
        }
    }
}

enable_fountain_transport()
{
	if (!is_gametype_active("zclassic"))
	{
		return;
	}

	flag_wait( "initial_blackscreen_passed" );

	wait 1;

	level notify( "courtyard_fountain_open" );
}

disable_ghost_free_perk_on_damage()
{
	if (!is_gametype_active("zclassic"))
	{
		return;
	}

	while (1)
	{
		disable_ghost_free_perk();
	}
}

disable_ghost_free_perk()
{
	level endon( "ghost_round_end" );

	level.ghost_round_no_damage = 1;

	flag_wait( "spawn_ghosts" );

	level waittill_any("ghost_drained_player", "ghost_damaged_player");

	level.ghost_round_no_damage = 0;

	flag_waitopen( "spawn_ghosts" );
}

add_jug_collision()
{
	origin = (-664, 1050, 8);
	angles = ( 0, 0, 0 );
	collision = spawn( "script_model", origin + anglesToUp(angles) * 64 );
	collision.angles = angles;
	collision setmodel( "collision_wall_128x128x10_standard" );
}

sloth_trap()
{
	if (!is_gametype_active("zclassic"))
	{
		return;
	}

	trig = spawn( "trigger_box_use", level.cell_door.origin, 0, 64, 64, 64 );
	trig.cost = 1000;
	trig setcursorhint( "HINT_NOICON" );
	level.sloth_trap_trig = trig;

	flag_wait( "initial_blackscreen_passed" );

	level.sloth.actor_damage_func = ::sloth_damage_func;

	level.candy_context = [];
	maps\mp\zombies\_zm_ai_sloth::register_candy_context( "protect", 100, maps\mp\zombies\_zm_ai_sloth::protect_condition, maps\mp\zombies\_zm_ai_sloth::protect_start, maps\mp\zombies\_zm_ai_sloth::protect_update, maps\mp\zombies\_zm_ai_sloth::protect_action );

	while (1)
	{
		trig sethintstring( &"ZM_BURIED_CANDY_GV", " [Cost: " + trig.cost + "]" );

		trig waittill( "trigger", who );

		if ( !is_player_valid( who ) )
        {
			continue;
		}

		if ( who.score < trig.cost )
		{
			play_sound_at_pos( "no_purchase", trig.origin );
			who maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "door_deny" );
			continue;
		}

		trig sethintstring( "" );

		who maps\mp\zombies\_zm_score::minus_to_player_score( trig.cost );
		play_sound_at_pos( "purchase", trig.origin );

		who thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "sloth_generic_feed" );

		who maps\mp\zm_buried_buildables::onuseplantobject_key( who );

		level.sloth maps\mp\zombies\_zm_ai_sloth::sloth_set_state( "eat", who );

		while (level.sloth.state == "eat")
		{
			wait 0.05;
		}

		wait 30;

		while (level.sloth maps\mp\zombies\_zm_ai_sloth_utility::sloth_is_traversing())
		{
			wait 0.05;
		}

		level.sloth maps\mp\zombies\_zm_ai_sloth::sloth_set_state( "jail_run", 0 );

		while (level.sloth.state == "jail_run")
		{
			wait 0.05;
		}

		level.sloth notify( "stop_action" );
		level.sloth dance_action();

		level.sloth maps\mp\zombies\_zm_ai_sloth::sloth_set_state( "jail_wait" );
	}
}

sloth_damage_func()
{
	return 0;
}

dance_action()
{
    self endon( "death" );
    self endon( "stop_action" );
    self setclientfield( "sloth_vomit", 0 );
    self.dance_end = gettime() + 30000;
    level.sloth_protect = 0;
	self.dance_action = 1;

    while ( true )
    {
        if ( gettime() >= self.dance_end )
            break;

        self animscripted( self.origin, self.jail_start.angles, "zm_dance" );
        maps\mp\animscripts\zm_shared::donotetracks( "dance_anim", maps\mp\zombies\_zm_ai_sloth::vomit_notetrack );
        wait 0.1;
    }

    self notify( "stop_dance" );
    self animscripted( self.origin, self.jail_start.angles, "zm_vomit" );
    maps\mp\animscripts\zm_shared::donotetracks( "vomit_anim", maps\mp\zombies\_zm_ai_sloth::vomit_notetrack );
    self.context_done = 1;
	self.dance_action = 0;
}