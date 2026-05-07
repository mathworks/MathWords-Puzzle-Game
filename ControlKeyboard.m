classdef ControlKeyboard < Component
    % CONTROLKEYBOARD Provides interactive control of model.
    %
    %  Copyright 2023 The MathWorks, Inc.
    
    properties ( Access = private )
        Keyboard (3,11) matlab.ui.control.Button % := size(Keys)
    end

    properties (Constant)
        KeyColor (1,3) double = [212 214 217]/255
        Keys (3,11) string = ...
            ["Q","W","E","R","T","Y","U","I","O","P","⌫"; ...
             "","A","S","D","F","G","H","J","K","L",""; ...
             "","","Z","X","C","V","B","N","M","","⏎"]
    end

    methods

        function obj = ControlKeyboard( model, namedArgs )
            % CONTROLKEYBOARD Controller constructor.
            arguments
                model (1,1) ModelMathWords
                namedArgs.?ControlKeyboard
            end
            
            % Call the superclass constructor
            obj@Component( model )

            % Set any user-specified properties
            set( obj, namedArgs )
        end

    end
    
    methods ( Access = protected )

        function setup( obj )
            % SETUP Initialize keyboard controller.
            % Create grid of keyboard buttons
            [nRows,nCols] = size( obj.Keyboard ); % = size(obj.keys)
            g = uigridlayout( Parent=obj, ...
                RowHeight=repmat( "1x", 1, nRows ), ...
                ColumnWidth=repmat( "1x", 1, nCols ) );

            % Add buttons for keys
            for c = 1:nCols
                for r = 1:nRows
                    if (obj.Keys(r,c)~="")
                        obj.Keyboard(r,c) = ...
                            uibutton( Parent=g, Text=obj.Keys(r,c), ...
                            FontName="Consolas", FontSize=28, FontWeight="bold", ...
                            BackgroundColor = obj.KeyColor, ...
                            ButtonPushedFcn=@obj.letterPushed );
                        obj.Keyboard(r,c).Layout.Row = r;
                        obj.Keyboard(r,c).Layout.Column = c;
                    end
                end
            end

            % Change backspace button callback
            b = ("⌫" == obj.Keys);
            obj.Keyboard(b).ButtonPushedFcn = @obj.backPushed;
            obj.Keyboard(b).FontSize = 24;

            % Change enter button callback and layout
            b = ("⏎" == obj.Keys);
            obj.Keyboard(b).ButtonPushedFcn = @obj.enterPushed;
            obj.Keyboard(b).Layout.Row = [(nRows-1) nRows];
            obj.Keyboard(b).FontSize = 24;
        end
        
        function update( ~ )
            % UPDATE Update the controller. This method is empty because 
            %  there are no public properties of the controller.
        end

        function refresh( obj, ~, ~ )
            % REFRESH Listener callback, responds to model event "RefreshPushed".
            for k = 1:numel( obj.Keys )
                if (obj.Keys(k) ~= "")
                    obj.Keyboard(k).FontColor = [0 0 0];
                    obj.Keyboard(k).BackgroundColor = obj.KeyColor;
                end
            end
        end

        function letter( ~, ~, ~ )
            % LETTER Listener callback inherited from Component, but not used.
        end

        function backspace( ~, ~, ~ )
            % BACKSPACE Listener callback inherited from Component, but not used.
        end

        function enter( obj, ~, ~ )
            % ENTER Listener callback, responds to model event "EnterPushed".
            guess = obj.Model.Guesses(obj.Model.Row,:);
            for k = 1:numel( guess )
                % For duplicate letters, set color to max spot/color
                j = (guess == guess(k));
                j = max( obj.Model.Matches(j) );
                b = (guess(k) == obj.Keys); 
                obj.Keyboard(b).FontColor = [1 1 1];
                obj.Keyboard(b).BackgroundColor = obj.Model.Colors(j,:);
            end
        end

    end

    methods ( Access = private )

        function letterPushed( obj, src, ~ )
            % LETTERPUSHED Respond to user pushing keyboard letter button.
            letter( obj.Model, src.Text )
            alert( obj ) % if input not valid
        end

        function backPushed( obj, ~, ~ )
            % BACKPUSHED Respond to user pushing keyboard backspace button.
            backspace( obj.Model )
            alert( obj ) % if input not valid
        end

        function enterPushed( obj, ~, ~ )
            % ENTERPUSHED Respond to user pushing keyboard enter button.
            enter( obj.Model )
            alert( obj ) % if input not valid
        end

        function alert( obj )
            if any( obj.Model.Message ~= "" )
                % Get parent figure and display Message
                fig = ancestor( obj.Parent, "figure" );
                uialert( fig, obj.Model.Message, obj.Model.Title, ...
                    Icon=obj.Model.Icon , Interpreter="html" )
            end
        end

    end

end