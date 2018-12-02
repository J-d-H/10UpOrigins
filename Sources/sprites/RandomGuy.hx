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
	private var statusAnimations = new Array<Animation>();
	public var lookLeft: Bool;
	
	private var stuff: Array<InteractiveSprite>;
	
	public var sleeping: Bool;
	
	private static var names = ["Augusto", "Ingo", "Christian", "Robert", "Björn", "Johannes", "Rebecca", "Stephen", "Alvar", "Michael", "Linh", "Roger", "Roman", "Max", "Paul", "Tobias", "Henno", "Niko", "Kai", "Julian", "Rebecca", "Rebecca", "Rebecca", "Rebecca", "Rebecca"];
	
	private var zzzzz: Image;
	private var zzzzzAnim: Animation;
	
	private static inline var employeeStartingAge: Float = 0;
	private static inline var employeeStartingTimeForCan: Float = 10;
	private static inline var employeeStartingProgressTo10UpPerCan: Float = 0;
	private static inline var timeToPause: Float = 20;
	private static inline var timeForPause: Float = 10;
	private static inline var healthPerFullPause: Float = 0.2;
	private static inline var healthChangeWhenWorking: Float = -(healthPerFullPause / timeToPause) * 0.5; // Lose one half Pause
	
	public var employeeAge: Float;
	public var employeeTimeForCan: Float;
	public var employeeProgressTo10UpPerCan: Float;
	public var employeeProgressToCan: Float;
	public var employeeProgressTo10Up: Float;
	public var employeeTimeToNextPause: Float;
	public var employeeTimeForCurrentPause: Float;
	public var employeeHealth: Float;

	private static inline var WORKER_DEAD = 0;
	private static inline var WORKER_DYING = WORKER_DEAD + 1;
	private static inline var WORKER_SLEEPING = WORKER_DYING + 1;
	private static inline var WORKER_PAUSE = WORKER_SLEEPING + 1;
	private static inline var WORKER_WORKING = WORKER_PAUSE + 1;
	private static inline var WORKER_WORKING_MOTIVATED = WORKER_WORKING + 1;
	private static inline var WORKER_WORKING_HARD = WORKER_WORKING_MOTIVATED + 1;
	private var status: Int;

	public var Status(get, set): WorkerStatus;
	private function intToStatus(value: Int):WorkerStatus {
		return switch(value)
		{
			case WORKER_DEAD: WorkerStatus.WorkerDead;
			case WORKER_DYING: WorkerStatus.WorkerDying;
			case WORKER_SLEEPING: WorkerStatus.WorkerSleeping;
			case WORKER_PAUSE: WorkerStatus.WorkerPause;
			case WORKER_WORKING: WorkerStatus.WorkerWorking;
			case WORKER_WORKING_HARD: WorkerStatus.WorkerWorkingHard;
			case WORKER_WORKING_MOTIVATED: WorkerStatus.WorkerWorkingMotivated;
			default: throw "This is not happening.";
		}
	}
	private function statusToInt(status: WorkerStatus):Int {
		return switch(status)
		{
			case WorkerStatus.WorkerDead: WORKER_DEAD;
			case WorkerStatus.WorkerDying: WORKER_DYING;
			case WorkerStatus.WorkerSleeping: WORKER_SLEEPING;
			case WorkerStatus.WorkerPause: WORKER_PAUSE;
			case WorkerStatus.WorkerWorking: WORKER_WORKING;
			case WorkerStatus.WorkerWorkingHard: WORKER_WORKING_HARD;
			case WorkerStatus.WorkerWorkingMotivated: WORKER_WORKING_MOTIVATED;
		}
	}
	private function get_Status(): WorkerStatus { return intToStatus(status); }
	
	public function set_Status(value: WorkerStatus): WorkerStatus {
		status = statusToInt(value);
		
		setAnimation(statusAnimations[status]);

		sleeping = (status == WORKER_SLEEPING || status == WORKER_DEAD);

		return value;
	}
	
	public function new(stuff: Array<InteractiveSprite>, customlook: Bool = false) {
		super(names[Random.getUpTo(names.length - 1)], Assets.images.nullachtsechzehnmann, 0, 0, Std.int(720 / 9), Std.int(256 / 2));
		collider = new Rectangle(-20, 0, width + 40, height);
		zzzzz = Assets.images.zzzzz;
		zzzzzAnim = Animation.createRange(0,2, 6);
		standLeft = Animation.create(9);
		standRight = Animation.create(0);
		walkLeft = Animation.createRange(10, 17, 4);
		walkRight = Animation.createRange(1, 8, 4);
		statusAnimations[WORKER_DEAD] = Animation.create(6);
		statusAnimations[WORKER_DYING] = Animation.create(0);
		statusAnimations[WORKER_SLEEPING] = Animation.create(14);
		statusAnimations[WORKER_PAUSE] = standLeft;
		statusAnimations[WORKER_WORKING] = new Animation([1, 2, 3, 3, 2, 1], 10);
		statusAnimations[WORKER_WORKING_MOTIVATED] = new Animation([1, 2, 2], 6);
		statusAnimations[WORKER_WORKING_HARD] = new Animation([1, 2, 3, 3, 2, 1, 10, 11, 12, 12, 11, 10], 4);
		lookLeft = false;
		sleeping = false;
		
		employeeAge = employeeStartingAge;
		employeeTimeForCan = employeeStartingTimeForCan;
		employeeProgressTo10UpPerCan = employeeStartingProgressTo10UpPerCan;
		employeeProgressToCan = 0;
		employeeProgressTo10Up = 0;
		employeeTimeToNextPause = timeToPause;
		employeeTimeForCurrentPause = 0;
		employeeHealth = 1;

		Status = intToStatus(Random.getUpTo(WORKER_WORKING_HARD));
		
		this.stuff = [];
		if (stuff != null) {
			/*for (thing in stuff) {
				if (thing.isUseable && thing.isUsableFrom(this) && (Std.is(thing, Computer) || Std.is(thing, Coffee))) {
					this.stuff.push(thing);
				}
			}*/
		}
		
		if (!customlook) {
			switch (name.substr(-1))
			{
			case "a" | "i" | "e":
				image = Assets.images.nullachtsechzehnfrau;
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
		if (sleeping) {
			if (image != null && visible) {
				g.color = Color.White;
				var angle = Math.PI / 2;
				var x = this.x + 100;
				var y = this.y + 60;
				lookLeft = true;
				if (angle != 0) g.pushTransformation(g.transformation.multmat(FastMatrix3.translation(x + originX, y + originY)).multmat(FastMatrix3.rotation(angle)).multmat(FastMatrix3.translation(-x - originX, -y - originY)));
				g.drawScaledSubImage(image, Std.int(animation.get() * w) % image.width, Math.floor(animation.get() * w / image.width) * h, w, h, Math.round(x - collider.x * scaleX), Math.round(y - collider.y * scaleY), width, height);
				if (angle != 0) g.popTransformation();
				if (Status != WorkerDead)
				{
					g.drawSubImage(zzzzz, x - 40, y - 20, zzzzz.width * zzzzzAnim.getIndex() / 3, 0, zzzzz.width / 3, zzzzz.height);
				}
			}
		}
		else {
			super.render(g);
			#if debug
			g.color = kha.Color.fromBytes(255,0,0);
			var rect = collisionRect();
			g.drawRect( rect.x, rect.y, rect.width, rect.height );
			g.color = Color.Black;
			g.drawRect( x - collider.x, y - collider.y, width, height );
			g.color = Color.fromBytes(0,255,0);
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
		else if (Status == WorkerDying || Status == WorkerDead)
		{
			return OrderType.WontWork;
		}
		else if (Std.is(selectedItem, manipulatables.Injection))
		{
			return OrderType.WorkHarder;
		}
		return OrderType.WontWork;
	}

	public override function executeOrder(order : OrderType) : Void
	{
		switch (order)
		{
		case WorkHarder:
			switch (Status)
			{
			case WorkerDying, WorkerDead:
				throw "Findet nicht statt.";
			case WorkerSleeping, WorkerPause:
				Status = WorkerWorking;
			case WorkerWorking, WorkerWorkingMotivated:
				Status = WorkerWorkingHard;
			case WorkerWorkingHard:
				Status = WorkerWorkingHard;
			}
		default:
			super.executeOrder(order);
		}
	}

	public function updateState(deltaTime: Float): WorkerStatus
	{
		// Employee aging and stats up-/ downgrades
		employeeAge += deltaTime * FactoryState.globalTimeSpeed;
		// (0, 10), (20, 3), (40, 10)
		employeeTimeForCan = 10 - 0.7 * employeeAge + 0.0175 * employeeAge * employeeAge;
		// (0, 0), (20, 0.25), (40, 0)
		employeeProgressTo10UpPerCan = 0 + 0.025 * employeeAge - 0.000625 * employeeAge * employeeAge;

		// Pause progress
		switch (Status)
		{
			case WorkerDying:
			{
				Status = WorkerDead;
			}
			case WorkerDead:
			{
				// ...
			}
			case WorkerSleeping | WorkerPause:
			{
				employeeHealth += (healthPerFullPause / timeForPause) * deltaTime * FactoryState.workTimeFactor;
				// No overheal plz, we are not Wolfenstein
				if (employeeHealth > 1)
					employeeHealth = 1;

				employeeTimeForCurrentPause += deltaTime * FactoryState.workTimeFactor;
				if (employeeTimeForCurrentPause >= timeForPause)
				{
					employeeTimeForCurrentPause -= timeForPause;
					Status = employeeHealth > 0.99 ? WorkerWorkingMotivated : WorkerWorking;
				}
			}
			case WorkerWorking | WorkerWorkingMotivated | WorkerWorkingHard:
			{
				employeeHealth += healthChangeWhenWorking * deltaTime * FactoryState.workTimeFactor;
				if (employeeHealth <= 0)
				{
					Status = WorkerDying;
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
						Status = WorkerPause;
					}
					// Can finished
					else if (employeeProgressToCan >= employeeTimeForCan)
					{
						if (employeeProgressTo10Up >= 1)
						{
							// 10up can
							employeeProgressTo10Up -= 1;
							FactoryState.the.onCanProduced(true);
							new manipulatables.Can10up(x + width / 2, y);
						}
						else
						{
							// Normal can
							employeeProgressTo10Up += employeeProgressTo10UpPerCan;
							FactoryState.the.onCanProduced(false);
							new manipulatables.CanNot(x + width / 2, y);
						}
						employeeProgressToCan -= employeeTimeForCan;
					}
				}
			}
		}

		return Status;
	}
}
