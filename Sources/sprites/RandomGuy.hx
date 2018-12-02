package sprites;

import manipulatables.Can10up;
import manipulatables.ManipulatableSprite.OrderType;
import kha.Assets;
import kha.Color;
import kha.graphics2.Graphics;
import kha.Image;
import kha.math.FastMatrix3;
import kha.math.Random;
import kha2d.Rectangle;
import kha2d.Animation;
import manipulatables.UseableSprite;

enum WorkerStatus
{
	WorkerDead;
	WorkerDying;
	WorkerSleeping;
	WorkerPause;
	WorkerWorking;
	WorkerWorkingMotivated;
	WorkerWorkingHard;
}

class RandomGuy extends UseableSprite {

	private var standLeft: Animation;
	private var standRight: Animation;
	private var walkLeft: Animation;
	private var walkRight: Animation;
	private var statusAnimations = new Map<WorkerStatus, Animation>();
	public var lookLeft: Bool;

	private var renderColor: Color;
	
	public var sleeping: Bool;
	
	private static var names = ["Augusto", "Ingo", "Christian", "Robert", "Björn", "Johannes", "Rebecca", "Stephen", "Alvar", "Michael", "Linh", "Roger", "Roman", "Max", "Paul", "Tobias", "Henno", "Niko", "Kai", "Julian", "Rebecca", "Rebecca", "Rebecca", "Rebecca", "Rebecca"];
	
	private var zzzzz: Image;
	private var zzzzzAnim: Animation;
	
	private static inline var employeeStartingAge: Float = 0;
	private static inline var employeeStartingWage: Float = 0.01;
	private static inline var employeeWageIncreaseFactor: Float = 0.1;
	private static inline var employeeStartingTimeForCan: Float = 10;
	private static inline var employeeStartingProgressTo10UpPerCan: Float = 0;
	private static inline var timeToPause: Float = 20;
	private static inline var timeForPause: Float = 10;
	private static inline var healthPerFullPause: Float = 0.2;
	private static inline var healthChangeWhenWorking: Float = -(healthPerFullPause / timeToPause) * 0.5; // Lose one half Pause
	
	public var employeeAge: Float;
	public var employeeExperience: Float;
	public var employeeWage: Float;
	public var employeeTimeForCan: Float;
	public var employeeProgressTo10UpPerCan: Float;
	public var employeeProgressToCan: Float;
	public var employeeProgressTo10Up: Float;
	public var employeeTimeToNextPause: Float;
	public var employeeTimeForCurrentPause: Float;
	public var employeeHealth: Float;
	public var employeeCansNot: Int;
	public var employeeCans10up: Int;

	public var status(default, set): WorkerStatus;

	@:noCompletion
	private function set_status(value: WorkerStatus): WorkerStatus
	{
		status = value;
	
		setAnimation(statusAnimations[status]);

		sleeping = (status == WorkerSleeping || status == WorkerDead);

		return value;
	}
	
	public function new(customlook: Bool = false) {
		super(names[Random.getUpTo(names.length - 1)], Assets.images.nullachtsechzehnmann, 0, 0, Std.int(720 / 9), Std.int(256 / 2));
		collider = new Rectangle(0, 0, width, height -20);
		renderColor = Color.White;
		zzzzz = Assets.images.zzzzz;
		zzzzzAnim = Animation.createRange(0,2, 6);
		standLeft = Animation.create(9);
		standRight = Animation.create(0);
		walkLeft = Animation.createRange(10, 17, 4);
		walkRight = Animation.createRange(1, 8, 4);
		statusAnimations[WorkerDead] = Animation.create(6);
		statusAnimations[WorkerDying] = Animation.create(0);
		statusAnimations[WorkerSleeping] = Animation.create(14);
		statusAnimations[WorkerPause] = standLeft;
		statusAnimations[WorkerWorking] = new Animation([1, 2, 3, 3, 2, 1], 10);
		statusAnimations[WorkerWorkingMotivated] = new Animation([1, 2, 2], 6);
		statusAnimations[WorkerWorkingHard] = new Animation([1, 2, 3, 3, 2, 1, 10, 11, 12, 12, 11, 10], 4);
		lookLeft = false;
		sleeping = false;
		
		employeeAge = employeeStartingAge;
		employeeExperience = 0;
		employeeWage = employeeStartingWage;
		employeeTimeForCan = employeeStartingTimeForCan;
		employeeProgressTo10UpPerCan = employeeStartingProgressTo10UpPerCan;
		employeeProgressToCan = 0;
		employeeProgressTo10Up = 0;
		employeeTimeToNextPause = timeToPause;
		employeeTimeForCurrentPause = 0;
		employeeHealth = 1;
		employeeCansNot = 0;
		employeeCans10up = 0;

		status = WorkerPause;

		if (!customlook) {
			switch (name.substr(-1))
			{
			case "a" | "i" | "e":
				image = Assets.images.nullachtsechzehnfrau;
				switch (Random.getUpTo(2))
				{
				case 0:
					renderColor = Color.Orange;
				case 2:
					renderColor = Color.fromBytes(150, 100, 50);
				}
			default:
				switch (Random.getUpTo(2))
				{
				case 0:
					image = Assets.images.nullachtsechzehnmann_rot;
				case 2:
					image = Assets.images.nullachtsechzehn_gruen;
				}
			}
		}
	}
	
	override public function update(): Void {
		super.update();

		if (speedx > 0) {
			setAnimation(walkRight);
			lookLeft = false;
		}
		else if (speedx < 0) {
			setAnimation(walkLeft);
			lookLeft = true;
		}
		else {
			/*if (lookLeft) {
				setAnimation(standLeft);
			}
			else {
				setAnimation(standRight);
			}*/
		}
		zzzzzAnim.next();
	}
	
	override public function render(g: Graphics): Void {
		if (image == null || !visible) return;
		if (sleeping) {
			g.color = Color.White;
			var angle = Math.PI / 2;
			var x = this.x + 100;
			var y = this.y + 60;
			lookLeft = true;
			if (angle != 0) g.pushTransformation(g.transformation.multmat(FastMatrix3.translation(x + originX, y + originY)).multmat(FastMatrix3.rotation(angle)).multmat(FastMatrix3.translation(-x - originX, -y - originY)));
			g.drawScaledSubImage(image, Std.int(animation.get() * w) % image.width, Math.floor(animation.get() * w / image.width) * h, w, h, Math.round(x - collider.x * scaleX), Math.round(y - collider.y * scaleY), width, height);
			if (angle != 0) g.popTransformation();
			if (status != WorkerDead)
			{
				g.drawSubImage(zzzzz, x - 40, y - 20, zzzzz.width * zzzzzAnim.getIndex() / 3, 0, zzzzz.width / 3, zzzzz.height);
			}
		}
		else {
			g.color = renderColor;
			if (angle != 0) g.pushTransformation(g.transformation.multmat(FastMatrix3.translation(x + originX, y + originY)).multmat(FastMatrix3.rotation(angle)).multmat(FastMatrix3.translation(-x - originX, -y - originY)));
			g.drawScaledSubImage(image, Std.int(animation.get() * w) % image.width, Math.floor(animation.get() * w / image.width) * h, w, h, Math.round(x - collider.x * scaleX), Math.round(y - collider.y * scaleY), width, height);
			if (angle != 0) g.popTransformation();
			#if debug
			g.color = Color.fromBytes(255, 0, 0);
			g.drawRect(x - collider.x * scaleX, y - collider.y * scaleY, width, height);
			g.color = Color.fromBytes(0, 255, 0);
			g.drawRect(tempcollider.x, tempcollider.y, tempcollider.width, tempcollider.height);
			g.fillRect( x - 2, y - 2, 5, 5 );
			#end
		}
	}
	
	public override function getOrder(selectedItem : UseableSprite) : OrderType
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
			return OrderType.Take;
		}
		else if (Std.is(selectedItem, manipulatables.Injection))
		{
			return OrderType.WorkHarder;
		}
		return OrderType.ToolTip;
	}

	public override function executeOrder(order : OrderType) : Void
	{
		switch (order)
		{
		case WorkHarder:
			switch (status)
			{
			case WorkerDying, WorkerDead:
				throw "Findet nicht statt.";
			case WorkerSleeping, WorkerPause:
				status = WorkerWorking;
			case WorkerWorking, WorkerWorkingMotivated:
				status = WorkerWorkingHard;
			case WorkerWorkingHard:
				status = WorkerWorkingHard;
			}
		default:
			super.executeOrder(order);
		}
	}

	@:access(kha2d.Animation)
	public function updateState(deltaTime: Float): WorkerStatus
	{
		// Employee aging and stats up-/ downgrades
		employeeAge += deltaTime * FactoryState.globalTimeSpeed;

		// Experience aging for up-/downgrades
		var workFaktor: Float = 1;
		var workHealthFaktor: Float = 1;
		var ageHealthFaktor: Float = 1;
		var agePauseFaktor: Float = 1;
		switch (status)
		{
		case WorkerWorking:
			employeeExperience += deltaTime * FactoryState.globalTimeSpeed;
		case WorkerWorkingMotivated:
			employeeExperience += 1.25 * deltaTime * FactoryState.globalTimeSpeed;
			workFaktor *= 1.5;
		case WorkerWorkingHard:
			employeeExperience += 0.5 * deltaTime * FactoryState.globalTimeSpeed;
			workHealthFaktor *= 2;
			workFaktor *= 2;
		case WorkerDying:
			employeeExperience += 1000;
		case WorkerDead | WorkerPause | WorkerSleeping:
			employeeExperience += 0;
		}
		if (employeeAge > 20)
		{
			ageHealthFaktor = 1 + 0.1 * (employeeAge-25);
			agePauseFaktor = 1 + 0.05 * (employeeAge-25);
		}
		employeeWage = 0.1 + 0.05 * employeeAge;

		// (0 10), (5 5), (10 2,5)
		if (employeeExperience < 2) employeeTimeForCan = 15 - 0.25 * employeeExperience;
		if (employeeExperience < 4) employeeTimeForCan = 15 - 0.5 - 1 * employeeExperience;
		if (employeeExperience < 6) employeeTimeForCan = 15 - 2.5 - 0.75 * employeeExperience;
		if (employeeExperience < 8) employeeTimeForCan = 15 - 4 - 0.5 * employeeExperience;
		if (employeeExperience >= 10) employeeTimeForCan = 15 - 4 - 0.25 * employeeExperience;
		employeeTimeForCan = Math.max(employeeTimeForCan, 1);
		if (employeeAge > 15)
		{ 
			// (15 *1), (25 *1,5), (55 *9)
			employeeTimeForCan *= 1 + 0.005 * ((employeeAge * employeeAge) - (15 * 15));
		}

		employeeProgressTo10UpPerCan = 0 + 0.05 * employeeExperience;

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
				employeeHealth += (healthPerFullPause / (agePauseFaktor * timeForPause))* deltaTime * FactoryState.workTimeFactor;
				// No overheal plz, we are not Wolfenstein
				if (employeeHealth > 1)
					employeeHealth = 1;

				employeeTimeForCurrentPause += deltaTime * FactoryState.workTimeFactor;
				if (employeeTimeForCurrentPause >= timeForPause * ageHealthFaktor)
				{
					employeeTimeForCurrentPause -= timeForPause;
					status = employeeHealth > 0.95 ? WorkerWorkingMotivated : WorkerWorking;
					animation.speeddiv = Std.int(Math.max(employeeTimeForCan*2, 1));
				}
			}
			case WorkerWorking | WorkerWorkingMotivated | WorkerWorkingHard:
			{
				animation.speeddiv = Std.int(Math.max(employeeTimeForCan*2, 1));
				employeeHealth += healthChangeWhenWorking * deltaTime * workHealthFaktor * ageHealthFaktor * FactoryState.workTimeFactor;
				if (employeeHealth <= 0)
				{
					status = WorkerDying;
					++FactoryState.the.casualties;
					new manipulatables.CanCross(x + width / 2, y);
				}
				else
				{
					if (status == WorkerWorkingMotivated && employeeHealth < 0.9) {
						status = WorkerWorking;
					}
					employeeProgressToCan += deltaTime * workFaktor * FactoryState.workTimeFactor;
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
				}
			}
		}

		return status;
	}
}
