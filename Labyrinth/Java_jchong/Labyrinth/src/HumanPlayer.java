import javax.swing.JLabel;

public class HumanPlayer extends Player {

	public HumanPlayer(String name) {
		super(name, true, "h0");
		// TODO Auto-generated constructor stub
	}

	@Override
	public void yourMove() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void getTarget() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public boolean update(GameBoard board, QueryProlog queryProlog, JLabel timeLabel) {
		if(queryProlog.haveIWon(this.name)){
			System.out.println("Player " + this.name + " has won!");
			return true;
		}
		return false;
	}

}
