
%-------------------------------------------------------
%						HEURISTIC 2 (H2)
% Tries to move towards the closest fixed tile in the maze such that it requires the minimun number of rotations,
% reachable by just one tile
%-------------------------------------------------------

% These are tiles that never move
get_list_of_fixed_tiles([1/1, 1/3, 1/5, 1/7, 3/1, 3/3, 3/5, 3/7, 5/1, 5/3, 5/5, 5/7, 7/1, 7/3, 7/5, 7/7]).
% The moves valid for fixed tiles
valid_fixed_move(1/1, [2/up,2/down,2/left,2/right]).
valid_fixed_move(1/3, [2/up,2/down,2/left,2/right,4/up,4/down]).
valid_fixed_move(1/5, [4/up,4/down,2/left,2/right,6/up,6/down]).
valid_fixed_move(1/7, [6/up,6/down,2/left,2/right]).
valid_fixed_move(3/1, [2/up,2/down,2/left,2/right,4/left,4/right]).
valid_fixed_move(3/3, [4/up,4/down,2/left,2/right,4/left,4/right]).
valid_fixed_move(3/5, [4/up,4/down,4/left,4/right,6/up,6/down]).
valid_fixed_move(3/7, [6/up,6/down,2/left,2/right,4/left,4/right]).
valid_fixed_move(5/1, [2/up,2/down,4/left,4/right,6/left,6/right]).
valid_fixed_move(5/3, [2/up,2/down,4/up,4/down,4/left,4/right]).
valid_fixed_move(5/5, [4/up,4/down,4/left,4/right,6/left,6/right]).
valid_fixed_move(5/7, [6/up,6/down,4/left,4/right,6/left,6/right]).
valid_fixed_move(7/1, [2/up,2/down,6/left,6/right]).
valid_fixed_move(7/3, [2/up,2/down,4/up,4/down,6/left,6/right]).
valid_fixed_move(7/5, [4/up,4/down,6/up,6/down,6/left,6/right]).
valid_fixed_move(7/7, [6/up,6/down,6/left,6/right]).


h2_make_best_move(h2, Player):- get_target(Player,Target),
						get_list_of_board_connections(Player, LocationsList), 
						get_list_of_board_connections(Target, TargetLocationsList),
						h2_evaluate_moves(Target, LocationsList, Move), write(Move), make_move(Move).
						



%
% Test 3 times the movement of the board
% The score is 7 - the number of movements
% If there is no possible move the score is 0

test_moves_and_scores(Target, [Location|LocationsList], Scores):-
						get_list_of_fixed_tiles(FixedTiles),
						member(FixedTile,FixedTiles),
						
						test_moves_and_scores(Target, LocationsList, Scores).

% Test all of the valid moves from FixedTile_I/FixedTile_J
test_all_3_moves(Target, FixedTile_I/FixedTile_J, Scores):-
	board(CurrentBoard),
	valid_fixed_move(FixedTile_I/FixedTile_J, ValidMoves),
	findall(FixedTile_I/FixedTile_J/Move/Count, (
					member(Move, ValidMoves),
					test_3_moves(CurrentBoard, Target, FixedTile_I/FixedTile_J, Move, Count)),
			Scores
	).
	
% Found in one move of type Move
test_3_moves(CurrentBoard, Target, FixedTile_I/FixedTile_J, Move, 1):-
	findall(ListOfVisitedNodes,(
			create_shifted_board(CurrentBoard, Move, NewBoard),
			graph_search_BFS(NewBoard, FixedTile_I, FixedTile_J, ListOfVisitedNodes)),LocationsList),
	member(Target, LocationsList), !.

% Found in two moves of type Move
test_3_moves(CurrentBoard, Target, FixedTile_I/FixedTile_J, Move, 2):-
	findall(ListOfVisitedNodes,(
			create_shifted_board(CurrentBoard, Move, NewBoard),
			graph_search_BFS(NewBoard, FixedTile_I, FixedTile_J, ListOfVisitedNodes)),LocationsList),
	findall(ListOfVisitedNodes2,(
			create_shifted_board(NewBoard, Move, NewBoard2),
			graph_search_BFS(NewBoard2, FixedTile_I, FixedTile_J, ListOfVisitedNodes2)),LocationsList2),
	member(Target, LocationsList2), !.
	
% Found in three moves of type Move					

test_3_moves(CurrentBoard, Target, FixedTile_I/FixedTile_J, Move, 3):-
	findall(ListOfVisitedNodes,(
			create_shifted_board(CurrentBoard, Move, NewBoard),
			graph_search_BFS(NewBoard, FixedTile_I, FixedTile_J, ListOfVisitedNodes)),LocationsList),
	findall(ListOfVisitedNodes2,(
			create_shifted_board(NewBoard, Move, NewBoard2),
			graph_search_BFS(NewBoard2, FixedTile_I, FixedTile_J, ListOfVisitedNodes2)),LocationsList2),
	findall(ListOfVisitedNodes3,(
			create_shifted_board(NewBoard2, Move, NewBoard3),
			graph_search_BFS(NewBoard3, FixedTile_I, FixedTile_J, ListOfVisitedNodes3)),LocationsList3),
	member(Target, LocationsList3), !.
% Not found
test_3_moves(_, _, _/_, _, 0).

% Test if 2 tiles are connected somehow
% connected(Board, Tile1_I, Tile1_J, Tile2_I, Tile2_J):-
	
	