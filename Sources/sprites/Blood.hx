package sprites;

import kha.Assets;
import kha.math.Random;
import kha2d.Scene;
import kha2d.Sprite;

class Blood extends Sprite {
	private var count = 60;
	
	public function new(x: Float, y: Float) {
		super(Assets.images.blood);
		this.x = x;
		this.y = y;
		collides = false;
		angle = Random.getUpTo(6);
		speedy = -2 - Random.getUpTo(3);
		speedx = -2 + Random.getUpTo(4);
		z = 6;
	}
	
	override public function update(): Void {
		super.update();
		angle += 0.1;
		--count;
		if (count < 0) Scene.the.removeOther(this);
	}
}
