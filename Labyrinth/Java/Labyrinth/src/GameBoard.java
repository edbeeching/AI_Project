import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.EventQueue;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.GridLayout;
import java.awt.Point;
import java.awt.event.ActionEvent;
import java.awt.geom.Line2D;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import javax.imageio.ImageIO;
import javax.swing.AbstractAction;
import javax.swing.BorderFactory;
import javax.swing.Box;
import javax.swing.BoxLayout;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JLayeredPane;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.SwingWorker;

import org.pmw.tinylog.Configurator;
import org.pmw.tinylog.Logger;
import org.pmw.tinylog.labelers.TimestampLabeler;
import org.pmw.tinylog.policies.SizePolicy;
import org.pmw.tinylog.policies.StartupPolicy;
import org.pmw.tinylog.writers.RollingFileWriter;
/**
 * The largest class, the game board, this implements:
 * 
 * @author Edward Beeching
 *
 */
public class GameBoard extends JLayeredPane {

	private ArrayList<BufferedImage> pieceImages;			// The images of the pieces
	private ArrayList<BufferedImage> treasureImages;		// The images of the treasures
	public ArrayList<MazePiece> pieces;						// An array list of maze pieces
	public JLabel player1_label,  player2_label;			// The coloured squares for the two players
	private Player player1, player2, currentPlayer;			// Classes for the players, note the interface is inherited so AI and Human player can be shared
	private int actionDelay, numGames;						// The time between actions
	private float oldX = 0.0f, oldY = 0.0f; 				//Stores treasure locations to avoid recreating them each loop
	
	
	private JFrame frame;									// The main Swing Frame
	private JPanel boardPanel;								// Panel representing the board
	private ArrayList<JButton> buttons;						// A array list of buttons for moving the rows
	private Map<Integer,Integer> pieceTypeMap;				// maps for working out which piece is which
	private Map<Integer,Integer> pieceRotMap;				// maps for working out the rotation of the pieces
	private QueryProlog queryProlog;
	private GameInfo gameInfo;								// Class holding user parameters, such as heuristics etc
	private GameBoard gameBoard;							// The game board
	private JPanel treasurePanel;							// panel for the treasures
	private JLabel turnLabel, timeLabel, player1InfoLabel, player2InfoLabel; // UI elements for showing the time, who's turn it is, etc
	
	private SwingWorker<Object, Object> worker;
	
	/** Constructor, implements the logging functionality, sets of QueryProlog class, gets a list of board strings from the query prolog class
	 * sets up the board in Java, starts a time which requests moves from Prolog
	 * 
	 * @param frame
	 * @param gameInfo
	 */
	public GameBoard(JFrame frame, GameInfo gameInfo){
		super();
		Configurator.currentConfig()
		   .writer(new RollingFileWriter("logs/log.txt", 10, new TimestampLabeler(),new SizePolicy(10000 * 1024)),"{date:yyyy-MM-dd HH:mm:ss} {class}.{method}()\t{message}")
		   .activate();
		Logger.info("Hello World!");
		
		numGames = 1;
		this.frame = frame;
		this.gameInfo = gameInfo;
		gameBoard = this;
		queryProlog = new QueryProlog(gameInfo);
		ArrayList<String> boardStrings = queryProlog.getBoard();
		this.actionDelay = gameInfo.actionDelay;
		initialise(boardStrings);
		startTimer();
		Point pos  = queryProlog.getTreasurePositions();
		//System.out.println(" player a: " + pos.getX() + "player b:"+ pos.getY());
		Logger.info(" player a: " + pos.getX() + "player b:"+ pos.getY());
	}
	/**
	 * Starts a second thread running which requests prolog to make moves
	 * The current player ping pongs between the two players as each finishes their turn.
	 * At the end of a game, a score is incremented to keep track of who is doing best.
	 */
	private void startTimer(){
		worker = new SwingWorker<Object, Object>(){
			@Override
			protected Object doInBackground() throws Exception {
				Thread.sleep(100);
				while(true){
					//System.out.println("updating");
					if(currentPlayer.update(gameBoard, queryProlog, timeLabel)){
						numGames++;
						if(currentPlayer == player1){
							player1.winCount++;
							// This has to be queued as we are not on the main thread
							EventQueue.invokeLater(new Runnable() {
							    @Override
							    public void run() {
							    	player1InfoLabel.setText("Player 1 has won " + player1.winCount + " times");
							    }
							  });
							if(numGames > gameInfo.totalGames){
								JOptionPane.showMessageDialog(frame, "Red player has won with heuristic " + player1.heuristic);
								numGames = 1;
							}
						}else{
							player2.winCount++;
							// This has to be queued as we are not on the main thread
							EventQueue.invokeLater(new Runnable() {
							    @Override
							    public void run() {
							    	player2InfoLabel.setText("Player 2 has won " + player2.winCount + " times");
							    }
							  });
							if(numGames > gameInfo.totalGames){
								JOptionPane.showMessageDialog(frame, "Green player has won with heuristic " + player2.heuristic);
								numGames = 1;
							}
						}
						restartBoard();
					}
					setupTreasurePanel();
					Thread.sleep(actionDelay);	
				}
			}
		};
		worker.execute();
	}
	/**
	 * Restarts the game board at the end of a game
	 */
	
	private void restartBoard(){
		Logger.info("--------------------------------------------------------------------------");
		Logger.info("-------------------       RESTARTING GAME     -----------------------------");
		Logger.info("--------------------------------------------------------------------------");
		queryProlog.reset(this.gameInfo);
		currentPlayer = player1;
		ArrayList<String> boardStrings = queryProlog.getBoard();
		this.actionDelay = gameInfo.actionDelay;
		updatePlayerPositons();
		recreateBoardFromString(boardStrings);
	}
	/**
	 * Initialises the game board from and array list of board pieces
	 * Gets player heuristics and other info from the GameInfo class
	 * @param boardStrings
	 */
	private void initialise(ArrayList<String> boardStrings) {
		this.setBounds(20, 20, 530, 530);
		this.setBorder(BorderFactory.createLineBorder(Color.gray));
		
		createButtons();
		if(boardStrings == null){
			System.out.println("Prolog has not provided a board string");
			Logger.info("Prolog has not provided a board string");
		}else{
			setupBoardFromString(boardStrings);
		}
		if(gameInfo.player1Heuristic == "h0"){
			player1 = new HumanPlayer("a");
		}else{
			player1 = new AI_Player("a", gameInfo.player1Heuristic);
		}
		if(gameInfo.player2Heuristic == "h0"){
			player2 = new HumanPlayer("b");
		}else{
			player2 = new AI_Player("b", gameInfo.player2Heuristic);
		}
		currentPlayer = player1;
		Point player1Indices = queryProlog.getPlayerPosition("a");
		Point player2Indices = queryProlog.getPlayerPosition("b");
		
		int p1_x = (int)(player1Indices.getX()-1)*70 + 48;
		int p1_y = (int)(player1Indices.getY()-1)*70 + 48;
		player1_label = new JLabel();
		player1_label.setBounds(p1_x,p1_y,16,16);
		player1_label.setOpaque(true);
		player1_label.setBackground(Color.RED);
		this.add(player1_label, new Integer(2),0);
		
		int p2_x = (int)(player2Indices.getX()-1)*70 + 48;
		int p2_y = (int)(player2Indices.getY()-1)*70 + 48;
		player2_label = new JLabel();
		player2_label.setBounds(p2_x,p2_y,16,16);
		player2_label.setOpaque(true);
		player2_label.setBackground(Color.GREEN);
		this.add(player2_label, new Integer(2),0);

		ArrayList<String> list = queryProlog.getTreasureList("a");
		System.out.println(list);
		Logger.info(list);
		list = queryProlog.getTreasureList("b");
		System.out.println(list);
		Logger.info(list);
	}

	/**
	 * Creates the buttons for shifting the rows and columns
	 */
	private void createButtons() {
		buttons = new ArrayList<JButton>();

		//create top row
		for(int i=0; i<3; i++){
			JButton button = new JButton();
			button.setBounds(140*i +114, 5, 20, 10);
			button.addActionListener(new ShiftAction());
			button.putClientProperty("pos", new Point(0,i*2 +1));
			this.add(button);
			buttons.add(button);
		}
		//create bottom row
		for(int i=0; i<3; i++){
			JButton button = new JButton();
			button.setBounds(140*i +114, 515, 20, 10);
			button.addActionListener(new ShiftAction());
			button.putClientProperty("pos", new Point(2,i*2 +1));
			this.add(button);
			buttons.add(button);
		}
		
		for(int j=0;j<3;j++){
			JButton button = new JButton();
			button.setBounds(5 , 114+140*j, 10, 20);
			button.addActionListener(new ShiftAction());
			button.putClientProperty("pos", new Point(j*2 + 1, 0));
			this.add(button);
			buttons.add(button);
		}
		for(int j=0;j<3;j++){
			JButton button = new JButton();
			button.setBounds(515 , 114+140*j, 10, 20);
			button.addActionListener(new ShiftAction());
			button.putClientProperty("pos", new Point(j*2 + 1, 2));
			this.add(button);
			buttons.add(button);
		}
	}
	/**
	 * Sets up the board from and array list of board strings
	 * @param boardStrings
	 */
	private void setupBoardFromString(ArrayList<String> boardStrings) {
				
		createMaps();
		
		boardPanel = new JPanel();		
		boardPanel.setPreferredSize(new Dimension(470, 470));
		boardPanel.setBounds(20, 20, 490, 490);
		boardPanel.setBorder(BorderFactory.createDashedBorder(Color.black));
		boardPanel.setLayout(new GridLayout(7,7,4,4));
		
		pieceImages = new ArrayList<BufferedImage>();
		
		try {
			loadImages(pieceImages);
		} catch (IOException e) {
			//System.out.println("Could not find images");
			Logger.info("Could not find images");
			e.printStackTrace();
		}
		pieces = new ArrayList<MazePiece>();
		int index=0;
		for( String boardString : boardStrings){
			
			int type = pieceTypeMap.get(Integer.valueOf(boardString));
			int rotation = pieceRotMap.get(Integer.valueOf(boardString));
			int i = index / 7;
			int j = index%7;
			
			Point pos = new Point(i,j);
			MazePiece piece = new MazePiece(pieceImages.get(type),rotation,pos);
			piece.putClientProperty("pos", pos);
			piece.putClientProperty("rot", new Integer(rotation));
			piece.putClientProperty("type", new Integer(type));
			piece.addActionListener(new ClickAction());
			
			boardPanel.add(piece);
			pieces.add(piece);
			index++;
		}
		this.add(boardPanel);
		addTreasures(this);
		
		//System.out.println("Board created");
		Logger.info("Board created");
		
	}
	/**
	 * Adds the treasure pieces to the gameboard
	 * @param gameBoard
	 */
	private void addTreasures(GameBoard gameBoard) {
		
		treasureImages = new ArrayList<BufferedImage>();
		try {
			loadTreasures(treasureImages);
		} catch (IOException e) {
			//System.out.println("Could not find treasure images");
			Logger.info("Could not find treasure images");
			e.printStackTrace();
		}
		
		Point[] locations = new Point[12];
		
		for(int j = 0;j<2;j++){
			locations[j] = new Point(140 + 140*j + 40,40);
		}
		for(int i = 0;i<2;i++){
			for(int j=0;j<4;j++){
				locations[i*4 + j + 2] = new Point(140*j+40,180 +140*i);
			}
		}
		for(int j = 0;j<2;j++){
			locations[j+10] = new Point(140 + 140*j + 40,420+40);
		}
		
		for(int i=0; i< treasureImages.size();i++){
			ImageIcon icon = new ImageIcon( treasureImages.get(i));
			
			JLabel label = new JLabel(icon );
			Point point = locations[i];
			label.setBounds(point.x, point.y,icon.getIconWidth(), icon.getIconHeight());
			this.add(label,new Integer(2),0);
		}
	}
	/** 
	 * Sets up the treasure panel from the list of treasures in Prolog
	 * Also checks to see if the treasure indices have changes in order to refresh the board
	 * @return
	 */
	public JPanel setupTreasurePanel(){
		
		Point pos  = queryProlog.getTreasurePositions();
		//System.out.println(pos.x + " " + pos.y);
		Logger.info(pos.x + " " + pos.y);
		if(treasurePanel == null){
			System.out.println("null");
			Logger.info("null");
			treasurePanel = new JPanel();
		}else{
			if(pos.x == oldX && pos.y == oldY) return null;
			treasurePanel.removeAll();
			treasurePanel.validate();
			oldX = pos.x;
			oldY = pos.y;
		}
		
		treasurePanel.setLayout(new BoxLayout(treasurePanel, BoxLayout.Y_AXIS));
		treasurePanel.setBorder(BorderFactory.createTitledBorder("Treasures"));
		JPanel player1TreasurePanel = new JPanel();
		player1TreasurePanel.setLayout(new BoxLayout(player1TreasurePanel, BoxLayout.X_AXIS));
		JPanel player2TreasurePanel = new JPanel();
		player2TreasurePanel.setLayout(new BoxLayout(player2TreasurePanel, BoxLayout.X_AXIS));
		ArrayList<String> prologTreasureList = queryProlog.getTreasureList("a");
		String[] treasureList = {"sword", "ring", "map", "keys", "helmet", "gold",
				 "fairy", "gem", "chest", "candle", "book", "crown"};
		
		// This is quite inefficient but treasure list is small so it's OK
		int counter = 1;
		for(String treasure : prologTreasureList){
			for(int i=0; i<treasureList.length; i++){
				//System.out.println(treasure + " " + treasureList[i] );
				if(treasureList[i].compareTo(treasure)==0){
					//System.out.println("adding " + treasure);
					Logger.info("adding " + treasure);
					ImageIcon icon = new ImageIcon(treasureImages.get(i));
					JLabel label = new JLabel(icon);
					label.setOpaque(true);
					label.setBorder(BorderFactory.createLineBorder(Color.red));
					label.setBackground(Color.GRAY);
					if(counter == (int)pos.getX()){
						label.setBackground(Color.WHITE);
					}
					player1TreasurePanel.add(label);
					counter++;
				}
			}
		}
		counter = 1; 
		prologTreasureList.clear();
		prologTreasureList = queryProlog.getTreasureList("b");
		for(String treasure : prologTreasureList){
			for(int i=0; i<treasureList.length; i++){
				//System.out.println(treasure + " " + treasureList[i] );
				if(treasureList[i].compareTo(treasure)==0){
					//System.out.println("adding " + treasure);
					Logger.info("adding " + treasure);
					ImageIcon icon = new ImageIcon(treasureImages.get(i));
					JLabel label = new JLabel(icon);
					label.setOpaque(true);
					label.setBorder(BorderFactory.createLineBorder(Color.green));
					label.setBackground(Color.GRAY);
					if(counter == pos.getY()){
						label.setBackground(Color.WHITE);
					}
					player2TreasurePanel.add(label);
					counter ++;
				}
			}
		}
		treasurePanel.add(Box.createVerticalStrut(20));
		treasurePanel.add(player1TreasurePanel);
		treasurePanel.add(Box.createVerticalStrut(20));
		treasurePanel.add(player2TreasurePanel);
		
		EventQueue.invokeLater(new Runnable() {
		    @Override
		    public void run() {
		    	treasurePanel.revalidate();
				treasurePanel.repaint();
		    }
		  });
			
		return treasurePanel;
	}

	/**
	 * Recreates the board from and array list of strings
	 * @param boardStrings
	 */
	public void recreateBoardFromString(ArrayList<String> boardStrings){
		
		boardPanel.removeAll();
		pieces.clear();
		
		int index = 0;
		for( String boardString : boardStrings){
			
			int type = pieceTypeMap.get(Integer.valueOf(boardString));
			int rotation = pieceRotMap.get(Integer.valueOf(boardString));
			int i = index / 7;
			int j = index%7;
			
			Point pos = new Point(i,j);
			MazePiece piece = new MazePiece(pieceImages.get(type),rotation,pos);
			piece.putClientProperty("pos", pos);
			piece.putClientProperty("rot", new Integer(rotation));
			piece.putClientProperty("type", new Integer(type));
			piece.addActionListener(new ClickAction());
			
			boardPanel.add(piece);
			pieces.add(piece);
			index++;
		}
		boardPanel.validate();
		
		//System.out.println("Board recreated");
		Logger.info("Board recreated");
	}
	/**
	 * create hash maps defining the types of pieces and orientations of each piece
	 */
	private void createMaps() {
		
		pieceTypeMap = new HashMap<Integer,Integer>();
		pieceRotMap  = new HashMap<Integer,Integer>();
		// This hashmap defines the type of each piece in order to retrieve the appropriate pieces from 
		// the list of strings given by prolog.
		// Types for Straight pieces
		pieceTypeMap.put(101,0);
		pieceTypeMap.put(1010,0);
		// Types for Corner pieces
		pieceTypeMap.put(1100,1);
		pieceTypeMap.put(110,1);
		pieceTypeMap.put(11,1);
		pieceTypeMap.put(1001,1);
		// Types for Junction pieces
		pieceTypeMap.put(1110,2);
		pieceTypeMap.put(111,2);
		pieceTypeMap.put(1011,2);
		pieceTypeMap.put(1101,2);
		
		// This Hashmap defines the rotation of a given piece based on the piece type
		// Rotations for Straight pieces
		pieceRotMap.put(101,0);
		pieceRotMap.put(1010,90);
		// Rotations for Corner pieces
		pieceRotMap.put(1001,0);
		pieceRotMap.put(1100,90);
		pieceRotMap.put(110,180);
		pieceRotMap.put(11,270);
		// Rotations for Junction pieces
		pieceRotMap.put(1101,0);
		pieceRotMap.put(1110,90);
		pieceRotMap.put(111,180);
		pieceRotMap.put(1011,270);
	}
	/**
	 * Moves column up
	 * @param j
	 */
	private void moveColumnUp(int j) {
		ArrayList<String> newBoard = queryProlog.requestShiftUp(j+1);
		recreateBoardFromString(newBoard);
	}

	/**
	 * Moves column down
	 * @param j
	 */
	private void moveColumnDown(int j) {
		ArrayList<String> newBoard = queryProlog.requestShiftDown(j+1);
		recreateBoardFromString(newBoard);
	}
	/**
	 * Moves row left
	 * @param i
	 */
	private void moveRowLeft(int i){
		ArrayList<String> newBoard = queryProlog.requestShiftLeft(i+1);
		recreateBoardFromString(newBoard);
	}
	/**
	 * Moves row right
	 * @param i
	 */
	private void moveRowRight(int i){
		ArrayList<String> newBoard = queryProlog.requestShiftRight(i+1);
		recreateBoardFromString(newBoard);
	}
	/**
	 * Used for loading the images of the maze pieces 
	 * @param images2
	 * @throws IOException
	 */
	private void loadImages(ArrayList<BufferedImage> images2) throws IOException{
		BufferedImage straight = ImageIO.read(new File("art/maze_piece_1.png"));
    	BufferedImage corner = ImageIO.read(new File("art/maze_piece_2.png"));
    	BufferedImage junction = ImageIO.read(new File("art/maze_piece_3.png"));
    	
    	images2.add(straight);
    	images2.add(corner);
    	images2.add(junction);
	}
	/**
	 * Used for loading the images of the treasures
	 * @param treasureImages
	 * @throws IOException
	 */
	private void loadTreasures(ArrayList<BufferedImage> treasureImages) throws IOException{
		String[] treasureList = {"Sword", "Ring", "Map", "Keys", "Helmet", "Gold",
								 "Fairy", "Diamond", "Chest", "Candle", "Book", "Crown"}; 
		
		for( String treasure : treasureList){
			treasureImages.add(ImageIO.read(new File("art/" + treasure + "32.png")));
		}
	}
	/**
	 * Creates icons for images
	 * @param path
	 * @return
	 */
    protected static ImageIcon createImageIcon(String path) {
        ImageIcon icon = new ImageIcon(path);
        
        return icon;
    }
    /**
     * update the player positions
     */
	public void updatePlayerPositons(){
		Point player1Indices = queryProlog.getPlayerPosition("a");

		int p1_x = (int)(player1Indices.getX()-1)*70 + 48;
		int p1_y = (int)(player1Indices.getY()-1)*70 + 48;
		player1_label.setBounds(p1_x,p1_y,16,16);
		
		Point player2Indices = queryProlog.getPlayerPosition("b");

		int p2_x = (int)(player2Indices.getX()-1)*70 + 48;
		int p2_y = (int)(player2Indices.getY()-1)*70 + 48;
		player2_label.setBounds(p2_x,p2_y,16,16);
		
	}
	/**
	 * Private class which is used to register clicks on the buttons
	 * @author Edward
	 *
	 */
	private class ShiftAction extends AbstractAction{
		
		@Override
		public void actionPerformed(ActionEvent e) {
			checkButtons(e);
		}
		private void checkButtons(ActionEvent e){
			
			for(JButton button : buttons){
				if((JButton)e.getSource()==button){
					
					JButton b = (JButton)e.getSource();
					Point p = (Point)b.getClientProperty("pos");
					if((int)p.getY()%2==1 && (int)p.getX()==0)	moveColumnUp((int)p.getY());
					if((int)p.getY()%2==1 && (int)p.getX()==2)	moveColumnDown((int)p.getY());
					if((int)p.getX()%2==1 && (int)p.getY()==0)	moveRowLeft((int)p.getX());
					if((int)p.getX()%2==1 && (int)p.getY()==2)	moveRowRight((int)p.getX());
					updatePlayerPositons();
				}
			}
		}
	}
	/**
	 * private class to register the clicks on pieces to move the player around the maze
	 * @author Edward
	 *
	 */
	private class ClickAction extends AbstractAction{

		@Override
		public void actionPerformed(ActionEvent e) {
			checkPieces(e);
		}
		private void checkPieces(ActionEvent e){
			for(MazePiece piece  : pieces){
				if((MazePiece)e.getSource() == piece){
					Point point = (Point) ((MazePiece)e.getSource()).getClientProperty("pos");
					System.out.print((point.getX()+1) + " " + (point.getY()+1)+ " ");
					Logger.info((point.getX()+1) + " " + (point.getY()+1)+ " ");
					String player = queryProlog.getCurrentPlayer();
					boolean canMove = queryProlog.canMove(player,(int)point.getX()+1, (int)point.getY() +1);
					System.out.println(canMove? "Can move": "Can't move");
					Logger.info(canMove? "Can move": "Can't move");
					if(canMove){
						
						queryProlog.tryAndMove(player,(int)point.getX()+1, (int)point.getY() +1);
						updatePlayerPositons();
						swapCurrentPlayer();
					}
				}
			}
		}
	}
	/**
	 * Swap the current player and update the player text from red-> green of visa versa
	 */
	public void swapCurrentPlayer() {
		if(currentPlayer == player1){
			//System.out.println("Swapping");
			Logger.info("Swapping");
			currentPlayer = player2;
			EventQueue.invokeLater(new Runnable() {
			    @Override
			    public void run() {
			    	//turnLabel.setText("Green players turn");
			    	//turnLabel.setForeground (Color.green);
			    	turnLabel.setText("<html><font color='green'>Green</font> players turn. </html>");
			    }
			  });
		}else{
			currentPlayer = player1;
			EventQueue.invokeLater(new Runnable() {
			    @Override
			    public void run() {
			    	//turnLabel.setText("Red players turn");
			    	//turnLabel.setForeground (Color.red);
			    	turnLabel.setText("<html><font color='red'>Red</font> players turn. </html>");
			    }
			  });
		}	
	}
	/**
	 * set up the player info panels
	 * @param turnLabel
	 * @param timeLabel
	 * @param player1InfoLabel
	 * @param player2InfoLabel
	 */
	public void setInfoPanels(JLabel turnLabel, JLabel timeLabel, JLabel player1InfoLabel, JLabel player2InfoLabel) {
		this.turnLabel = turnLabel;
		this.timeLabel = timeLabel;
		this.player1InfoLabel = player1InfoLabel;
		this.player2InfoLabel = player2InfoLabel;
	}	
}
