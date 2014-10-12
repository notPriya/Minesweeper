function board = MinesweeperAgent(board_size)
    % Initialize constants.
    num_cells = board_size^2;

    % Initialize a new game. Keep trying to initialize until you get a
    % board, where the first move doesnt blow up.
    board = false;
    while size(board, 1) < board_size
        [ms, board] = Minesweeper(board_size);
        bs = size(board);
        % Make the first move, since you're guessing anyways.
        board = ms.makeMove([1 1], board, ms.state);
    end

    % Play the game while we have a board.
    while size(board, 1) == board_size
        % Mark all open cells as having no bombs, in the equality matrix.
        ind = find(board >= 0);
        Aeq = zeros(1, num_cells);
        Aeq(ind) = 1;
        beq = 0;

        % Create constrains for each cell that has non-zero bombs around it.
        for i=1:board_size
            for j=1:board_size
                % If the cell is a non-zero number, mark the cells around it as
                % bombs.
                if board(i, j) > 0
                    % Select the cells around this index.
                    new_row = zeros(1, num_cells);
                    for ii=max(1, i-1):min(board_size, i+1)
                        for jj=max(1, j-1):min(board_size, j+1)
                            % Ignore the current cell.
                            if ii == i && jj == j
                                continue;
                            end
                            try
                                new_row(sub2ind(bs, ii, jj)) = 1;
                            catch
                                disp('broke again');
                            end
                        end
                    end
                    % Add to the constraint equation.
                    Aeq = [Aeq; new_row];
                    beq = [beq; board(i, j)];
                end
            end
        end

        % Solve for the mines.
        f = -ones(num_cells, 1);  % Maximize the number of bombs. (Be pessimistic.)
        lb = zeros(num_cells, 1);  % Lower bound.
        ub = ones(num_cells, 1);  % Upper bound.
        x = linprog(f, [], [], Aeq, beq, lb, ub);

        % Find the next move.
        x(ind) = 2;
        epsilon = 0.00001;
        % Check if there are any save moves.
        if any(x < epsilon)
            % Do all 0 likelihood moves, if there are any.
            moves = find(x < epsilon);
            for ii=1:length(moves)
                [a, b] = ind2sub(bs, moves(ii));
                board = ms.makeMove([a b], board, ms.state);
            end
        else
            % Otherwise select randomly between the best possible moves.
            likelihood = min(x);
            moves = find( abs(x - likelihood) < epsilon);
            ind = randperm(length(moves), 1);
            [a, b] = ind2sub(bs, moves(ind));
            board = ms.makeMove([a b], board, ms.state);
        end
    end
end