function [MS, board] = Minesweeper(board_size)

% Initialize the state of the board.
MS.state = InitializeBoard(board_size);

% Set up functions for playing the game.
MS.makeMove = @MakeMove;

% Visualize the board.
MS.display = @VisualizeBoard;

% Create an empty board as the playing field.
board = NaN(board_size);

end

function state = InitializeBoard(board_size)
    % Create an empty board.
    state = zeros(board_size);
    
    % Randomly place mines.
    num_mines = round(.1*(board_size^2));  % 10 percent is mines.
    mine_location = randperm(board_size^2, num_mines);
    state(mine_location) = -1;
    
    % Count the mines around each cell on the board.
    mine_count = zeros(board_size);
    % Iterate through the board positions and count the number of mines.
    for i=1:board_size
        for j=1:board_size
            % If the point is a mine, dont bother doing the count.
            if state(i, j) == -1
                continue;
            end
            mine_count(i, j) = -1*sum(sum(state(max(1, i-1):min(board_size, i+1), max(1, j-1):min(board_size, j+1))));
        end
    end
    
    % Place the mine counts on the state.
    state(mine_count ~= 0) = mine_count(mine_count ~= 0);
end

function [board] = MakeMove(move, board, state)

    % Fill in that cell.
    board(move(1), move(2)) = state(move(1), move(2));
    
    % If we've opened a bomb. Display message and exit.
    if state(move(1), move(2)) == -1
        disp('You Lose!');
        board = false;  % Nuke the board to be an asshole. Return the win condition.
        return;
    end
    
    % If all non-bomb spaces are opened, we've won. Display message and
    % return.
    if  all(all(state(isnan(board)) == -1))
        disp('You Win!');
        board = true;  % Nuke the board to be an asshole. Return the win condition.
        return;
    end
    
    % If we've opened an empty cell, flood fill.
    if state(move(1), move(2)) == 0
        board = FloodFill(move(1), move(2), board, state);
    end
    
    % This function opens all the cells around a particular move.
    function [board] = FloodFill(i, j, board, state)
        if state(i, j) ~= 0
            error('Invalid move passed into floodfill.');
        end
        
        % Save off board size and the original board state.
        board_size = size(board, 1);        
        old_board = board;
        
        % Copy over the 3x3 box around the move.
        board(max(1, i-1):min(board_size, i+1), max(1, j-1):min(board_size, j+1)) = ...
            state(max(1, i-1):min(board_size, i+1), max(1, j-1):min(board_size, j+1));
                
        for ii = max(1, i-1):min(board_size, i+1)
            for jj = max(1, j-1):min(board_size, j+1)
                if board(ii, jj) == 0 && old_board(ii, jj) ~= 0
                    board = FloodFill(ii, jj, board, state);
                end
            end
        end
    end
end

function VisualizeBoard(board)
    figure(1);
    imagesc(board);
    caxis([-1 4]);
    colorbar;
end

