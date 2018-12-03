package manipulatables;

import kha.graphics2.Graphics;

enum OrderType {
	Nothing;
	WontWork;
	Take;
	InventoryItem;
	UseItem;
	ToolTip;
}

interface ManipulatableItem {
	public var name(get, null): String;
	
	public function getOrder(selectedItem : ManipulatableItem) : OrderType;
	
	public function executeOrder(order : OrderType, item : ManipulatableItem) : Void;

	public function renderForInventory(g: Graphics, x : Int, y : Int, drawWidth : Int, drawHeight : Int): Void;
}