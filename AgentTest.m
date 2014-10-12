close all;

% Select the size of the board.
% board_size = input('Size of the board?   ');
board_size = 7;

% Set the number of trials to test the algorithm.
num_trials = 1000;
results = zeros(num_trials, 1);

for i=1:num_trials
    results(i) = MinesweeperAgent(board_size);
end

sum(results)/length(results)