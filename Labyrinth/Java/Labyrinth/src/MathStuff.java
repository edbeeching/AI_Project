

public final class  MathStuff {
	public static float randInRange(float min , float max){
		return ((float) Math.random()*(max-min) + min);
	}
	public static int randIntInRange(int min, int max){

		return (int)Math.floor((double)(randInRange((float)(min), (float)(max+1))));
	}
}
