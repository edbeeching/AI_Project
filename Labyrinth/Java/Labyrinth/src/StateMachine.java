
public class StateMachine {

	public enum State { SETUP, PLAYER_1_MOVE, PLAYER_2_MOVE, GAME_PAUSED, END_GAME}
	public State gameState;
	private Player player1;
	private Player player2;
	
	public static final StateMachine instance = new StateMachine();
	private StateMachine(){
		gameState = State.PLAYER_1_MOVE;
	}
	public void setPlayers(Player player1, Player player2){
		this.player1 = player1;
		this.player2 = player2;
	}
	public void restart(){
		
	}
	public Player currentPlayer(){
		if(gameState == State.PLAYER_1_MOVE) return player1;
		if(gameState == State.PLAYER_2_MOVE) return player2;
		
		System.out.println("Warning: The current player was requested out of turn.");
		return null;
	}
}
