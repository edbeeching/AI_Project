import java.awt.Color;
import java.awt.Dimension;
import java.awt.GridLayout;
import java.awt.Point;
import java.awt.event.ActionEvent;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import javax.imageio.ImageIO;
import javax.swing.AbstractAction;
import javax.swing.BorderFactory;
import javax.swing.Icon;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JLayeredPane;
import javax.swing.JPanel;

public class GameBoard extends JLayeredPane {

	private ArrayList<BufferedImage> pieceImages;
	private ArrayList<BufferedImage> treasureImages;
	public ArrayList<MazePiece> pieces;
	public JLabel player1_label;
	public JLabel player2_label;
	private Player player1;
	private Player player2;
	
	
	private JFrame frame;
	private JPanel boardPanel;
	private ArrayList<JButton> buttons;
	private Map<Integer,Integer> pieceTypeMap;
	private Map<Integer,Integer> pieceRotMap;
	private QueryProlog queryProlog;
	
	private JLabel crownLabel;
	
	
	public GameBoard(JFrame frame, GameInfo gameInfo){
		super();
		queryProlog = new QueryProlog(gameInfo);
		ArrayList<String> boardStrings = queryProlog.getBoard();
		initialise(boardStrings);
		

		
		this.frame = frame;
		
	}

	private void initialise(ArrayList<String> boardStrings) {
		this.setBounds(20, 20, 530, 530);
		this.setBorder(BorderFactory.createDashedBorder(Color.red));
		
		createButtons();
		if(boardStrings == null){
			System.out.println("Prolog has not provided a board string");
		}else{
			setupBoardFromString(boardStrings);
		}
		player1 = new HumanPlayer(true,0);
		player2 = new HumanPlayer(true,0);
		Point player1Indices = queryProlog.getPlayerPosition("a");
		Point player2Indices = queryProlog.getPlayerPosition("b");
		
		//createMaps();
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
		list = queryProlog.getTreasureList("b");
		System.out.println(list);
	}

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
			System.out.println("Could not find images");
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
		
		System.out.println("Board created");
		
	}
	private void addTreasures(GameBoard gameBoard) {
		
		treasureImages = new ArrayList<BufferedImage>();
		try {
			loadTreasures(treasureImages);
		} catch (IOException e) {
			System.out.println("Could not find treasure images");
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

	private void recreateBoardFromString(ArrayList<String> boardStrings){
		
		boardPanel.removeAll();
		pieces.clear();
		
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
		boardPanel.validate();
		
		System.out.println("Board recreated");
	}
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
	private void moveColumnUp(int j) {
		ArrayList<String> newBoard = queryProlog.requestShiftUp(j+1);
		recreateBoardFromString(newBoard);
	}
	private void moveColumnDown(int j) {
		ArrayList<String> newBoard = queryProlog.requestShiftDown(j+1);
		recreateBoardFromString(newBoard);
	}
	private void moveRowLeft(int i){
		ArrayList<String> newBoard = queryProlog.requestShiftLeft(i+1);
		recreateBoardFromString(newBoard);
	}
	private void moveRowRight(int i){
		ArrayList<String> newBoard = queryProlog.requestShiftRight(i+1);
		recreateBoardFromString(newBoard);
	}

	private void loadImages(ArrayList<BufferedImage> images2) throws IOException{
		BufferedImage straight = ImageIO.read(new File("art/maze_piece_1.png"));
    	BufferedImage corner = ImageIO.read(new File("art/maze_piece_2.png"));
    	BufferedImage junction = ImageIO.read(new File("art/maze_piece_3.png"));
    	
    	images2.add(straight);
    	images2.add(corner);
    	images2.add(junction);
	}
	private void loadTreasures(ArrayList<BufferedImage> treasureImages) throws IOException{
		String[] treasureList = {"Sword", "Ring", "Map", "Keys", "Helmet", "Gold",
								 "Fairy", "Diamond", "Chest", "Candle", "Book", "Crown"}; 
		
		for( String treasure : treasureList){
			treasureImages.add(ImageIO.read(new File("art/" + treasure + "32.png")));
		}
	}
    protected static ImageIcon createImageIcon(String path) {
        ImageIcon icon = new ImageIcon(path);
        
        return icon;
       
    }
	
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
	private class ClickAction extends AbstractAction{

		@Override
		public void actionPerformed(ActionEvent e) {
			// TODO Auto-generated method stub
			checkPieces(e);
			
		}
		private void checkPieces(ActionEvent e){
			for(MazePiece piece  : pieces){
				if((MazePiece)e.getSource() == piece){
					Point point = (Point) ((MazePiece)e.getSource()).getClientProperty("pos");
					System.out.print((point.getX()+1) + " " + (point.getY()+1)+ " ");
					boolean canMove = queryProlog.canMove("a",(int)point.getX()+1, (int)point.getY() +1);
					System.out.println(canMove? "Can move": "Can't move");
					if(canMove){
						queryProlog.tryAndMove("a",(int)point.getX()+1, (int)point.getY() +1);
//						Point player1Indices = queryProlog.getPlayerPosition("a");
//
//						int p1_x = (int)(player1Indices.getX()-1)*70 + 48;
//						int p1_y = (int)(player1Indices.getY()-1)*70 + 48;
//						player1_label.setBounds(p1_x,p1_y,16,16);
						updatePlayerPositons();
					}
				}
			}
		}
	}

}
