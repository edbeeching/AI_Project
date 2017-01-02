import java.awt.Point;

import javax.swing.JLabel;

public abstract class Player {

	private boolean isHuman;
	protected Point position;
	protected String heuristic;
	protected String name;
	public int winCount;
	public Player(String name,Boolean isHuman, String heuristic) {
		this.isHuman = isHuman;
		this.heuristic = heuristic;
		this.name = name;
		this.winCount = 0;
	}
	public void setPosition(Point position){
		this.position = position;
	}
	public abstract void yourMove();
	public abstract void getTarget();
	public boolean update(GameBoard board, QueryProlog queryProlog, JLabel timeLabel) {
		// TODO Auto-generated method stub
		return false;
	}

}
