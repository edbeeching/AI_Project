

%
%	The code base is split up into the following sections:
%	1. Predicates that are used by the user to play the game
%	2. Predicates for setting up the player starting positions, their treasure lists, etc
%	3. Predicates for seting the game board, moving the game board.
%	4. Predicates for a particular game board to find connected pieces
%	5. Predicates for different heuristics used in the game.



%---------------------------------------------------------------
%				Section 1. Predicates for Game playing.
%---------------------------------------------------------------

% The game is played with the following predicates
% setup(_) To set up the Game Board

setup(H):- 	retractall(board(_)),
			create_players(H),
			!,create_board(X),
			assert(board(X)),
			board(Y),
			write_board(Y).
			
setup(H):- create_board(X),create_players(H),  assert(board(X)),board(Y),write_board(Y).

move(Player,I,J).
%---------------------------------------------------------------
%				Section 2. Predicates setting up players.
%---------------------------------------------------------------

% Players are labelled "a" and "b" and positions are i/j e.g player(a,h1, 1/2) would be player "a" with heuristic at row 1 column 2.
create_players(H1/H2) :- retractall(player(_,_,_)), retractall(treasure_list(_,_)),retractall(treasure_index(_,_)),
						assert(player(a,H1,1/1)), assert(player(b,H2,1/7)),
						setup_treasure_lists(P1_List,P2_List), 
						assert(treasure_list(a,P1_List)),
						assert(treasure_list(b,P2_List)),
						assert(treasure_index(a,1)),assert(treasure_index(b,1)).
% Treasure locations [sword, ring, map, keys, helmet, gold, fairy, gem, chest, candle, book, crown]
treasures([	sword/1/3, ring/1/5, map/3/1, 
			keys/3/3, helmet/3/5, gold/3/7, 
			fairy/5/1, gem/5/3, chest/5/5, 
			candle/5/7, book/7/3, crown/7/5]).

% Create the treasure lists for the two players and assert them these in are the format treasure_list(Player, List, CurrentIndex)
%create_treasure_lists():- retractall(treasure_list(Player,List,CurrentTargetIndex)),						  setup_treasure_lists(P1,P2),						  assert(treasure_list(a,P1,1)), 						  assert(treasure_list(b,P2,1))).
get_treasure_list(Player,List):- treasure_list(Player,P1_List), extract_treasures(P1_List,List).
extract_treasures([],[]):-!.
extract_treasures([Treasure/_/_|Tail],[Treasure|Rest]):- extract_treasures(Tail,Rest).
% sets up the 5 treasures for each player, this uses random to mix the lists a bit
setup_treasure_lists(Player1List,Player2List):- treasures(Treasures),
												mix_treasures(Treasures,T1),
												mix_treasures(T1,T2),
												mix_treasures(T2,T3),
												mix_treasures(T3,T4),
												mix_treasures(T4,T5),
												get_first_5(T5,Player1List),
												get_next_5(T5,Player2List).
												

mix_treasures([T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12],[T5,T1,T6,T2,T10,T11,T4,T7,T8,T3,T12,T9 ]):-random_between(0,1,P),P is 1,!.
mix_treasures([T1,T2,T3,T4,T5, T6, T7,T8,T9,T10,T11,T12],[T2,T3,T4,T5, T6, T7,T8,T9,T10,T11,T12,T1]).

get_first_5([T1,T2,T3,T4,T5|_Rest],[T1,T2,T3,T4,T5]).
get_next_5([_T1,_T2,_T3,_T4,_T5,T6,T7,T8,T9,T10|_REST],[T6,T7,T8,T9,T10]).

% get_target(Player,I/J):- treasure_index(a,N), 

%---------------------------------------------------------------
%		Section 3. Predicates setting up the game board.
%---------------------------------------------------------------

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


%these predicates permantly move the board at the end of an AI heuristic or when the human player decides on a partciular move
shift_row_left(Row):- 	board(Board),
						rotate_row_left(Board,Row,NewBoard),
						check_shifted_players(Row,left),
						retractall(board(Board)),!,
						assert(board(NewBoard)).
						
shift_row_right(Row):- 	board(Board),
						rotate_row_right(Board,Row,NewBoard),
						check_shifted_players(Row,right),
						retractall(board(Board)),!,
						assert(board(NewBoard)).
						
shift_column_up(Column):- 	board(Board),
						rotate_column_up(Board,Column,NewBoard),
						check_shifted_players(Column,up), 
						retractall(board(Board)),!,
						assert(board(NewBoard)).
shift_column_down(Column):- 	board(Board),
						rotate_column_down(Board,Column,NewBoard), 
						check_shifted_players(Column,down), 
						retractall(board(Board)),!,
						assert(board(NewBoard)).

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

%% JChong: Update, code testing. I generated the Board:
%%       1     2     3     4     5     6     7
%% 1 [[ 110,   11,  111, 1001,  111,   11,   11],
%% 2  [ 101, 1010, 1010,   11, 1101, 1010,  111],
%% 3  [1110, 1110, 1110,  101,  111,  101, 1011],
%% 4  [ 101, 1100, 1010, 1010, 1100,  111, 1001],
%% 5  [1110,  110, 1101,   11, 1011,   11, 1011],
%% 6  [ 101,  101,  101, 1010, 1100, 1010, 1010],
%% 7  [1100,   11, 1101,  110, 1101, 1010, 1001]]
%% rotate_column_up([[110,11,111,1001,111,11,11],[101,1010,1010,11,1101,1010,111],[1110,1110,1110,101,111,101,1011],[101,1100,1010,1010,1100,111,1001],[1110,110,1101,11,1011,11,1011],[101,101,101,1010,1100,1010,1010],[1100,11,1101,110,1101,1010,1001]], 3, M)
%% should give:
%%
%%       1     2     3     4     5     6     7
%% 1 [[ 110,   11, 1010, 1001,  111,   11,   11],
%% 2  [ 101, 1010, 1110,   11, 1101, 1010,  111],
%% 3  [1110, 1110, 1010,  101,  111,  101, 1011],
%% 4  [ 101, 1100, 1101, 1010, 1100,  111, 1001],
%% 5  [1110,  110,  101,   11, 1011,   11, 1011],
%% 6  [ 101,  101, 1101, 1010, 1100, 1010, 1010],
%% 7  [1100,   11,  111,  110, 1101, 1010, 1001]]
%%
%% rotate_column_down([[110,11,111,1001,111,11,11],[101,1010,1010,11,1101,1010,111],[1110,1110,1110,101,111,101,1011],[101,1100,1010,1010,1100,111,1001],[1110,110,1101,11,1011,11,1011],[101,101,101,1010,1100,1010,1010],[1100,11,1101,110,1101,1010,1001]], 6, M)
%% should give:
%%       1     2     3     4     5     6     7
%% 1 [[ 110,   11,  111, 1001,  111, 1010,   11],
%% 2  [ 101, 1010, 1010,   11, 1101,   11,  111],
%% 3  [1110, 1110, 1110,  101,  111, 1010, 1011],
%% 4  [ 101, 1100, 1010, 1010, 1100,  101, 1001],
%% 5  [1110,  110, 1101,   11, 1011,  111, 1011],
%% 6  [ 101,  101,  101, 1010, 1100,   11, 1010],
%% 7  [1100,   11, 1101,  110, 1101, 1010, 1001]]
%%

%% Implementation of Vertical Rotations:
%% Rotates the Column j Up: Transpose Matrix, Rotate row to the left, Transpose again
%% rotate_column_up(Board, ColumnNumber, NewBoard)
rotate_column_up(Board, ColumnNumber, NewBoard):- transpose(Board, NewBoard2),
												  rotate_row_left(NewBoard2, ColumnNumber, NewBoard3),
												  transpose(NewBoard3, NewBoard).
%% Rotates the Column j Down: Transpose Matrix, Rotate row to the right, Transpose again												  
rotate_column_down(Board, ColumnNumber, NewBoard):-transpose(Board, NewBoard2),
											      rotate_row_right(NewBoard2, ColumnNumber, NewBoard3),
											      transpose(NewBoard3, NewBoard).
%% -------------------------------------------------------------------------------------------%%

%---------------------------------------------------------------
%		Section 4. Predicates for Searching the board
%---------------------------------------------------------------
%

% The following predicates implement a graph search BFS on a particular board
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
get_piece(Board, Row,Col,Piece) :- get_entry(Row,1,Board, List),get_entry(Col,1,List, Piece).
get_entry(Row,Row,[Head|_Tail],Head):-  !.
get_entry(Row,Index,[_Head|Tail],List):- 
			Index < Row, I2 is Index + 1 , 
			get_entry(Row,I2,Tail, List).

			
% Get_connections(Row,Column,ConnectionList). This predicate is a bit too
% complicated and should be simplified.

get_connections(Board, Row,Column,ConnectionList) :- 
		get_connections(Board, Row,Column, [] ,ConnectionList,1),!.
		
get_connections(Board, Row, Column, ConnectionList ,ConnectionList,5):- !.
get_connections(Board, Row, Column, List ,ConnectionList,1):-
	get_piece(Board, Row, Column, P1),R1 is Row - 1, get_piece(Board, R1, Column, P2),
	pieces_connected_up(P1, P2),!,get_connections(Board, Row, Column, [R1/Column|List], ConnectionList,2).
get_connections(Board, Row, Column, List , ConnectionList,1):-
	get_connections(Board, Row, Column, List , ConnectionList,2).
	
get_connections(Board,Row, Column, List ,ConnectionList,2):-
	get_piece(Board,Row, Column, P1),R1 is Row + 1, get_piece(Board,R1, Column, P2),
	pieces_connected_down(P1,P2),!,get_connections(Board,Row, Column, [R1/Column|List], ConnectionList,3).
get_connections(Board,Row,Column, List, ConnectionList,2):-
	get_connections(Board,Row,Column, List, ConnectionList,3).
	
get_connections(Board, Row, Column, List ,ConnectionList,3):-
	get_piece(Board, Row, Column,P1),C1 is Column - 1, get_piece(Board, Row, C1, P2),
	pieces_connected_left(P1, P2),!,get_connections(Board, Row, Column, [Row/C1|List], ConnectionList,4).
get_connections(Board, Row, Column, List ,ConnectionList,3):-
	get_connections(Board, Row, Column, List ,ConnectionList,4).
	
get_connections(Board, Row, Column, List ,ConnectionList,4):-
	get_piece(Board, Row, Column,P1),C1 is Column + 1, get_piece(Board, Row, C1, P2),
	pieces_connected_right(P1, P2),!,get_connections(Board, Row, Column, [Row/C1|List], ConnectionList,5).
get_connections(Board, Row, Column, List, ConnectionList,4):-
	get_connections(Board, Row, Column, List, ConnectionList,5).

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
graph_search_BFS(Board, StartI, StartJ, ListOfVisitedNodes):-
	graph_search_BFS_acc(Board, [StartI/StartJ], [], ListOfVisitedNodes).

graph_search_BFS_acc(Board, [], Visited, Visited):-!.
graph_search_BFS_acc(Board, [I/J|Frontier], Acc, Visited):-
	get_connections(Board, I, J, ConnectionList),
	add_connections(ConnectionList, Acc, Frontier, Newfrontier),
	graph_search_BFS_acc(Board, Newfrontier, [I/J|Acc], Visited).

% Can move to predicate, true if there is a path from startI/startJ to finishI/finishJ
% can_move(StartI/StartJ,FinishI/FinishJ)

can_move(StartI/StartJ, FinishI/FinishJ):- board(Board),
	graph_search_BFS(Board,StartI, StartJ, List), member(FinishI/FinishJ, List),!.

%---------------------------------------------------------------
%		Section 5. Predicates for Heuristics
%---------------------------------------------------------------


% First, the potential maze moves for heuristic to explore 0/0/0 refers to not moving the maze at all

maze_moves([0/nil, 2/up, 2/down, 4/up, 4/down, 6/up, 6/down, 2/left, 2/right, 4/left, 4/right, 6/left, 6/right]).


% Create the 13 possible maze boards: create_shifted_board(Board,Move,NewBoard )

create_shifted_board(Board, 0/nil, Board ):- !.
create_shifted_board(Board, Row/left, NewBoard ):- rotate_row_left(Board, Row, NewBoard), !.
create_shifted_board(Board, Row/right, NewBoard ):- rotate_row_right(Board, Row, NewBoard), !.
create_shifted_board(Board, Column/up, NewBoard ):- rotate_column_up(Board, Column, NewBoard), !.
create_shifted_board(Board, Column/down, NewBoard ):- rotate_column_down(Board, Column, NewBoard), !.

% get the 13 possible maze boards
get_possible_boards(BoardList):- board(CurrentBoard),maze_moves(Moves),
								 findall(NewBoard,(member(Move,Moves), create_shifted_board(CurrentBoard, Move,NewBoard)),
								 BoardList).

% unfortunately, the players can also move when the board moves and this must be accounted for.
% get a list of possible player locations in format [(a/1/2,b/4/5), (......), etc]

get_possible_locations(PlayerList) :- player(a,_,Ia/Ja),player(b,_,Ib/Jb),
									  maze_moves(Moves),
									  findall((a/Ra/Ca,b/Rb/Cb),(member(Move,Moves),
									  create_shifted_player(Ia,Ja,Move,Ra,Ca),create_shifted_player(Ib,Jb,Move,Rb,Cb)),PlayerList).

create_shifted_player(X,Y,0/nil,X,Y):-!.
create_shifted_player(I,J,I/left,I,NewJ) :- J2 is J + 5, NewJ is mod(J2,7) +1,!. % I use addition and mod to sort out wraparound
create_shifted_player(I,J,I/right,I,NewJ) :- J2 is J +7, NewJ is mod(J2,7) +1,!.
create_shifted_player(I,J,J/up,NewI,J) :- I2 is I + 5, NewI is mod(I2,7) +1,!.
create_shifted_player(I,J,J/down,NewI,J):- I2 is I +7, NewI is mod(I2,7) +1,!.
create_shifted_player(I,J,_/_,I,J).

check_shifted_players(C_R,Dir):- check_player_shift(a,C_R,Dir),check_player_shift(b,C_R,Dir).

check_player_shift(Player,C_R,Dir):- player(Player,H1,I/J),create_shifted_player(I,J,C_R/Dir,NewI,NewJ),!,retractall(player(Player,H1,I/J)),assert(player(Player,H1,NewI/NewJ)).
check_player_shift(Player,C_R,Dir).


move_player(C,I/J):-player(C,H,_/_),retractall(player(C,_,_/_)),assert(player(C,H,I/J)).
								 
								 
% Get a list of lists of nodes connected to a given player for all 13 board combinations
get_list_of_board_connections(Player, LocationsList):- 	board(CurrentBoard),player(Player,_,I/J),maze_moves(Moves),
														findall(ListOfVisitedNodes,(member(Move,Moves),
														create_shifted_player(I,J,Move,NewI,NewJ),
														create_shifted_board(CurrentBoard,Move,NewBoard),
														graph_search_BFS(NewBoard,NewI,NewJ,ListOfVisitedNodes)),LocationsList).


%-------------------------------------------------------
%						HEURISTICS
%-------------------------------------------------------



































