#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_hud_message;

main()
{
	if ( getDvar( "g_gametype" ) != "zgrief" )
    {
		return;
    }

	replaceFunc(maps/mp/zombies/_zm::onallplayersready, ::onallplayersready);
	replaceFunc(maps/mp/zombies/_zm_audio_announcer::playleaderdialogonplayer, ::playleaderdialogonplayer);
	replaceFunc(maps/mp/zombies/_zm_game_module::wait_for_team_death_and_round_end, ::wait_for_team_death_and_round_end);
	replaceFunc(maps/mp/zombies/_zm_blockers::handle_post_board_repair_rewards, ::handle_post_board_repair_rewards);
}

init()
{
    if ( getDvar( "g_gametype" ) != "zgrief" )
    {
		return;
    }

	precacheStatusIcon( "waypoint_revive" );

	if ( getDvarInt( "zombies_minplayers" ) < 2 || getDvar( "zombies_minplayers" ) == "" )
	{
		setDvar( "zombies_minplayers", 2 );
	}

	setroundsplayed(level.round_number); // don't show first round animation

	borough_move_quickrevive_machine();
	borough_move_speedcola_machine();
	borough_move_staminup_machine();

	level thread grief_score_hud();
	level thread set_grief_vars();
	level thread round_start_wait(5, true);
	level thread unlimited_zombies();
	//level thread spawn_bots(7);
}

set_team()
{
	teamplayersallies = countplayers( "allies");
	teamplayersaxis = countplayers( "axis");
	if ( teamplayersallies > teamplayersaxis )
	{
		self.team = "axis";
		self.sessionteam = "axis";
	 	self.pers[ "team" ] = "axis";
		self._encounters_team = "A";
	}
	else
	{
		self.team = "allies";
		self.sessionteam = "allies";
		self.pers[ "team" ] = "allies";
		self._encounters_team = "B";
	}
}

grief_score_hud()
{
	level.grief_hud = spawnstruct();
	level.grief_hud.icon = [];
	level.grief_hud.score = [];
	icon = [];

	icon["axis"] = "faction_cia";
	icon["allies"] = "faction_cdc";
	if(level.script == "zm_prison")
	{
		icon["axis"] = "faction_inmates";
		icon["allies"] = "faction_guards";
	}

	level.grief_hud.icon["axis"] = newHudElem();
	level.grief_hud.icon["axis"].alignx = "center";
	level.grief_hud.icon["axis"].aligny = "top";
	level.grief_hud.icon["axis"].horzalign = "user_center";
	level.grief_hud.icon["axis"].vertalign = "user_top";
	level.grief_hud.icon["axis"].x += 67.5;
	level.grief_hud.icon["axis"].y += 2;
	level.grief_hud.icon["axis"].hideWhenInMenu = 1;
	level.grief_hud.icon["axis"].alpha = 0;
	level.grief_hud.icon["axis"] setShader(icon["axis"], 32, 32);

	level.grief_hud.icon["allies"] = newHudElem();
	level.grief_hud.icon["allies"].alignx = "center";
	level.grief_hud.icon["allies"].aligny = "top";
	level.grief_hud.icon["allies"].horzalign = "user_center";
	level.grief_hud.icon["allies"].vertalign = "user_top";
	level.grief_hud.icon["allies"].x -= 67.5;
	level.grief_hud.icon["allies"].y += 2;
	level.grief_hud.icon["allies"].hideWhenInMenu = 1;
	level.grief_hud.icon["allies"].alpha = 0;
	level.grief_hud.icon["allies"] setShader(icon["allies"], 32, 32);

	level.grief_hud.score["axis"] = newHudElem();
	level.grief_hud.score["axis"].alignx = "center";
	level.grief_hud.score["axis"].aligny = "top";
	level.grief_hud.score["axis"].horzalign = "user_center";
	level.grief_hud.score["axis"].vertalign = "user_top";
	level.grief_hud.score["axis"].x += 22.5;
	level.grief_hud.score["axis"].y -= 4;
	level.grief_hud.score["axis"].fontscale = 3.5;
	level.grief_hud.score["axis"].color = (0.21, 0, 0);
	level.grief_hud.score["axis"].hideWhenInMenu = 1;
	level.grief_hud.score["axis"].alpha = 0;
	level.grief_hud.score["axis"] setValue(0);

	level.grief_hud.score["allies"] = newHudElem();
	level.grief_hud.score["allies"].alignx = "center";
	level.grief_hud.score["allies"].aligny = "top";
	level.grief_hud.score["allies"].horzalign = "user_center";
	level.grief_hud.score["allies"].vertalign = "user_top";
	level.grief_hud.score["allies"].x -= 22.5;
	level.grief_hud.score["allies"].y -= 4;
	level.grief_hud.score["allies"].fontscale = 3.5;
	level.grief_hud.score["allies"].color = (0.21, 0, 0);
	level.grief_hud.score["allies"].hideWhenInMenu = 1;
	level.grief_hud.score["allies"].alpha = 0;
	level.grief_hud.score["allies"] setValue(0);

	flag_wait( "initial_blackscreen_passed" );

	level.grief_hud.icon["axis"].alpha = 1;
	level.grief_hud.icon["allies"].alpha = 1;
	level.grief_hud.score["axis"].alpha = 1;
	level.grief_hud.score["allies"].alpha = 1;
}

set_grief_vars()
{
	level.noroundnumber = 1;
	level.player_starting_points = 10000;
	level.zombie_vars["zombie_health_start"] = 2000;
	level.zombie_vars["zombie_health_increase"] = 0;
	level.zombie_vars["zombie_health_increase_multiplier"] = 0;
	level.zombie_vars["zombie_spawn_delay"] = 1;
	level.brutus_health = 20000;
	level.brutus_expl_dmg_req = 12000;
	level.global_damage_func = ::zombie_damage;
	level.custom_end_screen = ::custom_end_screen;
	level.game_module_onplayerconnect = ::grief_onplayerconnect;
	level.game_mode_custom_onplayerdisconnect = ::grief_onplayerdisconnect;
	level._game_module_player_damage_callback = ::game_module_player_damage_callback;

	level.grief_winning_score = 3;
	level.grief_score = [];
	level.grief_score["A"] = 0;
	level.grief_score["B"] = 0;
	level.game_mode_shellshock_time = 0.75;
	level.game_mode_griefed_time = 2.5;
	level.crash_delay = 20;

	flag_wait( "start_zombie_round_logic" ); // needs a wait

	level.zombie_move_speed = 100;
}

grief_onplayerconnect()
{
	self set_team();
	self [[ level.givecustomcharacters ]]();
	self thread on_player_downed();
	self thread on_player_bleedout();
	self thread on_player_revived();
	self thread headstomp_watcher();
	self thread maps/mp/gametypes_zm/zmeat::create_item_meat_watcher();
	self.killsconfirmed = 0;
}

grief_onplayerdisconnect(disconnecting_player)
{
	level thread update_players_on_disconnect(disconnecting_player);
}

on_player_downed()
{
	self endon( "disconnect" );

	while(1)
	{
		self waittill( "entering_last_stand" );

		self.statusicon = "waypoint_revive";
		self kill_feed();
		self add_grief_downed_score();
		level thread update_players_on_downed( self );
	}
}

on_player_bleedout()
{
	self endon( "disconnect" );

	while(1)
	{
		self waittill( "bled_out" );

		self.statusicon = "hud_status_dead";
		self bleedout_feed();
		self add_grief_bleedout_score();
		level thread update_players_on_bleedout( self );
	}
}

on_player_revived()
{
	self endon( "disconnect" );

	while(1)
	{
		self waittill( "player_revived", reviver );

		self.statusicon = "";
		self revive_feed( reviver );
	}
}

kill_feed()
{
	if(isDefined(self.last_griefed_by))
	{
		self.last_griefed_by.attacker.killsconfirmed++;

		// show weapon icon for impact damage
		if(self.last_griefed_by.meansofdeath == "MOD_IMPACT")
		{
			self.last_griefed_by.meansofdeath = "MOD_UNKNOWN";
		}

		obituary(self, self.last_griefed_by.attacker, self.last_griefed_by.weapon, self.last_griefed_by.meansofdeath);
	}
	else
	{
		obituary(self, self, "none", "MOD_SUICIDE");
	}
}

bleedout_feed()
{
	obituary(self, self, "none", "MOD_CRUSH");
}

revive_feed(reviver)
{
	if(isDefined(reviver) && reviver != self)
	{
		obituary(self, reviver, level.revive_tool, "MOD_IMPACT");
	}
}

add_grief_downed_score()
{
	if(isDefined(self.score_lost_when_downed) && isDefined(self.last_griefed_by) && is_player_valid(self.last_griefed_by.attacker))
	{
		self.last_griefed_by.attacker maps/mp/zombies/_zm_score::add_to_player_score(self.score_lost_when_downed);
	}
}

add_grief_bleedout_score()
{
	players = get_players();
	foreach(player in players)
	{
		if(is_player_valid(player) && player.team != self.team)
		{
			points = round_up_to_ten(int(player.score * level.zombie_vars["penalty_no_revive"]));
			player maps/mp/zombies/_zm_score::add_to_player_score(points);
		}
	}
}

headstomp_watcher()
{
	self endon("disconnect");

	while(1)
	{
		if(self.sessionstate != "playing")
		{
			wait 0.05;
			continue;
		}

		players = get_players();
		foreach(player in players)
		{
			if(player != self && player.team != self.team && is_player_valid(player) && player isOnGround() && player getStance() == "prone" && self.origin[2] > player.origin[2])
			{
				max_horz_dist = 24;
				max_vert_dist = 68;

				if(player getStance() == "crouch")
				{
					max_vert_dist = 52;
				}
				else if(player getStance() == "prone")
				{
					max_vert_dist = 36;
				}

				if(distance2d(self.origin, player.origin) <= max_horz_dist && (self.origin[2] - player.origin[2]) <= max_vert_dist)
				{
					player store_player_damage_info(self, "none", "MOD_FALLING");
					player dodamage( 1000, (0, 0, 0) );
				}
			}
		}

		wait 0.05;
	}
}

wait_for_team_death_and_round_end()
{
	level endon( "game_module_ended" );
	level endon( "end_game" );

	checking_for_round_end = 0;
	level.isresetting_grief = 0;
	while ( 1 )
	{
		cdc_total = 0;
		cia_total = 0;
		cdc_alive = 0;
		cia_alive = 0;
		players = get_players();
		i = 0;
		while ( i < players.size )
		{
			if ( !isDefined( players[ i ]._encounters_team ) )
			{
				i++;
				continue;
			}
			if ( players[ i ]._encounters_team == "A" )
			{
				cia_total++;
				if ( is_player_valid( players[ i ] ) )
				{
					cia_alive++;
				}
				i++;
				continue;
			}
			cdc_total++;
			if ( is_player_valid( players[ i ] ) )
			{
				cdc_alive++;
			}
			i++;
		}

		if ( !checking_for_round_end )
		{
			if ( cia_alive == 0 )
			{
				level thread round_end( "B", cia_total == 0 );
				checking_for_round_end = 1;
			}
			else if ( cdc_alive == 0 )
			{
				level thread round_end( "A", cdc_total == 0 );
				checking_for_round_end = 1;
			}
		}

		if ( cia_alive > 0 && cdc_alive > 0 )
		{
			level notify( "stop_round_end_check" );
			checking_for_round_end = 0;
		}

		wait 0.05;
	}
}

zombie_goto_round(target_round)
{
	level endon( "end_game" );

	if ( target_round < 1 )
	{
		target_round = 1;
	}

	level.zombie_total = 0;
	zombies = get_round_enemy_array();
	if ( isDefined( zombies ) )
	{
		for ( i = 0; i < zombies.size; i++ )
		{
			zombies[ i ] dodamage( zombies[ i ].health + 666, zombies[ i ].origin );
		}
	}

	maps/mp/zombies/_zm_game_module::respawn_players();
	maps/mp/zombies/_zm::award_grenades_for_survivors();
	players = get_players();
	foreach(player in players)
	{
		if(player.score < level.player_starting_points)
		{
			player maps/mp/zombies/_zm_score::add_to_player_score(level.player_starting_points - player.score);
		}

		if(isDefined(player get_player_placeable_mine()))
		{
			player giveweapon(player get_player_placeable_mine());
			player set_player_placeable_mine(player get_player_placeable_mine());
			player setactionslot(4, "weapon", player get_player_placeable_mine());
			player setweaponammoclip(player get_player_placeable_mine(), 2);
		}
	}

	level thread round_start_wait(5);
}

round_start_wait(time, initial)
{
	if(!isDefined(initial))
	{
		initial = false;
	}

	if(initial)
	{
		flag_clear("spawn_zombies");

		flag_wait( "start_zombie_round_logic" );

		players = get_players();
		foreach(player in players)
		{
			player disableWeapons();
		}

		flag_wait("initial_blackscreen_passed");
	}

	level thread zombie_spawn_wait(time + 5);

	players = get_players();
	foreach(player in players)
	{
		player thread wait_and_freeze_controls(1); // need a wait or players can move
		player enableInvulnerability();
		player disableWeapons();
	}

	round_start_countdown_hud = round_start_countdown_hud(time);

	wait time;

	round_start_countdown_hud round_start_countdown_hud_destroy();

	players = get_players();
	foreach(player in players)
	{
		player freezeControls(0);
		player disableInvulnerability();
		player enableWeapons();
	}
}

wait_and_freeze_controls(bool)
{
	self endon("disconnect");

	wait_network_frame();

	self freezeControls(bool);
}

round_start_countdown_hud(time)
{
	countdown = createServerFontString( "objective", 2.2 );
    countdown setPoint( "CENTER", "CENTER", 0, 0 );
    countdown.foreground = false;
    countdown.alpha = 1;
    countdown.color = ( 1, 1, 0 );
    countdown.hidewheninmenu = true;
    countdown maps/mp/gametypes_zm/_hud::fontpulseinit();
    countdown thread round_start_countdown_hud_timer(time);
	countdown thread round_start_countdown_hud_end_game_watcher();

	countdown.countdown_text = createServerFontString( "objective", 1.5 );
    countdown.countdown_text setPoint( "CENTER", "CENTER", 0, -40 );
    countdown.countdown_text.foreground = false;
    countdown.countdown_text.alpha = 1;
    countdown.countdown_text.color = ( 1.000, 1.000, 1.000 );
    countdown.countdown_text.hidewheninmenu = true;
    countdown.countdown_text.label = &"ROUND BEGINS IN";

	return countdown;
}

round_start_countdown_hud_destroy()
{
	self.countdown_text destroy();
	self destroy();
}

round_start_countdown_hud_end_game_watcher()
{
	self endon("death");

	level waittill( "end_game" );

	self round_start_countdown_hud_destroy();
}

round_start_countdown_hud_timer(time)
{
	level endon( "end_game" );

    timer = time;
    while ( true )
    {
        self setValue( timer );
        wait 1;
        timer--;
        if ( timer <= 5 )
        {
            self thread countdown_pulse( self, timer );
            break;
        }
    }
}

countdown_pulse( hud_elem, duration )
{
    level endon( "end_game" );

    waittillframeend;

    while ( duration > 0 && !level.gameended )
    {
        hud_elem thread maps/mp/gametypes_zm/_hud::fontpulse( level );
        wait ( hud_elem.inframes * 0.05 );
        hud_elem setvalue( duration );
        duration--;
        wait ( 1 - ( hud_elem.inframes * 0.05 ) );
    }
}

zombie_spawn_wait(time)
{
	flag_clear("spawn_zombies");

	wait time;

	flag_set("spawn_zombies");
}

round_end(winner, force_win)
{
	if(!isDefined(force_win))
	{
		force_win = false;
	}

	winner_alive = 0;
	team = "axis";
	if(winner == "B")
	{
		team = "allies";
	}

	if(!force_win)
	{
		wait 5;
	}

	players = get_players();
	foreach(player in players)
	{
		if(is_player_valid(player) && player.team == team)
		{
			winner_alive = 1;
			break;
		}
	}

	if(winner_alive)
	{
		level.grief_score[winner]++;
		level.grief_hud.score[team] setValue(level.grief_score[winner]);
	}

	if(level.grief_score[winner] == level.grief_winning_score || force_win)
	{
		level.gamemodulewinningteam = winner;
		level.zombie_vars[ "spectators_respawn" ] = 0;
		players = get_players();
		i = 0;
		while ( i < players.size )
		{
			players[ i ] freezecontrols( 1 );
			if ( players[ i ]._encounters_team == winner )
			{
				players[ i ] thread maps/mp/zombies/_zm_audio_announcer::leaderdialogonplayer( "grief_won" );
				i++;
				continue;
			}
			players[ i ] thread maps/mp/zombies/_zm_audio_announcer::leaderdialogonplayer( "grief_lost" );
			i++;
		}
		level notify( "game_module_ended", winner );
		level._game_module_game_end_check = undefined;
		maps/mp/gametypes_zm/_zm_gametype::track_encounters_win_stats( level.gamemodulewinningteam );
		level notify( "end_game" );
	}
	else
	{
		players = get_players();
		foreach(player in players)
		{
			// don't give score back from down
			player.pers["score"] = player.score;

			if(is_player_valid(player))
			{
				// don't give perk
				player notify("perk_abort_drinking");
				// save weapons
				player [[level._game_module_player_laststand_callback]]();
			}
		}

		level.isresetting_grief = 1;
		level notify( "end_round_think" );
		level.zombie_vars[ "spectators_respawn" ] = 1;
		level notify( "keep_griefing" );
		level notify( "restart_round" );

		level.round_number++;
		setroundsplayed(level.round_number);

		level thread maps/mp/zombies/_zm_audio_announcer::leaderdialog( "grief_restarted" );
		if(!winner_alive)
		{
			foreach(player in players)
			{
				player thread show_grief_hud_msg( &"ZOMBIE_GRIEF_RESET" );
			}
		}

		zombie_goto_round( level.round_number );
		level thread maps/mp/zombies/_zm_game_module::reset_grief();
		level thread maps/mp/zombies/_zm::round_think( 1 );
	}
}

update_players_on_downed(excluded_player)
{
	players_remaining = 0;
	last_player = undefined;
	other_team = undefined;

	players = get_players();
	i = 0;

	while ( i < players.size )
	{
		player = players[i];
		if ( player == excluded_player )
		{
			i++;
			continue;
		}
		if ( player.team == excluded_player.team )
		{
			if ( is_player_valid( player ) )
			{
				players_remaining++;
				last_player = player;
			}
			i++;
			continue;
		}
		i++;
	}

	i = 0;

	while ( i < players.size )
	{
		player = players[i];

		if ( player == excluded_player )
		{
			i++;
			continue;
		}
		if ( player.team != excluded_player.team )
		{
			other_team = player.team;
			if ( players_remaining < 1 )
			{
				player thread show_grief_hud_msg( &"ZOMBIE_ZGRIEF_ALL_PLAYERS_DOWN" );
				player thread show_grief_hud_msg( &"ZOMBIE_ZGRIEF_SURVIVE", undefined, 30, 2 );
				i++;
				continue;
			}
			player thread show_grief_hud_msg( &"ZOMBIE_ZGRIEF_PLAYER_BLED_OUT", players_remaining );
		}
		i++;
	}

	if ( players_remaining == 1 )
	{
		if(isDefined(last_player))
		{
			last_player thread maps/mp/zombies/_zm_audio_announcer::leaderdialogonplayer( "last_player" );
		}
	}

	if ( !isDefined( other_team ) )
	{
		return;
	}

	level thread maps/mp/zombies/_zm_audio_announcer::leaderdialog( players_remaining + "_player_left", other_team );
}

update_players_on_bleedout(excluded_player)
{
	other_team = undefined;
	team_bledout = 0;
	players = get_players();
	i = 0;

	while(i < players.size)
	{
		player = players[i];

		if(player.team == excluded_player.team)
		{
			if(player == excluded_player || player.sessionstate != "playing")
			{
				team_bledout++;
			}
		}
		else
		{
			other_team = player.team;
		}

		i++;
	}

	if(!isDefined(other_team))
	{
		return;
	}

	level thread maps/mp/zombies/_zm_audio_announcer::leaderdialog(team_bledout + "_player_down", other_team);
}

update_players_on_disconnect(excluded_player)
{
	if(is_player_valid(excluded_player))
	{
		update_players_on_downed(excluded_player);
	}
}

show_grief_hud_msg( msg, msg_parm, offset, delay )
{
	if(!isDefined(delay))
	{
		self notify( "show_grief_hud_msg" );
	}

	self endon( "disconnect" );

	zgrief_hudmsg = newclienthudelem( self );
	zgrief_hudmsg.alignx = "center";
	zgrief_hudmsg.aligny = "middle";
	zgrief_hudmsg.horzalign = "center";
	zgrief_hudmsg.vertalign = "middle";
	zgrief_hudmsg.y -= 130;

	if ( self issplitscreen() )
	{
		zgrief_hudmsg.y += 70;
	}

	if ( isDefined( offset ) )
	{
		zgrief_hudmsg.y += offset;
	}

	zgrief_hudmsg.foreground = 1;
	zgrief_hudmsg.fontscale = 5;
	zgrief_hudmsg.alpha = 0;
	zgrief_hudmsg.color = ( 1, 1, 1 );
	zgrief_hudmsg.hidewheninmenu = 1;
	zgrief_hudmsg.font = "default";

	zgrief_hudmsg endon( "death" );

	zgrief_hudmsg thread show_grief_hud_msg_cleanup(self);

	while ( isDefined( level.hostmigrationtimer ) )
	{
		wait 0.05;
	}

	if(isDefined(delay))
	{
		wait delay;
	}

	if ( isDefined( msg_parm ) )
	{
		zgrief_hudmsg settext( msg, msg_parm );
	}
	else
	{
		zgrief_hudmsg settext( msg );
	}

	zgrief_hudmsg changefontscaleovertime( 0.25 );
	zgrief_hudmsg fadeovertime( 0.25 );
	zgrief_hudmsg.alpha = 1;
	zgrief_hudmsg.fontscale = 2;

	wait 3.25;

	zgrief_hudmsg changefontscaleovertime( 1 );
	zgrief_hudmsg fadeovertime( 1 );
	zgrief_hudmsg.alpha = 0;
	zgrief_hudmsg.fontscale = 5;

	wait 1;

	if ( isDefined( zgrief_hudmsg ) )
	{
		zgrief_hudmsg destroy();
	}
}

show_grief_hud_msg_cleanup(player)
{
	self endon( "death" );

	self thread show_grief_hud_msg_cleanup_restart_round();
	self thread show_grief_hud_msg_cleanup_end_game();

	player waittill( "show_grief_hud_msg" );

	if ( isDefined( self ) )
	{
		self destroy();
	}
}

show_grief_hud_msg_cleanup_restart_round()
{
	self endon( "death" );

	level waittill( "restart_round" );

	if ( isDefined( self ) )
	{
		self destroy();
	}
}

show_grief_hud_msg_cleanup_end_game()
{
	self endon( "death" );

	level waittill( "end_game" );

	if ( isDefined( self ) )
	{
		self destroy();
	}
}

custom_end_screen()
{
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		players[ i ].game_over_hud = newclienthudelem( players[ i ] );
		players[ i ].game_over_hud.alignx = "center";
		players[ i ].game_over_hud.aligny = "middle";
		players[ i ].game_over_hud.horzalign = "center";
		players[ i ].game_over_hud.vertalign = "middle";
		players[ i ].game_over_hud.y -= 130;
		players[ i ].game_over_hud.foreground = 1;
		players[ i ].game_over_hud.fontscale = 3;
		players[ i ].game_over_hud.alpha = 0;
		players[ i ].game_over_hud.color = ( 1, 1, 1 );
		players[ i ].game_over_hud.hidewheninmenu = 1;
		players[ i ].game_over_hud settext( &"ZOMBIE_GAME_OVER" );
		players[ i ].game_over_hud fadeovertime( 1 );
		players[ i ].game_over_hud.alpha = 1;
		if ( players[ i ] issplitscreen() )
		{
			players[ i ].game_over_hud.fontscale = 2;
			players[ i ].game_over_hud.y += 40;
		}
		players[ i ].survived_hud = newclienthudelem( players[ i ] );
		players[ i ].survived_hud.alignx = "center";
		players[ i ].survived_hud.aligny = "middle";
		players[ i ].survived_hud.horzalign = "center";
		players[ i ].survived_hud.vertalign = "middle";
		players[ i ].survived_hud.y -= 100;
		players[ i ].survived_hud.foreground = 1;
		players[ i ].survived_hud.fontscale = 2;
		players[ i ].survived_hud.alpha = 0;
		players[ i ].survived_hud.color = ( 1, 1, 1 );
		players[ i ].survived_hud.hidewheninmenu = 1;
		if ( players[ i ] issplitscreen() )
		{
			players[ i ].survived_hud.fontscale = 1.5;
			players[ i ].survived_hud.y += 40;
		}
		winner_text = "YOU WIN!";
		loser_text = "YOU LOSE!";

		if ( isDefined( level.host_ended_game ) && level.host_ended_game )
		{
			players[ i ].survived_hud settext( &"MP_HOST_ENDED_GAME" );
		}
		else
		{
			if ( isDefined( level.gamemodulewinningteam ) && players[ i ]._encounters_team == level.gamemodulewinningteam )
			{
				players[ i ].survived_hud settext( winner_text );
			}
			else
			{
				players[ i ].survived_hud settext( loser_text );
			}
		}
		players[ i ].survived_hud fadeovertime( 1 );
		players[ i ].survived_hud.alpha = 1;
		i++;
	}
}

game_module_player_damage_callback( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
	self.last_damage_from_zombie_or_player = 0;
	if ( isDefined( eattacker ) )
	{
		if ( isplayer( eattacker ) && eattacker == self )
		{
			return;
		}
		if ( isDefined( eattacker.is_zombie ) || eattacker.is_zombie && isplayer( eattacker ) )
		{
			self.last_damage_from_zombie_or_player = 1;
		}
	}

	if ( self maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
	{
		return;
	}

	if ( isplayer( eattacker ) && isDefined( eattacker._encounters_team ) && eattacker._encounters_team != self._encounters_team )
	{
		if ( is_true( self.hasriotshield ) && isDefined( vdir ) )
		{
			if ( is_true( self.hasriotshieldequipped ) )
			{
				if ( self maps/mp/zombies/_zm::player_shield_facing_attacker( vdir, 0.2 ) && isDefined( self.player_shield_apply_damage ) )
				{
					return;
				}
			}
			else if ( !isdefined( self.riotshieldentity ) )
			{
				if ( !self maps/mp/zombies/_zm::player_shield_facing_attacker( vdir, -0.2 ) && isdefined( self.player_shield_apply_damage ) )
				{
					return;
				}
			}
		}

		is_melee = false;
		if ( isDefined( eattacker ) && isplayer( eattacker ) && eattacker != self && eattacker.team != self.team && smeansofdeath == "MOD_MELEE" )
		{
			is_melee = true;
			self applyknockback( idamage, vdir );

			if(self getstance() == "prone")
			{
				self setStance("crouch");
			}
		}

		if ( is_true( self._being_shellshocked ) && !is_melee )
		{
			return;
		}

		if ( isDefined( level._effect[ "butterflies" ] ) )
		{
			if ( isDefined( sweapon ) && weapontype( sweapon ) == "grenade" )
			{
				playfx( level._effect[ "butterflies" ], self.origin + vectorScale( ( 1, 1, 1 ), 40 ) );
			}
			else
			{
				playfx( level._effect[ "butterflies" ], vpoint, vdir );
			}
		}

		self thread do_game_mode_shellshock();
		self playsound( "zmb_player_hit_ding" );

		self thread stun_score_steal(eattacker, 10);
		self thread store_player_damage_info(eattacker, sweapon, smeansofdeath);
	}
}

do_game_mode_shellshock()
{
	self notify( "do_game_mode_shellshock" );
	self endon( "do_game_mode_shellshock" );
	self endon( "disconnect" );

	self._being_shellshocked = 1;
	self shellshock( "grief_stab_zm", level.game_mode_shellshock_time );
	wait level.game_mode_shellshock_time;
	self._being_shellshocked = 0;
}

stun_score_steal(attacker, score)
{
	if(is_player_valid(attacker))
	{
		attacker maps/mp/zombies/_zm_score::add_to_player_score(score);
	}

	if(self.score < score)
	{
		self maps/mp/zombies/_zm_score::minus_to_player_score(self.score);
	}
	else
	{
		self maps/mp/zombies/_zm_score::minus_to_player_score(score);
	}
}

store_player_damage_info(attacker, weapon, meansofdeath)
{
	self.last_griefed_by = spawnStruct();
	self.last_griefed_by.attacker = attacker;
	self.last_griefed_by.weapon = weapon;
	self.last_griefed_by.meansofdeath = meansofdeath;

	self thread remove_player_damage_info();
}

remove_player_damage_info()
{
	self notify("new_griefer");
	self endon("new_griefer");
	self endon("disconnect");

	health = self.health;
	time = getTime();
	max_time = level.game_mode_griefed_time * 1000;

	wait_network_frame(); // need to wait at least one frame

	while(((getTime() - time) < max_time || self.health < health) && is_player_valid(self))
	{
		wait_network_frame();
	}

	self.last_griefed_by = undefined;
}

unlimited_zombies()
{
	while(1)
	{
		if(!is_true(level.isresetting_grief))
		{
			level.zombie_total = 100;
		}

		wait 1;
	}
}

onallplayersready()
{
	while ( getPlayers().size < getDvarInt( "zombies_minplayers" ) )
	{
		wait 0.1;
	}
	game[ "state" ] = "playing";
	wait_for_all_players_to_connect( level.crash_delay );
	setinitialplayersconnected();
	flag_set( "initial_players_connected" );
	while ( !aretexturesloaded() )
	{
		wait 0.05;
	}
	thread maps/mp/zombies/_zm::start_zombie_logic_in_x_sec( 3 );
	maps/mp/zombies/_zm::fade_out_intro_screen_zm( 5, 1.5, 1 );
}

wait_for_all_players_to_connect( max_wait )
{
	timeout = int( max_wait * 10 );
	cur_time = 0;
	player_count_actual = 0;
	while ( getnumconnectedplayers() < getnumexpectedplayers() || player_count_actual != getnumexpectedplayers() )
	{
		players = getPlayers();
		player_count_actual = 0;
		for ( i = 0; i < players.size; i++ )
		{
			players[ i ] freezecontrols( 1 );
			if ( players[ i ].sessionstate == "playing" )
			{
				player_count_actual++;
			}
		}
		wait 0.1;
		cur_time++;
		if ( cur_time >= timeout )
		{
			return;
		}
	}
}

playleaderdialogonplayer( dialog, team, waittime )
{
	self endon( "disconnect" );

	if ( level.allowzmbannouncer )
	{
		if ( !isDefined( game[ "zmbdialog" ][ dialog ] ) )
		{
			return;
		}
	}
	self.zmbdialogactive = 1;
	if ( isDefined( self.zmbdialoggroups[ dialog ] ) )
	{
		group = dialog;
		dialog = self.zmbdialoggroups[ group ];
		self.zmbdialoggroups[ group ] = undefined;
		self.zmbdialoggroup = group;
	}
	if ( level.allowzmbannouncer )
	{
		alias = game[ "zmbdialog" ][ "prefix" ] + "_" + game[ "zmbdialog" ][ dialog ];
		variant = self maps/mp/zombies/_zm_audio_announcer::getleaderdialogvariant( alias );
		if ( !isDefined( variant ) )
		{
			full_alias = alias + "_" + "0";
			if ( level.script == "zm_prison" )
			{
				dialogType = strtok( game[ "zmbdialog" ][ dialog ], "_" );
				switch ( dialogType[ 0 ] )
				{
					case "powerup":
						full_alias = alias;
						break;
					case "grief":
						full_alias = alias + "_" + "0";
						break;
					default:
						full_alias = alias;
				}
			}
		}
		else
		{
			full_alias =  alias + "_" + variant;
		}
		self playlocalsound( full_alias );
	}

	/*
	if ( isDefined( waittime ) )
	{
		wait waittime;
	}
	else
	{
		wait 4;
	}
	*/

	self.zmbdialogactive = 0;
	self.zmbdialoggroup = "";
	if ( self.zmbdialogqueue.size > 0 && level.allowzmbannouncer )
	{
		nextdialog = self.zmbdialogqueue[0];
		for( i = 1; i < self.zmbdialogqueue.size; i++ )
		{
			self.zmbdialogqueue[ i - 1 ] = self.zmbdialogqueue[ i ];
		}
		self.zmbdialogqueue[ i - 1 ] = undefined;
		self thread playleaderdialogonplayer( nextdialog, team );
	}
}

zombie_damage( mod, hit_location, hit_origin, player, amount, team )
{
	if ( is_magic_bullet_shield_enabled( self ) )
	{
		return;
	}
	player.use_weapon_type = mod;
	if ( isDefined( self.marked_for_death ) )
	{
		return;
	}
	if ( !isDefined( player ) )
	{
		return;
	}
	if ( isDefined( hit_origin ) )
	{
		self.damagehit_origin = hit_origin;
	}
	else
	{
		self.damagehit_origin = player getweaponmuzzlepoint();
	}
	if ( self maps/mp/zombies/_zm_spawner::check_zombie_damage_callbacks( mod, hit_location, hit_origin, player, amount ) )
	{
		return;
	}
	else if ( self maps/mp/zombies/_zm_spawner::zombie_flame_damage( mod, player ) )
	{
		if ( self maps/mp/zombies/_zm_spawner::zombie_give_flame_damage_points() )
		{
			player maps/mp/zombies/_zm_score::player_add_points( "damage", mod, hit_location, self.isdog, team );
		}
	}
	else if ( maps/mp/zombies/_zm_spawner::player_using_hi_score_weapon( player ) )
	{
		damage_type = "damage";
	}
	else
	{
		damage_type = "damage_light";
	}
	if ( !is_true( self.no_damage_points ) )
	{
		player maps/mp/zombies/_zm_score::player_add_points( damage_type, mod, hit_location, self.isdog, team, self.damageweapon );
	}
	if ( isDefined( self.zombie_damage_fx_func ) )
	{
		self [[ self.zombie_damage_fx_func ]]( mod, hit_location, hit_origin, player );
	}
	modname = remove_mod_from_methodofdeath( mod );
	if ( is_placeable_mine( self.damageweapon ) )
	{
		damage = 2000;
		if ( isDefined( self.zombie_damage_claymore_func ) )
		{
			self [[ self.zombie_damage_claymore_func ]]( mod, hit_location, hit_origin, player );
		}
		else if ( isDefined( player ) && isalive( player ) )
		{
			self dodamage( damage, self.origin, player, self, hit_location, mod );
		}
		else
		{
			self dodamage( damage, self.origin, undefined, self, hit_location, mod );
		}
	}
	else if ( mod == "MOD_GRENADE" || mod == "MOD_GRENADE_SPLASH" )
	{
		damage = 150;
		if ( isDefined( player ) && isalive( player ) )
		{
			player.grenade_multiattack_count++;
			player.grenade_multiattack_ent = self;
			self dodamage( damage, self.origin, player, self, hit_location, modname );
		}
		else
		{
			self dodamage( damage, self.origin, undefined, self, hit_location, modname );
		}
	}
	else if ( mod != "MOD_PROJECTILE" || mod == "MOD_EXPLOSIVE" && mod == "MOD_PROJECTILE_SPLASH" )
	{
		damage = 1000;
		if ( isDefined( player ) && isalive( player ) )
		{
			self dodamage( damage, self.origin, player, self, hit_location, modname );
		}
		else
		{
			self dodamage( damage, self.origin, undefined, self, hit_location, modname );
		}
	}
	if ( isDefined( self.a.gib_ref ) && self.a.gib_ref == "no_legs" && isalive( self ) )
	{
		if ( isDefined( player ) )
		{
			rand = randomintrange( 0, 100 );
			if ( rand < 10 )
			{
				player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "crawl_spawn" );
			}
		}
	}
	else if ( isDefined( self.a.gib_ref ) || self.a.gib_ref == "right_arm" && self.a.gib_ref == "left_arm" )
	{
		if ( self.has_legs && isalive( self ) )
		{
			if ( isDefined( player ) )
			{
				rand = randomintrange( 0, 100 );
				if ( rand < 7 )
				{
					player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "shoot_arm" );
				}
			}
		}
	}
	self thread maps/mp/zombies/_zm_powerups::check_for_instakill( player, mod, hit_location );
}

handle_post_board_repair_rewards( cost, zbarrier )
{
	self maps/mp/zombies/_zm_stats::increment_client_stat( "boards" );
	self maps/mp/zombies/_zm_stats::increment_player_stat( "boards" );
	if ( isDefined( self.pers[ "boards" ] ) && ( self.pers[ "boards" ] % 10 ) == 0 )
	{
		self thread do_player_general_vox( "general", "reboard", 90 );
	}
	self maps/mp/zombies/_zm_pers_upgrades_functions::pers_boards_updated( zbarrier );
	self.rebuild_barrier_reward += cost;

	self maps/mp/zombies/_zm_score::player_add_points( "rebuild_board", cost );
	self play_sound_on_ent( "purchase" );

	if ( isDefined( self.board_repair ) )
	{
		self.board_repair += 1;
	}
}

borough_move_quickrevive_machine()
{
	if (level.scr_zm_map_start_location != "street")
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
			if (struct.script_noteworthy == "specialty_quickrevive" && IsSubStr(struct.script_string, "zgrief"))
			{
				perk_struct = struct;
			}
			else if (struct.script_noteworthy == "specialty_fastreload" && IsSubStr(struct.script_string, "zgrief"))
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
	perk_location_struct.origin += (0, -30, 0); // fix for location being slightly off
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
	maps/mp/zombies/_zm_power::add_powered_item( maps/mp/zombies/_zm_power::perk_power_on, scripts/zm/main/_zm_reimagined::perk_power_off, maps/mp/zombies/_zm_power::perk_range, maps/mp/zombies/_zm_power::cost_low_if_local, 0, powered_on, use_trigger );
}

borough_move_speedcola_machine()
{
	if (level.scr_zm_map_start_location != "street")
	{
		return;
	}

	perk_struct = undefined;
	structs = getstructarray("zm_perk_machine", "targetname");
	foreach (struct in structs)
	{
		if (IsDefined(struct.script_noteworthy) && IsDefined(struct.script_string))
		{
			if (struct.script_noteworthy == "specialty_fastreload" && IsSubStr(struct.script_string, "zclassic"))
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
		if (IsDefined(trig.script_noteworthy) && trig.script_noteworthy == "specialty_fastreload")
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

	use_trigger.script_sound = "mus_perks_speed_jingle";
	use_trigger.script_string = "speedcola_perk";
	use_trigger.script_label = "mus_perks_speed_sting";
	use_trigger.target = "vending_sleight";
	perk_machine.script_string = "speedcola_perk";
	perk_machine.targetname = "vending_sleight";
	bump_trigger.script_string = "speedcola_perk";

	level thread maps/mp/zombies/_zm_perks::turn_sleight_on();
	use_trigger thread maps/mp/zombies/_zm_perks::vending_trigger_think();
	use_trigger thread maps/mp/zombies/_zm_perks::electric_perks_dialog();

	powered_on = maps/mp/zombies/_zm_perks::get_perk_machine_start_state( use_trigger.script_noteworthy );
	maps/mp/zombies/_zm_power::add_powered_item( maps/mp/zombies/_zm_power::perk_power_on, scripts/zm/main/_zm_reimagined::perk_power_off, maps/mp/zombies/_zm_power::perk_range, maps/mp/zombies/_zm_power::cost_low_if_local, 0, powered_on, use_trigger );
}

borough_move_staminup_machine()
{
	if (level.scr_zm_map_start_location != "street")
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
			if (struct.script_noteworthy == "specialty_longersprint" && IsSubStr(struct.script_string, "zgrief"))
			{
				perk_struct = struct;
			}
			else if (struct.script_noteworthy == "specialty_quickrevive" && IsSubStr(struct.script_string, "zgrief"))
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
	maps/mp/zombies/_zm_power::add_powered_item( maps/mp/zombies/_zm_power::perk_power_on, scripts/zm/main/_zm_reimagined::perk_power_off, maps/mp/zombies/_zm_power::perk_range, maps/mp/zombies/_zm_power::cost_low_if_local, 0, powered_on, use_trigger );
}

spawn_bots(num)
{
	level waittill( "connected", player );

	level.bots = [];

	for(i = 0; i < num; i++)
	{
		if(get_players().size == 8)
		{
			break;
		}

		// fixes bot occasionally not spawning
		while(!isDefined(level.bots[i]))
		{
			level.bots[i] = addtestclient();
		}

		wait 0.4; // need wait or bots don't spawn at correct origin
	}
}