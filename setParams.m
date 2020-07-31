classdef setParams < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                  matlab.ui.Figure
        Wid_minEditFieldLabel     matlab.ui.control.Label
        Wid_minEditField          matlab.ui.control.NumericEditField
        LEditFieldLabel           matlab.ui.control.Label
        LEditField                matlab.ui.control.NumericEditField
        NsEditFieldLabel          matlab.ui.control.Label
        NsEditField               matlab.ui.control.NumericEditField
        multiplierEditFieldLabel  matlab.ui.control.Label
        multiplierEditField       matlab.ui.control.NumericEditField
        n_spikesEditFieldLabel    matlab.ui.control.Label
        n_spikesEditField         matlab.ui.control.NumericEditField
        wnameEditFieldLabel       matlab.ui.control.Label
        wnameEditField            matlab.ui.control.EditField
        SaveButton                matlab.ui.control.Button
        Wid_maxEditFieldLabel     matlab.ui.control.Label
        Wid_maxEditField          matlab.ui.control.NumericEditField
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: SaveButton
        function SaveButtonPushed(app, event)
params = struct;
Wid_min = app.Wid_minEditField.Value;
Wid_max = app.Wid_maxEditField.Value;
Wid = [Wid_min Wid_max];
params.Wid = Wid;
params.L = app.LEditField.Value;
params.Ns = app.NsEditField.Value;
params.n_spikes = app.n_spikesEditField.Value;
params.wname = app.wnameEditField.Value;
params.multiplier = app.multiplierEditField.Value;
save('params.mat','-struct','params');
delete(app.UIFigure)
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [500 300 226 299];
            app.UIFigure.Name = 'Parameters:';

            % Create Wid_minEditFieldLabel
            app.Wid_minEditFieldLabel = uilabel(app.UIFigure);
            app.Wid_minEditFieldLabel.HorizontalAlignment = 'right';
            app.Wid_minEditFieldLabel.Position = [25 248 52 22];
            app.Wid_minEditFieldLabel.Text = 'Wid_min';

            % Create Wid_minEditField
            app.Wid_minEditField = uieditfield(app.UIFigure, 'numeric');
            app.Wid_minEditField.Position = [92 248 100 22];
            app.Wid_minEditField.Value = 0.5;

            % Create LEditFieldLabel
            app.LEditFieldLabel = uilabel(app.UIFigure);
            app.LEditFieldLabel.HorizontalAlignment = 'right';
            app.LEditFieldLabel.Position = [51 188 25 22];
            app.LEditFieldLabel.Text = 'L';

            % Create LEditField
            app.LEditField = uieditfield(app.UIFigure, 'numeric');
            app.LEditField.Position = [91 188 100 22];

            % Create NsEditFieldLabel
            app.NsEditFieldLabel = uilabel(app.UIFigure);
            app.NsEditFieldLabel.HorizontalAlignment = 'right';
            app.NsEditFieldLabel.Position = [51 158 25 22];
            app.NsEditFieldLabel.Text = 'Ns';

            % Create NsEditField
            app.NsEditField = uieditfield(app.UIFigure, 'numeric');
            app.NsEditField.Position = [91 158 100 22];
            app.NsEditField.Value = 5;

            % Create multiplierEditFieldLabel
            app.multiplierEditFieldLabel = uilabel(app.UIFigure);
            app.multiplierEditFieldLabel.HorizontalAlignment = 'right';
            app.multiplierEditFieldLabel.Position = [21 128 54 22];
            app.multiplierEditFieldLabel.Text = 'multiplier';

            % Create multiplierEditField
            app.multiplierEditField = uieditfield(app.UIFigure, 'numeric');
            app.multiplierEditField.Position = [90 128 100 22];
            app.multiplierEditField.Value = 4;

            % Create n_spikesEditFieldLabel
            app.n_spikesEditFieldLabel = uilabel(app.UIFigure);
            app.n_spikesEditFieldLabel.HorizontalAlignment = 'right';
            app.n_spikesEditFieldLabel.Position = [21 98 53 22];
            app.n_spikesEditFieldLabel.Text = 'n_spikes';

            % Create n_spikesEditField
            app.n_spikesEditField = uieditfield(app.UIFigure, 'numeric');
            app.n_spikesEditField.Position = [89 98 100 22];
            app.n_spikesEditField.Value = 200;

            % Create wnameEditFieldLabel
            app.wnameEditFieldLabel = uilabel(app.UIFigure);
            app.wnameEditFieldLabel.HorizontalAlignment = 'right';
            app.wnameEditFieldLabel.Position = [31 68 44 22];
            app.wnameEditFieldLabel.Text = 'wname';

            % Create wnameEditField
            app.wnameEditField = uieditfield(app.UIFigure, 'text');
            app.wnameEditField.Position = [90 68 100 22];
            app.wnameEditField.Value = 'mea';

            % Create SaveButton
            app.SaveButton = uibutton(app.UIFigure, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.Position = [89 31 100 22];
            app.SaveButton.Text = 'Save';

            % Create Wid_maxEditFieldLabel
            app.Wid_maxEditFieldLabel = uilabel(app.UIFigure);
            app.Wid_maxEditFieldLabel.HorizontalAlignment = 'right';
            app.Wid_maxEditFieldLabel.Position = [22 218 55 22];
            app.Wid_maxEditFieldLabel.Text = 'Wid_max';

            % Create Wid_maxEditField
            app.Wid_maxEditField = uieditfield(app.UIFigure, 'numeric');
            app.Wid_maxEditField.Position = [92 218 100 22];
            app.Wid_maxEditField.Value = 1;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = setParams

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end