import java.awt.EventQueue;
import java.util.ArrayList;

import javax.swing.JLabel;

import org.pmw.tinylog.Logger;

/**
 * The AI Player 
 * @author Edward
 *
 */
public class AI_Player extends Player {

	public AI_Player(String name, String heuristic) {
		super(name, false, heuristic);
		// TODO Auto-generated constructor stub
	}
	/**
	 * The update function, this either asks prolog to shift the board, based on a certain heuristic or asks prolog to move the player based on a certain heuristic
	 */
	@Override
	public boolean update(GameBoard gameBoard, QueryProlog queryProlog, JLabel timeLabel) {
		
		//System.out.println("update");
		Logger.info("------------------------------------------------------------------------------------");
		Logger.info("update");
		if(queryProlog.isGameState(this.name, 1)){
			//ArrayList<String> board = queryProlog.getBoard();
			long start_time = System.currentTimeMillis();
			queryProlog.tryAndMakeMove(this.name, this.heuristic);
			//System.out.println("Search took" + (System.currentTimeMillis() - start_time ) +"ms");
			Logger.info("Search took" + (System.currentTimeMillis() - start_time ) +"ms");
			EventQueue.invokeLater(new Runnable() {
			    @Override
			    public void run() {
			    	timeLabel.setText("Search took: "+ (System.currentTimeMillis() - start_time ) +"ms");
			    }
			  });
			ArrayList<String> newBoard = queryProlog.getBoard();
			Logger.info("----------------------------------------------------------------------");
			for(int i=0;i<7;i++){
				Logger.info("\t{},\t{},\t{},\t{},\t{},\t{},\t{}", newBoard.get(i*7+0), newBoard.get(i*7+1), newBoard.get(i*7+2),newBoard.get(i*7+3),newBoard.get(i*7+4),newBoard.get(i*7+5),newBoard.get(i*7+6));			
			}
			
			Logger.info("----------------------------------------------------------------------");
			gameBoard.recreateBoardFromString(newBoard);
			gameBoard.updatePlayerPositons();
				//gameBoard.swapCurrentPlayer();	
		}else{
			if(queryProlog.isGameState(this.name, 2)){
				queryProlog.makeBestLocalMove(this.name, this.heuristic);
				gameBoard.updatePlayerPositons();
				gameBoard.swapCurrentPlayer();
			}
		}
		if(queryProlog.haveIWon(this.name)){
			//System.out.println("Player " + this.name + " has won!");
			Logger.info("Player " + this.name + " has won!");
			return true;
		}
		return false;
	}
}
