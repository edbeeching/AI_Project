
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
% The game is played with the following predicated

% setup(_) To set up the Game Board

% 

setup(_):- retractall(board(X)),!,create_board(X),  assert(board(X)),board(Y),write_board(Y).
setup(_):- create_board(X),  assert(board(X)),board(Y),write_board(Y).








% I understand that create_piece(1, 1, Piece) :- Piece is 0110 . is the same as
% create_piece(1, 1, 0110). However this is somewhat clearer for the moment.
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
create_piece(_Row, _Column, Piece):- 
	random_between(0,32,X),( 
	(X < 15, create_corner(Piece));
	(X >= 15, X < 27, create_straight(Piece));
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

% Some helper Predicates
% Reverse List
% reverse_list(List,Reverse)

reverse_list(List,Reverse):- reverse_list(List,[],Reverse).
reverse_list([],Final,Final).

reverse_list([Head|Tail],Acc,Final):-reverse_list(Tail,[Head|Acc],Final).

% Creation of a row of elements
create_row(Row,RowList):- create_pieces(Row,8,1,[],Backward),reverse_list(Backward,RowList).

create_pieces(_Row, Total, Col, Acc, Acc):- Col = Total,!.
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
% 2. Change the board by moving the rows / columns.

% Some more helper predicates are useful here.

% Write board write_board(Board)
write_board([]):- nl .
write_board([Head|Tail]):-
	print(Head),nl,write_board(Tail).


% Transpose matrix from session 3 is useful when shifting columns.

split_matrix([[Head|Tail]|Tail2],FirstCol,Rest):-
	split_matrix(Tail2,X,Y),
	append([Head],X,FirstCol),
	append([Tail],Y,Rest).
	
split_matrix([],[],[]).

transpose([[]|_], []).
transpose(Matrix, Output):-
	split_matrix(Matrix,Row1,Rest),
	transpose(Rest,X),
	append([Row1],X,Output).

% Checks for connections between two pieces.
	
pieces_connected_right(Left,Right) :- has_left_connection(Right),has_right_connection(Left).
pieces_connected_left(Right,Left) :- pieces_connected_right(Left,Right).

pieces_connected_up(Down,Up) :- has_up_connection(Down),has_down_connection(Up).
pieces_connected_down(Up,Down) :- pieces_connected_up(Down,Up).


has_left_connection(Piece) :-  X is mod(Piece,10), X = 1.
has_right_connection(Piece) :-  Piece > 0011, X is Piece // 100, 
								Y is mod(X,10), Y = 1.
has_up_connection(Piece) :- Piece > 0111 .
has_down_connection(Piece) :- 
			Piece > 1 , X is  Piece // 10, 
			Y is mod(X,10), Y = 1.


%get a particular piece at an index i,j			
%get_piece()
get_piece(Row,Col,Piece) :- board(Board), get_entry(Row,1,Board, List),get_entry(Col,1,List, Piece).
%get_piece(Row,Col,Board,Piece) :- get_entry(Row,1,Board, List),write(List),nl,get_entry(Col,1,List, Piece).
get_entry(Row,Row,[Head|_Tail],Head):-  !.
get_entry(Row,Index,[_Head|Tail],List):- 
			Index < Row, I2 is Index + 1 , 
			get_entry(Row,I2,Tail, List).

			
% Get_connections(Row,Column,ConnectionList). This predicate is a bit too
% complicated and should be simplified.

get_connections(Row,Column,ConnectionList) :- 
		get_connections(Row,Column, [] ,ConnectionList,1),!.
		
get_connections(Row,Column, ConnectionList ,ConnectionList,5):- !.
get_connections(Row,Column, List ,ConnectionList,1):-
	get_piece(Row,Column,P1),R1 is Row - 1, get_piece(R1,Column,P2),
	pieces_connected_up(P1,P2),!,get_connections(Row,Column, [R1/Column|List] ,ConnectionList,2).
get_connections(Row,Column, List ,ConnectionList,1):-
	get_connections(Row,Column, List ,ConnectionList,2).
	
get_connections(Row,Column, List ,ConnectionList,2):-
	get_piece(Row,Column,P1),R1 is Row + 1, get_piece(R1,Column,P2),
	pieces_connected_down(P1,P2),!,get_connections(Row,Column, [R1/Column|List] ,ConnectionList,3).
get_connections(Row,Column, List ,ConnectionList,2):-
	get_connections(Row,Column, List ,ConnectionList,3).
	
get_connections(Row,Column, List ,ConnectionList,3):-
	get_piece(Row,Column,P1),C1 is Column - 1, get_piece(Row,C1,P2),
	pieces_connected_left(P1,P2),!,get_connections(Row,Column, [Row/C1|List] ,ConnectionList,4).
get_connections(Row,Column, List ,ConnectionList,3):-
	get_connections(Row,Column, List ,ConnectionList,4).
	
get_connections(Row,Column, List ,ConnectionList,4):-
	get_piece(Row,Column,P1),C1 is Column + 1, get_piece(Row,C1,P2),
	pieces_connected_right(P1,P2),!,get_connections(Row,Column, [Row/C1|List] ,ConnectionList,5).
get_connections(Row,Column, List ,ConnectionList,4):-
	get_connections(Row,Column, List ,ConnectionList,5).

% Add connections to search frontier The lists are defined index i/j  eg... [1/2,4/5,3/4....]

% add_connections(ConnectionList, Visited, Frontier, Newfrontier)   

add_connections(ConnectionList, Visited, Frontier, FinalFrontier) :- 
	check_connections(ConnectionList, Visited, Frontier ,[], Newfrontier),append(Frontier,Newfrontier,FinalFrontier), ! .

check_connections([], Visited, _Frontier, FinalFrontier, FinalFrontier):- !.


check_connections([Head|ConnectionList], Visited, Frontier,Acc, Newfrontier):-
	\+ member(Head,Visited), \+ member(Head,Frontier),!,
	check_connections(ConnectionList,Visited,Frontier,[Head|Acc],Newfrontier).

check_connections([_Head|ConnectionList], Visited, Frontier,Acc, Newfrontier):-
	!, check_connections(ConnectionList,Visited,Frontier,Acc,Newfrontier).

%The graph search Algorithm graph_search_BFS(StartI,StartJ,ListOfVisitedNodes)

graph_search_BFS(StartI,StartJ,ListOfVisitedNodes):-
	graph_search_BFS2([StartI/StartJ],[],ListOfVisitedNodes).

graph_search_BFS2([],Visited,Visited):-!.
graph_search_BFS2([I/J|Frontier],Acc,Visited):-
	get_connections(I,J,ConnectionList),
	add_connections(ConnectionList,Acc,Frontier,Newfrontier),
	graph_search_BFS2(Newfrontier,[I/J|Acc],Visited).












	
	
	
	