classdef ViewHowTo < Component
    % VIEWHOWTO Visualizes how to play and responds to relevant model events.
    %
    %  Copyright 2023 The MathWorks, Inc.

    properties ( Access = private )
        Title (1,1) matlab.ui.control.Label
        Rules (1,1) matlab.ui.control.Label
    end

    methods
        function obj = ViewHowTo( model, namedArgs )
            % VIEWHOWTO ViewHowTo constructor.
            arguments
                model (1,1) ModelMathWords
                namedArgs.?ViewHowTo
            end

            % Call the superclass constructor
            obj@Component( model )

            % Set any user-specified properties
            set( obj, namedArgs )
        end
    end

    methods ( Access = protected )

        function setup( obj )
            % SETUP Initialize the how to play view.
            g = uigridlayout( Parent=obj, ...
                RowHeight=["1x" "9x"], ColumnWidth="1x" );
            
            obj.Title = uilabel( Parent=g, Text="How to Play", ...
                HorizontalAlignment="center", ...
                FontName="Bookman Old Style", FontSize=24 );

            [m,n] = size( obj.Model.Guesses );
            list = ["<b>Goal:</b> guess the MathWord in "+m+" tries or less."; ""; "<ul>" + ...
                "<li>Each guess must be a valid "+n+"-letter word or function.</li>" + ...
                "<li>Each solution will be a core MATLAB function or method.</li>" + ...
                "<li>Letter tiles will change color to show how " + ...
                "close your guess was to the solution:</li></ul>"];

            % see COMPAREWORDS for color order
            colors = join( string( flip( 255*obj.Model.Colors ) ), "," );
            key = "<p style='color:White;background-color:rgb(" + colors + ... 
                ");border:1px solid Black;text-align:center;'>" + ...
                ["The letter is in the word and in the correct location."; ...
                "The letter is in the word but in the wrong location."; ...
                "The letter is not in the word in any location."] + "</p>";

            obj.Rules = uilabel( Parent=g, Text=[list;key], WordWrap="on", ...
                Interpreter = "html", VerticalAlignment="top", ...
                FontName="Bookman Old Style", FontSize=16 );
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

        function enter( ~, ~, ~ )
            % ENTER Listener callback inherited from Component, but not used.
        end
        
    end

end