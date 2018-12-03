package hr;

import kha.graphics2.Graphics;
import kha2d.Rectangle;
import manipulatables.ManipulatableSprite;
import manipulatables.UseableSprite;
import manipulatables.ManipulatableSprite.OrderType;
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

	public override function getOrder(selectedItem : UseableSprite) : OrderType
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
					return OrderType.HireWorker;
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
			else return OrderType.BuildWorkplace;
		}
		return OrderType.WontWork;
	}

	public override function executeOrder(order : OrderType) : Void
	{
		switch (order)
		{
		case BuildWorkplace:
			visible = true;
			FactoryState.the.money -= FactoryState.workplaceInitialCosts;
		case HireWorker:
			var guy: DiscreteGuy = cast Inventory.getSelectedItem();
			Staff.hireGuy(slot, new DiscreteGuy(guy.employeeWage, guy.employeeExperience, guy.employeeAge));
		default:
			return super.executeOrder(order);
		}
	}
}