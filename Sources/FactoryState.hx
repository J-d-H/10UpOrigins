package;

import hr.Staff;

class FactoryState {
	private static var instance : FactoryState;
	
	public static var the(get, null): FactoryState;
	
	public static inline var globalTimeSpeed: Float = 1 / 20;
	public static inline var workTimeFactor: Float = 1;
	private static inline var moneyPerNormalCan = 1;
	private static inline var moneyPer10upCan = 10 + moneyPerNormalCan;

	public static inline var workplaceInitialCosts = 25;
	public static inline var workplaceCostsPerYear = 2;

	public var time: Float = 0;
	public var yearTime: Float = 0;
	public var months: Int = 0;
	public var years: Int = 0;
	public var money: Int = 200;
	public var cansNormal: Int = 0;
	public var cans10up: Int = 0;
	public var casualties: Int = 0;
	public var workplaceBuild: Int = 0;
	
	private var lastYears: Int = 0;
	private var lastYearsIncome: Int = 0;
	private var lastYearsWages: Int = 0;
	private var lastYearsCosts: Int = 0;
	private var lastYearsCansNormal: Int = 0;
	private var lastYearsCans10up: Int = 0;
	private var lastYearsCasualties: Int = 0;
	private var lastYearsWorkplaceBuild: Int = 0;

	public var showYearlyStatsFlag: Bool = false;
	public var yearlyIncome: Array<Int> = new Array<Int>();
	public var yearlyWages: Array<Int> = new Array<Int>();
	public var yearlyCosts: Array<Int> = new Array<Int>();
	public var yearlyCansNormal: Array<Int> = new Array<Int>();
	public var yearlyCans10up: Array<Int> = new Array<Int>();
	public var yearlyCasualties: Array<Int> = new Array<Int>();
	
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
		if (yearTime >= 1)
		{
			yearTime -= 1;
			var wages: Float = Staff.calcWages();
			var costs: Float = Staff.calcWorkplaceCosts() + (workplaceBuild - lastYearsWorkplaceBuild) * workplaceInitialCosts;
			lastYearsWages += Math.round(wages);
			lastYearsCosts += Math.round(costs);
			money -= Math.round(wages + costs);
		}
		months = Math.floor(time * 12) % 12;
		years = Math.floor(time);
		if (years != lastYears)
		{
			showYearlyStatsFlag = true;

			yearlyIncome.push(lastYearsIncome);
			yearlyWages.push(lastYearsWages);
			yearlyCosts.push(lastYearsCosts);
			yearlyCansNormal.push(cansNormal - lastYearsCansNormal);
			yearlyCans10up.push(cans10up - lastYearsCans10up);
			yearlyCasualties.push(casualties - lastYearsCasualties);

			lastYearsIncome = 0;
			lastYearsWages = 0;
			lastYearsCosts = 0;
			lastYearsCansNormal = cansNormal;
			lastYearsCans10up = cans10up;
			lastYearsCasualties = casualties;
			lastYearsWorkplaceBuild = workplaceBuild;
			lastYears = years;
		}
	}

	public function onCanProduced(is10up: Bool): Void
	{
		if (is10up)
		{
			++cans10up;
			money += moneyPer10upCan;
			lastYearsIncome += moneyPer10upCan;
		}
		else
		{
			++cansNormal;
			money += moneyPerNormalCan;
			lastYearsIncome += moneyPerNormalCan;
		}
	}
}
