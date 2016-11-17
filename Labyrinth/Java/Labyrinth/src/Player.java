import java.awt.Point;

public abstract class Player {

	private boolean isHuman;
	private Point position;
	private int heuristic = 0;
	public Player(Boolean isHuman, int heuristic) {
		this.isHuman = isHuman;
		this.heuristic = heuristic;
	}
	public void setPosition(Point position){
		this.position = position;
	}
	public abstract void yourMove();
	public abstract void getTarget();
	
}
