package hr;

import kha.graphics2.Graphics;
import kha2d.Rectangle;
import manipulatables.ManipulatableItem;
import manipulatables.UseableSprite;
import manipulatables.ManipulatableItem.OrderType;
import kha.Assets;

class Workplace extends UseableSprite
{
	public var slot(default, null): Int;
	public var worker: RandomGuy;

	public function new(slot: Int) {
		if (slot < 0) super("Workplace", Assets.images.coffee, 0, 0);
		else super("Workplace " + slot, Assets.images.coffee, Main.npcSpawns[slot].x + 60, Main.npcSpawns[slot].y + 60);
		this.slot = slot;
		visible = false;
	}

	override function render(g:Graphics) {
		if (!visible)
		{
			visible = true;
			g.pushOpacity(0.3);
			super.render(g);
			g.popOpacity();
			visible = false;
		}
		else 
		{
			super.render(g);
		}
	}

	public override function getOrder(selectedItem : ManipulatableItem) : OrderType
	{
		if (isInInventory)
		{
			return OrderType.WontWork;
		}
		else if (selectedItem == null)
		{
			return OrderType.Nothing;
		}
		else if (Std.is(selectedItem, DiscreteGuy))
		{
			if (visible) 
			{
				if (worker == null)
					return OrderType.UseItem;
				else 
					return OrderType.WontWork;
				
			}
			else
			{
				return OrderType.Nothing;
			}
		}
		else if (Std.is(selectedItem, Workplace))
		{
			if (visible) return OrderType.WontWork;
			else return OrderType.UseItem;
		}
		return OrderType.WontWork;
	}

	public override function executeOrder(order : OrderType, item : ManipulatableItem) : Void
	{
		switch (order)
		{
		case UseItem:
			if (Std.is(item, Workplace)) {
				// build workplace
				visible = true;
				FactoryState.the.money -= FactoryState.workplaceInitialCosts;
			} else if (Std.is(item, DiscreteGuy)) {
				// hire worker
				var guy: DiscreteGuy = cast Inventory.getSelectedItem();
				Staff.hireGuy(slot, new DiscreteGuy(guy.employeeWage, guy.employeeExperience, guy.employeeAge));
			}
		default:
			super.executeOrder(order, item);
		}
	}
}