import javax.swing.JLabel;
/**
 * The class for the Human player
 * This essentially does nothing as the Human players actions are from mouse clicks.
 * AI_player and HUmanPlayer require a shared interface in order to have the option to play one heuristic against another 
 * @author Edward
 *
 */
public class HumanPlayer extends Player {

	public HumanPlayer(String name) {
		super(name, true, "h0");
		// TODO Auto-generated constructor stub
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
