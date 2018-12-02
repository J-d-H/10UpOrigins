package hr;

import kha.math.Vector2;
import kha2d.Scene;
import sprites.RandomGuy;

@:access(Main)
class Staff
{
	public static var allguys = new Array<RandomGuy>();
	
	public static function addGuy(slot:Int = -1): RandomGuy
	{
		var newGuy = new RandomGuy(Main.interactiveSprites);
		allguys.push(newGuy);
		
		/*for (npcSpawn in Main.npcSpawns)
		{
			
		}*/
		
		if (slot < 0)
		{
			slot = allguys.length-1;
		}
		newGuy.setPosition(Main.npcSpawns[slot]);

		Scene.the.addHero(newGuy);
		
		newGuy.Status = WorkerWorking;
		
		return newGuy;
	}

	public static function update(deltaTime:Float) 
	{
		for (i in 0...allguys.length)
		{
			if (allguys[i].updateState(deltaTime) == WorkerDead)
			{
				// Hire new employe
				addGuy(i);
			}
		}
	}
}
