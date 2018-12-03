package hr;

import manipulatables.Encourage;
import manipulatables.Injection;
import manipulatables.ManipulatableItem;
import hr.RandomGuy;
import manipulatables.UseableSprite;
import manipulatables.ManipulatableItem.OrderType;

class DiscreteGuy extends RandomGuy
{
	private static inline var timeToPause: Float = 20;
	private static inline var timeForPause: Float = 10;
	private static inline var motivatedWorkingStartHealth: Float = 0.95;
	private static inline var motivatedWorkingMinHealth: Float = 0.9;
	private static inline var healthPerFullPause: Float = 0.2;
	private static inline var healthChangeWhenWorking: Float = -(healthPerFullPause / timeToPause) * 0.5; // Lose one half Pause

	private var _startingExperience: Float;
	private var _startingWage: Float;

	private var _maxHealth: Float;

	public function new(startingWage: Float, startingExperience: Float, statingAge: Float)
	{
		super();
		_startingExperience = startingExperience;
		_startingWage = startingWage;
		_maxHealth = 1.0;
		employeeAge = statingAge;
	}

	@:access(kha2d.Animation)
	public override function updateState(deltaTime: Float): WorkerStatus
	{
		if (status == WorkerDead) return status;

		// Employee aging and stats up-/ downgrades
		employeeAge += deltaTime * FactoryState.globalTimeSpeed;

		// Experience aging for up-/downgrades
		var experienceGain = 0.5 * deltaTime * FactoryState.globalTimeSpeed;
		var workFactor: Float = 1;
		var workHealthFactor: Float = 1;
		switch (status)
		{
		case WorkerWorking:
			employeeExperience += experienceGain;
		case WorkerWorkingMotivated:
			employeeExperience += 1.25 * experienceGain;
			workFactor *= 1.25;
		case WorkerWorkingHard:
			employeeExperience += experienceGain;
			workHealthFactor *= 2;
			workFactor *= 2;
		case WorkerDying:
			employeeExperience += 1000;
		case WorkerDead | WorkerPause | WorkerSleeping:
			employeeExperience += 0;
		}

		if (employeeExperience < 1)	
		{
			employeeTimeForCan =  10;
			employeeProgressTo10UpPerCan = 0;
		}
		else if (employeeExperience < 2) 
		{
			employeeTimeForCan =  8;
			employeeProgressTo10UpPerCan = 0;
		}
		else if (employeeExperience < 3)
		{
			employeeTimeForCan =  7;
			employeeProgressTo10UpPerCan = 0.1;
		}
		else if (employeeExperience < 4)
		{
			employeeTimeForCan =  6;
			employeeProgressTo10UpPerCan = 0.15;
		}
		else if (employeeExperience < 5)
		{
			employeeTimeForCan =  5;
			employeeProgressTo10UpPerCan = 0.2;
		}
		else if (employeeExperience < 6)
		{
			employeeTimeForCan =  5;
			employeeProgressTo10UpPerCan = 0.25;
		}
		else if (employeeExperience < 7)
		{
			employeeTimeForCan =  5;
			employeeProgressTo10UpPerCan = 0.33;
		}
		else if (employeeExperience < 8)
		{
			employeeTimeForCan =  5;
			employeeProgressTo10UpPerCan = 0.5;
		}
		else if (employeeExperience < 9)
		{
			employeeTimeForCan =  5;
			employeeProgressTo10UpPerCan = 0.75;
		}
		else if (employeeExperience > 999)
		{
			// Dying people know how the things work...
			employeeTimeForCan =  1;
			employeeProgressTo10UpPerCan = 10.0;
		}
		else
		{
			employeeTimeForCan =  5;
			employeeProgressTo10UpPerCan = 1.0;
		}

		var ageWorkingHealthFactor: Float = 1;
		var agePauseHealthFactor: Float = 1;
		var agePauseTimeFactor: Float = 1;
		var decayStartAge = 20;
		var maxAge = 100;
		if (employeeAge > decayStartAge)
		{
			var decayAge = employeeAge - decayStartAge;
			_maxHealth -= 1.0/(maxAge - decayStartAge) *  decayAge;
			ageWorkingHealthFactor = 1 + 0.1 * decayAge;
			agePauseTimeFactor = 1 + 0.1 * decayAge;
			agePauseHealthFactor = 1 - 0.05 * decayAge;

			employeeTimeForCan += 0.5 * Std.int(decayAge);
		}

		if (employeeHealth > _maxHealth)
			employeeHealth = _maxHealth;

		employeeWage = _startingWage * Math.pow(0.03, Math.ffloor(employeeAge)); // + 3 % per Year

		// Pause progress
		switch (status)
		{
			case WorkerDying:
			{
				status = WorkerDead;
			}
			case WorkerDead:
			{
				// ...
			}
			case WorkerSleeping | WorkerPause:
			{
				employeeHealth += (healthPerFullPause * agePauseHealthFactor / timeForPause) * deltaTime * FactoryState.workTimeFactor;
				// No overheal plz, we are not Wolfenstein
				if (employeeHealth > _maxHealth)
					employeeHealth = _maxHealth;

				employeeTimeForCurrentPause += deltaTime * FactoryState.workTimeFactor;
				if (employeeTimeForCurrentPause >= timeForPause * agePauseTimeFactor)
				{
					employeeTimeForCurrentPause -= timeForPause;
					status = (employeeHealth >= motivatedWorkingStartHealth) ? WorkerWorkingMotivated : WorkerWorking;
					animation.speeddiv = Std.int(Math.max(employeeTimeForCan*2, 1));
				}
			}
			case WorkerWorking | WorkerWorkingMotivated | WorkerWorkingHard:
			{
				animation.speeddiv = Std.int(Math.max(employeeTimeForCan*2, 1));
				employeeHealth += healthChangeWhenWorking * deltaTime 
				                  * workHealthFactor 
								  * ageWorkingHealthFactor 
								  * FactoryState.workTimeFactor;

				if (employeeHealth <= 0)
				{
					status = WorkerDying;
					++FactoryState.the.casualties;
					new manipulatables.CanCross(x + width / 2, y);
				}
				else
				{
					employeeProgressToCan += deltaTime * FactoryState.workTimeFactor;
					employeeTimeToNextPause -= deltaTime * FactoryState.workTimeFactor;

					// Needs pause
					if (employeeTimeToNextPause <= 0)
					{
						employeeTimeToNextPause += timeToPause;
						status = WorkerPause;
					}
					// Can finished
					else if (employeeProgressToCan >= employeeTimeForCan)
					{
						if (employeeProgressTo10Up >= 1)
						{
							// 10up can
							employeeProgressTo10Up -= 1;
							++employeeCans10up;
							FactoryState.the.onCanProduced(true);
							new manipulatables.Can10up(x + width / 2, y);
						}
						else
						{
							// Normal can
							employeeProgressTo10Up += employeeProgressTo10UpPerCan;
							++employeeCansNot;
							FactoryState.the.onCanProduced(false);
							new manipulatables.CanNot(x + width / 2, y);
						}
						employeeProgressToCan -= employeeTimeForCan;
					}

					if (status == WorkerWorkingMotivated && employeeHealth < motivatedWorkingMinHealth)
					{
						// all motivation ends at some point...
						status = WorkerWorking;
						animation.speeddiv = Std.int(Math.max(employeeTimeForCan*2, 1));
					}
				}
			}
		}

		return status;
	}

	public override function getOrder(selectedItem : ManipulatableItem) : OrderType
	{
		if (isInInventory)
		{
			return OrderType.WontWork;
		}
		else if (status == WorkerDying)
		{
			return OrderType.WontWork;
		}
		else if (status == WorkerDead)
		{
			if (selectedItem == null) return OrderType.Take;
			else return OrderType.WontWork;
		}
		else if (selectedItem != null)
		{
			if (Std.is(selectedItem, manipulatables.Injection))
			{
				return OrderType.UseItem;
			}
			else if (Std.is(selectedItem, Encourage))
			{
				return OrderType.UseItem;
			}
			return OrderType.WontWork;
		}

		return OrderType.Nothing;
	}

	public override function executeOrder(order : OrderType, item : ManipulatableItem) : Void
	{
		switch (order)
		{
		case UseItem:
			if (Std.is(item, Injection))
			{
				switch (status)
				{
				case WorkerDying, WorkerDead:
					throw "Findet nicht statt.";
				case WorkerSleeping, WorkerPause:
					status = WorkerWorkingHard;
				case WorkerWorking, WorkerWorkingMotivated:
					status = WorkerWorkingHard;
				case WorkerWorkingHard:
					status = WorkerWorkingHard;
				}
			} 
			else if (Std.is(item, Encourage))
			{
				switch (status)
				{
				case WorkerDying, WorkerDead:
					throw "Findet nicht statt.";
				case WorkerSleeping, WorkerPause:
					status = WorkerWorking;
				case WorkerWorking, WorkerWorkingMotivated:
					status = WorkerWorking;
				case WorkerWorkingHard:
					status = WorkerWorking;
				}
				employeeHealth -= 0.005;
			} 
			else 
			{
				throw "Noch nicht da - wird auch nicht mehr implementiert.";
			}
		default:
			super.executeOrder(order, item);
		}
	}
}