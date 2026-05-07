classdef ViewGuesses < Component
    % VIEWGUESSES Visualizes guesses and responds to relevant model events.
    %
    %  Copyright 2023 The MathWorks, Inc.

    properties (Constant, Access=private)
        NumKeys (1,1) double = 11 % width of keyboard
    end

    properties % public: allows toolbar to toggle Title/Hint
        Title (1,1) matlab.ui.control.Label
    end

    properties ( Access = private )
        GuessGrid matlab.ui.control.EditField
    end

    methods
        
        function obj = ViewGuesses( model, namedArgs )
            % VIEWGUESSES ViewGuesses constructor.
            arguments
                model (1,1) ModelMathWords
                namedArgs.?ViewGuesses
            end

            % Call the superclass constructor
            obj@Component( model )

            % Set any user-specified properties
            set( obj, namedArgs )
        end

    end

    methods ( Access = protected )
        
        function setup( obj )
            % SETUP Initialize guessing grid view.
            [nRows,nCols] = size( obj.Model.Guesses );
            obj.GuessGrid = repmat( matlab.ui.control.EditField, nRows, nCols );

            nPad = round( (obj.NumKeys - nCols)/2 );
            g = uigridlayout( Parent=obj, ...
                RowHeight=repmat( "1x", 1, nRows+1 ), ...
                ColumnWidth=repmat( "1x",1, 2*nPad+nCols ) );

            obj.Title = uilabel( Parent=g, Text="MathWords", ...
                HorizontalAlignment="center", ...
                FontName="Bookman Old Style", FontSize=32 );
            obj.Title.Layout.Row = 1;
            obj.Title.Layout.Column = [1 2*nPad+nCols];

            for c = 1:nCols
                for r = 1:nRows
                    obj.GuessGrid(r,c) = uieditfield( Parent=g, ...
                        Editable="off", HorizontalAlignment="center", ...
                        FontName="Consolas", FontSize=28, FontWeight="bold", ...
                        BackgroundColor = [1 1 1] );
                    obj.GuessGrid(r,c).Layout.Row = 1 + r;
                    obj.GuessGrid(r,c).Layout.Column = nPad + c;
                end
            end
        end

        function update( ~ )
            % UPDATE Update the view. This method is empty
            %  because there are no public properties of the view.
        end

        function refresh( obj, ~, ~ )
            % REFRESH Listener callback, responds to model event "RefreshPushed".
            for k = 1:numel( obj.GuessGrid )
                obj.GuessGrid(k).Value = "";
                obj.GuessGrid(k).FontColor = [0 0 0];
                obj.GuessGrid(k).BackgroundColor = [1 1 1];
            end
        end

        function letter( obj, ~, ~ )
            % LETTER Listener callback, responds to model event "LetterPushed".
            r = obj.Model.Row;
            c = obj.Model.Col;
            obj.GuessGrid(r,c).Value = obj.Model.Guesses(r,c);
        end

        function backspace( obj, ~, ~ )
            % BACKSPACE Listener callback, responds to model event "BackPushed".
            r = obj.Model.Row;
            c = obj.Model.Col;
            obj.GuessGrid(r,c).Value = "";
        end

        function enter( obj, ~, ~ )
            % ENTER Listener callback, responds to model event "EnterPushed".
            r = obj.Model.Row;
            for c = 1:size( obj.GuessGrid, 2 )
                obj.GuessGrid(r,c).FontColor = [1 1 1];
                obj.GuessGrid(r,c).BackgroundColor = ...
                    obj.Model.Colors(obj.Model.Matches(c),:);
            end
        end
        
    end

end