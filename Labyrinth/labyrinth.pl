
% 	Predicates for setting up the board

% 	Pieces are defined by the connections they can make. 1000 would be a 
% 	piece that connects above, 1010 would be above and below.
%	there are 3 different pieces on the board which can be rotated 90 degrees
%	to 4 different orientations
%	 ____________	
%	|			 |		
%	|	 ________|
%	|	|		 		This is a "corner" piece with connections at the  
%	|	|     ___		right and the bottom and is represented as 0110
%	|	|	 |	 |		
%	|___|    |___|
%	
%    ___      ___	
%	|	|    |	 |		This is a "straight" piece with connections at the top
%	|	|	 |	 |		and the bottom and is represented as 1010.
%	|	|	 |	 |
%	|	|	 |	 |
%	|	|	 |	 |
%	|___|    |___|
%
%	 ___      ___	
%	|	|    |   |	
%	|	|    |___|
%	|	|		 		The is "junction" piece with connections at the top,    
%	|	|     ___		right and the bottom and is represented as 1110
%	|	|	 |	 |		
%	|___|    |___|
%
%
% Create Pieces, at the start some locations at predefined as follows:
%
%[[ 0110 ,     , 0111 ,     , 0111 ,     , 0011 ],
% [      ,     ,      ,     ,      ,     ,      ],
% [ 1011 ,     , 1011 ,     , 0111 ,     , 1110 ],
% [      ,     ,      ,     ,      ,     ,      ],
% [ 1011 ,     , 1101 ,     , 1110 ,     , 1110 ],
% [      ,     ,      ,     ,      ,     ,      ],
% [ 1100 ,     , 1101 ,     , 1101 ,     , 1001 ]]
%

% Row 1 , Columns 1, 3, 5 & 7
create_piece(1, 1, Piece) :- Piece is 0110 .
create_piece(1, 3, Piece) :- Piece is 0111 .
create_piece(1, 5, Piece) :- Piece is 0111 .
create_piece(1, 7, Piece) :- Piece is 0011 .
% Row 3 , Columns 1, 3, 5 & 7
create_piece(3, 1, Piece) :- Piece is 1011 .
create_piece(3, 3, Piece) :- Piece is 1011 .
create_piece(3, 5, Piece) :- Piece is 0111 .
create_piece(3, 7, Piece) :- Piece is 1110 .
% Row 5 , Columns 1, 3, 5 & 7
create_piece(5, 1, Piece) :- Piece is 1011.
create_piece(5, 3, Piece) :- Piece is 1101.
create_piece(5, 5, Piece) :- Piece is 1110.
create_piece(5, 7, Piece) :- Piece is 1110.
% Row 7 , Columns 1, 3, 5 & 7
create_piece(7, 1, Piece) :- Piece is 1100.
create_piece(7, 3, Piece) :- Piece is 1101.
create_piece(7, 5, Piece) :- Piece is 1101.
create_piece(7, 7, Piece) :- Piece is 1001.

% Rows 2 ,4 & 6. and Columns 2, 4 & 6 have thier pieces generated randomly
% there is a 15 / 33 chance to be a corner piece, 12/33 to be straight and 
% 6/33 to be a junction.
create_piece(Row, Column, Piece):- 
	random_between(0,32,X),( 
	(X < 15, create_corner(Piece));
	(X =< 15, X < 27, create_straight(Piece));
	(X > 26,  create_junction(Piece))).
	
% Creation of 4 corner pieces, there is a more clever way to do this in one
% predicate using 1111 - 10 ^ rand (0,1,2,3), but i couldn't get it working
create_corner(Piece):- random_between(1,4, C), 
			((C = 1, Piece is 0011);
			(C = 2, Piece is 0110);
			(C = 3, Piece is 1100);
			(C = 4, Piece is 1001)).
% Subtract powers of 10 to make 1010 or 0101
create_straight(Piece):- random_between(0,1,P),
			P2 is P + 2, Piece is ((1111 - 10**P)-10**P2).
% Create junction piece, simply subtrace a power of 10.
create_junction(Piece):- random_between(0,3,P), Piece is (1111 - 10**P).

% Some useful helper Predicates
% Reverse List
% reverse_list(List,Reverse)

reverse_list(List,Reverse):- reverse_list(List,[],Reverse).
reverse_list([],Final,Final).

reverse_list([Head|Tail],Acc,Final):-reverse_list(Tail,[Head|Acc],Final).

% Creation of a row of elements
create_row(Row,RowList):- create_pieces(Row,8,1,[],Backward),reverse_list(Backward,RowList).

create_pieces(Row, Total, Col, Acc, Acc):- Col = Total,!.
create_pieces(Row, Total, Col, Acc,Final):- 
		create_piece(Row, Col,Piece),
		C2 is Col + 1,!,
		create_pieces(Row,Total,C2,[Piece|Acc],Final).

% Creating the gameBoard, this is a 7x7 board.

create_board(Board) :- create_board(0,[],Backward),reverse_list(Backward,Board).

create_board(7,Board,Board):- ! .
create_board(Row,Acc,Board):-
	R1 is Row + 1 ,
	create_row(R1,List),
	create_board(R1,[List|Acc],Board).
	
% Now that the Game Board has been created comes to hard part, we need to:
% 1. Search the board for the best move
% 2. Change the board by moving the pieces.
	
	
	
	
	
	