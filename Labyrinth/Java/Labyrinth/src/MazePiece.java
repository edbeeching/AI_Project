import java.awt.Color;
import java.awt.Image;
import java.awt.Point;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;

import javax.swing.BorderFactory;
import javax.swing.ImageIcon;
import javax.swing.JButton;
/**
 * The maze pieces class
 * @author Edward Beeching
 *
 */
public class MazePiece extends JButton {
	
	int rotation;
	Point pos;
	
	public MazePiece(){
		super();
		initButton();
	}
	public MazePiece(Image image){
		super(new ImageIcon(image));
		initButton();
	}
	public MazePiece(Image image,int rotation, Point pos){
		
		super(new RotatedIcon(new ImageIcon(image),(float)rotation));
		this.rotation = rotation;
		this.pos = pos;
		this.setToolTipText("Position: "+ ((int)pos.getX()+1) + ", " + ((int)pos.getY()+1));
		initButton();
	}
	private void initButton() {

		setBorder(BorderFactory.createLineBorder(Color.gray));
		
		addMouseListener(new MouseAdapter(){
			
			@Override
			public void mouseEntered(MouseEvent e){
				setBorder(BorderFactory.createLineBorder(Color.red));
			}
			@Override 
			public void mouseExited(MouseEvent e){
				setBorder(BorderFactory.createLineBorder(Color.gray));
			}
		});
		
	}

}
