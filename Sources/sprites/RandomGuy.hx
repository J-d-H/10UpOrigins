package sprites;

import kha.Assets;
import kha.Color;
import kha.graphics2.Graphics;
import kha.Image;
import kha.math.FastMatrix3;
import kha.math.Random;
import kha.math.Vector2;
import kha2d.Rectangle;
import kha2d.Animation;
import kha2d.Sprite;

class RandomGuy extends InteractiveSprite {
	
	private var standLeft: Animation;
	private var standRight: Animation;
	private var walkLeft: Animation;
	private var walkRight: Animation;
	public var lookLeft: Bool;
	
	private var stuff: Array<InteractiveSprite>;
	
	public var sleeping: Bool;
	
	private static var names = ["Augusto", "Ingo", "Christian", "Robert", "Björn", "Johannes", "Rebecca", "Stephen", "Alvar", "Michael", "Linh", "Roger", "Roman", "Max", "Paul", "Tobias", "Henno", "Niko", "Kai", "Julian"];
	public static var allguys = new Array<RandomGuy>();
	
	private var zzzzz: Image;
	private var zzzzzAnim: Animation;

	
	public function new(stuff: Array<InteractiveSprite>, customlook: Bool = false) {
		super(Assets.images.nullachtsechzehnmann, Std.int(720 / 9), Std.int(256 / 2));
		collider = new Rectangle(-20, 0, width + 40, height);
		isUseable = true;
		zzzzz = Assets.images.zzzzz;
		zzzzzAnim = Animation.createRange(0, 2, 8);
		standLeft = Animation.create(9);
		standRight = Animation.create(0);
		walkLeft = Animation.createRange(10, 17, 4);
		walkRight = Animation.createRange(1, 8, 4);
		lookLeft = false;
		sleeping = false;
		setAnimation(standRight);
		
		this.stuff = [];
		if (stuff != null) {
			/*for (thing in stuff) {
				if (thing.isUseable && thing.isUsableFrom(this) && (Std.is(thing, Computer) || Std.is(thing, Coffee))) {
					this.stuff.push(thing);
				}
			}*/
		}
		
		trace("names.length=" + names.length);
		trace(Random.getUpTo(5));
		trace(Random.getUpTo(Std.int(names.length - 1)));
		trace(Random.getUpTo(names.length - 1));
		
		var name = names[Random.getUpTo(names.length - 1)];
		names.remove(name);
		
		if (!customlook) {
			if (name == "Rebecca") {
				image = Assets.images.nullachtsechzehnfrau;
				w = 820 / 10;
				h = 402 / 3;
				standLeft = Animation.create(10);
				standRight = Animation.create(0);
				walkLeft = Animation.createRange(11, 18, 4);
				walkRight = Animation.createRange(1, 8, 4);
			}
			else {
				switch (Random.getUpTo(2)) {
				case 0:
					image = Assets.images.nullachtsechzehnmann_rot;
				case 2:
					image = Assets.images.nullachtsechzehn_gruen;
				}
			}
		}
		
		allguys.push(this);
	}
	
	private function createMichaelTask(): Void {
		var guy: RandomGuy = this;
		var count = 0;
		for (guy in allguys) {
			if (guy.visible && guy != this) {
				++count;
			}
		}
		if (count > 0) {
			while (guy == this || !guy.visible) {
				var value = Random.getUpTo(RandomGuy.allguys.length - 1);
				guy = RandomGuy.allguys[value];
			}
			//schedule.add(new MoveTask(this, guy));
			//schedule.add(new BlaTask(this, guy));
		}
	}
	
	override public function update(): Void {
		super.update();
		if (isCurrentlyUsedFrom != null) {
			speedx = 0;
			speedy = 0;
		}
		else {
			//schedule.update();
		}
		if (speedx > 0) {
			setAnimation(walkRight);
			lookLeft = false;
		}
		else if (speedx < 0) {
			setAnimation(walkLeft);
			lookLeft = true;
		}
		else {
			if (lookLeft) {
				setAnimation(standLeft);
			}
			else {
				setAnimation(standRight);
			}
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
				g.drawSubImage(zzzzz, x - 40, y - 20, zzzzz.width * zzzzzAnim.getIndex() / 3, 0, zzzzz.width / 3, zzzzz.height);
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
	
	override public function isUsableFrom(user:Dynamic):Bool 
	{
		return super.isUsableFrom(user) && Main.Player == user;
	}
	override public function useFrom(user:Dynamic):Bool 
	{
		#if false
		if (super.useFrom(user))
		{
			Empty.the.playerDlg.insert([
				new Bla(Localization.getText(Keys_text.HELLO, [IdCard.Name + ', ${IdCard.Id}']), user, false)
				, new Bla(Localization.getText(Keys_text.HELLO, [idUser.IdCard.Name]), this, false)
				, new BlaWithChoices(Localization.getText(Keys_text.HOW_TO_HELP), this, [
					[ /* Seltsames?*/ 
						new Bla(Keys_text.STRANGE_NOTHING_ + Random.getUpTo(1), this, false)
					]
					, [ /* tun gerade? */
						new Bla(schedule.nextTwoTaskDescription(), this, true)
					]
					, [ /* YOU ARE THE MONSTER */
						new StartDialogue(everybodyRunToPlayer.bind(this))
						, new StartDialogue(function() { 
							Empty.the.showdown = true;
							Empty.the.renderOverlay = true;
							Empty.the.overlayColor = Color.fromBytes(0, 0, 0, 0);
						})
						, new Action(null, FADE_TO_BLACK)
						, new Bla(Keys_text.YOUMONSTER_SHOWDOWN_1, user, true)
						, new SpawnNpcDialog([new Action(null, ActionType.FADE_FROM_BLACK_TO_DUSK)])
						, new Bla(Keys_text.YOUMONSTER_SHOWDOWN_1, user, false)
						, new Bla(Keys_text.YOUMONSTER_SHOWDOWN_1, user, false)
						, new Action(null, PAUSE)
						, new Bla(Keys_text.YOUMONSTER_REACTION_ + Random.getUpTo(6), this, false)
						, new StartDialogue(Dialogues.showdownChatter.bind(this))
						, new Bla(Localization.getText(Keys_text.YOUMONSTER_SHOWDOWN_2, [this.IdCard.Name]), null, false)
						, new Bla(Localization.getText(Keys_text.YOUMONSTER_SHOWDOWN_2, [this.IdCard.Name]), null, false)
						, new Bla(Localization.getText(Keys_text.YOUMONSTER_SHOWDOWN_2, [this.IdCard.Name]), null, false)
						, new BlaWithChoices(Keys_text.YOUMONSTER_SHOWDOWN_3, null, [
							[new StartDialogue(Dialogues.showdownShoot.bind(this))]
							, [new StartDialogue(Dialogues.showdownHesitate.bind(this))]
						])
					]
				])
				, new StartDialogue(stopUsing.bind(true))
			]);
			return true;
		}
		#end
		return false;
	}
	override public function stopUsing(clean:Bool):Void 
	{
		super.stopUsing(clean);
	}
}
