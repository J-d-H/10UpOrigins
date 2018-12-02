package;

import hr.Staff;

class FactoryState {
	private static var instance : FactoryState;
	
	public static var the(get, null): FactoryState;
	
	public static inline var globalTimeSpeed: Float = 1 / 30;
	public static inline var workTimeFactor: Float = 2;
	private static inline var moneyPerNormalCan = 1;
	private static inline var moneyPer10upCan = 10;

	public var time: Float = 0;
	public var yearTime: Float = 0;
	public var months: Int = 0;
	public var years: Int = 0;
	public var money: Int = 0;
	public var cansNormal: Int = 0;
	public var cans10up: Int = 0;
	public var casualties: Int = 0;
	
	private static function get_the(): FactoryState {
		if (instance == null) instance = new FactoryState();
		return instance;
	}
	
	function new() {
		
	}

	public function update(deltaTime: Float) 
	{
		time += deltaTime * globalTimeSpeed;
		yearTime += deltaTime * globalTimeSpeed;
		if (yearTime >= 1 / 12)
		{
			yearTime -= 1 / 12;
			money -= Math.round(Staff.calcWages());
		}
		months = Math.floor(time * 12) % 12;
		years = Math.floor(time);
	}

	public function onCanProduced(is10up: Bool): Void
	{
		if (is10up)
		{
			++cans10up;
			money += moneyPer10upCan;
		}
		else
		{
			++cansNormal;
			money += moneyPerNormalCan;
		}
	}
}
