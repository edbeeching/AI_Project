import java.awt.Point;
import java.util.ArrayList;
import java.util.List;

import org.jpl7.Query;
import org.jpl7.Term;
import org.jpl7.fli.Prolog;

public class QueryProlog {

	public QueryProlog(GameInfo gameInfo){
		initialise(gameInfo);
	}
	private void initialise(GameInfo gameInfo){
		String string = "consult('prolog/labyrinth.pl')";
		Query query = new Query(string);
		System.out.println(string + " " + (query.hasSolution() ? "suceeded" : "failed"));
		query.close();
		
		String setupString = "setup(" + gameInfo.player1Heuristic + "/" + gameInfo.player2Heuristic + ").";
		Query querySetup = new Query(setupString);
		System.out.println(string + " " + (querySetup.hasSolution() ? "suceeded" : "failed"));
		querySetup.close();
	}
//	public boolean generateMaze(ArrayList<MazePiece> pieces){
//		
//		
//		return false;
//	}
	public ArrayList<String> getBoard(){
		
		String boardQueryString = "board(X).";
		Query boardQuery = new Query(boardQueryString);
		System.out.println(boardQueryString + " " + (boardQuery.hasSolution() ? "suceeded" : "failed"));
		Term term = boardQuery.oneSolution().get("X");
		
		
		//The following iterates through a list of lists to get all elements into a ArrayList of string
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
	public Point getPlayerPosition(String player){
		String positionString = "player(" + player +",_,I/J)";
		Query positionQuery = new Query(positionString);
		System.out.println(positionString + " " + (positionQuery.hasSolution() ? "suceeded" : "failed"));
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
//	public ArrayList<ArrayList<String>> generateMaze(){
//		
//		ArrayList<ArrayList<String>> mazeStrings = new ArrayList<ArrayList<String>>();
//		
//		//for(int i=0;i<)
//		
//		
//		
//		return mazeStrings;
//	}
	public ArrayList<String> getTreasureList(String player){
		//treasure_list(a,P1_List)
		String treasureString = "get_treasure_list("+player+",List).";
		Query treasureQuery = new Query(treasureString);
		System.out.println(treasureString + " " + (treasureQuery.hasSolution() ? "suceeded" : "failed"));
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
	public ArrayList<String> requestShiftLeft(int row) {
		
		String shiftLeft = "try_to_shift_row_left("+ row +  ")";
		Query shiftQuery = new Query(shiftLeft);
		System.out.println(shiftQuery + " " + (shiftQuery.hasSolution() ? "suceeded" : "failed"));
		shiftQuery.close();
		
		return getBoard();
	}
	public ArrayList<String> requestShiftRight(int row) {
		String shiftRight = "try_to_shift_row_right("+ row +  ")";
		Query shiftQuery = new Query(shiftRight);
		System.out.println(shiftQuery + " " + (shiftQuery.hasSolution() ? "suceeded" : "failed"));
		shiftQuery.close();
		
		return getBoard();
	}
	public ArrayList<String> requestShiftUp(int column) {
		String shiftUp = "try_to_shift_column_up("+ column +  ")";
		Query shiftQuery = new Query(shiftUp);
		System.out.println(shiftQuery + " " + (shiftQuery.hasSolution() ? "suceeded" : "failed"));
		shiftQuery.close();
		
		return getBoard();
	}
	public ArrayList<String> requestShiftDown(int column) {
		String shiftDown = "try_to_shift_column_down("+ column +  ")";
		Query shiftQuery = new Query(shiftDown);
		System.out.println(shiftQuery + " " + (shiftQuery.hasSolution() ? "suceeded" : "failed"));
		shiftQuery.close();
		
		return getBoard();
	}
	public boolean canMove(int i, int j) {
		
		String moveString = "can_move(1/1,"+i+"/"+j+").";
		Query moveQuery = new Query (moveString);
		boolean canMove = moveQuery.hasSolution();
		moveQuery.close();
		return canMove; 
	}
	
	public boolean tryAndMakeMove(String player, String heuristic){
		String moveString = "try_and_make_move(" + player + "," + heuristic +").";
		Query moveQuery = new Query(moveString);
		System.out.println(moveString + " " + (moveQuery.hasSolution() ? "suceeded" : "failed"));
		moveQuery.close();
		if(!moveQuery.hasSolution()){
			return false;
		}
		return true;
	}
	
	public void makeBestLocalMove(String player, String heuristic){
		String localMoveString = "make_best_local_move(" + player + "," + heuristic +").";
		Query localMoveQuery = new Query(localMoveString);
		System.out.println(localMoveString + " " + (localMoveQuery.hasSolution() ? "suceeded" : "failed"));
		localMoveQuery.close();
	}
	
	public boolean isGameState(String player, int state){
		String stateString = "game_state(" + player + "," + state +").";
		Query stateQuery = new Query(stateString);
		System.out.println(stateQuery + " " + (stateQuery.hasSolution() ? "suceeded" : "failed"));
		stateQuery.close();
		if(!stateQuery.hasSolution()){
			return false;
		}
		return true;
	}

	public boolean canMove(String player, int i, int j) {
		String positionString = "player(" + player +",_,I/J).";
		Query positionQuery = new Query(positionString);
		System.out.println(positionString + " " + (positionQuery.hasSolution() ? "suceeded" : "failed"));
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
	public void tryAndMove(String player, int i, int j) {
		String moveString = "move_player(" + player + "," + i + "/" + j +").";
		Query moveQuery = new Query(moveString);
		System.out.println(moveString + " " + (moveQuery.hasSolution() ? "suceeded" : "failed"));
		moveQuery.close();
		
		
		
		//move_player(C,I/J)
	}
	public String getCurrentPlayer() {
		String playerString = "get_current_player(Player).";
		Query playerQuery = new Query(playerString);
		System.out.println(playerString + " " + (playerQuery.hasSolution() ? "suceeded" : "failed"));
		playerQuery.close();
		if(!playerQuery.hasSolution()){
			return null;
		}
		Term playerTerm = playerQuery.oneSolution().get("Player");
		return playerTerm.toString();
		
		
	}
}
