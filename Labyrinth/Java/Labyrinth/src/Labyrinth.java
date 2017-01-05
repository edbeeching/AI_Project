import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseEvent;
import java.awt.event.MouseMotionListener;

import javax.swing.BorderFactory;
import javax.swing.BoxLayout;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JLayeredPane;
import javax.swing.JPanel;
import javax.swing.SwingUtilities;
/**
 * Class defining the Labyrinth Game Frame 
 * @author Edward Beeching
 *
 */

public class Labyrinth extends JPanel implements ActionListener, MouseMotionListener{


	private static final long serialVersionUID = 1L;
	private JFrame frame;
	private JLayeredPane gamePanel;
	private GameBoard gameBoard;
	/**
	 * Constructor for Class
	 * Calls initialize to initialize the game
	 * 
	 */
	public Labyrinth() {
		initialize();
	}
	/**
	 * Sets up the Java swing frame
	 * Gets user setup parameters with a Dialog pop-up
	 * sets up the Game board and control, info & debug panels
	 */
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
		

		controlPanel.setLayout(new GridLayout(4, 1));
		frame.getContentPane().add(controlPanel, BorderLayout.EAST);	

		JPanel infoPanel = new JPanel();
		infoPanel.setBorder(BorderFactory.createTitledBorder("Info"));
		
		infoPanel.setLayout(new BoxLayout(infoPanel, BoxLayout.Y_AXIS));
		JLabel turnLabel = new JLabel("<html><font color='red'>Red</font> players turn. </html>");
		JLabel timeLabel = new JLabel("Search time in ms: 1 ");
		JLabel player1InfoLabel = new JLabel("Player 1 has won 0 times");
		JLabel player2InfoLabel = new JLabel("Player 2 has won 0 times");
		gameBoard.setInfoPanels(turnLabel,timeLabel,player1InfoLabel,player2InfoLabel);
		
		infoPanel.add(turnLabel);
		infoPanel.add(timeLabel);
		infoPanel.add(player1InfoLabel);
		infoPanel.add(player2InfoLabel);
		JPanel treasurePanel = gameBoard.setupTreasurePanel();
		
		
		JPanel debugPanel = new JPanel();
		debugPanel.setLayout(new BoxLayout(debugPanel, BoxLayout.X_AXIS));
		debugPanel.setBorder(BorderFactory.createTitledBorder("Debug"));
		
		controlPanel.add(infoPanel);
		controlPanel.add(treasurePanel);
		controlPanel.add(debugPanel);
    }
    /**
     *  invokes the jframe 
     * @param args no args required
     */
	public static void main(String[] args) {
    	//EventQueue.invokeLater(new Runnable() {
		SwingUtilities.invokeLater(new Runnable() {
			public void run() {
				try {
					Labyrinth labyrinth = new Labyrinth();
					labyrinth.frame.setVisible(true);
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
