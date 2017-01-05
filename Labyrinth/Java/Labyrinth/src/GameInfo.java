/**
 * A helper class to hold the game information
 * @author Edward Beeching
 *
 */
public class GameInfo{
	
		public String player1Heuristic;
		public String player2Heuristic;
		public int actionDelay;
		public int totalGames;
		
		public GameInfo(){
			player1Heuristic = "h0"; // h0 is a human heuristic
			player2Heuristic = "h0";
			actionDelay = 100;
			totalGames = 1;
		}
}
