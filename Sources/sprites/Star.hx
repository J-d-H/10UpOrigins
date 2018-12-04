package sprites;

import kha.math.Matrix2;
import kha.math.Vector2;
import kha.Assets;
import kha2d.Scene;
import kha2d.Sprite;

class Star extends Sprite {
	private var count = 60;
	
	public static function createEffect(x: Float, y: Float)
	{
		for (i in 0...5)
		{
			var v: Vector2 = Matrix2.rotation(2 * Math.PI * i / 5).multvec(new Vector2(0, 1));

			var star: Star = new Star(x, y);
			star.speedy = v.x;
			star.speedx = v.y;

			kha2d.Scene.the.addProjectile(star);
		}
	}

	public function new(x: Float, y: Float) {
		super(Assets.images.star);
		this.x = x - image.width / 2;
		this.y = y;
		this.accy = 0;
		collides = false;
		z = 6;
	}
	
	override public function update(): Void {
		super.update();
		--count;
		if (count < 0) Scene.the.removeProjectile(this);
	}
}
