import java.awt.Container;
import java.awt.Frame;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.ItemEvent;
import java.awt.event.ItemListener;

import javax.swing.BorderFactory;
import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JDialog;
import javax.swing.JLabel;
import javax.swing.JPanel;
// some code taken taken from http://zetcode.com/tutorials/javaswingtutorial/swingdialogs/
public class GameInfoDialog extends JDialog implements ItemListener{

	private GameInfo gameInfo;
	private String[] heuristicOptions;
	private String[] timeOptions;
	private String[] gameOptions;
	private JComboBox<String> player1OptionsBox;
	private JComboBox<String> player2OptionsBox;
	private JComboBox<String> timeBox;
	private JComboBox<String> gameBox;
	public GameInfoDialog(Frame parent, GameInfo gameInfo){
		super(parent);
		
		init(gameInfo);
	}
	private void init(GameInfo gameInfo){
		
		
		this.gameInfo = gameInfo;
		
		
		JLabel name = new JLabel("Game setup");
		this.setBounds(100, 100, 400, 400);
		
		
		JPanel player1Panel = new JPanel();
		player1Panel.setBorder(BorderFactory.createTitledBorder("Player 1"));
		JPanel player2Panel = new JPanel();
		player2Panel.setBorder(BorderFactory.createTitledBorder("Player 2"));
		JPanel optionsPanel = new JPanel();
		optionsPanel.setBorder(BorderFactory.createTitledBorder("Option"));
		
		heuristicOptions = new String[]{"Human","Heuristic 1", "Heuristic 2", "Heuristic 3", "Heuristic 4","Heuristic 5"};
		player1OptionsBox = new JComboBox<>(heuristicOptions);
		player1OptionsBox.addItemListener(this);
		player2OptionsBox = new JComboBox<>(heuristicOptions);
		player2OptionsBox.addItemListener(this);
		
		
		player1Panel.add(player1OptionsBox);
		player2Panel.add(player2OptionsBox);
		JButton button = new JButton("Create game!");
		
		button.addActionListener(new ActionListener() {	
			@Override
			public void actionPerformed(ActionEvent e) {
				dispose();
			}
		});
		
		
		
		
		gameOptions = new String[]{"1","5","10","50","100"};
		gameBox = new JComboBox<>(gameOptions);
		gameBox.addItemListener(this);
		
		timeOptions = new String[]{"100 ms","200 ms","500 ms","1000 ms","1 ms" };
		timeBox = new JComboBox<>(timeOptions);
		timeBox.addItemListener(this);
		
		
		optionsPanel.add(button);
		optionsPanel.add(gameBox);
		optionsPanel.add(timeBox);
		
		Container panel = getContentPane();
		BoxLayout boxLayout =  new BoxLayout(panel, BoxLayout.Y_AXIS);
		panel.setLayout(boxLayout);
		panel.add(player1Panel);
		panel.add(player2Panel);
		panel.add(optionsPanel);
		setModalityType(ModalityType.APPLICATION_MODAL);
		setDefaultCloseOperation(DISPOSE_ON_CLOSE);
		setLocationRelativeTo(getParent());
	}
	@Override
	public void itemStateChanged(ItemEvent e) {
		if(e.getSource()==player1OptionsBox){
			int i = player1OptionsBox.getSelectedIndex();
			switch(i){
				case 0:
					gameInfo.player1Heuristic = "h0";
					break;
				case 1:
					gameInfo.player1Heuristic = "h1";
					break;
				case 2:
					gameInfo.player1Heuristic = "h2";
					break;
				case 3:
					gameInfo.player1Heuristic = "h3";
					break;
				case 4:
					gameInfo.player1Heuristic = "h4";
					break;		
				case 5:
					gameInfo.player1Heuristic = "h5";
					break;	
			}
			System.out.println("combox box 1 toggled" + i);
		}
		if(e.getSource()==player2OptionsBox){
			int i = player2OptionsBox.getSelectedIndex();
			switch(i){
				case 0:
					gameInfo.player2Heuristic = "h0";
					break;
				case 1:
					gameInfo.player2Heuristic = "h1";
					break;
				case 2:
					gameInfo.player2Heuristic = "h2";
					break;
				case 3:
					gameInfo.player2Heuristic = "h3";
					break;
				case 4:
					gameInfo.player2Heuristic = "h4";
					break;	
				case 5:
					gameInfo.player2Heuristic = "h5";
					break;	
			}
			System.out.println("combox box 2 toggled"+ i);
		}

		if(e.getSource()==timeBox){
			int i = timeBox.getSelectedIndex();
			switch(i){
				case 0:
					gameInfo.actionDelay = 100;
					break;
				case 1:
					gameInfo.actionDelay = 200;
					break;
				case 2:
					gameInfo.actionDelay = 500;
					break;
				case 3:
					gameInfo.actionDelay = 1000;
					break;
				case 4:
					gameInfo.actionDelay = 1;
					break;
			}
		}
		if(e.getSource()==gameBox){
			int i = gameBox.getSelectedIndex();
			switch(i){
				case 0:
					gameInfo.totalGames = 1;
					break;
				case 1:
					gameInfo.totalGames = 5;
					break;
				case 2:
					gameInfo.totalGames = 10;
					break;
				case 3:
					gameInfo.totalGames = 50;
					break;
				case 4:
					gameInfo.totalGames = 100;
					break;
			}
			System.out.println("num games"+ i);
		}
			
		
	}
}
