classdef ( Abstract ) Component < matlab.ui.componentcontainer.ComponentContainer
    %COMPONENT Superclass for implementing views and controllers.
    %
    % Copyright 2023 The MathWorks, Inc.

    properties ( SetAccess = immutable, GetAccess = protected )
        % Application data model.
        Model (1,1) ModelMathWords
        ListenerRefresh (:,1) event.listener {mustBeScalarOrEmpty}
        ListenerLetter (:,1) event.listener {mustBeScalarOrEmpty}
        ListenerBack (:,1) event.listener {mustBeScalarOrEmpty}
        ListenerEnter (:,1) event.listener {mustBeScalarOrEmpty}
    end

    methods

        function obj = Component( model )
            %COMPONENT Component constructor.
            arguments
                model (1,1) ModelMathWords
            end

            % Do not create a default figure parent for the component,
            % and ensure that the component spans its parent. By default,
            % ComponentContainer objects are auto-parenting - that is, a
            % figure is created automatically if no parent argument is 
            % specified.
            obj@matlab.ui.componentcontainer.ComponentContainer( ...
                Parent=[], Units="normalized", Position=[0, 0, 1, 1] )

            % Store the model
            obj.Model = model;

            % Listen for model events
            obj.ListenerRefresh = listener( obj.Model, ...
                "RefreshPushed", @obj.refresh );
            obj.ListenerLetter = listener( obj.Model, ...
                "LetterPushed", @obj.letter );
            obj.ListenerBack = listener( obj.Model, ...
                "BackPushed", @obj.backspace );
            obj.ListenerEnter = listener( obj.Model, ...
                "EnterPushed", @obj.enter );            
        end
    end

    methods ( Abstract, Access = protected )
        % Abstract methods for implementing Listener callbacks.
        refresh( obj, ~, ~ )
        letter( obj, ~, ~ )
        backspace( obj, ~, ~ )
        enter( obj, ~, ~ )
    end

end