package manipulatables;

enum OrderType {
	Nothing;
	WontWork;
	Take;
	InventoryItem;
	ToolTip;
	WorkHarder;
	HireWorker;
	BuildWorkplace;
}

interface ManipulatableSprite {
	public var name(get, null): String;
	
	public function getOrder(selectedItem : UseableSprite) : OrderType;
	
	public function executeOrder(order : OrderType) : Void;
}