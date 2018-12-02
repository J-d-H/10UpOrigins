package;

class FactoryState {
	private static var instance : FactoryState;
	
	public static var the(get, null): FactoryState;
	
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
}
