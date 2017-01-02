import java.awt.Point;

public abstract class Player {

	private boolean isHuman;
	protected Point position;
	protected String heuristic;
	protected String name;
	public Player(String name,Boolean isHuman, String heuristic) {
		this.isHuman = isHuman;
		this.heuristic = heuristic;
		this.name = name;
	}
	public void setPosition(Point position){
		this.position = position;
	}
	public abstract void yourMove();
	public abstract void getTarget();
	public void update(GameBoard board, QueryProlog queryProlog) {
		// TODO Auto-generated method stub
		
	}

}
