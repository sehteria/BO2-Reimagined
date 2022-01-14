#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm;

#include scripts/zm/replaced/utility;
#include scripts/zm/locs/loc_common;

struct_init()
{
	scripts/zm/replaced/utility::register_perk_struct( "specialty_armorvest", "zombie_vending_jugg", ( -3563, -7196, -59 ), ( 0, 0, 0 ) );
    scripts/zm/replaced/utility::register_perk_struct( "specialty_quickrevive", "zombie_vending_quickrevive", ( -6207, -6544, -46 ), ( 0, 60, 0 ) );
    scripts/zm/replaced/utility::register_perk_struct( "specialty_fastreload", "zombie_vending_sleight", ( -5470, -7859.5, 0 ), ( 0, 270, 0 ) );
    scripts/zm/replaced/utility::register_perk_struct( "specialty_rof", "zombie_vending_doubletap2", ( -4170, -7592, -63 ), ( 0, 270, 0 ) );

    ind = 0;
    respawnpoints = maps/mp/gametypes_zm/_zm_gametype::get_player_spawns_for_gametype();
    for(i = 0; i < respawnpoints.size; i++)
    {
        if(respawnpoints[i].script_noteworthy == "zone_gas")
        {
            ind = i;
            break;
        }
    }

    respawn_array = getstructarray(respawnpoints[ind].target, "targetname");
    foreach(respawn in respawn_array)
    {
        if(respawn.script_int == 2)
        {
            respawn.angles += (0, 180, 0);
        }

        scripts/zm/replaced/utility::register_map_initial_spawnpoint( respawn.origin, respawn.angles, respawn.script_int );
    }

	gameObjects = getEntArray( "script_model", "classname" );
	foreach ( object in gameObjects )
	{
		if ( object.script_gameobjectname == "zcleansed zturned" )
		{
			object.script_gameobjectname = "zstandard zgrief zcleansed zturned";
		}
	}
}

precache()
{
    precacheModel( "zm_collision_transit_diner_survival" );
    precacheModel( "collision_wall_128x128x10_standard" );
    precacheModel( "p6_zm_buildable_bench_tarp" );
}

main()
{
    treasure_chest_init();
	init_wallbuys();
	init_barriers();
    generatebuildabletarps();
    disable_zombie_spawn_locations();
	scripts/zm/locs/loc_common::init();
}

treasure_chest_init()
{
    chests = getstructarray( "treasure_chest_use", "targetname" );
	level.chests = [];
	level.chests[0] = chests[3];
    maps/mp/zombies/_zm_magicbox::treasure_chest_init( "start_chest" );
}

init_wallbuys()
{
	scripts/zm/replaced/utility::wallbuy( "m14_zm", "m14", "weapon_upgrade", ( -5085, -7807, -5 ), ( 0, 0, 0 ) );
    scripts/zm/replaced/utility::wallbuy( "rottweil72_zm", "olympia", "weapon_upgrade", ( -4576, -7748, 18 ), ( 0, 90, 0 ) );
    scripts/zm/replaced/utility::wallbuy( "mp5k_zm", "mp5", "weapon_upgrade", ( -5489, -7982.7, 62 ), ( 0, 1, 0 ) );
    scripts/zm/replaced/utility::wallbuy( "tazer_knuckles_zm", "tazer_knuckles", "tazer_upgrade", ( -6265, -7941, 100 ), ( 0, 90, 0 ) );
}

init_barriers()
{
	collision = spawn( "script_model", ( -5000, -6700, 0 ), 1 );
	collision setmodel( "zm_collision_transit_diner_survival" );
	collision disconnectpaths();

    collision = spawn( "script_model", ( -5569, -6385, 25 ) );
    collision.angles = ( 0, 0, 0 );
	collision setmodel( "collision_wall_128x128x10_standard" );
}

generatebuildabletarps()
{
    tarp = spawn( "script_model", ( -4688, -7974, -64 ) );
    tarp.angles = ( 0, 0, 0 );
	tarp setModel( "p6_zm_buildable_bench_tarp" );
}

disable_zombie_spawn_locations()
{
	for ( z = 0; z < level.zone_keys.size; z++ )
	{
		zone = level.zones[ level.zone_keys[ z ] ];

        i = 0;
        while ( i < zone.spawn_locations.size )
        {
            if ( zone.spawn_locations[ i ].targetname == "zone_trans_diner_spawners")
            {
                zone.spawn_locations[ i ].is_enabled = false;
            }
            else if ( zone.spawn_locations[ i ].targetname == "zone_trans_diner2_spawners")
            {
                zone.spawn_locations[ i ].is_enabled = false;
            }
            else if ( zone.spawn_locations[ i ].origin == ( -3825, -6576, -52.7 ) )
            {
                zone.spawn_locations[ i ].is_enabled = false;
            }
            else if ( zone.spawn_locations[ i ].origin == ( -5130, -6512, -35.4 ) )
            {
                zone.spawn_locations[ i ].is_enabled = false;
            }
            else if ( zone.spawn_locations[ i ].origin == ( -6462, -7159, -64 ) )
            {
                zone.spawn_locations[ i ].is_enabled = false;
            }
            else if ( zone.spawn_locations[ i ].origin == ( -6531, -6613, -54.4 ) )
            {
                zone.spawn_locations[ i ].is_enabled = false;
            }

            i++;
		}
	}
}