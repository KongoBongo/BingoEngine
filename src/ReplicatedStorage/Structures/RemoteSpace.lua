return {
	Players = {
		OptIn = "OptIn", -- Invokes when the client properly connects to the server.
		OptOut = "OptOut",
		Replicate = {
			--@ lifecycle
			OptIn = "OptIn",
			OptOut = "OptOut",
			
			Equip = "Equip",
			--[=[
				Replicates what the player has equipped to all other clients.
				
				@params
				{Player} player: The player that's going to have their state replicated.
				{String} item: The item that's going to be repliated to the player.
				
				The clients will then require the client settings module for that weapon
				and play the THIRD Person Animation found in the "Animations" module for that
				item's directory.
				
			]=]--
			
			Unequip = "Unequip",
			--[=[
				Replicates what the player has unequipped to all other clients.
				
				@params
				{Player} player: The player that's going to have their state replicated.
				{String} item: The item that's going to be repliated to the player.
				
				The clients will then require the client settings module for that weapon
				and play the THIRD Person Animation found in the "Animations" module for that
				item's directory.
			]=]--
			
			SimulateTrajectory = "SimulateTrajectory",
			--[=[
				Replicates the bullet that the player shot to all other clients.
				
				@params
				{Dictionary} details: The details for the weapon being shot, i.e:
					- Muzzle Velocity
					- Origin
					- Ballistics Coefficient
					- Raycast Parameters (Blacklist)
					- etc..
				
				The clients will then use the "SimulateTrajectory" method within a common
				"Simulations" module that both the client and server uses when simulating
				objects with drop.
				
				Things that'll use the "SimulateTrajectory" would be:
					- Bullets from Firearms
					- Shrapnel from Fragmentation Explosives
			]=]--
			
		},
        
		Equip_Request = "Equip_Request",
		Unequip_Request = "Unequip_Request",
	}
}