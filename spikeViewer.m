classdef spikeViewer < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                   matlab.ui.Figure
        GridLayout                 matlab.ui.container.GridLayout
        LeftPanel                  matlab.ui.container.Panel
        WaveletDropDownLabel       matlab.ui.control.Label
        WaveletDropDown            matlab.ui.control.DropDown
        LoadfileButton             matlab.ui.control.Button
        Lamp                       matlab.ui.control.Lamp
        PlotButton                 matlab.ui.control.Button
        ElectrodeXYEditFieldLabel  matlab.ui.control.Label
        ElectrodeXYEditField       matlab.ui.control.NumericEditField
        BinmsEditFieldLabel        matlab.ui.control.Label
        BinmsEditField             matlab.ui.control.NumericEditField
        CenterPanel                matlab.ui.container.Panel
        PreviousButton             matlab.ui.control.Button
        NextButton                 matlab.ui.control.Button
        SpikeSliderLabel           matlab.ui.control.Label
        SpikeSlider                matlab.ui.control.Slider
        traceAx                    matlab.ui.control.UIAxes
        RightPanel                 matlab.ui.container.Panel
        TPButton                   matlab.ui.control.Button
        FNButton                   matlab.ui.control.Button
        FPButton                   matlab.ui.control.Button
        SensitivityEditFieldLabel  matlab.ui.control.Label
        SensitivityEditField       matlab.ui.control.EditField
        PrecisionEditFieldLabel    matlab.ui.control.Label
        PrecisionEditField         matlab.ui.control.EditField
        SaveButton                 matlab.ui.control.Button
        spikeAx                    matlab.ui.control.UIAxes
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
        twoPanelWidth = 768;
    end

    
    properties (Access = public)
        channels; % Electrode XY coordinates
        channel; % Electrode to plot
        spikeDetectionResult;
        spikeTimes;
        spikeWaveforms;
        wname;
        trace;
        rawData;
        spikeVector;
        subsampleTime = [];
        spikeIndex = 1;
        binMs;
        stdTrace;
        yOffset;
        spikes;
        FN = 0;
        FP = 0;
        TP = 0;
        fName;
    end
    
    methods (Access = private)
        
        function filteredTrace = bandpassFilter(app, data)
            
            lowpass = 600;
            highpass = 8000;
            wn = [lowpass highpass] / (25000 / 2);
            filterOrder = 3;
            [b, a] = butter(filterOrder, wn);
            filteredTrace = filtfilt(b, a, double(data));
            
        end
        
        function plotBin(app)
            
            cla(app.traceAx, 'reset');
            
            st = app.spikeVector(app.spikeIndex) - (app.binMs/2)*25;
            en = app.spikeVector(app.spikeIndex) + (app.binMs/2)*25;

            plot(app.traceAx, app.trace(st:en), 'k');
            
            xlim(app.traceAx, [1 (app.binMs*25+1)]);
            ylim(app.traceAx, [-app.stdTrace*7 app.yOffset+3]);
            
            ylabel(app.traceAx, ['Voltage (' char(956) 'V)']);
            set(app.traceAx, ...
                'XColor','none', ...
                'Box', 'off');
            
            hold(app.traceAx, 'on');
            
            % Plot spike markers
            pos = [find(app.spikeVector >= st) find(app.spikeVector <= en)];
            spVector = app.spikeVector(pos) - st;
            y = repmat(app.yOffset, length(pos), 1);
            scatter(app.traceAx, (spVector)', y(:,1), 'v','filled');
            
        end
        
        function plotSpike(app)
            cla(app.spikeAx, 'reset');
            spike = app.spikes(:, app.spikeIndex);
            spike = spline(1:length(spike), spike, linspace(1, length(spike), 100));
            plot(app.spikeAx, spike,...
                'k', "LineWidth", 2);
            xlim(app.spikeAx, [1 100]);
            ylim(app.spikeAx, [min(spike)-2 max(spike)+2]);
            ylabel(app.spikeAx, ['Voltage (' char(956) 'V)']);
            set(app.spikeAx, ...
                'XColor','none', ...
                'Box', 'off');
        end
        
        function plotOverlay(app)
            cla(app.spikeAx, 'reset');
            
            plot(app.spikeAx, app.spikes(:, 1:200),...
                'Color', [0.9 0.9 0.9],...
                'LineWidth', 0.2);
            
            hold(app.spikeAx, 'on');
            
            aveSpike = median(app.spikes');
            plot(app.spikeAx, aveSpike,...
                'Color', [0 0 0],...
                'LineWidth', 1.5);
            
            xlim(app.spikeAx, [1 51]);
            ylim(app.spikeAx, [-7*app.stdTrace 4*app.stdTrace]);
            ylabel(app.spikeAx, ['Voltage (' char(956) 'V)']);
            set(app.spikeAx, ...
                'XColor','none', ...
                'Box', 'off');
            
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: LoadfileButton
        function LoadfileButtonPushed(app, event)
            
            % Load spike detection results
            app.fName = uigetfile('*.mat');
            fileName = app.fName;
            file = load(fileName);
            
            % Assign variables
            app.channels = file.channels;
            app.spikeDetectionResult = file.spikeDetectionResult;
            app.spikeTimes = file.spikeTimes;
            app.spikeWaveforms = file.spikeWaveforms;
            app.Lamp.Color = [0.39,0.83,0.07];
            app.WaveletDropDown.Items = strrep(fieldnames(app.spikeTimes{1}), 'p', '.');
            
            % Load raw data
            rawFileName = [fileName(1:strfind(fileName, '_L')-1) '.mat'];
            rawFilePath = [pwd filesep];
            rawFile = load([rawFilePath rawFileName]);
            app.rawData = rawFile.dat;
            
            app.wname = app.WaveletDropDown.Items(1);
            app.wname = app.wname{1};
            
            if isfield(app.spikeDetectionResult.params, 'subsample_time')
                app.subsampleTime = app.spikeDetectionResult.params.subsample_time;
            end
        end

        % Value changed function: WaveletDropDown
        function WaveletDropDownValueChanged(app, event)
            value = app.WaveletDropDown.Value;
            app.wname = strrep(value, '.', 'p');
        end

        % Value changed function: ElectrodeXYEditField
        function ElectrodeXYEditFieldValueChanged(app, event)
            value = app.ElectrodeXYEditField.Value;
            app.channel = find(app.channels == value);
            rawTrace = app.rawData(:, app.channel);
            app.trace = bandpassFilter(app, rawTrace);
            app.stdTrace = std(app.trace);
            app.yOffset = max(app.trace)-2;
            
            app.spikeVector = app.spikeTimes{app.channel}.(app.wname);
            app.spikeVector = app.spikeVector * 25000;
            app.spikes = app.spikeWaveforms{app.channel}.(app.wname);
            
            spikeCount = length(app.spikeVector);
            app.SpikeSlider.Limits = [1, spikeCount];
            app.SpikeSlider.MajorTicks = [1, round(spikeCount/5), ...
                round(2*spikeCount/5), ...
                round(3*spikeCount/5), ...
                round(4*spikeCount/5), ...
                spikeCount];
        end

        % Button pushed function: PlotButton
        function PlotButtonPushed(app, event)
            
            % Set limits of the x axis
            if ~isempty(app.subsampleTime)
                st = app.subsampleTime(1)*25000;
                en = app.subsampleTime(2)*25000;
                app.spikeVector = app.spikeVector+st;
            else
                st = 1;
                en = length(app.trace);
            end
            
            cla(app.traceAx, 'reset');
            
            % Plot raw trace
            plot(app.traceAx, app.trace, 'k');
            xlim(app.traceAx, [st en]);
            ylabel(app.traceAx, ['Voltage (' char(956) 'V)']);
            
            
            set(app.traceAx, ...
                'XColor','none', ...
                'Box', 'off');
            
            hold(app.traceAx, 'on');
            
            % Plot spike markers
            y = repmat(app.yOffset, length(app.spikeVector), 1);
            scatter(app.traceAx, (app.spikeVector)', y(:,1), 'v','filled');
            
            plotOverlay(app);
        end

        % Value changed function: BinmsEditField
        function BinmsEditFieldValueChanged(app, event)
            value = app.BinmsEditField.Value;
            app.binMs = value;
        end

        % Value changed function: SpikeSlider
        function SpikeSliderValueChanged(app, event)
            value = app.SpikeSlider.Value;
            app.spikeIndex = round(value);
            plotBin(app);
            plotSpike(app);
        end

        % Button pushed function: PreviousButton
        function PreviousButtonPushed(app, event)
            if app.spikeIndex-1 > 0
                app.spikeIndex = app.spikeIndex - 1;
                plotBin(app);
                plotSpike(app);
            end
        end

        % Button pushed function: NextButton
        function NextButtonPushed(app, event)
            if app.spikeIndex+1 <= length(app.spikeVector)
                app.spikeIndex = app.spikeIndex + 1;
                plotBin(app);
                plotSpike(app);
            end
        end

        % Button pushed function: TPButton
        function TPButtonPushed(app, event)
            app.TP = app.TP + 1;
            s = 100*app.TP/(app.TP + app.FN);
            p = 100*app.TP/(app.TP + app.FP);
            app.SensitivityEditField.Value = [num2str(s), ' %'];
            app.PrecisionEditField.Value = [num2str(p), '%'];
        end

        % Button pushed function: FNButton
        function FNButtonPushed(app, event)
            app.FN = app.FN + 1;
            s = 100*app.TP/(app.TP + app.FN);
            p = 100*app.TP/(app.TP + app.FP);
            app.SensitivityEditField.Value = [num2str(s), ' %'];
            app.PrecisionEditField.Value = [num2str(p), '%'];
        end

        % Button pushed function: FPButton
        function FPButtonPushed(app, event)
            app.FP = app.FP + 1;
            s = 100*app.TP/(app.TP + app.FN);
            p = 100*app.TP/(app.TP + app.FP);
            app.SensitivityEditField.Value = [num2str(s), ' %'];
            app.PrecisionEditField.Value = [num2str(p), '%'];
        end

        % Button pushed function: SaveButton
        function SaveButtonPushed(app, event)
            stats = struct();
            stats.(app.wname).sensitivity = app.SensitivityEditField.Value;
            stats.(app.wname).precision = app.PrecisionEditField.Value;
            save(app.fName, 'stats','-append');

        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 3x1 grid
                app.GridLayout.RowHeight = {459, 459, 459};
                app.GridLayout.ColumnWidth = {'1x'};
                app.CenterPanel.Layout.Row = 1;
                app.CenterPanel.Layout.Column = 1;
                app.LeftPanel.Layout.Row = 2;
                app.LeftPanel.Layout.Column = 1;
                app.RightPanel.Layout.Row = 3;
                app.RightPanel.Layout.Column = 1;
            elseif (currentFigureWidth > app.onePanelWidth && currentFigureWidth <= app.twoPanelWidth)
                % Change to a 2x2 grid
                app.GridLayout.RowHeight = {459, 459};
                app.GridLayout.ColumnWidth = {'1x', '1x'};
                app.CenterPanel.Layout.Row = 1;
                app.CenterPanel.Layout.Column = [1,2];
                app.LeftPanel.Layout.Row = 2;
                app.LeftPanel.Layout.Column = 1;
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 2;
            else
                % Change to a 1x3 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {159, '1x', 247};
                app.LeftPanel.Layout.Row = 1;
                app.LeftPanel.Layout.Column = 1;
                app.CenterPanel.Layout.Row = 1;
                app.CenterPanel.Layout.Column = 2;
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 3;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 1042 459];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {159, '1x', 247};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create WaveletDropDownLabel
            app.WaveletDropDownLabel = uilabel(app.LeftPanel);
            app.WaveletDropDownLabel.Position = [7 371 48 22];
            app.WaveletDropDownLabel.Text = 'Wavelet';

            % Create WaveletDropDown
            app.WaveletDropDown = uidropdown(app.LeftPanel);
            app.WaveletDropDown.ValueChangedFcn = createCallbackFcn(app, @WaveletDropDownValueChanged, true);
            app.WaveletDropDown.Position = [69 371 85 22];

            % Create LoadfileButton
            app.LoadfileButton = uibutton(app.LeftPanel, 'push');
            app.LoadfileButton.ButtonPushedFcn = createCallbackFcn(app, @LoadfileButtonPushed, true);
            app.LoadfileButton.Position = [31 410 99 22];
            app.LoadfileButton.Text = 'Load file';

            % Create Lamp
            app.Lamp = uilamp(app.LeftPanel);
            app.Lamp.Position = [134 411 20 20];
            app.Lamp.Color = [0.8196 0 0.149];

            % Create PlotButton
            app.PlotButton = uibutton(app.LeftPanel, 'push');
            app.PlotButton.ButtonPushedFcn = createCallbackFcn(app, @PlotButtonPushed, true);
            app.PlotButton.Position = [31 276 100 22];
            app.PlotButton.Text = 'Plot';

            % Create ElectrodeXYEditFieldLabel
            app.ElectrodeXYEditFieldLabel = uilabel(app.LeftPanel);
            app.ElectrodeXYEditFieldLabel.Position = [7 340 81 22];
            app.ElectrodeXYEditFieldLabel.Text = 'Electrode [XY]';

            % Create ElectrodeXYEditField
            app.ElectrodeXYEditField = uieditfield(app.LeftPanel, 'numeric');
            app.ElectrodeXYEditField.ValueChangedFcn = createCallbackFcn(app, @ElectrodeXYEditFieldValueChanged, true);
            app.ElectrodeXYEditField.Position = [97 340 30 22];
            app.ElectrodeXYEditField.Value = 1;

            % Create BinmsEditFieldLabel
            app.BinmsEditFieldLabel = uilabel(app.LeftPanel);
            app.BinmsEditFieldLabel.Position = [7 308 49 22];
            app.BinmsEditFieldLabel.Text = 'Bin [ms]';

            % Create BinmsEditField
            app.BinmsEditField = uieditfield(app.LeftPanel, 'numeric');
            app.BinmsEditField.ValueChangedFcn = createCallbackFcn(app, @BinmsEditFieldValueChanged, true);
            app.BinmsEditField.Position = [97 308 30 22];
            app.BinmsEditField.Value = 1;

            % Create CenterPanel
            app.CenterPanel = uipanel(app.GridLayout);
            app.CenterPanel.Layout.Row = 1;
            app.CenterPanel.Layout.Column = 2;

            % Create PreviousButton
            app.PreviousButton = uibutton(app.CenterPanel, 'push');
            app.PreviousButton.ButtonPushedFcn = createCallbackFcn(app, @PreviousButtonPushed, true);
            app.PreviousButton.Position = [268 168 100 22];
            app.PreviousButton.Text = 'Previous';

            % Create NextButton
            app.NextButton = uibutton(app.CenterPanel, 'push');
            app.NextButton.ButtonPushedFcn = createCallbackFcn(app, @NextButtonPushed, true);
            app.NextButton.Position = [386 168 100 22];
            app.NextButton.Text = 'Next';

            % Create SpikeSliderLabel
            app.SpikeSliderLabel = uilabel(app.CenterPanel);
            app.SpikeSliderLabel.HorizontalAlignment = 'right';
            app.SpikeSliderLabel.Position = [158 117 46 51];
            app.SpikeSliderLabel.Text = 'Spike #';

            % Create SpikeSlider
            app.SpikeSlider = uislider(app.CenterPanel);
            app.SpikeSlider.ValueChangedFcn = createCallbackFcn(app, @SpikeSliderValueChanged, true);
            app.SpikeSlider.Position = [223 141 309 3];
            app.SpikeSlider.Value = 1;

            % Create traceAx
            app.traceAx = uiaxes(app.CenterPanel);
            title(app.traceAx, 'Title')
            xlabel(app.traceAx, 'X')
            ylabel(app.traceAx, 'Y')
            zlabel(app.traceAx, 'Z')
            app.traceAx.Position = [7 205 693 246];

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 3;

            % Create TPButton
            app.TPButton = uibutton(app.RightPanel, 'push');
            app.TPButton.ButtonPushedFcn = createCallbackFcn(app, @TPButtonPushed, true);
            app.TPButton.Position = [7 131 70 22];
            app.TPButton.Text = 'TP';

            % Create FNButton
            app.FNButton = uibutton(app.RightPanel, 'push');
            app.FNButton.ButtonPushedFcn = createCallbackFcn(app, @FNButtonPushed, true);
            app.FNButton.Position = [87 131 70 22];
            app.FNButton.Text = 'FN';

            % Create FPButton
            app.FPButton = uibutton(app.RightPanel, 'push');
            app.FPButton.ButtonPushedFcn = createCallbackFcn(app, @FPButtonPushed, true);
            app.FPButton.Position = [166 131 70 22];
            app.FPButton.Text = 'FP';

            % Create SensitivityEditFieldLabel
            app.SensitivityEditFieldLabel = uilabel(app.RightPanel);
            app.SensitivityEditFieldLabel.HorizontalAlignment = 'right';
            app.SensitivityEditFieldLabel.Position = [7 91 60 22];
            app.SensitivityEditFieldLabel.Text = 'Sensitivity';

            % Create SensitivityEditField
            app.SensitivityEditField = uieditfield(app.RightPanel, 'text');
            app.SensitivityEditField.Position = [82 91 58 22];

            % Create PrecisionEditFieldLabel
            app.PrecisionEditFieldLabel = uilabel(app.RightPanel);
            app.PrecisionEditFieldLabel.HorizontalAlignment = 'right';
            app.PrecisionEditFieldLabel.Position = [12 60 55 22];
            app.PrecisionEditFieldLabel.Text = 'Precision';

            % Create PrecisionEditField
            app.PrecisionEditField = uieditfield(app.RightPanel, 'text');
            app.PrecisionEditField.Position = [82 60 58 22];

            % Create SaveButton
            app.SaveButton = uibutton(app.RightPanel, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.Position = [42 28 99 22];
            app.SaveButton.Text = 'Save';

            % Create spikeAx
            app.spikeAx = uiaxes(app.RightPanel);
            title(app.spikeAx, 'Title')
            xlabel(app.spikeAx, 'X')
            ylabel(app.spikeAx, 'Y')
            zlabel(app.spikeAx, 'Z')
            app.spikeAx.Position = [7 166 219 284];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = spikeViewer

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