%
%	The code base is split up into the following sections:
%	1. Predicates that are used by the user to play the game
%	2. Predicates for setting up the player starting positions, their treasure lists, etc
%	3. Predicates for seting the game board, moving the game board.
%	4. Predicates for a particular game board to find connected pieces
%	5. Predicates for different heuristics used in the game.

%---------------------------------------------------------------
%				Section 0. Game representation
%---------------------------------------------------------------
% 
% The state of the game is represented by 
% A board, two players, a history of states, valid moves, list of treasures

% Board: Matrix of tiles
% Represented as a matrix using a list of lists. Each element of 
% the list is a row. Each element of a row is a binary representation
% of the tile. See Section 3 for tile representation

% Players: represented by predicate player(Player name, Heuristic, PositionI/PositionJ)
% There are two players a and b. Examples:
% player(a, h1, 1/1): Player a using heuristics h1 in row 1 column 1
% player(b, h2, 4/3): Player b using heuristics h2 in row 4 column 3

% History: a List of game states
% Each element of history is represented as:
% Board/a/A2/A3/A4/b/B2/B3/B4
% Board: The board
% A2: Player a's heuristic
% A3: Player a's PositionI/PositionJ
% A4: Player a's Target
% B2: Player b's heuristic
% B3: Player b's PositionI/PositionJ
% B4: Player b's Target

% Valid shift or rotations of the board
% Represented by the predicate
% maze_moves([2/up, 2/down, 4/up, 4/down, 6/up, 6/down, 2/left, 2/right, 4/left, 4/right, 6/left, 6/right]).
% Each element of the list means which column or row can be shifted up, down, left or right

% Treasures: Represents the list of targets each player has to collect
% Each treasure is represented as Treasure/PositionI/PositionJ
% treasures([sword/1/3, ring/1/5, map/3/1, 
%			keys/3/3, helmet/3/5, gold/3/7, 
%			fairy/5/1, gem/5/3, chest/5/5, 
%			candle/5/7, book/7/3, crown/7/5]).

% Game state:
% game_state(a, 1): player a's move to shift a row/column
% game_state(a, 2): player a's move to move to a position I/J
% game_state(b, 1): player b's move to shift a row/column
% game_state(b, 2): player b's move to move to a position I/J
% This is necessary to validate the rule of the game that specifies the order
% of a player move: 1st shift column or row, 2nd move the player to a valid
% position.

%---------------------------------------------------------------
%				Section 1. Predicates for Game playing.
%---------------------------------------------------------------

% The game is played with the following predicates
% setup(_) To set up the Game Board

% Restarts the game
setup(H):- 	retractall(board(_)),	% Retracts any board from KB
			create_players(H),		% Creates two players
			!,
			create_board(X),		% Creates a new board
			assert(board(X)),		% Stores board in KB
			board(Y),
			write_board(Y),
			retractall(history(_)),	% Retracts all history
			assert(history([])),	% Stores history with an empty list
			update_history(),!.		% Updates the history with the initial state
			
% Creates a new game from zero
setup(H):- create_board(X),			% Creates a new board
			create_players(H),  	% Creates two players
			assert(board(X)),		% Stores board
			board(Y),
			write_board(Y),		
			retractall(history(_)),	% Retracts all history
			assert(history([])),	% Stores history with an empty list
			update_history().		% Updates the history with the initial state

% move(Player,I,J).
%---------------------------------------------------------------
%				Section 2. Predicates setting up players.
%---------------------------------------------------------------

% Players are labelled "a" and "b" and positions are i/j e.g player(a,h1, 1/2) would be player "a" with heuristic at row 1 column 2.
create_players(H1/H2) :- retractall(player(_,_,_)),		% Retracts all important predicates
						retractall(game_state(_,_)), 
						retractall(treasure_list(_,_)),
						retractall(treasure_index(_,_)),
						assert(player(a,H1,1/1)), 		% Player a initial position
						assert(player(b,H2,1/7)),		% Player b initial position
						assert(game_state(a,1)),
						setup_treasure_lists(P1_List,P2_List), 
						assert(treasure_list(a,P1_List)),
						assert(treasure_list(b,P2_List)),
						assert(treasure_index(a,1)),assert(treasure_index(b,1)).
% Game states can be a,1 a,2 b,1 b,2
get_current_player(Player):- game_state(Player,_).
% Treasure locations [sword, ring, map, keys, helmet, gold, fairy, gem, chest, candle, book, crown]
treasures([	sword/1/3, ring/1/5, map/3/1, 
			keys/3/3, helmet/3/5, gold/3/7, 
			fairy/5/1, gem/5/3, chest/5/5, 
			candle/5/7, book/7/3, crown/7/5]).

% Create the treasure lists for the two players and assert them these in are the format treasure_list(Player, List, CurrentIndex)
%create_treasure_lists():- retractall(treasure_list(Player,List,CurrentTargetIndex)),						  setup_treasure_lists(P1,P2),						  assert(treasure_list(a,P1,1)), 						  assert(treasure_list(b,P2,1))).
get_treasure_list(Player,List):- treasure_list(Player,P1_List), 
								extract_treasures(P1_List,List).
extract_treasures([],[]):-!.
extract_treasures([Treasure/_/_|Tail],[Treasure|Rest]):- extract_treasures(Tail,Rest).

% sets up the 5 treasures for each player, this uses randomnes to mix the lists a bit
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

% Get the position of the next target for Player
% get_target(Player,I/J):- treasure_index(a,N), 
get_target(Player,I/J):- treasure_list(Player,List),
						treasure_index(Player,Index),
						Index < 6,
						!,
						get_element_number(Index,List,_Treasure/I/J).
get_target(a,1/1):- treasure_index(a,6).
get_target(b,1/7):- treasure_index(b,6).

% Checks if Player has reached his current Target, if so, increase the index and assert
check_reached_target(Player):- get_target(Player,Target),
								player(Player,_,Target),!,
								treasure_index(Player,Index),
								NewIndex is Index + 1, 
								retractall(treasure_index(Player,Index)),
								assert(treasure_index(Player,NewIndex)).
check_reached_target(Player).

% If the index is 7 Player has won. There are 6 targets for each player:
% 5 treasures, after that, the player has to come back to home (target 6),
% The first player to reach home wins.
have_I_won(Player):- treasure_index(Player,7).

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


% Transpose and split matrix from session 3 is useful when shifting columns.
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


%these predicates permanently move the board at the end of an AI heuristic or when the human player decides on a particular move

try_to_shift_board(Row/left):-try_to_shift_row_left(Row).
try_to_shift_board(Row/right):-try_to_shift_row_right(Row).
try_to_shift_board(Column/up):-try_to_shift_column_up(Column).
try_to_shift_board(Column/down):-try_to_shift_column_down(Column).

try_to_shift_row_left(Row):- game_state(Player,1), 
							shift_row_left(Row),
							retractall(game_state(_,_)),
							assert(game_state(Player,2)),
							update_history().
try_to_shift_row_right(Row):- game_state(Player,1), 
							shift_row_right(Row),
							retractall(game_state(_,_)),
							assert(game_state(Player,2)),
							update_history().
try_to_shift_column_up(Column):- game_state(Player,1), 
								shift_column_up(Column),
								retractall(game_state(_,_)),
								assert(game_state(Player,2)),
								update_history().
try_to_shift_column_down(Column):- game_state(Player,1), 
								shift_column_down(Column),
								retractall(game_state(_,_)),
								assert(game_state(Player,2)),
								update_history().

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
						
% Stores the game state in KB
% The game board history
update_history():- history(H),
					retractall(history(_)),
					board(Board),
					player(a,A2,A3),
					player(b,B2,B3),
					get_target(a,A4),
					get_target(b,B4),
					append(H,[Board/a/A2/A3/A4/b/B2/B3/B4],H2), 
					assert(history(H2)),
					nl,
					write(H2),nl.
%% -------------------------------------------------------------------------------------------%%



%% -------------------------------------------------------------------------------------------%%
%% Predicates to shift columns and rows (rotation) in the Board:

%% Rotate Row i Right
%% Rotate Row i Left
%% Rotate Column j Up
%% Rotate Column j Down

%%
%% Helper functions to rotate a row or column in the board matrix
%% Rotates List Left
%% rotate_list_left(List, NewList): rotates a List to the left, moving the first element to the back of the list,
%% 									and puts the result in NewList
rotate_list_left([], []).
rotate_list_left([First|Rest], NewList):- append(Rest, [First], NewList).												 

%% 
%% Rotates List Right
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

% Can-move-to predicate, true if there is a path from startI/startJ to finishI/finishJ
% can_move(StartI/StartJ,FinishI/FinishJ)
can_move(StartI/StartJ, FinishI/FinishJ):- game_state(_,2),board(Board),
	graph_search_BFS(Board,StartI, StartJ, List), member(FinishI/FinishJ, List),!.


%---------------------------------------------------------------
%		Section 5. Predicates for Heuristics
%---------------------------------------------------------------

% First, the potential maze moves for heuristic to explore 0/0/0 refers to not moving the maze at all
maze_moves([2/up, 2/down, 4/up, 4/down, 6/up, 6/down, 2/left, 2/right, 4/left, 4/right, 6/left, 6/right]).

% Create the 12 possible maze boards: create_shifted_board(Board,Move,NewBoard )
create_shifted_board(Board, 0/nil, Board ):- !.
create_shifted_board(Board, Row/left, NewBoard ):- rotate_row_left(Board, Row, NewBoard), !.
create_shifted_board(Board, Row/right, NewBoard ):- rotate_row_right(Board, Row, NewBoard), !.
create_shifted_board(Board, Column/up, NewBoard ):- rotate_column_up(Board, Column, NewBoard), !.
create_shifted_board(Board, Column/down, NewBoard ):- rotate_column_down(Board, Column, NewBoard), !.

% get the 12 possible maze boards
get_possible_boards(BoardList):- board(CurrentBoard),
								maze_moves(Moves),
								findall(NewBoard,
										(
											member(Move,Moves), 
											create_shifted_board(CurrentBoard, Move,NewBoard)
										),
								BoardList).

% unfortunately, the players can also move when the board moves and this must be accounted for.
% get a list of possible player locations in format [(a/1/2,b/4/5), (......), etc]

get_possible_locations(PlayerList) :- 	player(a,_,Ia/Ja),
										player(b,_,Ib/Jb),
										maze_moves(Moves),
										findall(
												(a/Ra/Ca,b/Rb/Cb),
												(
													member(Move,Moves),
													create_shifted_player(Ia,Ja,Move,Ra,Ca),
													create_shifted_player(Ib,Jb,Move,Rb,Cb)
												),
												PlayerList).

create_shifted_player(X,Y,0/nil,X,Y):-!.
create_shifted_player(I,J,I/left,I,NewJ) :- J2 is J + 5, NewJ is mod(J2,7) +1,!. % I use addition and mod to sort out wraparound
create_shifted_player(I,J,I/right,I,NewJ) :- J2 is J +7, NewJ is mod(J2,7) +1,!.
create_shifted_player(I,J,J/up,NewI,J) :- I2 is I + 5, NewI is mod(I2,7) +1,!.
create_shifted_player(I,J,J/down,NewI,J):- I2 is I +7, NewI is mod(I2,7) +1,!.
create_shifted_player(I,J,_/_,I,J).

check_shifted_players(C_R,Dir):- check_player_shift(a,C_R,Dir),check_player_shift(b,C_R,Dir).

check_player_shift(Player,C_R,Dir):- player(Player,H1,I/J),create_shifted_player(I,J,C_R/Dir,NewI,NewJ),!,retractall(player(Player,H1,I/J)),assert(player(Player,H1,NewI/NewJ)).
check_player_shift(Player,C_R,Dir).


move_player(a,I/J):-game_state(a,2),player(a,H,_/_),retractall(player(a,_,_/_)),assert(player(a,H,I/J)),retractall(game_state(a,_)),assert(game_state(b,1)),check_reached_target(a).
move_player(b,I/J):-game_state(b,2),player(b,H,_/_),retractall(player(b,_,_/_)),assert(player(b,H,I/J)),retractall(game_state(b,_)),assert(game_state(a,1)),check_reached_target(b).
								 				 
% Get a list of lists of nodes connected to a given player for all 12 board combinations
get_list_of_board_connections(Player, LocationsList):- 	board(CurrentBoard),
														player(Player,_,I/J),
														maze_moves(Moves),
														findall(
																ListOfVisitedNodes,
																(
																	member(Move,Moves),
																	create_shifted_player(I,J,Move,NewI,NewJ),
																	create_shifted_board(CurrentBoard,Move,NewBoard),
																	graph_search_BFS(NewBoard,NewI,NewJ,ListOfVisitedNodes)
																),
														LocationsList).


%-------------------------------------------------------
%						HEURISTICS
%-------------------------------------------------------

%-------------------------------------------------------
% 				GAME EXECUTION AND DYNAMICS
%-------------------------------------------------------
% Game dynamics: The main predicates for the AI is this:
% - try_and_make_move(Player, Heuristic)	<- Tries to shift the Board according to Heuristic
% - make_best_local_move(Player, Heuristic) <- Tries to move the Player according to Heuristic
% 
% try_and_make_move uses the predicate make_best_move(Heuristic, Player)
%
% In order to implement a Heuristic H1, H2, H3 or H4
% we just need to rewrite the predicates for make_best_move(Heuristic, Player) and
% make_best_local_move(Player, Heuristic)
%
% For example to implement H1, rewrite:
% make_best_move(h1, Player)
% make_best_local_move(Player, h1)
%
% Each Heuristic tries to make a certain number of shifts and moves ahead and score them
% following a criteria unique for every heuristic. 
%

make_move(Move):- 	try_to_shift_board(Move).

try_and_make_move(Player,H):- 	game_state(Player,1),
								%board(Board),graph_search_BFS(Board,I,J,ListOfVisitedNodes),write(Player/I/J),nl,write(ListOfVisitedNodes),nl,
								make_best_move(H,Player).
% Distance Function:
% Standard Manhattan Distance between two tiles X1/Y1 and X2/Y2
man_distance(X1/Y1,X2/Y2,ManDist):-
	D1 is abs(X1 - X2), D2 is abs(Y1 - Y2),
	ManDist is D1 + D2 .

make_best_local_move(Player,h1):- game_state(Player,2),
								  player(Player,_,I/J),
								  board(Board),
								  graph_search_BFS(Board,I,J,Locations),
								  get_target(Player,Target),
								  get_best_local_best(I/J,Target,Locations,Move),
								  move_player(Player,Move).

get_best_local_best(I/J,Target,Locations,Move):- get_best_local_best_acc(Target,Locations,0,I/J,Move).

get_best_local_best_acc(_Target,[],_BestScore,Move,Move):-!.
get_best_local_best_acc(Target,[Head|Tail],BestScore,Acc,Move):-
					man_distance(Target,Head,ManDist),Score2 is 12 - ManDist, Score2 > BestScore,!,
					get_best_local_best_acc(Target,Tail,Score2,Head,Move).
get_best_local_best_acc(Target,[Head|Tail],BestScore,Acc,Move):-
					get_best_local_best_acc(Target,Tail,BestScore,Acc,Move).

				
%-------------------------------------------------------
%						HEURISTIC 1 (H1)
% This heuristic evaluates the manhattan distance between the player and its target.
% This heuristic ignores the other player in it's calculation entirely, it also only looks 1 ahead and tends to get stuck
%-------------------------------------------------------
make_best_move(h1, Player):- !,
							get_target(Player,Target), % Get Target given Player
							get_list_of_board_connections(Player, LocationsList),	% For Player, get a list of lists LocationsList, each element of LocationsList is a list representing all tiles reachable from the moves executed. See get_list_of_board_connections for more details
							h1_evaluate_moves(Target, LocationsList, Move), 		% Given Target, LocationsList get the highest scored Move
							% write(Move),
							make_move(Move).
						
h1_evaluate_moves(Target,LocationsList,Move):-  h1_score_moves(Target,LocationsList,Scores),
												get_index_of_highest(Scores,Index),
												maze_moves(Moves),
												get_element_number(Index,Moves,Move).

h1_score_moves(_Target,[],[]):-!.
h1_score_moves(Target,[Head|LocationsList],[Score|Scores]):-
	h1_get_best_score(Target,Head,0,Score),
		h1_score_moves(Target,LocationsList,Scores).
	

h1_get_best_score(_Target,[],Score,Score):-!.
h1_get_best_score(Target,[Position|Rest],Acc,Score):-
	man_distance(Target,Position,ManDist),
	Score2 is 12 - ManDist,
	Acc2 is max(Acc,Score2),
	h1_get_best_score(Target,Rest,Acc2,Score).

% Get the index in the list Scores of the maximum score
get_index_of_highest(Scores,Index):- get_index_of_highest_acc(Scores,Index,1,0,1).
get_index_of_highest_acc([],Index,Index,_ScoreAcc,_Counter):-!.
get_index_of_highest_acc([Head|Scores],Index,IndexAcc,ScoreAcc,Counter):- Head > ScoreAcc, 
						maze_moves(Moves), get_element_number(Counter, Moves, Move), h3_check_valid_move(Move), !,  C2 is Counter +1,
			get_index_of_highest_acc(Scores,Index,Counter,Head,C2).
get_index_of_highest_acc([_Head|Scores],Index,IndexAcc,ScoreAcc,Counter):-   C2 is Counter +1,
			get_index_of_highest_acc(Scores,Index,IndexAcc,ScoreAcc,C2).

% Get the Nth element of List
get_element_number(1,[Head|_Tail],Head):-!.
get_element_number(N,[_Head|Tail],E):-
	N2 is N - 1,
	get_element_number(N2,Tail,E).

	
%-------------------------------------------------------
%						HEURISTIC 2 (H2)
% H2 is based on H3 but the score now considers the best position of
% the opponent in the second shift of the board.
% It is better to analyse H3 first to understand H2
% This heuristics can be interpreted as getting the best score
% for a Move and Position, which maximizes the chances to get closer to
% the player's target, and minimizes the chances of the opponent to 
% get closer to his own target
%-------------------------------------------------------

% First get a list of 12 boards and the list of nodes reachable for each board
% and for each of this boards, shift again, calculate the scores and put the maximum
% in a list of type: [Move/Score/I/J, .....] called ListOfScores 
% Move/Score/I/J: Move is the shift of the board, Score the score according to our rules
% I/J is the position where the player is going to move after the shift of the board
h2_get_list_of_board_connections(CurrentBoard, Player_A, Player_B, ListOfScores):- 	
								player(Player_A,_,IA/JA),			% Get coordinates of player A
								player(Player_B,_,IB/JB),			% Get coordinates of player B
								get_target(Player_A, TargetA),		% Target of player A
								get_target(Player_B, TargetB),		% Target of player B
								maze_moves(Moves),					% Valid Moves
								findall(Move/Score2/IK/JK, 
											(
												member(Move, Moves),		% For every Move in Moves
												h3_check_valid_move(Move),	% which is valid
												%write(Move),nl,
												create_shifted_player(IA,JA,Move,NewIA,NewJA), % move Player A according to Move
												create_shifted_player(IB,JB,Move,NewIB,NewJB), % move Player B according to Move
												create_shifted_board(CurrentBoard,Move,NewBoard), % shift the board according to Move
												graph_search_BFS(NewBoard,NewIA,NewJA,ListOfVisitedNodes1), % get the list of all reachable tiles from the position NewIA, NewJA
												score_add(TargetA,ListOfVisitedNodes1,Val), % If it is connected to TargetA, add one to the score
												h2_get_list_of_board_connections_second_move(NewBoard, 
																							TargetA, 
																							TargetB, 
																							ListOfVisitedNodes1, 
																							NewIB, 
																							NewJB, 
																							Score1/IK/JK), % For every tile in ListOfVisitedNodes1, get the ones with the highest score
												Score2 is Score1 + Val
												% write(Score)
											), 
										ListOfScores
										)
								%,write(TargetA/ListOfScores),nl,nl,nl
								.
																
% Get a Score taking into consideration the next best move from the point of view of player B
% The score can be calculated by the formula BestScoreOfA - (0.5 x BestScoreOfB) 
h2_get_list_of_board_connections_second_move(CurrentBoard, TargetA, TargetB, ListOfVisitedNodes1, IB, JB, Score/I/J):-
											maze_moves(Moves),
											findall(MaxScoreA/IA/JA, 
														(
															member(Move, Moves),
															member(IA/JA, ListOfVisitedNodes1),
															create_shifted_player(IA,JA,Move,NewIA,NewJA),
															create_shifted_board(CurrentBoard,Move,NewBoard),
															graph_search_BFS(NewBoard,NewIA,NewJA,ListOfVisitedNodesA),
															h3_get_score(TargetA, ListOfVisitedNodesA, ListOfScoresA),
															%write("ListOfScoresA: "), write(ListOfScoresA), nl,
															%write("ListOfScoresB: "), write(ListOfScoresB), nl,
															h3_get_highest_score(ListOfScoresA, MaxScoreA)		
														), ScoresA
													),
											findall(MaxScoreB/1/1, 
														(
															member(Move2, Moves),
															create_shifted_player(IB,JB,Move2,NewIB,NewJB),
															create_shifted_board(CurrentBoard,Move2,NewBoard2),
															graph_search_BFS(NewBoard2,NewIB,NewJB,ListOfVisitedNodesB),
															%write(Target), write(ListOfVisitedNodes),
															h3_get_score(TargetB, ListOfVisitedNodesB, ListOfScoresB),
															%write("ListOfScoresA: "), write(ListOfScoresA), nl,
															%write("ListOfScoresB: "), write(ListOfScoresB), nl,
															h3_get_highest_score(ListOfScoresB, MaxScoreB)		
														), ScoresB
													),		
											%write("Scores A: "), write(ScoresA),nl,nl,		
											%write("Scores B: "), write(ScoresB),nl,nl,		
											h3_get_highest_score_I_J(ScoresA, ScoreA/I/J),
											%write("Score A: "),write(ScoreA), nl, nl,
											h3_get_highest_score_I_J(ScoresB, ScoreB/1/1),
											%write("Score B: "),write(ScoreB), nl, nl,
											Score is ScoreA - ScoreB//2  % priorizes the ScoreA over ScoreB
											% Score is 12 - ScoreB//2
											%write("Score: "),write(Score), nl, nl
											.

% Given a player name (a or b), it gives the opponent player
get_other_player(a,b):-!.
get_other_player(b,a).
% Try to make the move using h2_get_list_of_board_connections, 
% then get the highest score set of Move/Score/I/J,
% Assert the position I/J, then shift the board with make_move(Move)
make_best_move(h2, PlayerA):- get_target(PlayerA, TargetA),
						get_other_player(PlayerA, PlayerB),
						board(CurrentBoard),
						h2_get_list_of_board_connections(CurrentBoard, PlayerA, PlayerB, ListOfScores), 
						%write_list_of_scores(ListOfScores),
						%write(ListOfScores),
						h3_get_highest_score_move_I_J(TargetA, ListOfScores, Move/Score/I/J), 
						%nl, write(Player),write(' '), write(Move/Score/I/J),nl,
						assert(h2_best_position(PlayerA,I/J)),
						make_move(Move).
% After the shift of the table, in state 2, just move the piece of Player to the position indicated by
% h2_best_position(Player,I/J) with move_player, finally retractall after the move.
make_best_local_move(Player,h2):- game_state(Player,2),
								  player(Player,_,I/J),
								  board(Board),
								  graph_search_BFS(Board,I,J,Locations),
								  get_target(Player,Target),
								  member(Target,Locations),!,
								  move_player(Player,Target),
								  retractall(h2_best_position(_,_)).
								  							  
make_best_local_move(Player, h2):- game_state(Player, 2),
								% No need to do the graph search
								% But we need to retrieve the move that we stored in the knowledge base
								h2_best_position(Player,Move),
								move_player(Player,Move),
								%write('2 step'),nl,
								retractall(h2_best_position(_,_)).

	
%-------------------------------------------------------
%						HEURISTIC 3 (H3)
% Tries to search 2 moves ahead and evaluates the move that maximizes the score in the second move
% The score is based on the manhattan distance to target and defined as 12 - distance
% It does this from the perspective of the player 1, without taking into consideration the possible
% moves from player 2. In other words, assumes that we are trying to solve the
% puzzle of how to move the board (in two moves) to reach the target.
% In doing so, evaluates for every 1st shift of the board a score that quantifies heuristic 2
%-------------------------------------------------------

% First get a list of 12 boards and the list of nodes reachable for each board
% and for each of this boards, shift again, calculate the scores and put the maximum
% in a list of type: [Move/Score/I/J, .....] called ListOfScores 
% Move/Score/I/J: Move is the shift of the board, Score the score according to our rules
% I/J is the position where the player is going to move after the shift of the board
h3_get_list_of_board_connections(CurrentBoard, Player, ListOfScores):- 	
								player(Player,_,I/J), 			% Get Player's position I/J
								get_target(Player, Target),		% Get Player's target position
								maze_moves(Moves),				% Get the valid Moves
								findall(Move/Score2/IK/JK, 		% ListOfScores is a list of Move/Score2/IK/JK
										(
										member(Move, Moves),	% For every Move in Moves
										h3_check_valid_move(Move),
										create_shifted_player(I,J,Move,NewI,NewJ), % Shift the Player with Move. New position into NewI, NewJ
										create_shifted_board(CurrentBoard,Move,NewBoard), % Shift the Board with Move. New board into NewBoard
										graph_search_BFS(NewBoard,NewI,NewJ,ListOfVisitedNodes1), % All reachable tiles from NewI, NewJ into ListOfVisitedNodes1
										score_add(Target,ListOfVisitedNodes1,Val), % If the Target is reachable in one Move, just add 1 to the final Score. This guarantees that if we reach the Target in one move, the score is the maximum
										h3_get_list_of_board_connections_second_move(NewBoard, 
																					Target, 
																					ListOfVisitedNodes1, 
																					Score1/IK/JK), 	% Given the NewBoard, 
																									% For each tile position in ListOfVisited Nodes1
																									% Shift the board
																									% and put the IK/JK that
																									% maximizes the Score1
										Score2 is Score1 + Val
										), ListOfScores)
								.%,write(Target/ListOfScores),nl,nl,nl.
% Executes the shift of the board for every node in ListOfVisitedNodes1 and evaluates the Score for each move. Then Put the one that maximizes the score in Score = MaxScore/I/J														
h3_get_list_of_board_connections_second_move(CurrentBoard, Target, ListOfVisitedNodes1, Score):-
											maze_moves(Moves),			% Get the valid Moves
											findall(MaxScore/I/J, 
														(
															member(Move, Moves), % For every Move in Moves
															% h3_check_valid_move(Move), % <---- Can be here
															member(I/J, ListOfVisitedNodes1), % For each node I/J in ListOfVisitedNodes1
															create_shifted_player(I,J,Move,NewI,NewJ), % Shift the Player with Move
															create_shifted_board(CurrentBoard,Move,NewBoard), % Shift the CurrentBoard with Move
															graph_search_BFS(NewBoard,NewI,NewJ,ListOfVisitedNodes), % All tiles reachable from NewI, NewJ into ListOfVisitedNodes
															%write(Target), write(ListOfVisitedNodes),
															h3_get_score(Target, ListOfVisitedNodes, ListOfScores), % Get the scores
															h3_get_highest_score(ListOfScores, MaxScore)			% Get the highest score
														), 
														Scores
													),
											%write(Scores),nl,nl,
											h3_get_highest_score_I_J(Scores, Score).

% If the Target is in ListOfVisitedNodes1, then add 1
score_add(Target,ListOfVisitedNodes1,1):- member(Target,ListOfVisitedNodes1),!.
score_add(Target,ListOfVisitedNodes1,0).

% This is a "circular" man_distance
h3_man_distance(X1/Y1,X2/Y2,ManDist):-
	D1 is abs(X1 - X2), D2 is abs(Y1 - Y2),
	D3 is 7 - D1, D4 is 7 - D2,
	ManDist is min(D1, D3) + min(D2, D4).

% Manhattan distance between a position X1/Y1 and all the reachable positions
% from X2/Y2
h3_man_distance_between_pos_set(Board, X1/Y1, X2/Y2, ManDist):-
	graph_search_BFS(Board,X2,Y2,ListOfVisitedNodes2),
	findall(Distance,
			(
				member(Tile2, ListOfVisitedNodes2),
				man_distance(X1/Y1, Tile2, Distance)
			),
			Distances
		),
	min_list(Distances, ManDist).

% Manhattan distance between all reachable positions from X1/Y1 and all
% reachable positions from X2/Y2
h3_man_distance_between_sets(Board, X1/Y1, X2/Y2, ManDist):-
	graph_search_BFS(Board,X1,Y1,ListOfVisitedNodes1),
	graph_search_BFS(Board,X2,Y2,ListOfVisitedNodes2),
	findall(Distance,
			(
				member(Tile1, ListOfVisitedNodes1),
				member(Tile2, ListOfVisitedNodes2),
				man_distance(Tile1, Tile2, Distance)
			),
			Distances
		),
	min_list(Distances, ManDist).
	
% Score based on man_distance from Position to Target											
h3_man_score(Target, Position, Score):-
	h3_man_distance(Target, Position, Distance),
	Score is 12 - Distance.
	
% Given a ListOfVisitedNodes calculate the scores in ListOfScores
h3_get_score(Target, ListOfVisitedNodes, ListOfScores):-
	findall(Score, ( member(Position, ListOfVisitedNodes),
					 % write(Position), write(Target),
					 h3_man_score(Target, Position, Score)
					), ListOfScores
			).

% Given a list of scores, find the highest number
h3_get_highest_score(ListOfScores, MaxScore):-
	h3_get_highest_score_acc(ListOfScores, 0, MaxScore).
h3_get_highest_score_acc([], ScoreAcc, ScoreAcc):- !.
h3_get_highest_score_acc([Score|ListOfScores], ScoreAcc, MaxScore):-
	Score2 is max(Score, ScoreAcc),
	h3_get_highest_score_acc(ListOfScores, Score2, MaxScore).
	
% Get the Score/I/J that maximizes the Score
h3_get_highest_score_I_J([Score/I/J|ListOfScores], MaxScore):- 
	h3_get_highest_score_I_J_acc([Score/I/J|ListOfScores], Score/I/J, MaxScore).
h3_get_highest_score_I_J_acc([], ScoreAcc/I/J, ScoreAcc/I/J):- !.
h3_get_highest_score_I_J_acc([Score/I/J|ListOfScores], ScoreAcc/IK/JK, MaxScore):-
	Score =< ScoreAcc, !,
	h3_get_highest_score_I_J_acc(ListOfScores, ScoreAcc/IK/JK, MaxScore).
h3_get_highest_score_I_J_acc([Score/I/J|ListOfScores], ScoreAcc/IK/JK, MaxScore):-
	Score > ScoreAcc,
	h3_get_highest_score_I_J_acc(ListOfScores, Score/I/J, MaxScore).

% These predicates help finding in a list of Move/Score/I/J the one that
% maximizes the Score. If two or more scores are equal, break ties by the 
% h3_man_distance
% Find the max score
h3_get_max([Move/Score/I/J|ListOfScores], MaxScoreInt):-
	h3_get_max_acc([Move/Score/I/J|ListOfScores], -12, MaxScoreInt).
	
h3_get_max_acc([], MaxAcc, MaxAcc):- !.
h3_get_max_acc([Move/Score/I/J|ListOfScores], MaxAcc, MaxScoreInt):-
	MaxAcc2 is max(Score, MaxAcc),
	h3_get_max_acc(ListOfScores, MaxAcc2, MaxScoreInt).
	
% Considers the Move, and the distance to Target
h3_get_all_max(ListOfScores, NewListOfScores):-
	h3_get_max(ListOfScores, Max),
	findall(
			Move/Max/I/J,
			(
				member(Move/Max/I/J, ListOfScores)
			), NewListOfScores
			).

% The next predicates help getting the Move/Score/I/J with the highest Score
% from a list of Move/Score/I/J			
h3_get_highest_score_move_I_J(Target, ListOfScores, MaxMoveScoreIJ):- 
	h3_get_all_max(ListOfScores, [Move/Score/I/J|NewListOfScores]),
	h3_get_highest_score_move_I_J_acc(Target, [Move/Score/I/J|NewListOfScores], 12, Move/Score/I/J, MaxMoveScoreIJ).

h3_get_highest_score_move_I_J_acc(Target, [], _, MaxMoveScoreIJ, MaxMoveScoreIJ):- !.
h3_get_highest_score_move_I_J_acc(Target, [Move/Score/I/J|NewListOfScores], DistanceAcc, MoveK/Score/IK/JK, MaxMoveScoreIJ):-
	h3_man_distance(Target, I/J, NewDistance),
	NewDistance >= DistanceAcc, !,
	h3_get_highest_score_move_I_J_acc(Target, NewListOfScores, DistanceAcc, MoveK/Score/IK/JK, MaxMoveScoreIJ).

h3_get_highest_score_move_I_J_acc(Target, [Move/Score/I/J|NewListOfScores], DistanceAcc, MoveK/Score/IK/JK, MaxMoveScoreIJ):-
	h3_man_distance(Target, I/J, NewDistance),
	NewDistance < DistanceAcc, h3_check_valid_move(Move),
	!,h3_get_highest_score_move_I_J_acc(Target, NewListOfScores, NewDistance, Move/Score/I/J, MaxMoveScoreIJ).
	
h3_get_highest_score_move_I_J_acc(Target, [Move/Score/I/J|NewListOfScores], DistanceAcc, MoveK/Score/IK/JK, MaxMoveScoreIJ):-
	write('INVALID MOVE '),write(Move),nl,
	h3_get_highest_score_move_I_J_acc(Target, NewListOfScores, DistanceAcc, MoveK/Score/IK/JK, MaxMoveScoreIJ).

% Check if a Move is valid
% To do this checks in the history of moves for the same combinations
% of next board, players, heuristics, new positions
% If they are not in the History, then the Move is Valid
h3_check_valid_move(Move):- 
						board(Board),player(a,A2,AI/AJ),player(b,B2,BI/BJ),get_target(a,A4),get_target(b,B4),
						create_shifted_board(Board, Move, NewBoard),
						create_shifted_player(AI, AJ, Move, NewAI, NewAJ), AA3 = NewAI/NewAJ,
						create_shifted_player(BI, BJ, Move, NewBI, NewBJ), BB3 = NewBI/NewBJ,
						history(H), \+ member(NewBoard/a/A2/AA3/A4/b/B2/BB3/B4,H), !.

h3_check_valid_move(Move):- 
	write("INVALID MOVE "), write(Move), nl, fail.
						
% For debugging only. Don't use
%write_list_of_scores([]):- !, nl.
%write_list_of_scores([Move/Score/I/J|Tail]):-
%	write(Move/Score/I/J), nl, write_list_of_scores(Tail).

%testing_first_move(ListOfScores):-
%	setup(Game), 
%	board(CurrentBoard), 
%	h3_get_list_of_board_connections(CurrentBoard, a, ListOfScores), 
	%write(ListOfScores),
	%write_list_of_scores(ListOfScores),
%	make_best_move(h3, a),
%	nl.

	
% h3 Heuristics Make Best Local Move: This is the implementation of the shift of the board 
% and the move of the player. 
% This is different to H1, in the sense that, we have recorded the best next position into the 
% knowledge base, then, we move there, then retractall
make_best_move(h3, Player):- get_target(Player,Target),
							board(CurrentBoard),
							h3_get_list_of_board_connections(CurrentBoard, Player, ListOfScores), 
							%write_list_of_scores(ListOfScores),
							%write(ListOfScores),
							h3_get_highest_score_move_I_J(Target, ListOfScores, Move/Score/I/J), 
							%nl, write(Player),write(' '), write(Move/Score/I/J),nl,
							assert(h3_best_position(Player,I/J)),
							make_move(Move).
make_best_local_move(Player,h3):- game_state(Player,2),
								  player(Player,_,I/J),
								  board(Board),
								  graph_search_BFS(Board,I,J,Locations),
								  get_target(Player,Target),
								  member(Target,Locations),!,
								  move_player(Player,Target),
								  %write('1 step'),nl,
								  retractall(h3_best_position(_,_)).
								  
make_best_local_move(Player, h3):- game_state(Player, 2),
								% No need to do the graph search
								% But we need to retrieve the move that we stored in the knowledge base
								h3_best_position(Player,Move),
								move_player(Player,Move),
								%write('2 step'),nl,
								retractall(h3_best_position(_,_)).
	

	
% h3_make_best_move()


%-------------------------------------------------------
%						HEURISTIC 4 (H4)
% Same as H2, but test the normal manhattan distance
% This was created to test normal manhattan distance versus "circular" manhattan distance
%-------------------------------------------------------
h4_get_list_of_board_connections(CurrentBoard, Player_A, Player_B, ListOfScores):- 	
								player(Player_A,_,IA/JA),			% Get coordinates of player A
								player(Player_B,_,IB/JB),			% Get coordinates of player B
								get_target(Player_A, TargetA),		% Target of player A
								get_target(Player_B, TargetB),		% Target of player B
								maze_moves(Moves),					% Valid Moves
								findall(Move/Score2/IK/JK, 
											(
												member(Move, Moves),		% For every Move in Moves
												h3_check_valid_move(Move),	% which is valid
												%write(Move),nl,
												create_shifted_player(IA,JA,Move,NewIA,NewJA), % move Player A according to Move
												create_shifted_player(IB,JB,Move,NewIB,NewJB), % move Player B according to Move
												create_shifted_board(CurrentBoard,Move,NewBoard), % shift the board according to Move
												graph_search_BFS(NewBoard,NewIA,NewJA,ListOfVisitedNodes1), % get the list of all reachable tiles from the position NewIA, NewJA
												score_add(TargetA,ListOfVisitedNodes1,Val), % If it is connected to TargetA, add one to the score
												h4_get_list_of_board_connections_second_move(NewBoard, 
																							TargetA, 
																							TargetB, 
																							ListOfVisitedNodes1, 
																							NewIB, 
																							NewJB, 
																							Score1/IK/JK), % For every tile in ListOfVisitedNodes1, get the ones with the highest score
												Score2 is Score1 + Val
												% write(Score)
											), 
										ListOfScores
										)
								%,write(TargetA/ListOfScores),nl,nl,nl
								.
																
% Get a Score taking into consideration the next best move from the point of view of player B
h4_get_list_of_board_connections_second_move(CurrentBoard, TargetA, TargetB, ListOfVisitedNodes1, IB, JB, Score/I/J):-
											maze_moves(Moves),
											findall(MaxScoreA/IA/JA, 
														(
															member(Move, Moves),
															member(IA/JA, ListOfVisitedNodes1),
															create_shifted_player(IA,JA,Move,NewIA,NewJA),
															create_shifted_board(CurrentBoard,Move,NewBoard),
															graph_search_BFS(NewBoard,NewIA,NewJA,ListOfVisitedNodesA),
															h4_get_score(TargetA, ListOfVisitedNodesA, ListOfScoresA),
															h3_get_highest_score(ListOfScoresA, MaxScoreA)		
														), ScoresA
													),
											findall(MaxScoreB/1/1, 
														(
															member(Move2, Moves),
															create_shifted_player(IB,JB,Move2,NewIB,NewJB),
															create_shifted_board(CurrentBoard,Move2,NewBoard2),
															graph_search_BFS(NewBoard2,NewIB,NewJB,ListOfVisitedNodesB),
															%write(Target), write(ListOfVisitedNodes),
															h4_get_score(TargetB, ListOfVisitedNodesB, ListOfScoresB),
															%write("ListOfScoresA: "), write(ListOfScoresA), nl,
															%write("ListOfScoresB: "), write(ListOfScoresB), nl,
															h3_get_highest_score(ListOfScoresB, MaxScoreB)		
														), ScoresB
													),		
											%write("Scores A: "), write(ScoresA),nl,nl,		
											%write("Scores B: "), write(ScoresB),nl,nl,		
											h3_get_highest_score_I_J(ScoresA, ScoreA/I/J),
											%write("Score A: "),write(ScoreA), nl, nl,
											h3_get_highest_score_I_J(ScoresB, ScoreB/1/1),
											%write("Score B: "),write(ScoreB), nl, nl,
											Score is ScoreA - ScoreB//2  % priorizes the ScoreA over ScoreB
											% Score is 12 - ScoreB//2
											%write("Score: "),write(Score), nl, nl
											.

% Score based on man_distance from Position to Target											
h4_man_score(Target, Position, Score):-
	man_distance(Target, Position, Distance),
	Score is 12 - Distance.
	
% Given a ListOfVisitedNodes calculate the scores in ListOfScores
h4_get_score(Target, ListOfVisitedNodes, ListOfScores):-
	findall(Score, ( member(Position, ListOfVisitedNodes),
					 % write(Position), write(Target),
					 h4_man_score(Target, Position, Score)
					), ListOfScores
			).
h4_get_highest_score_move_I_J(Target, ListOfScores, MaxMoveScoreIJ):- 
	h3_get_all_max(ListOfScores, [Move/Score/I/J|NewListOfScores]),
	h4_get_highest_score_move_I_J_acc(Target, [Move/Score/I/J|NewListOfScores], 12, Move/Score/I/J, MaxMoveScoreIJ).

h4_get_highest_score_move_I_J_acc(Target, [], _, MaxMoveScoreIJ, MaxMoveScoreIJ):- !.
h4_get_highest_score_move_I_J_acc(Target, [Move/Score/I/J|NewListOfScores], DistanceAcc, MoveK/Score/IK/JK, MaxMoveScoreIJ):-
	man_distance(Target, I/J, NewDistance),
	NewDistance >= DistanceAcc, !,
	h4_get_highest_score_move_I_J_acc(Target, NewListOfScores, DistanceAcc, MoveK/Score/IK/JK, MaxMoveScoreIJ).

h4_get_highest_score_move_I_J_acc(Target, [Move/Score/I/J|NewListOfScores], DistanceAcc, MoveK/Score/IK/JK, MaxMoveScoreIJ):-
	man_distance(Target, I/J, NewDistance),
	NewDistance < DistanceAcc, h3_check_valid_move(Move),
	!,h4_get_highest_score_move_I_J_acc(Target, NewListOfScores, NewDistance, Move/Score/I/J, MaxMoveScoreIJ).
	
h4_get_highest_score_move_I_J_acc(Target, [Move/Score/I/J|NewListOfScores], DistanceAcc, MoveK/Score/IK/JK, MaxMoveScoreIJ):-
	write('INVALID MOVE '),write(Move),nl,
	h4_get_highest_score_move_I_J_acc(Target, NewListOfScores, DistanceAcc, MoveK/Score/IK/JK, MaxMoveScoreIJ).
% Try to make the move using h2_get_list_of_board_connections, 
% then get the highest score set of Move/Score/I/J,
% Assert the position I/J, then shift the board with make_move(Move)
make_best_move(h4, PlayerA):- get_target(PlayerA, TargetA),
						get_other_player(PlayerA, PlayerB),
						board(CurrentBoard),
						h4_get_list_of_board_connections(CurrentBoard, PlayerA, PlayerB, ListOfScores), 
						% write_list_of_scores(ListOfScores),
						% write(ListOfScores),
						h4_get_highest_score_move_I_J(TargetA, ListOfScores, Move/Score/I/J), 
						%nl, write(Player),write(' '), write(Move/Score/I/J),nl,
						assert(h4_best_position(PlayerA,I/J)),
						make_move(Move).
% After the shift of the table, in state 2, just move the piece of Player to the position indicated by
% h4_best_position(Player,I/J) with move_player, finally retractall after the move.
make_best_local_move(Player,h4):- game_state(Player,2),
								  player(Player,_,I/J),
								  board(Board),
								  graph_search_BFS(Board,I,J,Locations),
								  get_target(Player,Target),
								  member(Target,Locations),!,
								  move_player(Player,Target),
								  retractall(h4_best_position(_,_)).
								  							  
make_best_local_move(Player, h4):- game_state(Player, 2),
								% No need to do the graph search
								% But we need to retrieve the move that we stored in the knowledge base
								h4_best_position(Player,Move),
								move_player(Player,Move),
								%write('2 step'),nl,
								retractall(h4_best_position(_,_)).


%-------------------------------------------------------
%						HEURISTIC 5 (H5)
% Tries to search 2 moves ahead and evaluates the move that maximizes the score in the second move,
% maximizes the chances to get to the next target and minimizes the chances of opponent to 
% get to his target
%-------------------------------------------------------

% To implement H5 we need to retrieve the next target of the
% current target for a player
get_target_next(Player, Target_Next_I/Target_Next_J):-
		treasure_list(Player,List),
		treasure_index(Player,Index),
		Index_1 is Index + 1,
		Index_1 < 6,!,
		get_element_number(Index_1,List,_Treasure/Target_Next_I/Target_Next_J).

get_target_next(a,1/1):- treasure_index(a,5).
get_target_next(b,1/7):- treasure_index(b,5).
get_target_next(a,1/1):- treasure_index(a,6).
get_target_next(b,1/7):- treasure_index(b,6).

% First get a list of 12 boards and the list of nodes reachable for each board
% and for each of this boards, shift again, calculate the scores and put the maximum
% in a list of type: [Move/Score/I/J, .....] called ListOfScores 
% Move/Score/I/J: Move is the shift of the board, Score the score according to our rules
% I/J is the position where the player is going to move after the shift of the board
h5_get_list_of_board_connections(CurrentBoard, Player_A, Player_B, ListOfScores):-
								player(Player_A,_,IA/JA),
								player(Player_B,_,IB/JB),
								get_target(Player_A, TargetA),
								get_target_next(Player_A, Next_TargetA),
								% write(Next_TargetA), nl, 
								get_target(Player_B, TargetB),
								%get_target_next(Player_B, TargetB),
								maze_moves(Moves),
								findall(Move/Score2/IK/JK, (
													member(Move, Moves),
													h3_check_valid_move(Move),
													%write(Move),nl,
													create_shifted_player(IA,JA,Move,NewIA,NewJA),
													create_shifted_player(IB,JB,Move,NewIB,NewJB),
													create_shifted_board(CurrentBoard,Move,NewBoard),
													graph_search_BFS(NewBoard,NewIA,NewJA,ListOfVisitedNodes1),score_add(TargetA,ListOfVisitedNodes1,Val),
													h5_get_list_of_board_connections_second_move(NewBoard, TargetA, Next_TargetA, TargetB, ListOfVisitedNodes1, NewIB, NewJB, Score1/IK/JK),
													Score2 is Score1 + Val,
													% write(Score2)
													), ListOfScores)

								%,write(TargetA/ListOfScores),nl,nl,nl
								.

h5_get_score(ListOfVisitedNodes, Target, ListOfScores):-
	findall(Score, ( member(Position, ListOfVisitedNodes),
					 % write(Position), write(Target),
					 h3_man_score(Target, Position, Score)
					), ListOfScores
			).

% Get a Score taking into consideration the next best move from the point of view of player B
% The score can be calculated by the formula BestScoreOfA + (0.25 x BestScoreOfAForNextTarget) - (0.5 x BestScoreOfB) 
h5_get_list_of_board_connections_second_move(CurrentBoard, TargetA, Next_TargetA, TargetB, ListOfVisitedNodes1, IB, JB, Score/I/J):-
											maze_moves(Moves),
											findall(Sum_AC/IA/JA, (member(Move, Moves),
																	member(IA/JA, ListOfVisitedNodes1),
																	create_shifted_player(IA,JA,Move,NewIA,NewJA),
																	create_shifted_board(CurrentBoard,Move,NewBoard),
																	graph_search_BFS(NewBoard,NewIA,NewJA,ListOfVisitedNodesA),
																	h3_get_score(TargetA, ListOfVisitedNodesA, ListOfScoresA),
																	h5_get_score(ListOfVisitedNodesA, Next_TargetA, ListOfScoresNextA),
																	%write("ListOfScoresA: "), write(ListOfScoresA), nl,
																	%write("ListOfScoresNextA: "), write(ListOfScoresNextA), nl,
																	%write("ListOfScoresB: "), write(ListOfScoresB), nl,
																	h3_get_highest_score(ListOfScoresA, MaxScoreA),
																	h3_get_highest_score(ListOfScoresNextA, MaxScoreC),
																	Sum_AC is (MaxScoreA + (MaxScoreC * 0.25))
															), ScoresA
													),

											findall(MaxScoreB/1/1, (member(Move2, Moves),
																	create_shifted_player(IB,JB,Move2,NewIB,NewJB),
																	create_shifted_board(CurrentBoard,Move2,NewBoard2),
																	graph_search_BFS(NewBoard2,NewIB,NewJB,ListOfVisitedNodesB),
																	 %write(Target), write(ListOfVisitedNodes),
																	h3_get_score(TargetB, ListOfVisitedNodesB, ListOfScoresB),
																	%write("ListOfScoresA: "), write(ListOfScoresA), nl,
																	%write("ListOfScoresB: "), write(ListOfScoresB), nl,
																	h3_get_highest_score(ListOfScoresB, MaxScoreB)
															), ScoresB
													),

											%write("Scores A: "), write(ScoresA),nl,nl,
											%write("Scores B: "), write(ScoresB),nl,nl,

											h3_get_highest_score_I_J(ScoresA, ScoreA/I/J),
											%write("Score A: "),write(ScoreA), nl, nl,
											h3_get_highest_score_I_J(ScoresB, ScoreB/1/1),
											

											%write("Score B: "),write(ScoreB), nl, nl,
											Score is ScoreA - ScoreB//2.
											% Score is 12 - ScoreB//2
											%write("Score: "),write(Score), nl, nl.

% h5 Heuristics Make Best Local Move:
% This is different to H1, in the sense that, we have recorded the best next position into the
% knowledge base, then, we move there, then retractall
%make_best_move(h5, Player):- get_target(Player,Target),
%						get_list_of_board_connections(Player, LocationsList),
%						member(Target,LocationsList),!,
%						h1_evaluate_moves(Target, LocationsList,Move), write(Move),make_move(Move).
make_best_move(h5, PlayerA):- get_target(PlayerA, TargetA),
						get_other_player(PlayerA, PlayerB),
						board(CurrentBoard),
						% write(CurrentBoard), nl, nl,
						h5_get_list_of_board_connections(CurrentBoard, PlayerA, PlayerB, ListOfScores),
						%write_list_of_scores(ListOfScores),
						%write(ListOfScores),
						h3_get_highest_score_move_I_J(TargetA, ListOfScores, Move/Score/I/J),
						%nl, write(Player),write(' '), write(Move/Score/I/J),nl,
						assert(h5_best_position(PlayerA,I/J)),
						make_move(Move)
						% write(PlayerA),write(' '), write(Move/Score/I/J),nl
						.

make_best_local_move(Player,h5):- game_state(Player,2),
								  player(Player,_,I/J),
								  board(Board),
								  graph_search_BFS(Board,I,J,Locations),
								  get_target(Player,Target),
								  member(Target,Locations),!,
								  move_player(Player,Target),
								  % write('1 step'),nl,
								  retractall(h5_best_position(_,_)).


make_best_local_move(Player, h5):- game_state(Player, 2),
								% No need to do the graph search
								% But we need to retrieve the move that we stored in the knowledge base
								h5_best_position(Player,Move),
								move_player(Player,Move),
								% write('2 step'),nl,
								retractall(h5_best_position(_,_)).

								
%-------------------------------------------------------
%						THE END
%-------------------------------------------------------
