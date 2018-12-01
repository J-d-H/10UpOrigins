package hr;

import kha.math.Vector2;
import kha2d.Scene;
import sprites.RandomGuy;

@:access(Main)
class Staff
{
	private static inline var employeeStartingAge: Float = 0;
	private static inline var employeeStartingTimeForCan: Float = 10;
	private static inline var employeeStartingProgressTo10UpPerCan: Float = 0;
	private static inline var agingSpeed: Float = 1 / 30;
	private static inline var timeToPause: Float = 20;
	private static inline var timeForPause: Float = 10;
	private static inline var healthPerFullPause: Float = 0.2;
	private static inline var healthChangeWhenWorking: Float = -(healthPerFullPause / timeToPause) * 0.5; // Lose one half Pause

	public static var employeeAge: Array<Float> = new Array<Float>();
	public static var employeeTimeForCan: Array<Float> = new Array<Float>();
	public static var employeeProgressTo10UpPerCan: Array<Float> = new Array<Float>();
	public static var employeeProgressToCan: Array<Float> = new Array<Float>();
	public static var employeeProgressTo10Up: Array<Float> = new Array<Float>();
	public static var employeeTimeToNextPause: Array<Float> = new Array<Float>();
	public static var employeeTimeForCurrentPause: Array<Float> = new Array<Float>();
	public static var employeeHealth: Array<Float> = new Array<Float>();

	public static function addGuy(slot:Int = -1): RandomGuy
	{
		var newGuy = new RandomGuy(Main.interactiveSprites);
		
		/*for (npcSpawn in Main.npcSpawns)
		{
			
		}*/
		
		if (slot < 0)
		{
			slot = RandomGuy.allguys.length-1;
		}
		newGuy.setPosition(Main.npcSpawns[slot]);

		Scene.the.addHero(newGuy);
		
		newGuy.Status = WorkerWorking;
		employeeAge.push(employeeStartingAge);
		employeeTimeForCan.push(employeeStartingTimeForCan);
		employeeProgressTo10UpPerCan.push(employeeStartingProgressTo10UpPerCan);
		employeeProgressToCan.push(0);
		employeeProgressTo10Up.push(0);
		employeeTimeToNextPause.push(timeToPause + slot - timeToPause/2);
		employeeTimeForCurrentPause.push(0);
		employeeHealth.push(1);

		return newGuy;
	}


	public static function update(deltaTime:Float) 
	{
		for (i in 0...RandomGuy.allguys.length)
		{
			var employee = RandomGuy.allguys[i];
			// Employee aging and stats up-/ downgrades
			employeeAge[i] += deltaTime * agingSpeed;
			// (0, 10), (20, 3), (40, 10)
			employeeTimeForCan[i] = 10 - 0.7 * employeeAge[i] + 0.0175 * employeeAge[i] * employeeAge[i];
			// (0, 0), (20, 0.25), (40, 0)
			employeeProgressTo10UpPerCan[i] = 0 + 0.025 * employeeAge[i] - 0.00625 * employeeAge[i] * employeeAge[i];

			// Pause progress
			switch (employee.Status)
			{
				case WorkerDead:
				{
					// ...
				}
				case WorkerSleeping | WorkerPause:
				{
					employeeHealth[i] += (healthPerFullPause / timeForPause) * deltaTime;
					// No overheal plz, we are not Wolfenstein
					if (employeeHealth[i] > 1)
						employeeHealth[i] = 1;

					employeeTimeForCurrentPause[i] += deltaTime;
					if (employeeTimeForCurrentPause[i] >= timeForPause)
					{
						employeeTimeForCurrentPause[i] -= timeForPause;
						employee.Status = employeeHealth[i] > 0.99 ? WorkerWorkingMotivated : WorkerWorking;
					}
				}
				case WorkerWorking | WorkerWorkingMotivated | WorkerWorkingHard:
				{
					employeeHealth[i] += healthChangeWhenWorking * deltaTime;
					if (employeeHealth[i] <= 0)
					{
						employee.Status = WorkerDead;

						// Hire new employe
						addGuy(i);
					}
					else
					{
						employeeProgressToCan[i] += deltaTime;
						employeeTimeToNextPause[i] -= deltaTime;
						// Needs pause
						if (employeeTimeToNextPause[i] <= 0)
						{
							employeeTimeToNextPause[i] += timeToPause;
							employee.Status = WorkerPause;
						}
						// Can finished
						else if (employeeProgressToCan[i] >= employeeTimeForCan[i])
						{
							if (employeeProgressTo10Up[i] >= 1)
							{
								// 10up can
								employeeProgressTo10Up[i] -= 1;
								++Main.cans10up;
							}
							else
							{
								// Normal can
								employeeProgressTo10Up[i] += employeeProgressTo10UpPerCan[i];
								++Main.cansNormal;
							}
							employeeProgressToCan[i] -= employeeTimeForCan[i];
						}
					}
				}
			}
		}
	}
}
