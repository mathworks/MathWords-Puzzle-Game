classdef LaunchMathWords < handle
    % LAUNCHMATHWORDS Launch MathWords application.
    %
    %  Copyright 2023-2026 The MathWorks, Inc.

    properties
        Model (1,1) ModelMathWords
    end

    properties ( Access = private )
        UIFigure       matlab.ui.Figure
        Toolbar        matlab.ui.container.Toolbar
        RefreshButton  matlab.ui.container.toolbar.PushTool
        HowToToggle    matlab.ui.container.toolbar.ToggleTool
        HintToggle     matlab.ui.container.toolbar.ToggleTool
        SolvedToggle   matlab.ui.container.toolbar.ToggleTool
        MainLayout     matlab.ui.container.GridLayout
        SubLayout      matlab.ui.container.GridLayout
        GuessesView    matlab.ui.componentcontainer.ComponentContainer
        SolvedView     matlab.ui.componentcontainer.ComponentContainer
    end

    methods
        function app = LaunchMathWords( fig )
            % LAUNCHMATHWORDS LaunchMathWords constructor.
            arguments
                fig (1,1) matlab.ui.Figure = uifigure
            end

            % Create Model
            app.Model = ModelMathWords; 

            % Create UIFigure
            app.UIFigure = fig;
            app.UIFigure.Name = "MathWords";
            app.UIFigure.Position = [50 50 1365 575];
            movegui( app.UIFigure, "center" )

            % Create app figure icon
            m = 6; % pixels, size of each color square in icon (mxm)
            n = 3*m + 4; % pixels, total size of icon (nxn)
            mask = false( n, n ); % create mask of grid lines and border
            mask([1 (m+2) (2*m+3) n],:) = true;
            mask(:,[1 (m+2) (2*m+3) n]) = true;
            icon = imresize( ind2rgb( [2 1 2; 3 2 1; 3 3 3], ...
                app.Model.Colors ), [n n], "nearest" ); % 3x3 color squares
            icon(repmat(mask,1,1,3)) = 0; % add grid lines, set to black
            app.UIFigure.Icon = icon;

            % Setup toolbar icons
            iconPath = fullfile( matlabroot, "ui", "icons", "24x24" );
            if isfolder( iconPath ) % should exist for R2022a or newer
                refreshIcon = fullfile( iconPath, "refresh.svg" );
                infoIcon = fullfile( iconPath, "info.svg" );
                hintIcon = fullfile( iconPath, "help.svg" );
                solvedIcon = fullfile( iconPath, "validated.svg" );
            else
                iconPath = fullfile( matlabroot, "toolbox", "matlab", "icons" );
                refreshIcon = fullfile( iconPath, "tool_rotate_3d.png" );
                infoIcon = fullfile( iconPath, "help_rn.png" );
                hintIcon = fullfile( iconPath, "helpicon.gif" );
                solvedIcon = fullfile( iconPath, "book_link.png" );
            end

            % Create Toolbar
            app.Toolbar = uitoolbar( app.UIFigure );

            % Create RefreshButton
            app.RefreshButton = uipushtool( app.Toolbar );
            app.RefreshButton.Tooltip = "New MathWord";
            app.RefreshButton.ClickedCallback = @(~,~) refreshPushed( app );
            app.RefreshButton.Icon = refreshIcon;

            % Create HowToToggle button
            app.HowToToggle = uitoggletool(app.Toolbar);
            app.HowToToggle.Tooltip = "How to Play";
            app.HowToToggle.ClickedCallback = @(~,~) toggleHowTo( app );
            app.HowToToggle.Icon = infoIcon;
            app.HowToToggle.State = "on";

            % Create HintToggle button
            app.HintToggle = uitoggletool( app.Toolbar );
            app.HintToggle.Tooltip = "Need a hint?";
            app.HintToggle.ClickedCallback = @(~,~) toggleHint( app );
            app.HintToggle.Icon = hintIcon;

            % Create SolvedToggle button
            app.SolvedToggle = uitoggletool( app.Toolbar );
            app.SolvedToggle.Tooltip = "Solved Words";
            app.SolvedToggle.ClickedCallback = @(~,~) toggleSolved( app );
            app.SolvedToggle.Icon = solvedIcon;
            app.SolvedToggle.State = "on";

            % Create MainLayout grid (HowTo | Guessing | Solved)
            app.MainLayout = uigridlayout( app.UIFigure );
            app.MainLayout.RowHeight = "1x";
            app.MainLayout.ColumnWidth = ["6x" "11x" "6x"];

            % Create "how to play" view (before/underneath SubLayout)
            ViewHowTo( app.Model, Parent=app.MainLayout );

            % Create solution info view (before/underneath SubLayout)
            % SideBar allows Row/Col assignment before creating SubLayout
            SideBar = uigridlayout( app.MainLayout );
            SideBar.RowHeight = "1x";
            SideBar.ColumnWidth = "1x";
            SideBar.Layout.Row = 1;
            SideBar.Layout.Column = 3;
            app.SolvedView = ViewSolved( app.Model, Parent=SideBar );
            
            % Create SubLayout grid (after/over previous two side bars)
            % which allows it to overflow on top of these side bars
            app.SubLayout = uigridlayout( app.MainLayout );
            app.SubLayout.RowHeight = ["7x" "3x"];
            app.SubLayout.ColumnWidth = "1x";
            app.SubLayout.Layout.Row = 1;
            app.SubLayout.Layout.Column = 2;

            % Create guessing grid view (store view to toggle title/hint)
            app.GuessesView = ViewGuesses( app.Model, Parent=app.SubLayout );

            % Create keyboard controller
            ControlKeyboard( app.Model, Parent=app.SubLayout );
        end
    end

    methods ( Access = protected )

        function refreshPushed( app )
            % REFRESHPUSHED Reset app/model to initial state and get new MathWord.
            app.HintToggle.State = "off";
            toggleHint( app )

            if all( app.Model.Solved )
                clear( app.SolvedView )
            end
            refresh( app.Model )
        end

        function toggleHowTo( app )
            % TOGGLEHOWTO Toggle how to view, expand/contract middle to fill.
            if app.HowToToggle.State
                cols = [2 app.SubLayout.Layout.Column(end)];
            else
                cols = [1 app.SubLayout.Layout.Column(end)];
            end
            app.SubLayout.Layout.Column = unique( cols );
        end

        function toggleHint( app )
            % TOGGLEHINT Toggle ViewGuesses Title/Hint.
            if app.HintToggle.State
                hint = app.Model.MatWords.Hint(app.Model.Index);
                app.GuessesView.Title.Text = "Hint: " + hint;
                app.GuessesView.Title.FontSize = 18;
                app.GuessesView.Title.FontAngle = "italic";
            else
                app.GuessesView.Title.Text = "MathWords";
                app.GuessesView.Title.FontSize = 32;
                app.GuessesView.Title.FontAngle = "normal";                
            end
        end

        function toggleSolved( app )
            % TOGGLESOLVED Toggle solved info view, expand/contract middle to fill.
            if app.SolvedToggle.State
                cols = [app.SubLayout.Layout.Column(1) 2];
            else
                cols = [app.SubLayout.Layout.Column(1) 3];
            end
            app.SubLayout.Layout.Column = unique( cols );
        end

    end

end