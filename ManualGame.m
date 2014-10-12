close all;

% board_size = input('Size of the board?   ');
board_size = 7;

% Initialize a new game.
[ms, board] = Minesweeper(board_size);

% Play the game while we have a board.
while size(board, 1) == board_size
    % Display the board.
    ms.display(board);
    % Get user input.
    [y, x] = ginput(1);
    % Make the user's move.
    board = ms.makeMove(round([x y]), board, ms.state);
end

% Display the solution in the end.
ms.display(ms.state);