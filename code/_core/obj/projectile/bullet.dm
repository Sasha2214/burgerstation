/obj/projectile/bullet/
	name = "bullet"
	impact_effect_turf = /obj/effect/temp/impact/bullet
	collision_bullet_flags = FLAG_COLLISION_BULLET_SOLID

	muzzleflash_effect = /obj/effect/temp/muzzleflash/
	alpha = 255

/obj/projectile/bullet/update_icon()
	. = ..()
	color = bullet_color

/obj/projectile/bullet/bolt
	name = "crossbow bolt"
	icon = 'icons/obj/projectiles/bolt.dmi'
	icon_state = "bolt"

/obj/projectile/bullet/tungsten
	name = "tungsten bolt"
	icon = 'icons/obj/projectiles/bolt.dmi'
	icon_state = "tungsten"

/obj/projectile/bullet/syringe
	name = "launched syringe"
	icon = 'icons/obj/projectiles/bolt.dmi'
	icon_state = "syringe"
	ignore_iff = TRUE
	var/reagent_to_add = /reagent/medicine/omnizine
	var/volume_to_add = 15

/obj/projectile/bullet/syringe/damage_atom(var/atom/hit_atom)

	if(is_living(hit_atom))
		var/mob/living/L = hit_atom
		if(L.iff_tag == iff_tag)
			if(L.reagents)
				L.reagents.add_reagent(reagent_to_add,volume_to_add,caller=owner)
			return TRUE

	return ..()

/obj/projectile/bullet/HE_40M

	icon = 'icons/obj/projectiles/explosive.dmi'
	icon_state = "HE"

/obj/projectile/bullet/HE_40M/post_on_hit(var/atom/hit_atom)
	. = ..()

	if(.)
		explode(get_turf(hit_atom),20,owner,weapon,iff_tag)


/obj/projectile/bullet/gyrojet
	name = "gyrojet"
	icon = 'icons/obj/projectiles/rocket.dmi'
	icon_state = "gyrojet"

/obj/projectile/bullet/gyrojet/post_on_hit(var/atom/hit_atom)
	explode(get_turf(hit_atom),10,owner,weapon,iff_tag)
	. = ..()

/obj/projectile/bullet/gyrojet/update_projectile(var/tick_rate=1)

	. = ..()

	if(.)

		var/vel_x_change = vel_x * 0.05
		var/vel_y_change = vel_y * 0.05

		if(prob(50))
			vel_x += clamp(vel_y_change * rand(-1,1),-(TILE_SIZE-1),TILE_SIZE-1)

		if(prob(50))
			vel_y += clamp(vel_x_change * rand(-1,1),-(TILE_SIZE-1),TILE_SIZE-1)

		if(abs(vel_x) <= 1	&& abs(vel_y) <= 1)
			on_hit(current_loc,TRUE)
			return FALSE



/obj/projectile/bullet/rocket
	name = "rocket"
	icon = 'icons/obj/projectiles/rocket.dmi'
	icon_state = "rocket"

/obj/projectile/bullet/rocket/post_on_hit(var/atom/hit_atom)
	. = ..()

	if(.)
		explode(get_turf(hit_atom),20,owner,src,iff_tag)

