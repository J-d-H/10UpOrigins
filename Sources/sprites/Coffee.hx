package sprites;

import kha.Assets;
import kha2d.Animation;
import kha2d.Direction;
import kha2d.Sprite;

class Coffee extends InteractiveSprite {
	
	var defaultAnimation : Animation;
	
	public function new(x: Float, y: Float) {
		super(null/*Assets.images.coffee*/, 32, 64, 0);
		this.x = x;
		this.y = y + 2;
		this.isUseable = true;
		accy = 0;
		
		defaultAnimation = Animation.create(0);
		setAnimation(defaultAnimation);
	}
	
	/*function search(): Void {
		if (important) {
			// TODO: Fix item pickup
			var fk : UseableSprite = new UseableSprite(Localization.getText(Keys_text.FLUXCOMPENSATOR), Loader.the.getImage("broetchen1"), 0, 0, 39, 39, 0);
			Inventory.pick(fk);
			setAnimation(destroyedAnimation);
			destroyed = true;
			
			var text = Localization.getText(Keys_text.ITEMFOUND, [ fk.name ]);
			dlg.insert([new Bla(text, this, true)]);
		}
	}
	
	function useComputerDialogue(): Void {
		var choices = new Array<Array<DialogueItem>>();
		var text = Localization.getText(Keys_text.BOOKSHELF_ACTIONS);
		choices.push([new StartDialogue(search)]);
		text += '\n${choices.length}: ' + Localization.getText(Keys_text.BOOKSHELF_SEARCH);
		choices.push([]); // TODO Blabox FAIL
		text += '\n${choices.length}: ' + Localization.getText(Keys_text.BOOKSHELF_LEAVE);
		dlg.insert([new BlaWithChoices( text, this, choices)]);
	}*/
	
	override public function isUsableFrom(user:Dynamic):Bool 
	{
		return user != Main.Player && super.isUsableFrom(user);
	}
	override public function useFrom(user:Dynamic): Bool 
	{
		if (super.useFrom(user))
		{
			return true;
		}
		return false;
	}
}
