import java.util.ArrayList;

public class AI_Player extends Player {

	public AI_Player(String name, String heuristic) {
		super(name, false, heuristic);
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
	public void update(GameBoard gameBoard, QueryProlog queryProlog) {
		System.out.println("update");
		if(queryProlog.isGameState(this.name, 1)){
			ArrayList<String> board = queryProlog.getBoard();
			long start_time = System.currentTimeMillis();
			queryProlog.tryAndMakeMove(this.name, this.heuristic);
			System.out.println("Search took" + (start_time -System.currentTimeMillis()) +"ms");
			ArrayList<String> newBoard = queryProlog.getBoard();
			
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
	}
}
