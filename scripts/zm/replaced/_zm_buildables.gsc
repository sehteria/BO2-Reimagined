#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_equipment;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zombies\_zm_buildables;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\_demo;

buildable_place_think()
{
	self endon( "kill_trigger" );
	player_built = undefined;
	while ( isDefined( self.stub.built ) && !self.stub.built )
	{
		self waittill( "trigger", player );

		slot = self.stub.buildablestruct.buildable_slot;
		bind_to = self.stub.buildable_pool scripts\zm\replaced\_zm_buildables_pooled::pooledbuildable_stub_for_piece( player player_get_buildable_piece( slot ) );

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

		status = player maps\mp\zombies\_zm_buildables::player_can_build( self.stub.buildablezone );
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
			result = self maps\mp\zombies\_zm_buildables::buildable_use_hold_think( player );
			team = player.pers[ "team" ];
			if ( isDefined( self.stub.onenduse ) )
			{
				self.stub [[ self.stub.onenduse ]]( team, player, result );
			}
			if ( !result )
			{
				continue;
			}

			if (bind_to != self.stub)
			{
				scripts\zm\replaced\_zm_buildables_pooled::swap_buildable_fields( self.stub, bind_to );
			}

			if ( isDefined( self.stub.onuse ) )
			{
				self.stub [[ self.stub.onuse ]]( player );
			}
			prompt = player maps\mp\zombies\_zm_buildables::player_build( self.stub.buildablezone );
			player_built = player;
			self.stub.hint_string = prompt;
			self sethintstring( self.stub.hint_string );
		}
	}

	if ( self.stub.persistent == 4 )
	{
        self [[ self.stub.custom_completion_callback ]]( player_built );
		return;
	}

	if ( self.stub.persistent == 0 )
	{
		self.stub maps\mp\zombies\_zm_buildables::buildablestub_remove();
		thread maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( self.stub );
		return;
	}

	if ( self.stub.persistent == 3 )
	{
		maps\mp\zombies\_zm_buildables::stub_unbuild_buildable( self.stub, 1 );
		return;
	}

	if ( self.stub.persistent == 2 )
	{
		if ( isDefined( player_built ) )
		{
			self scripts\zm\replaced\_zm_buildables_pooled::pooledbuildabletrigger_update_prompt( player_built );
		}

		if ( !maps\mp\zombies\_zm_weapons::limited_weapon_below_quota( self.stub.weaponname, undefined ) )
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

			if ( !maps\mp\zombies\_zm_weapons::limited_weapon_below_quota( self.stub.weaponname, undefined ) )
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

			player maps\mp\zombies\_zm_score::minus_to_player_score( self.stub.cost );
			self play_sound_on_ent( "purchase" );

			self.stub.bought = 1;

			if ( isDefined( self.stub.model ) )
			{
				self.stub.model thread maps\mp\zombies\_zm_buildables::model_fly_away();
			}

			player maps\mp\zombies\_zm_weapons::weapon_give( self.stub.weaponname );

			if ( isDefined( level.zombie_include_buildables[ self.stub.equipname ].onbuyweapon ) )
			{
				self [[ level.zombie_include_buildables[ self.stub.equipname ].onbuyweapon ]]( player );
			}

            if ( isDefined( level.zombie_buildables[ self.stub.equipname ].bought ) )
            {
                self.stub.hint_string = level.zombie_buildables[ self.stub.equipname ].bought;
            }
            else
            {
                if ( !maps\mp\zombies\_zm_weapons::limited_weapon_below_quota( self.stub.weaponname, undefined ) )
                {
                    self.stub.hint_string = &"ZOMBIE_GO_TO_THE_BOX_LIMITED";
                }
                else
                {
                    self.stub.hint_string = &"ZOMBIE_GO_TO_THE_BOX";
                }
            }

			self sethintstring( self.stub.hint_string );
			player maps\mp\zombies\_zm_buildables::track_buildables_pickedup( self.stub.weaponname );
		}
	}
	else while ( !isDefined( player_built ) || self scripts\zm\replaced\_zm_buildables_pooled::pooledbuildabletrigger_update_prompt( player_built ) )
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

			if ( !maps\mp\zombies\_zm_equipment::is_limited_equipment( self.stub.weaponname ) || !maps\mp\zombies\_zm_equipment::limited_equipment_in_use( self.stub.weaponname ) )
			{
				player maps\mp\zombies\_zm_score::minus_to_player_score( self.stub.cost );
				self play_sound_on_ent( "purchase" );

				player maps\mp\zombies\_zm_equipment::equipment_buy( self.stub.weaponname );
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
				player maps\mp\zombies\_zm_buildables::track_buildables_pickedup( self.stub.weaponname );
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