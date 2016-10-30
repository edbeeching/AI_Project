
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
% Create Pieces, at the start some locations are predefined as follows:
%
%[[ 0110 ,     , 0111 ,     , 0111 ,     , 0011 ],
% [      ,     ,      ,     ,      ,     ,      ],
% [ 1110 ,     , 1110 ,     , 0111 ,     , 1011 ],
% [      ,     ,      ,     ,      ,     ,      ],
% [ 1110 ,     , 1101 ,     , 1011 ,     , 1011 ],
% [      ,     ,      ,     ,      ,     ,      ],
% [ 1100 ,     , 1101 ,     , 1101 ,     , 1001 ]]
%
% The game is played with the following predicate

% setup(_) To set up the Game Board

% 

setup(Y):- retractall(board(X)),!,create_board(X),  assert(board(X)),board(Y),write_board(Y).
setup(Y):- create_board(X),  assert(board(X)),board(Y),write_board(Y).








% I understand that create_piece(1, 1, Piece) :- Piece is 0110 . is the same as
% create_piece(1, 1, 0110). However this is somewhat clearer for the moment.
% Row 1 , Columns 1, 3, 5 & 7
create_piece(1, 1, Piece) :- Piece is 0110 ,!.
create_piece(1, 3, Piece) :- Piece is 0111 ,!.
create_piece(1, 5, Piece) :- Piece is 0111 ,!.
create_piece(1, 7, Piece) :- Piece is 0011 ,!.
% Row 3 , Columns 1, 3, 5 & 7
create_piece(3, 1, Piece) :- Piece is 1110 ,!.
create_piece(3, 3, Piece) :- Piece is 1110 ,!.
create_piece(3, 5, Piece) :- Piece is 0111 ,!.
create_piece(3, 7, Piece) :- Piece is 1011 ,!.
% Row 5 , Columns 1, 3, 5 & 7
create_piece(5, 1, Piece) :- Piece is 1110 ,!.
create_piece(5, 3, Piece) :- Piece is 1101 ,!.
create_piece(5, 5, Piece) :- Piece is 1011 ,!.
create_piece(5, 7, Piece) :- Piece is 1011 ,!.
% Row 7 , Columns 1, 3, 5 & 7
create_piece(7, 1, Piece) :- Piece is 1100 ,!.
create_piece(7, 3, Piece) :- Piece is 1101 ,!.
create_piece(7, 5, Piece) :- Piece is 1101 ,!.
create_piece(7, 7, Piece) :- Piece is 1001 ,!.

% Rows 2 ,4 & 6. and Columns 2, 4 & 6 have their pieces generated randomly
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
			P2 is P + 2, Piece is ((1111 - 10 ** P)-10 ** P2).
% Create junction piece, simply subtrace a power of 10.
create_junction(Piece):- random_between(0,3,P), Piece is (1111 - 10 ** P).

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
	
%% -------------------------------------------------------------------------------------------%%

%%Hmmmm, maybe instead of using transpose, could we use a predicate to move the last
%%element of a list to the beginning of this list and vice-versa:
%% move_last_element([], []).
%% move_last_element(Last, [H|T]):-
%%	append(T, [H], Last).

%% -------------------------------------------------------------------------------------------%%


%% -------------------------------------------------------------------------------------------%%
%% JChong:
%% If I'm not wrong, Board is a List of Lists that represents a matrix, right??
%% So, we need to implement predicates to move columns and rows (rotation) in the Board:

%% Rotate Row i Right
%% Rotate Row i Left
%% Rotate Column j Up
%% Rotate Column j Down

%%
%% JChong:
%% Helper functions to rotate a row or column in the board matrix
%% Rotates List Left
%% rotate_list_left(List, NewList): rotates a List to the left, moving the first element to the back of the list,
%% 									and puts the result in NewList
rotate_list_left([], []).
rotate_list_left([First|Rest], NewList):- append(Rest, [First], NewList).												 

%% 
%% Rotates List Right
%% rotate_list_right(List, NewList): rotates a List to the right, moving the last element to the front of the list,
%%									 and puts the result in NewList
%% rotate_list_right([],[]).
%% rotate_get_everything_but_last(List, NewList): helper predicate to implement rotate_list_right() 
%%                                                get the original List, without the last element of the list in NewList
%%rotate_get_everything_but_last([First,Second|[]], [First]).										 
%%rotate_get_everything_but_last([First|Rest], [First|RestNewList]):- rotate_get_everything_but_last(Rest, RestNewList).
%%rotate_list_right(List, NewList):- 	rotate_get_everything_but_last(List, ListMinusLast),
%%									append(ListMinusLast, Last, List),
%%									append(Last, ListMinusLast, NewList).
%% rotate_list_right is not working properly with empty lists. Im trying to debug. Maybe something relate to cuts,
%% but I still don't get the idea of the cut and how to used it. Reading about that on Prolog. So I'll finish Later
%%
%% I think this code for rotate_list_right is clearer, and works with empty lists. Uses the built-in predicate reverse
rotate_list_right([], []).	
rotate_list_right(List, NewList):- reverse(List, [Last|NewRest]),
								   reverse(NewRest, NewRest2),
								   append([Last], NewRest2, NewList).

								   

%% Missing the next predicates:

%% replace_nth(Matrix, Index, Element, NewMatrix): Replace the element in position Index by Element in NewMatrix.
%% Index starts in 1.
replace_nth(Matrix, Index, Element, NewMatrix):- replace_nth_h(Matrix, Index, 1, Element, NewMatrix).
replace_nth_h([],_,_,_,[]).
replace_nth_h([First|RestMatrix], Index, Counter, Element, [First|NewMatrix]):-
																				Index =\= Counter,
																				NewCounter is Counter + 1,
																				replace_nth_h(RestMatrix, Index, NewCounter, Element, NewMatrix).

replace_nth_h([First|RestMatrix], Index, Counter, Element, [Element|NewMatrix]):-
																				Index =:= Counter,
																				NewCounter is Counter + 1,
																				replace_nth_h(RestMatrix, Index, NewCounter, Element, NewMatrix).

										
%% Rotates the Row i to the Left
%% rotate_row_left(Board, RowNumber, NewBoard)
rotate_row_left(Board, RowNumber, NewBoard):- nth1(RowNumber, Board, Row),  %% Built-in predicate in SWI-Prolog
											  rotate_list_left(Row, NewRow),
											  replace_nth(Board, RowNumber, NewRow, NewBoard).
%% Rotates the Row i to the Right
%% rotate_row_right(Board, RowNumber, NewBoard)
rotate_row_right(Board, RowNumber, NewBoard):- nth1(RowNumber, Board, Row),
											   rotate_list_right(Row, NewRow),
											   replace_nth(Board, RowNumber, NewRow, NewBoard).								

%% <- Warning: I haven't tested this predicates yet. I'm taking a rest to study Complexity. Sorry!
%% Rotates the Column j Up: Transpose Matrix, Rotate row to the left, Transpose again
%% rotate_column_up(Board, ColumnNumber, NewBoard)
rotate_column_up(Board, ColumnNumber, NewBoard):- transpose(Board, NewBoard2),
												  rotate_row_left(NewBoard2, ColumnNumber, NewBoard3),
												  transpose(NewBoard3, NewBoard).
%% Rotate the Column j Down: Transpose Matrix, Rotate row to the right, Transpose again												  
%% rotate_column_down(Board, ColumnNumber, NewBoard):-transpose(Board, NewBoard2),
												      rotate_row_right(NewBoard2, ColumnNumber, NewBoard3),
												      transpose(NewBoard3, NewBoard).
%% -------------------------------------------------------------------------------------------%%


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

% Add connections to search frontier The lists are defined index i/j  eg... [1/2,4/5,3/4...i/j]

% add_connections(ConnectionList, Visited, Frontier, Newfrontier)   

add_connections(ConnectionList, Visited, Frontier, FinalFrontier) :- 
	check_connections(ConnectionList, Visited, Frontier ,[], Newfrontier),append(Frontier,Newfrontier,FinalFrontier), ! .

check_connections([], Visited, _Frontier, FinalFrontier, FinalFrontier):- !.


check_connections([Head|ConnectionList], Visited, Frontier,Acc, Newfrontier):-
	\+ member(Head,Visited), \+ member(Head,Frontier),!,
	check_connections(ConnectionList,Visited,Frontier,[Head|Acc],Newfrontier).

check_connections([_Head|ConnectionList], Visited, Frontier,Acc, Newfrontier):-
	check_connections(ConnectionList,Visited,Frontier,Acc,Newfrontier).

% The graph search Algorithm graph_search_BFS(StartI,StartJ,ListOfVisitedNodes)
% The ListOfVisitedNodes are all the nodes in the maze connected to index (i,j)
graph_search_BFS(StartI,StartJ,ListOfVisitedNodes):-
	graph_search_BFS_acc([StartI/StartJ],[],ListOfVisitedNodes).

graph_search_BFS_acc([],Visited,Visited):-!.
graph_search_BFS_acc([I/J|Frontier],Acc,Visited):-
	get_connections(I,J,ConnectionList),
	add_connections(ConnectionList,Acc,Frontier,Newfrontier),
	graph_search_BFS_acc(Newfrontier,[I/J|Acc],Visited).

% Can move to predicate, true if there is a path from startI/startJ to finishI/finishJ
% can_move(StartI/StartJ,FinishI/FinishJ)

can_move(StartI/StartJ, FinishI/FinishJ):-
	graph_search_BFS(StartI,StartJ,List), member(FinishI/FinishJ,List),!.








<<<<<<< HEAD
=======


	
	
	
	
>>>>>>> origin/master
