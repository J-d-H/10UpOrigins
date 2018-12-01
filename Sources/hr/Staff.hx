package hr;

import kha2d.Scene;
import sprites.RandomGuy;

class Staff
{
	public static function AddGuy()
	{
		var newGuy = new RandomGuy(Main.interactiveSprites);
		
		/*for (npcSpawn in Main.npcSpawns)
		{
			
		}*/

		newGuy.setPosition(Main.npcSpawns[RandomGuy.allguys.length-1]);

		Scene.the.addHero(newGuy);
	}
}
