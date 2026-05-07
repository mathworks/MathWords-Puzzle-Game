classdef ModelMathWords < handle
    % MODELMATHWORDS MathWords application model.
    %
    %  Copyright 2023 The MathWorks, Inc.

    properties ( SetAccess = private )
        MatWords (:,:) table
        Solved (:,1) logical = true
        Index (1,1) double
        Row (1,1) double
        Col (1,1) double
        Title (1,1) string
        Message (:,1) string
        Icon (1,1) string
        Guesses (6,5) string  % (NumGuesses,NumLetters)
        Matches (1,5) double  % (1,NumLetters)
    end

    properties ( Access = private )
        AllWords (:,1) string
        Solution (1,5) string  % (1,NumLetters)
    end

    properties ( Constant )
        Colors (3,3) double = ...
            [120 124 126; ...  % dark gray
            201 180  88; ...   % yellow
            106 170 100]/255;  % green
    end

    properties (Constant, Access=private)
        NumLetters (1,1) double = 5
        NumGuesses (1,1) double = 6  % Levels is size (1,NumGuesses)
        Levels (1,6) string = ["Genius!" "Magnificent!" ...
            "Impressive!" "Splendid!" "Great!" "Phew!"];
        IsWebApp (1,1) logical = ~isempty( which( "webappLaunchApp" ) )
    end

    events ( NotifyAccess = private )
        % Event broadcasts
        RefreshPushed
        LetterPushed
        BackPushed
        EnterPushed
    end

    methods

        function obj = ModelMathWords
            % MODELMATHWORDS ModelMathWords constructor.
            rng( "shuffle" )
            obj.MatWords = readtable( "MathWordsDictionary.xlsx", ...
                TextType="string", Sheet="MathWords" );
            obj.AllWords = readmatrix( "MathWordsDictionary.xlsx", ...
                OutputType="string", Sheet="AllWords" );

            % Remove flagged MATLAB functions
            idx = contains( obj.MatWords.Hint, "*not used*" );
            obj.MatWords(idx,:) = [];
            obj.AllWords = unique( [obj.AllWords; obj.MatWords.Function] );
            refresh( obj )
        end

        function refresh( obj )
            % REFRESH Refresh the application for a new MathWord.
            obj.Row = 1;
            obj.Col = 0;
            if all( obj.Solved )
                obj.Solved = false( size( obj.MatWords.Function ) );
            end

            k = find( ~obj.Solved );
            obj.Index = k( randi( numel(k) ) );
            soln = obj.MatWords.Function(obj.Index);
            obj.Solution = string( num2cell( char( soln ) ) );
            obj.Guesses(:) = "";
            obj.Matches(:) = 0;

            % Display solution in web app "Show Log"
            if obj.IsWebApp
                disp( "Cheater! ... " + obj.MatWords.Function(obj.Index) )
            end
            notify( obj, "RefreshPushed" )
        end

        function letter( obj, value )
            % LETTER Type each letter of guess.
            valid = validate( obj , "letter" );
            if (valid && (obj.Col < obj.NumLetters))
                obj.Col = obj.Col + 1;
                obj.Guesses(obj.Row,obj.Col) = value;
                notify( obj, "LetterPushed" )
            end
            % ControlKeyboard will display obj.Message if puzzle complete.
            % Else, do nothing if user keeps pressing letters on full row.
        end

        function backspace( obj )
            % BACKSPACE Erase previously typed letter.
            valid = validate( obj , "backspace" );
            if (valid && (obj.Col > 0))
                obj.Guesses(obj.Row,obj.Col) = "";
                notify( obj, "BackPushed" ) % listener need current Col
                obj.Col = obj.Col - 1;
            end
            % ControlKeyboard will display obj.Message if puzzle complete.
            % Else, do nothing if user keeps pressing backspace on empty row.
        end

        function enter( obj )
            % ENTER Submit completed guess.
            valid = validate( obj , "enter" );
            if ~valid
                % ControlKeyboard displays obj.Message if entry not valid.
                return
            end

            % Check if Guess is correct
            obj.Matches = compareWords( obj );

            % Set uialert Title value, if puzzle complete
            if all( obj.Matches == 3 ) % MathWord solved
                obj.Solved(obj.Index) = true;
                obj.Title = obj.Levels(obj.Row);
                obj.Icon = "success";
                
            elseif (obj.Row == obj.NumGuesses) % out of guesses
                obj.Title = "Nice try! The answer was...";
                obj.Icon = fullfile( matlabroot, "ui", "icons", "24x24", "refresh.svg" );
            end

            % Set Message, if puzzle complete (solved or out of guesses)
            if (obj.Solved(obj.Index) || (obj.Row == obj.NumGuesses))
                % Extract doc page and create HTML hyperlink
                link = "<a href='" + obj.MatWords.DocPage(obj.Index) ...
                    + "'>" + join(obj.Solution,"") + "</a>";
                obj.Message = ["<p style='font-family:consolas'>" + link + ...
                    " " + obj.MatWords.Description(obj.Index) + ".</p>"; ...
                    "Click the link above to learn more."; ""; ...
                    "Press the refresh button in the toolbar for a new MathWord."];
            end

            % EnterPushed listeners need current Row
            notify( obj, "EnterPushed" ) % before updating Row/Col

            % Update Row and Col
            if obj.Solved(obj.Index)      % MathWord solved
                obj.Row = obj.NumGuesses; % do not allow more guesses
            end
            obj.Row = obj.Row + 1;
            obj.Col = 0;
        end

        function valid = validate( obj, caller )
            % VALIDATE Check if entry is valid.
            enterCalled = (caller == "enter");
            if (obj.Row > obj.NumGuesses)
                obj.Title = "Puzzle Complete";
                obj.Message = "Press the refresh button in the toolbar for a new MathWord.";
                obj.Icon = fullfile( matlabroot, "ui", "icons", "24x24", "refresh.svg" );
                valid = false;

            elseif (enterCalled && (obj.Col ~= obj.NumLetters))
                obj.Title = "Please Try Again";
                obj.Message = "Each guess must be a valid "+obj.NumLetters+"-letter word.";
                obj.Icon = "error";
                valid = false;

            elseif (enterCalled && ~ismember( join(obj.Guesses(obj.Row,:),""), obj.AllWords) )
                obj.Title = "Please Try Again";
                obj.Message = "The current guess is not in the word list.";
                obj.Icon = "warning";
                valid = false;
                
            else
                obj.Title = "";
                obj.Message = "";
                obj.Icon = "";
                valid = true;
            end
        end

        function matches = compareWords( obj )
            % COMPAREWORDS Compare current guess to solution.
            %   = 1 -> not in word, gray
            %   = 2 -> wrong spot, yellow
            %   = 3 -> correct spot, green

            % To ensure duplicate letter are handled appropriately,
            % remove letters from solution as they are matched
            soln = obj.Solution;
            guess = obj.Guesses(obj.Row,:);
            exact = (guess == soln);
            soln(exact) = "";
            matches = 1 + 2*exact; % 3 or 1
            for k = find(~exact(:))' % ensure row vector
                j = (guess(k) == soln);
                if any(j)
                    matches(k) = 2;
                    j = find(j,1,"first");
                    soln(j) = "";
                end
            end
        end

    end

end