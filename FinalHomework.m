% Sternberg Memory Experiment_FinalHomework
%Florian Schinwald
Screen('Preference', 'SkipSyncTests', 1); 
myScreen = 0;
[myWindow, rect] = Screen('OpenWindow', myScreen, [128 128 128]);
Screen('TextSize', myWindow, 32);

% Display Instructions
instructions = ['Sternberg Memory Experiment\n\n' ...
    'Eine Liste von Zahlen wird nacheinander angezeigt.\n' ...
    'Danach erscheint eine Testzahl.\n\n' ...
    'Drücken Sie die **linke Pfeiltaste**, wenn die Zahl in der Liste war.\n' ...
    'Drücken Sie die **rechte Pfeiltaste**, wenn die Zahl NICHT in der Liste war.\n\n' ...
    'Drücken Sie eine beliebige Taste, um zu beginnen.'];
DrawFormattedText(myWindow, instructions, 'center', 'center', [0 0 0]);
Screen('Flip', myWindow);

% Waiting for keypress
KbWait;

% Parameters
listLength = 5; % Number of items in the memory list
stimulusDuration = 0.5; % Duration to display each item 
testDuration = 3; % Maximum duration to display test item 
ISI = 0.5; % interval between stimulus
nTrials = 10; % Number of trials
reactionTimes = zeros(1, nTrials);
accuracy = zeros(1, nTrials);

% Main Experiment Loop
for trial = 1:nTrials
    % Generate Memory List
    memoryList = randi([0, 9], 1, listLength); % Random numbers between 0 and 9
    disp(['Memory List for Trial ', num2str(trial), ': ', num2str(memoryList)]);
    
    % Present Memory List
    for i = 1:listLength
        DrawFormattedText(myWindow, num2str(memoryList(i)), 'center', 'center', [0 0 0]);
        Screen('Flip', myWindow);
        WaitSecs(stimulusDuration); 
        Screen('Flip', myWindow);
        WaitSecs(ISI); 
    end
    
    % Generate Test Item
    if rand > 0.5
        testItem = memoryList(randi(listLength)); % Choose a random item from the list
        isPresent = true;
    else
        testItem = randi([0, 9]);
        while ismember(testItem, memoryList) % Ensure the test item is not in the list
            testItem = randi([0, 9]);
        end
        isPresent = false;
    end
    disp(['Test Item for Trial ', num2str(trial), ': ', num2str(testItem)]);
    
    % Present Test Item 
    Screen('TextSize', myWindow, 48); % Größere Schriftgröße für das Test-Item
    DrawFormattedText(myWindow, num2str(testItem), 'center', 'center', [0 0 0]);
    Screen('Flip', myWindow);
    testOnset = GetSecs; % Record onset time of the test item

    % Wait for Response
    [keyIsDown, secs, keyCode] = KbCheck;
    while ~keyIsDown && (GetSecs - testOnset < testDuration)
        [keyIsDown, secs, keyCode] = KbCheck;
    end

    % Clear Screen and Reset Font Size
    Screen('Flip', myWindow);
    Screen('TextSize', myWindow, 32);
    
    % Record Response
    if keyIsDown
        responseTime = secs - testOnset;
        reactionTimes(trial) = responseTime;
        if strcmp(KbName(keyCode), 'LeftArrow') && isPresent
            accuracy(trial) = 1; % Correct "Yes" response
        elseif strcmp(KbName(keyCode), 'RightArrow') && ~isPresent
            accuracy(trial) = 1; % Correct "No" response
        else
            accuracy(trial) = 0; % Incorrect response
        end
    else
        reactionTimes(trial) = NaN; % No response recorded
        accuracy(trial) = 0; % Mark as incorrect
    end
end

% Close Window
Screen('CloseAll');

% Results
disp('Experiment Completed!');
disp(['Mean Reaction Time: ', num2str(mean(reactionTimes, 'omitnan')), ' seconds']);
disp(['Accuracy: ', num2str(mean(accuracy) * 100), '%']);
