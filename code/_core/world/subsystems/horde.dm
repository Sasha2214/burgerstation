SUBSYSTEM_DEF(horde)
	name = "Horde Subsystem"
	desc = "Spawns hoards for each player to fight."
	priority = SS_ORDER_LAST
	tick_rate = SECONDS_TO_TICKS(30)

	var/list/queued_players = list() //Assoc list.
	var/list/queued_overdue_players = list() //NOT AN ASSOC LIST

	var/list/ckey_to_time_to_horde = list() //Assoc list

	tick_usage_max = 25
	cpu_usage_max = 25


//The way that this works is that once every 10 seconds, it checks a single player to see if there are any valid spawns for it.
//It's better this way so that the system is staggered out and 30 players don't get processed on a single tick.
//There is a "failsafe" for when the player is overdue for an ass kinking.

/subsystem/horde/on_life()

	for(var/k in all_players)
		var/mob/living/advanced/player/P = k
		/*
		if(P.dead || !P.ckey || P.loyalty_tag != "NanoTrasen")
			continue
		var/area/A = get_area(P)
		if(A.area_identifier != "Mission")
			continue
		*/
		if(ckey_to_time_to_horde[P.ckey] && ckey_to_time_to_horde[P.ckey] > world.time)
			continue
		ckey_to_time_to_horde[P.ckey] = world.time + SECONDS_TO_DECISECONDS(300)
		if(queued_players[P.ckey]) //Overdue
			queued_overdue_players |= P.ckey
		else
			queued_players[P.ckey] = TRUE

	if(length(queued_players))
		queued_overdue_players |= queued_players[1] //Lazy and a bit of a misnomer, but it saves code.
		queued_players -= queued_players[1]

	for(var/ckey in queued_overdue_players)
		CHECK_TICK(tick_usage_max,FPS_SERVER)
		queued_overdue_players -= ckey
		var/client/C = CLIENT(ckey)
		if(!C || !is_player(C.mob))
			continue
		var/mob/living/advanced/player/P = C.mob
		if(!P.ckey || P.loyalty_tag != "NanoTrasen" || P.dead)
			continue
		if(!send_squad(P,/mob/living/advanced/npc/zombie/civilian/))
			ckey_to_time_to_horde[P.ckey] = world.time + SECONDS_TO_DECISECONDS(60)

	return TRUE


/subsystem/horde/proc/send_squad(var/mob/victim,var/mob/living/attacker_type,var/bypass_restrictions=FALSE)

	var/turf/T = get_turf(victim)
	if(!T)
		return FALSE

	var/area/A = T.loc
	if(!bypass_restrictions && A.area_identifier != "Mission")
		return FALSE
	//Okay. Here is the fun part. Finding spawns.
	var/my_chunk_x = CEILING(victim.loc.x/CHUNK_SIZE,1)
	var/my_chunk_y = CEILING(victim.loc.y/CHUNK_SIZE,1)
	var/my_chunk_z = victim.loc.z

	var/list/valid_nodes = list()

	for(var/x=-1,x<=1,x++)
		var/real_x = my_chunk_x+x*2
		if(real_x <= 1 || real_x >= SSchunk.chunk_count_x-1)
			continue
		for(var/y=-1,y<=1,y++)
			if(x == 0 && y == 0) //Redundant checking.
				continue
			var/real_y = my_chunk_y+y*2
			if(real_y <= 1 || real_y >= SSchunk.chunk_count_y-1)
				continue

			var/chunk/CH_CENTER = SSchunk.active_chunks[my_chunk_z][real_x][real_y]
			if(length(CH_CENTER.players))
				continue
			var/valid=TRUE
			for(var/dir in DIRECTIONS_ALL)
				var/list/offsets = direction_to_pixel_offset(dir)
				var/check_x = real_x+offsets[1]
				var/check_y = real_y+offsets[2]
				if(check_x < 1 || check_x > SSchunk.chunk_count_x) //Corner.
					continue
				if(check_y < 1 || check_y > SSchunk.chunk_count_y) //Corner.
					continue
				var/chunk/CH = SSchunk.active_chunks[my_chunk_z][check_x][check_y]
				if(length(CH.players))
					valid = FALSE
					break
			if(!valid)
				continue
			valid_nodes |= CH_CENTER.nodes

	if(!length(valid_nodes))
		return FALSE

	var/obj/marker/map_node/N_start = pick(valid_nodes)
	var/turf/squad_spawn = N_start.loc
	var/obj/marker/map_node/N_end = find_closest_node(T)
	if(!N_end)
		return FALSE
	var/list/obj/marker/map_node/found_path = N_start.find_path(N_end)
	if(!found_path)
		return FALSE

	var/list/valid_directions = list(null,NORTH,EAST,SOUTH,WEST)

	. = TRUE
	for(var/i=1,i<=5,i++)
		var/mob/living/Z = new attacker_type(get_step(squad_spawn,valid_directions[i]))
		INITIALIZE(Z)
		GENERATE(Z)
		FINALIZE(Z)
		if(!Z.ai.set_hunt_target(victim))
			. = FALSE