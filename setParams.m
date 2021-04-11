classdef setParams < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        SaveButton                      matlab.ui.control.Button
        MultiplierEditFieldLabel        matlab.ui.control.Label
        MultiplierEditField             matlab.ui.control.EditField
        NospikesEditFieldLabel          matlab.ui.control.Label
        NospikesEditField               matlab.ui.control.NumericEditField
        NoscalesEditFieldLabel          matlab.ui.control.Label
        NoscalesEditField               matlab.ui.control.NumericEditField
        WidthmsEditFieldLabel           matlab.ui.control.Label
        WidthmsEditField                matlab.ui.control.EditField
        GroundedEditFieldLabel          matlab.ui.control.Label
        GroundedEditField               matlab.ui.control.EditField
        CostparametersEditFieldLabel    matlab.ui.control.Label
        CostparametersEditField         matlab.ui.control.EditField
        WaveletsEditFieldLabel          matlab.ui.control.Label
        WaveletsEditField               matlab.ui.control.EditField
        SubsamplingEditFieldLabel       matlab.ui.control.Label
        SubsamplingEditField            matlab.ui.control.EditField
        MinvethresholdEditFieldLabel    matlab.ui.control.Label
        MinvethresholdEditField         matlab.ui.control.NumericEditField
        MaxvethresholdEditField_2Label  matlab.ui.control.Label
        MaxvethresholdEditField_2       matlab.ui.control.NumericEditField
        MaxvethresholdEditFieldLabel    matlab.ui.control.Label
        MaxvethresholdEditField         matlab.ui.control.NumericEditField
        SpiketimeunitDropDownLabel      matlab.ui.control.Label
        SpiketimeunitDropDown           matlab.ui.control.DropDown
    end

    
    properties (Access = private)
    end
    
    methods (Access = private)
        
        function r = list2mat(app, str, flag)
            str = strrep(str, ' ', '');
            str = split(str, ',');
            if flag
                for i = 1:numel(str)
                    r(i) = str2num(str{i});
                end
            else
                r = str;
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Callback function
        function SpiketimeunitDropDownValueChanged(app, event)
            value = app.SpiketimeunitDropDown.Value;
        end

        % Button pushed function: SaveButton
        function SaveButtonPushed(app, event)
            
            params = struct();
            params.nSpikes = app.NospikesEditField.Value;
            params.nScales = app.NoscalesEditField.Value;
            
            wid = app.WidthmsEditField.Value;
            params.wid = list2mat(app, wid, 1);
            
            
            if app.GroundedEditField.Value
                grd = app.GroundedEditField.Value;
                params.grd = list2mat(app, grd, 1);
            else
                params.grd = [];
            end
            
            costList = app.CostparametersEditField.Value;
            params.costList = list2mat(app, costList, 1);
            
            wnameList = app.WaveletsEditField.Value;
            params.wnameList = list2mat(app, wnameList, 0);
            
            if app.SubsamplingEditField.Value
                subsample_time = app.SubsamplingEditField.Value;
                params.subsample_time = list2mat(app, subsample_time, 1);
            end
            
            params.minPeakThrMultiplier = app.MinvethresholdEditField.Value;
            params.maxPeakThrMultiplier = app.MaxvethresholdEditField_2.Value;
            params.posPeakThrMultiplier = app.MaxvethresholdEditField.Value;
            
            unit = strrep(app.SpiketimeunitDropDown.Value, '[', '');
            unit = strrep(unit, ']', '');
            params.unit = unit;
            
            multipliers = app.MultiplierEditField.Value;
            params.thresholds = list2mat(app, multipliers, 0);
            params.multiplier = str2num(multipliers(1));
            
            save('params.mat', 'params');
            delete(app);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [550 200 290 450];
            app.UIFigure.Name = 'Set spike detection parameters';

            % Create SaveButton
            app.SaveButton = uibutton(app.UIFigure, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.Position = [144 1 100 22];
            app.SaveButton.Text = 'Save';

            % Create MultiplierEditFieldLabel
            app.MultiplierEditFieldLabel = uilabel(app.UIFigure);
            app.MultiplierEditFieldLabel.HorizontalAlignment = 'right';
            app.MultiplierEditFieldLabel.Position = [74 403 55 22];
            app.MultiplierEditFieldLabel.Text = 'Multiplier';
            app.MultiplierEditFieldLabel.Tooltip = 'The threshold multiplier used in spike detection. List separated by commas. At least 1 required. First entry will be used to extract waveforms to adapt the custom wavelet.';

            % Create MultiplierEditField
            app.MultiplierEditField = uieditfield(app.UIFigure, 'text');
            app.MultiplierEditField.Position = [144 403 100 22];
            app.MultiplierEditField.Value = '2.5';
            app.MultiplierEditField.Tooltip = app.MultiplierEditField.Tooltip;
            app.MultiplierEditField.HorizontalAlignment = 'right';
            app.MultiplierEditField.Tooltip = app.MultiplierEditFieldLabel.Tooltip;
            
            % Create NospikesEditFieldLabel
            app.NospikesEditFieldLabel = uilabel(app.UIFigure);
            app.NospikesEditFieldLabel.HorizontalAlignment = 'right';
            app.NospikesEditFieldLabel.Position = [67 369 62 22];
            app.NospikesEditFieldLabel.Text = 'No. spikes';
            app.NospikesEditFieldLabel.Tooltip = 'Number of spikes used to adapt the wavelet, recommended: 200';

            % Create NospikesEditField
            app.NospikesEditField = uieditfield(app.UIFigure, 'numeric');
            app.NospikesEditField.Limits = [50 1000];
            app.NospikesEditField.Position = [144 369 100 22];
            app.NospikesEditField.Value = 200;
            app.NospikesEditField.Tooltip = app.NospikesEditFieldLabel.Tooltip;

            % Create NoscalesEditFieldLabel
            app.NoscalesEditFieldLabel = uilabel(app.UIFigure);
            app.NoscalesEditFieldLabel.HorizontalAlignment = 'right';
            app.NoscalesEditFieldLabel.Position = [67 335 62 22];
            app.NoscalesEditFieldLabel.Text = 'No. scales';
            app.NoscalesEditFieldLabel.Tooltip = 'Number of scales across which wavelet will be stretched; recommended: 5';

            % Create NoscalesEditField
            app.NoscalesEditField = uieditfield(app.UIFigure, 'numeric');
            app.NoscalesEditField.Limits = [2 inf];
            app.NoscalesEditField.Position = [144 335 100 22];
            app.NoscalesEditField.Value = 5;
            app.NoscalesEditField.Tooltip = app.NoscalesEditField.Tooltip;

            % Create WidthmsEditFieldLabel
            app.WidthmsEditFieldLabel = uilabel(app.UIFigure);
            app.WidthmsEditFieldLabel.HorizontalAlignment = 'right';
            app.WidthmsEditFieldLabel.Position = [66 301 63 22];
            app.WidthmsEditFieldLabel.Text = 'Width [ms]';
            app.WidthmsEditFieldLabel.Tooltip = 'Width of the voltage transient (spike) in [ms], recommended: 0.4, 0.8';

            % Create WidthmsEditField
            app.WidthmsEditField = uieditfield(app.UIFigure, 'text');
            app.WidthmsEditField.HorizontalAlignment = 'right';
            app.WidthmsEditField.Position = [144 301 100 22];
            app.WidthmsEditField.Value = '0.4, 0.8';
            app.WidthmsEditField.Tooltip = app.WidthmsEditFieldLabel.Tooltip;

            % Create GroundedEditFieldLabel
            app.GroundedEditFieldLabel = uilabel(app.UIFigure);
            app.GroundedEditFieldLabel.HorizontalAlignment = 'right';
            app.GroundedEditFieldLabel.Position = [70 267 59 22];
            app.GroundedEditFieldLabel.Text = 'Grounded';
            app.GroundedEditFieldLabel.Tooltip = 'Vector of grounded electrode XY coordinates separated by commas; e.g. 15, 23, 32';

            % Create GroundedEditField
            app.GroundedEditField = uieditfield(app.UIFigure, 'text');
            app.GroundedEditField.HorizontalAlignment = 'right';
            app.GroundedEditField.Position = [144 267 100 22];
            app.GroundedEditField.Tooltip = app.GroundedEditFieldLabel.Tooltip;
            
            % Create CostparametersEditFieldLabel
            app.CostparametersEditFieldLabel = uilabel(app.UIFigure);
            app.CostparametersEditFieldLabel.HorizontalAlignment = 'right';
            app.CostparametersEditFieldLabel.Position = [34 233 95 22];
            app.CostparametersEditFieldLabel.Text = 'Cost parameters';
            app.CostparametersEditFieldLabel.Tooltip = 'List of cost parameters (separated by comma).';

            % Create CostparametersEditField
            app.CostparametersEditField = uieditfield(app.UIFigure, 'text');
            app.CostparametersEditField.HorizontalAlignment = 'right';
            app.CostparametersEditField.Position = [144 233 100 22];
            app.CostparametersEditField.Value = '0';
            app.CostparametersEditField.Tooltip = app.CostparametersEditFieldLabel.Tooltip;

            % Create WaveletsEditFieldLabel
            app.WaveletsEditFieldLabel = uilabel(app.UIFigure);
            app.WaveletsEditFieldLabel.HorizontalAlignment = 'right';
            app.WaveletsEditFieldLabel.Position = [75 199 54 22];
            app.WaveletsEditFieldLabel.Text = 'Wavelets';
            app.WaveletsEditFieldLabel.Tooltip = 'List of wavelets to be used in spike detection. Available: mea, bior1.5, bior1.3, db2';
 
            % Create WaveletsEditField
            app.WaveletsEditField = uieditfield(app.UIFigure, 'text');
            app.WaveletsEditField.HorizontalAlignment = 'right';
            app.WaveletsEditField.Position = [144 199 100 22];
            app.WaveletsEditField.Value = 'mea';
            app.WaveletsEditField.Tooltip = app.WaveletsEditFieldLabel.Tooltip;
            
            % Create SubsamplingEditFieldLabel
            app.SubsamplingEditFieldLabel = uilabel(app.UIFigure);
            app.SubsamplingEditFieldLabel.HorizontalAlignment = 'right';
            app.SubsamplingEditFieldLabel.Position = [53 166 76 22];
            app.SubsamplingEditFieldLabel.Text = 'Subsampling';
            app.SubsamplingEditFieldLabel.Tooltip = '(optional) Vector of start and end times in the recording to be analysed in [s], e.g. ‘30, 60’ will analyze 30 s of the recording between 30th and 60th second';

            % Create SubsamplingEditField
            app.SubsamplingEditField = uieditfield(app.UIFigure, 'text');
            app.SubsamplingEditField.HorizontalAlignment = 'right';
            app.SubsamplingEditField.Position = [144 166 100 22];
            app.SubsamplingEditField.Tooltip = app.SubsamplingEditFieldLabel.Tooltip;

            % Create MinvethresholdEditFieldLabel
            app.MinvethresholdEditFieldLabel = uilabel(app.UIFigure);
            app.MinvethresholdEditFieldLabel.HorizontalAlignment = 'right';
            app.MinvethresholdEditFieldLabel.Position = [30 133 99 22];
            app.MinvethresholdEditFieldLabel.Text = 'Min -ve threshold';
            app.MinvethresholdEditFieldLabel.Tooltip = 'Threshold that specifies the minimum negative peak amplitude of a spike (type in negative sign)';

            % Create MinvethresholdEditField
            app.MinvethresholdEditField = uieditfield(app.UIFigure, 'numeric');
            app.MinvethresholdEditField.Position = [144 133 100 22];
            app.MinvethresholdEditField.Value = -5;
            app.MinvethresholdEditField.Tooltip = app.MinvethresholdEditFieldLabel.Tooltip;

            % Create MaxvethresholdEditField_2Label
            app.MaxvethresholdEditField_2Label = uilabel(app.UIFigure);
            app.MaxvethresholdEditField_2Label.HorizontalAlignment = 'right';
            app.MaxvethresholdEditField_2Label.Position = [20 100 102 22];
            app.MaxvethresholdEditField_2Label.Text = 'Max -ve threshold';
            app.MaxvethresholdEditField_2Label.Tooltip = 'Threshold that specifies the maximum negative peak amplitude of a spike (type in the negative sign)';

            % Create MaxvethresholdEditField_2
            app.MaxvethresholdEditField_2 = uieditfield(app.UIFigure, 'numeric');
            app.MaxvethresholdEditField_2.Position = [144 100 100 22];
            app.MaxvethresholdEditField_2.Value = -100;
            app.MaxvethresholdEditField_2.Tooltip = app.MaxvethresholdEditField_2Label.Tooltip;

            % Create MaxvethresholdEditFieldLabel
            app.MaxvethresholdEditFieldLabel = uilabel(app.UIFigure);
            app.MaxvethresholdEditFieldLabel.HorizontalAlignment = 'right';
            app.MaxvethresholdEditFieldLabel.Position = [17 67 105 22];
            app.MaxvethresholdEditFieldLabel.Text = 'Max +ve threshold';
            app.MaxvethresholdEditFieldLabel.Tooltip = 'Threshold that specifies the maximum positive peak amplitude of a spike (type in the positive sign)';
            
            % Create MaxvethresholdEditField
            app.MaxvethresholdEditField = uieditfield(app.UIFigure, 'numeric');
            app.MaxvethresholdEditField.Position = [144 67 100 22];
            app.MaxvethresholdEditField.Value = 100;
            app.MaxvethresholdEditField.Tooltip = app.MaxvethresholdEditFieldLabel.Tooltip;
            
            % Create SpiketimeunitDropDownLabel
            app.SpiketimeunitDropDownLabel = uilabel(app.UIFigure);
            app.SpiketimeunitDropDownLabel.Position = [17 34 100 22];
            app.SpiketimeunitDropDownLabel.HorizontalAlignment = 'right';
            app.SpiketimeunitDropDownLabel.Text = 'Spike time unit';
            app.SpiketimeunitDropDownLabel.Tooltip = 'Select the time unit in which the spikes will be saved';
            
            % Create SpiketimeunitDropDown
            app.SpiketimeunitDropDown = uidropdown(app.UIFigure);
            app.SpiketimeunitDropDown.Position = [144 34 100 22];
            app.SpiketimeunitDropDown.Items = {'[frames]', '[s]', '[ms]'};
            app.SpiketimeunitDropDown.ValueChangedFcn = createCallbackFcn(app, @SpiketimeunitDropDownValueChanged, true);
            app.SpiketimeunitDropDown.Value = '[s]';
            app.SpiketimeunitDropDown.Tooltip = app.SpiketimeunitDropDownLabel.Tooltip;

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