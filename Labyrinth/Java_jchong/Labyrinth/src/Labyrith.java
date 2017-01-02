import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseEvent;
import java.awt.event.MouseMotionListener;

import javax.swing.BorderFactory;
import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLayeredPane;
import javax.swing.JPanel;
import javax.swing.SwingUtilities;


public class Labyrith extends JPanel implements ActionListener, MouseMotionListener{

	private JFrame frame;
	private JLayeredPane gamePanel;
	private GameBoard gameBoard;
	public Labyrith() {
		initialize();
	}
    private void initialize() {
    	System.out.println("Initialising");
    	frame = new JFrame();
		frame.setBounds(100, 100, 800, 610);
		frame.setResizable(false);
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setLayout(new BoxLayout(this, BoxLayout.PAGE_AXIS));
		
		GameInfo gameInfo = new GameInfo();
		
		GameInfoDialog dialog = new GameInfoDialog(frame, gameInfo);
		dialog.setVisible(true);

		gamePanel = new JLayeredPane();
		gamePanel.setPreferredSize(new Dimension(580,600));
		gamePanel.setBorder(BorderFactory.createTitledBorder("Game Panel"));
		gamePanel.addMouseMotionListener(this);
		frame.getContentPane().add(gamePanel, BorderLayout.WEST);
		
		gameBoard = new GameBoard(frame,gameInfo);
		gamePanel.add(gameBoard);
		
		JPanel controlPanel = new JPanel();
		controlPanel.setPreferredSize(new Dimension(200,600));
		controlPanel.setBorder(BorderFactory.createTitledBorder("Control Panel"));
		
		//BoxLayout boxLayout =  new BoxLayout(controlPanel,BoxLayout.Y_AXIS);
		//controlPanel.setLayout(new BoxLayout(controlPanel,BoxLayout.Y_AXIS));
		controlPanel.setLayout(new GridLayout(4, 1));
		frame.getContentPane().add(controlPanel, BorderLayout.EAST);	
		
//		JButton button = new JButton();
//		button.setBounds(10,10,40,40);
//		button.setText("Generate Maze!");
//		button.addActionListener(new ActionListener() {
//			
//			@Override
//			public void actionPerformed(ActionEvent e) {
//				generateMaze();
//				
//			}
//		});
//		controlPanel.add(button);
		
		
		JPanel infoPanel = new JPanel();
		infoPanel.setBorder(BorderFactory.createTitledBorder("Info"));
		infoPanel.setLayout(new BoxLayout(infoPanel, BoxLayout.X_AXIS));
		JPanel treasurePanel = gameBoard.setupTreasurePanel();
		
		
		JPanel debugPanel = new JPanel();
		debugPanel.setLayout(new BoxLayout(debugPanel, BoxLayout.X_AXIS));
		debugPanel.setBorder(BorderFactory.createTitledBorder("Debug"));
		
		controlPanel.add(infoPanel);
		controlPanel.add(treasurePanel);
		controlPanel.add(debugPanel);
    }
    private void generateMaze(){
    	System.out.print("[");
    	for(int j =0;j<7;j++){
    		System.out.print("[");
    		for(int i=0;i<7;i++){
    			if(i!=6){
    				System.out.print(""+getString(gameBoard.pieces.get(j*7 + i))+",");
    			}else{
    				System.out.print(""+getString(gameBoard.pieces.get(j*7 + i)));
    			}
    		}
    		if(j!=6){
    			System.out.println("],");
    		}else{
    			System.out.println("]");
    		}
    		
    		
    	}
    	System.out.println("]");    	
    }
    private String getString(MazePiece mazePiece) {
    	
    	if((Integer)mazePiece.getClientProperty("type")==0){
    		//The piece is a straight piece
    		int rotation = (Integer)mazePiece.getClientProperty("rot");
    		String s = new String();
    		if(rotation == 90 || rotation == 270)  s = "1010";
    		if(rotation ==  0 || rotation == 180)  s = "0101";
    		return s;
    	}else if((Integer)mazePiece.getClientProperty("type")==1){
    		//The piece is a corner
    		int rotation = (Integer)mazePiece.getClientProperty("rot");
    		String s = new String();
    		if(rotation ==   0) s = "1001";
    		if(rotation ==  90) s = "1100";
    		if(rotation == 180) s = "0110";
    		if(rotation == 270) s = "0011";
    		
    		return s;
    	}else{
    		//its a junction
    		int rotation = (Integer)mazePiece.getClientProperty("rot");
    		String s = new String();
    		if(rotation ==   0) s = "1101";
    		if(rotation ==  90) s = "1011";
    		if(rotation == 180) s = "0111";
    		if(rotation == 270) s = "1110";
    		return s;
    	}
	}
	public static void main(String[] args) {
    	//EventQueue.invokeLater(new Runnable() {
		SwingUtilities.invokeLater(new Runnable() {
			public void run() {
				try {
					Labyrith demo = new Labyrith();
					demo.frame.setVisible(true);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		});
    }
	@Override
	public void mouseDragged(MouseEvent arg0) {
		
	}

	@Override
	public void mouseMoved(MouseEvent arg0) {

	}

	@Override
	public void actionPerformed(ActionEvent arg0) {
		
	}
}
