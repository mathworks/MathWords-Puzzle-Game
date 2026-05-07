classdef ViewSolved < Component
    % VIEWSOLVED Visualizes solved words and responds to relevant model events.
    %
    %  Copyright 2023 The MathWorks, Inc.

    properties ( Access = private )
        Title (1,1) matlab.ui.control.Label
        UITable (1,1) matlab.ui.control.Table
    end

    methods
        
        function obj = ViewSolved( model, namedArgs )
            % VIEWSOLVED ViewSolved constructor.
            arguments
                model (1,1) ModelMathWords
                namedArgs.?ViewSolved
            end

            % Call the superclass constructor
            obj@Component( model )

            % Set any user-specified properties
            set( obj, namedArgs )
        end
        
        function clear( obj )
            obj.UITable.Data = strings(size(obj.UITable.Data));
        end

    end

    methods ( Access = protected )

        function setup( obj )
            % SETUP Initialize the solution information view.
            g = uigridlayout( Parent=obj, ...
                RowHeight=["1x" "9x"], ColumnWidth="1x");
            obj.Title = uilabel( Parent=g, Text="Solved Words", ...
                HorizontalAlignment="center", ...
                FontName="Bookman Old Style", FontSize=24);
            obj.UITable = uitable( Parent=g, FontName="Consolas", FontSize=16);

            % Initialize table of solved MathWords
            chart( obj )
        end

        function update( ~ )
            % UPDATE Update the view. This method is empty 
            % because there are no public properties of the view.
        end

        function refresh( ~, ~, ~ )
            % REFRESH Listener callback inherited from Component, but not used.
        end

        function letter( ~, ~, ~ )
            % LETTER Listener callback inherited from Component, but not used.
        end

        function backspace( ~, ~, ~ )
            % BACKSPACE Listener callback inherited from Component, but not used.
        end

        function enter( obj, ~, ~ )
            % ENTER Listener callback, responds to model event "EnterPushed".
            idx = obj.Model.Index;
            if obj.Model.Solved(idx) % check if MathWord is solved
                % Add function/word (with hyperlink) to Solutions table
                url = obj.Model.MatWords.DocPage(idx);
                fun = join( obj.Model.Guesses(obj.Model.Row,:), "" );
                obj.UITable.Data(idx) = "<a href='"+url+"'>"+fun+"</a>";
                [tableRow,~] = ind2sub( size(obj.UITable.Data), idx );
                scroll( obj.UITable, "row", tableRow )
            end
            
        end

    end

    methods ( Access = private )

        function chart( obj )
            % Extract possible solutions and initialize table
            words = obj.Model.MatWords.Function;
            nWrds = numel( words );
            nCols = 3;
            nRows = ceil( nWrds/nCols );
            obj.UITable.Data = strings( nRows, nCols );
            obj.UITable.RowName = [];
            obj.UITable.ColumnName = "Column"+(1:nCols);
            for c = 1:nCols
                firstWord = words((c-1)*nRows+1);
                lastWord = words(min(c*nRows,nWrds));
                obj.UITable.ColumnName{c} = extractBefore( firstWord, 2 ) ...
                    + "-" + extractBefore( lastWord, 2 );
            end
            sty = uistyle( HorizontalAlignment="center", Interpreter="html" );
            addStyle( obj.UITable, sty )
        end

    end

end