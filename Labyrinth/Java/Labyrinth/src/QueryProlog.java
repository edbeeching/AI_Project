import java.awt.Point;
import java.util.ArrayList;
import java.util.List;

import org.jpl7.Query;
import org.jpl7.Term;
import org.jpl7.fli.Prolog;
import org.pmw.tinylog.Logger;

/**
 * The QueryProlog class is used to communicate between the Labyrinth user interface and the Game AI in prolog.
 * 
 * @author Edward Beeching
 *
 */

public class QueryProlog {

	/**
	 * Instantiate and initialise the query prolog class, user parameters are contained in the GameInfo class.
	 * 
	 * @param gameInfo
	 */	
	public QueryProlog(GameInfo gameInfo){
		initialise(gameInfo);
	}
	/**
	 * Initialise the Game by
	 * 1. Consulting the prolog .pl file
	 * 2. Call setup(H). where H are the heuristics
	 * @param gameInfo
	 */
	private void initialise(GameInfo gameInfo){
		String string = "consult('prolog/labyrinth.pl')";
		Query query = new Query(string);
		//System.out.println(string + " " + (query.hasSolution() ? "suceeded" : "failed"));
		Logger.info(string + " " + (query.hasSolution() ? "suceeded" : "failed"));
		query.close();
		
		String setupString = "setup(" + gameInfo.player1Heuristic + "/" + gameInfo.player2Heuristic + ").";
		Query querySetup = new Query(setupString);
		//System.out.println(setupString + " " + (querySetup.hasSolution() ? "suceeded" : "failed"));
		Logger.info(setupString + " " + (querySetup.hasSolution() ? "suceeded" : "failed"));
		querySetup.close();
	}	
	/**
	 * Reset the game and create a new maze, treasure list etc.
	 * @param gameInfo
	 */
	public void reset(GameInfo gameInfo){
		String setupString = "setup(" + gameInfo.player1Heuristic + "/" + gameInfo.player2Heuristic + ").";
		Query querySetup = new Query(setupString);
		//System.out.println(setupString + " " + (querySetup.hasSolution() ? "suceeded" : "failed"));
		Logger.info(setupString + " " + (querySetup.hasSolution() ? "suceeded" : "failed"));
		querySetup.close();	
		
	}
	/**
	 * get the current board from prolog
	 * @return ArrayList of strings containing the board pieces
	 */
	public ArrayList<String> getBoard(){
		
		String boardQueryString = "board(X).";
		Query boardQuery = new Query(boardQueryString);
		//System.out.println(boardQueryString + " " + (boardQuery.hasSolution() ? "suceeded" : "failed"));
		Logger.info(boardQueryString + " " + (boardQuery.hasSolution() ? "suceeded" : "failed"));
		Term term = boardQuery.oneSolution().get("X");
		//The following iterates through a list of lists to get all elements into a ArrayList of strings
		ArrayList<String> elements = new ArrayList<String>(49);
		
		Term t1 =  term;
		while(true){
			if(t1.type() == Prolog.COMPOUND){
				Term t2 = t1.arg(1);
				while(true){
					if(t2.type() == Prolog.COMPOUND){
						elements.add(t2.arg(1).toString());
						//System.out.println(t2.arg(1));
						t2 = t2.arg(2);	
					}else if(t2.type() == Prolog.ATOM){
						break;
					}
				}
				t1=t1.arg(2);	
			}else if (t1.type() == Prolog.ATOM){
				break;
			}
		}
		boardQuery.close();
		
		return elements;
	}
	/**
	 * Get the position of a particular player
	 * @param player
	 * @return a 2D Point containing the players location
	 */
	public Point getPlayerPosition(String player){
		String positionString = "player(" + player +",_,I/J)";
		Query positionQuery = new Query(positionString);
		//System.out.println(positionString + " " + (positionQuery.hasSolution() ? "suceeded" : "failed"));
		Logger.info(positionString + " " + (positionQuery.hasSolution() ? "suceeded" : "failed"));
		positionQuery.close();
		if(!positionQuery.hasSolution()){
			return null;
		}
		Term I = positionQuery.oneSolution().get("I");
		Term J = positionQuery.oneSolution().get("J");
		
		//System.out.println(I.intValue());
		//System.out.println(J.intValue());
		// Just to be confusing, x and y are swapped in my implementation of prolog :)
		return new Point(J.intValue(),I.intValue());
	}
	/**
	 * Get the treasure indices for the two players
	 * @return a 2D point containing the Indices X = a, Y = b
	 */
	public Point getTreasurePositions(){
		Point pos = new Point();
		
		String player1TreasureString = "treasure_index(a,Index).";
		Query player1TreasureQuery = new Query(player1TreasureString);
		//System.out.println(player1TreasureString + " " + (player1TreasureQuery.hasSolution() ? "suceeded" : "failed"));
		Logger.info(player1TreasureString + " " + (player1TreasureQuery.hasSolution() ? "suceeded" : "failed"));
		player1TreasureQuery.close();
		if(!player1TreasureQuery.hasSolution()){
			return null;
		}
		 pos.x = player1TreasureQuery.oneSolution().get("Index").intValue();
		
		String player2TreasureString = "treasure_index(b,Index).";
		Query player2TreasureQuery = new Query(player2TreasureString);
		//System.out.println(player2TreasureString + " " + (player2TreasureQuery.hasSolution() ? "suceeded" : "failed"));
		Logger.info(player2TreasureString + " " + (player2TreasureQuery.hasSolution() ? "suceeded" : "failed"));
		player2TreasureQuery.close();
		if(!player2TreasureQuery.hasSolution()){
			return null;
		}
		 pos.y = player2TreasureQuery.oneSolution().get("Index").intValue();
		 
		 
		return pos;
	}
	/**
	 * Get the treasure lists for a particular player
	 * @param player
	 * @return An arraylist of strings containing the treasures
	 */
	public ArrayList<String> getTreasureList(String player){
		String treasureString = "get_treasure_list("+player+",List).";
		Query treasureQuery = new Query(treasureString);
		//System.out.println(treasureString + " " + (treasureQuery.hasSolution() ? "suceeded" : "failed"));
		Logger.info(treasureString + " " + (treasureQuery.hasSolution() ? "suceeded" : "failed"));
		treasureQuery.close();
		Term term = treasureQuery.oneSolution().get("List");
		Term t = term;
		if(!treasureQuery.hasSolution()){
			return null;
		}
		ArrayList<String> treasures = new ArrayList<String>();
		while(true){
			if(t.type()== Prolog.COMPOUND){
				treasures.add(t.arg(1).toString());
				t=t.arg(2);
			}else if (t.type() == Prolog.ATOM){
				break;
			}
		}
		return treasures;
	}
	/**
	 * Request to shift the maze left
	 * @param row		The row
	 * @return 			returns the new board and an arraylist of strings
	 */
	public ArrayList<String> requestShiftLeft(int row) {
		
		String shiftLeft = "try_to_shift_row_left("+ row +  ")";
		Query shiftQuery = new Query(shiftLeft);
		//System.out.println(shiftQuery + " " + (shiftQuery.hasSolution() ? "suceeded" : "failed"));
		Logger.info(shiftQuery + " " + (shiftQuery.hasSolution() ? "suceeded" : "failed"));
		shiftQuery.close();
		
		return getBoard();
	}
	/**
	 * Request to shift the maze right
	 * @param row		The row
	 * @return 			returns the new board and an arraylist of strings
	 */
	public ArrayList<String> requestShiftRight(int row) {
		String shiftRight = "try_to_shift_row_right("+ row +  ")";
		Query shiftQuery = new Query(shiftRight);
		//System.out.println(shiftQuery + " " + (shiftQuery.hasSolution() ? "suceeded" : "failed"));
		Logger.info(shiftQuery + " " + (shiftQuery.hasSolution() ? "suceeded" : "failed"));
		shiftQuery.close();
		
		return getBoard();
	}
	/**
	 * Request to shift the maze up
	 * @param column	The column
	 * @return 			returns the new board and an arraylist of strings
	 */
	public ArrayList<String> requestShiftUp(int column) {
		String shiftUp = "try_to_shift_column_up("+ column +  ")";
		Query shiftQuery = new Query(shiftUp);
		//System.out.println(shiftQuery + " " + (shiftQuery.hasSolution() ? "suceeded" : "failed"));
		Logger.info(shiftQuery + " " + (shiftQuery.hasSolution() ? "suceeded" : "failed"));
		shiftQuery.close();
		
		return getBoard();
	}
	/**
	 * Request to shift the maze down
	 * @param column	The column
	 * @return 			returns the new board and an arraylist of strings
	 */
	public ArrayList<String> requestShiftDown(int column) {
		String shiftDown = "try_to_shift_column_down("+ column +  ")";
		Query shiftQuery = new Query(shiftDown);
		//System.out.println(shiftQuery + " " + (shiftQuery.hasSolution() ? "suceeded" : "failed"));
		Logger.info(shiftQuery + " " + (shiftQuery.hasSolution() ? "suceeded" : "failed"));
		shiftQuery.close();
		
		return getBoard();
	}
	/**
	 * Checks to see if a player can move to a particular location, I think this is deprecated now.
	 * @param i		the index I
	 * @param j		the index J
	 * @return boolean whether the move is possible or not
	 */
	public boolean canMove(int i, int j) {
		
		String moveString = "can_move(1/1,"+i+"/"+j+").";
		Query moveQuery = new Query (moveString);
		boolean canMove = moveQuery.hasSolution();
		moveQuery.close();
		return canMove; 
	}
	/**
	 * for a given player and heuristic, this will try and make move to shift the maze
	 * @param player 		The player
	 * @param heuristic		The heuristic
	 * @return	boolean showing whether a move was possible
	 */
	public boolean tryAndMakeMove(String player, String heuristic){
		String moveString = "try_and_make_move(" + player + "," + heuristic +").";
		Query moveQuery = new Query(moveString);
		//System.out.println(moveString + " " + (moveQuery.hasSolution() ? "suceeded" : "failed"));
		Logger.info(moveString + " " + (moveQuery.hasSolution() ? "suceeded" : "failed"));
		moveQuery.close();
		if(!moveQuery.hasSolution()){
			return false;
		}
		return true;
	}
	/**
	 * makes the best local move after the maze has been shifted
	 * @param player		the player
	 * @param heuristic		the heuristic
	 */
	
	public void makeBestLocalMove(String player, String heuristic){
		String localMoveString = "make_best_local_move(" + player + "," + heuristic +").";
		Query localMoveQuery = new Query(localMoveString);
		//System.out.println(localMoveString + " " + (localMoveQuery.hasSolution() ? "suceeded" : "failed"));
		Logger.info(localMoveString + " " + (localMoveQuery.hasSolution() ? "suceeded" : "failed"));
		localMoveQuery.close();
	}
	/**
	 * Checks the game state for a given player and state comination, e.g isGameState("a",1)
	 * @param player
	 * @param state
	 * @return boolean value indicating whether that was the state
	 */
	public boolean isGameState(String player, int state){
		String stateString = "game_state(" + player + "," + state +").";
		Query stateQuery = new Query(stateString);
		//System.out.println(stateQuery + " " + (stateQuery.hasSolution() ? "suceeded" : "failed"));
		Logger.info(stateQuery + " " + (stateQuery.hasSolution() ? "suceeded" : "failed"));
		stateQuery.close();
		if(!stateQuery.hasSolution()){
			return false;
		}
		return true;
	}
	/**
	 * Asks Prolog is there is a connected path in the maze between a given player and a i,k locations
	 * @param player
	 * @param i
	 * @param j
	 * @return boolean indicating whether the was a connected path
	 */
	public boolean canMove(String player, int i, int j) {
		String positionString = "player(" + player +",_,I/J).";
		Query positionQuery = new Query(positionString);
		//System.out.println(positionString + " " + (positionQuery.hasSolution() ? "suceeded" : "failed"));
		Logger.info(positionString + " " + (positionQuery.hasSolution() ? "suceeded" : "failed"));
		positionQuery.close();
		if(!positionQuery.hasSolution()){
			return false;
		}
		Term I = positionQuery.oneSolution().get("I");
		Term J = positionQuery.oneSolution().get("J");
		
		String moveString = "can_move("+I.intValue()+"/"+J.intValue()+","+i+"/"+j+").";
		Query moveQuery = new Query (moveString);
		boolean canMove = moveQuery.hasSolution();
		moveQuery.close();
		return canMove; 
	}
	/**
	 * Asks prolog to try and move a player to a given i and j location
	 * @param player
	 * @param i
	 * @param j
	 */
	public void tryAndMove(String player, int i, int j) {
		String moveString = "move_player(" + player + "," + i + "/" + j +").";
		Query moveQuery = new Query(moveString);
		//System.out.println(moveString + " " + (moveQuery.hasSolution() ? "suceeded" : "failed"));
		Logger.info(moveString + " " + (moveQuery.hasSolution() ? "suceeded" : "failed"));
		moveQuery.close();
	}
	/**
	 * Gets the current player from prolog
	 * @return string containing "a" or "b"
	 */
	public String getCurrentPlayer() {
		String playerString = "get_current_player(Player).";
		Query playerQuery = new Query(playerString);
		//System.out.println(playerString + " " + (playerQuery.hasSolution() ? "suceeded" : "failed"));
		Logger.info(playerString + " " + (playerQuery.hasSolution() ? "suceeded" : "failed"));
		playerQuery.close();
		if(!playerQuery.hasSolution()){
			return null;
		}
		Term playerTerm = playerQuery.oneSolution().get("Player");
		return playerTerm.toString();
	}
	/**
	 * Askes prolog whether a particular player has won the game
	 * @param player
	 * @return boolean indicting whether the player has won.
	 */
	public boolean haveIWon(String player) {
		// TODO Auto-generated method stub
		String wonString = "have_I_won(" + player + ").";
		Query wonQuery = new Query(wonString);
		//System.out.println(wonString + " " + (wonQuery.hasSolution() ? "suceeded" : "failed"));
		Logger.info(wonString + " " + (wonQuery.hasSolution() ? "suceeded" : "failed"));
		return wonQuery.hasSolution();
	}
}
