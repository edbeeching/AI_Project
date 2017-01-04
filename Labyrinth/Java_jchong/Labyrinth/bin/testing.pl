setup(Game), board(CurrentBoard), h3_get_list_of_board_connections_first_move(CurrentBoard, a, ListOfBoards).

h3_get_highest_score_move_I_J(5/5, [up/12/1/1,down/12/4/6,up/10/1/1,down/11/1/1,up/12/1/1,down/12/1/1,left/12/1/2,right/12/2/7,left/8/1/1,right/12/1/1,left/12/1/1,right/12/1/1], X).



h3_get_all_max([up/12/1/1,down/12/4/6,up/10/1/1,down/11/1/1,up/12/1/1,down/12/1/1,left/12/1/2,right/12/2/7,left/8/1/1,right/12/1/1,left/12/1/1,right/12/1/1], NewListOfScores)


h3_get_max([up/12/1/1,down/12/4/6,up/10/1/1,down/11/1/1,up/12/1/1,down/12/1/1,left/12/1/2,right/12/2/7,left/8/1/1,right/12/1/1,left/12/1/1,right/12/1/1], MaxScoreInt)



2/up/12/1/3
2/down/12/2/2
4/up/12/1/6
4/down/12/1/6
6/up/12/1/3
6/down/12/1/3
2/left/12/1/3
2/right/12/5/7
4/left/12/1/3
4/right/12/1/3
6/left/12/1/3
6/right/12/1/3



h3_get_highest_score_move_I_J(5/5,[2/up/12/1/6,2/down/10/1/1,4/up/12/1/6,4/down/12/7/7,6/up/12/3/6,6/down/12/3/1,2/left/10/1/2,2/right/10/1/3,4/left/12/5/3,4/right/12/6/4,6/left/12/1/6,6/right/12/1/6], M).



Player: a
Target: 5/1
Move: 2/up
FixI/FixJ: 1/1
IsTarget: 0

Player: a
Target: 5/1
Move: 2/down
FixI/FixJ: 1/1
IsTarget: 0

Player: a
Target: 5/1
Move: 2/left
FixI/FixJ: 1/1
IsTarget: 0

Player: a
Target: 5/1
Move: 2/right
FixI/FixJ: 1/1
IsTarget: 0
5/1
