classdef spikeBrowser < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        GridLayout                    matlab.ui.container.GridLayout
        LeftPanel                     matlab.ui.container.Panel
        LoadfileButton                matlab.ui.control.Button
        ChannelIDEditFieldLabel       matlab.ui.control.Label
        ChannelIDEditField            matlab.ui.control.NumericEditField
        UIAxes                        matlab.ui.control.UIAxes
        SpikeSliderLabel              matlab.ui.control.Label
        SpikeSlider                   matlab.ui.control.Slider
        PlotButton                    matlab.ui.control.Button
        NextButton                    matlab.ui.control.Button
        PreviousButton                matlab.ui.control.Button
        Lamp                          matlab.ui.control.Lamp
        BinmsEditFieldLabel           matlab.ui.control.Label
        BinmsEditField                matlab.ui.control.NumericEditField
        RightPanel                    matlab.ui.container.Panel
        TabGroup                      matlab.ui.container.TabGroup
        SpikeTab                      matlab.ui.container.Tab
        UIAxes2                       matlab.ui.control.UIAxes
        TPButton                      matlab.ui.control.Button
        FNButton                      matlab.ui.control.Button
        FPButton                      matlab.ui.control.Button
        SpikenoEditFieldLabel         matlab.ui.control.Label
        SpikenoEditField              matlab.ui.control.EditField
        HistogramTab                  matlab.ui.container.Tab
        UIAxes3                       matlab.ui.control.UIAxes
        ThresholdmethodDropDownLabel  matlab.ui.control.Label
        ThresholdmethodDropDown       matlab.ui.control.DropDown
        ThresholdvalueEditFieldLabel  matlab.ui.control.Label
        ThresholdvalueEditField       matlab.ui.control.NumericEditField
        equalField                    matlab.ui.control.EditField
        Label                         matlab.ui.control.Label
        lbbLabel                      matlab.ui.control.Label
        StatsTab                      matlab.ui.container.Tab
        FiringrateEditFieldLabel      matlab.ui.control.Label
        FiringrateEditField           matlab.ui.control.EditField
        SensitivityEditFieldLabel     matlab.ui.control.Label
        SensitivityEditField          matlab.ui.control.EditField
        samplesEditFieldLabel         matlab.ui.control.Label
        samplesEditField              matlab.ui.control.EditField
        PrecisionEditFieldLabel       matlab.ui.control.Label
        PrecisionEditField            matlab.ui.control.EditField
        CostparameterEditFieldLabel   matlab.ui.control.Label
        CostparameterEditField        matlab.ui.control.EditField
        spikesEditFieldLabel          matlab.ui.control.Label
        spikesEditField               matlab.ui.control.EditField
        SaveButton                    matlab.ui.control.Button
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    
    properties (Access = public)
        electrodes;
        trace;
        traces;
        spikeMatrix;
        spikeVector;
        spike = 1;
        waveforms;
        channel;
        TP = 0;
        FN = 0;
        FP = 0;
        sensitivity;
        precision;
        samples = 0;
        L;
        spikeCount;
        binLength;
        fname;
        thrMode;
        amp;
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: LoadfileButton
        function LoadfileButtonPushed(app, event)
            app.Lamp.Color = [1 0 0];
            app.lbbLabel.Text = [char(956), 'V'];
            file = uigetfile('*jSpikes.mat');
            load(file);
            app.fname = file;
            
            app.electrodes = channels;
            app.traces = traces;
            app.spikeMatrix = jSpikes;
            app.waveforms = spikes;
            app.L = L;
            app.Lamp.Color = [0 1 0];
        end

        % Value changed function: ChannelIDEditField
        function ChannelIDEditFieldValueChanged(app, event)
            value = app.ChannelIDEditField.Value;
            app.channel = find(app.electrodes == value);
        end

        % Value changed function: SpikeSlider
        function SpikeSliderValueChanged(app, event)
            value = app.SpikeSlider.Value;
            app.spike = round(value);
            app.SpikenoEditField.Value = num2str(app.spike);
            app.UIAxes.cla;
            app.trace = app.traces(app.channel,:);
            app.spikeVector = app.spikeMatrix(app.channel, :);
            spikeTimes = find(app.spikeVector == 1);
            app.spikeCount = length(spikeTimes);
            length(spikeTimes)
            spikeTimes(1)
            
            plot(app.UIAxes, app.trace, 'k');
            hold(app.UIAxes, 'on')
            
            thr = mad(app.trace, 1)/0.6745;
            yOffset = 4*thr;
            y = repmat(yOffset - 0, length(spikeTimes), 1);
            
            scatter(app.UIAxes, (spikeTimes)', y, 'v','filled');
            
            xlim(app.UIAxes, [(spikeTimes(app.spike)- app.binLength), (spikeTimes(app.spike)+ app.binLength)]);
            ylim(app.UIAxes, [-thr*7 thr*7]);
            
            app.UIAxes2.cla;
            spikeWaveforms = app.waveforms{app.channel};
            spikeWaveform = spikeWaveforms(:, app.spike);
            
            plot(app.UIAxes2, spikeWaveform,'k','LineWidth',1.5);
            ylim(app.UIAxes2, [min(spikeWaveform)-3 max(spikeWaveform)+3]);
            xlim(app.UIAxes2, [1 51]);
        end

        % Button pushed function: PlotButton
        function PlotButtonPushed(app, event)
            app.UIAxes.cla;
            
            app.trace = app.traces(app.channel,:);
            app.spikeVector = app.spikeMatrix(app.channel, :);
            spikeTimes = find(app.spikeVector == 1);
            app.spikeCount = length(spikeTimes);
            spikeTimes(1)
            
            plot(app.UIAxes, app.trace, 'k');
            hold(app.UIAxes, 'on')
            
            thr = mad(app.trace, 1)/0.6745;
            yOffset = 4*thr;
            y = repmat(yOffset - 0, length(spikeTimes), 1);
            
            scatter(app.UIAxes, (spikeTimes)', y, 'v','filled');
            
            xlim(app.UIAxes, [1 length(app.trace)]);
            
            firingRate = round(length(spikeTimes)/(length(app.trace)/25000),2);
            app.FiringrateEditField.Value = [num2str(firingRate) ' Hz'];
            app.CostparameterEditField.Value = num2str(app.L);
            app.spikesEditField.Value = num2str(app.spikeCount);
            
            
            fs = 25000;
            durationInSec = 0.001;
            durationInFrame = fs * durationInSec;
            alpha = 0.2;
            peakAlignedSpikeMatrix  = [];
            
            app.UIAxes2.cla;
            
            [spikeWaves, ~] = spikeAlignment(...
                app.trace, app.spikeVector, 25000, 0.002);
            
            for spikeTimeSeries = 1:size(spikeWaves, 1)
                [pks,locs] = findpeaks(-spikeWaves(spikeTimeSeries, :));
                spikePeakLoc = locs(abs(pks) == max(abs(pks)));
                spStart = spikePeakLoc - round(durationInFrame / 2);
                spEnd = spikePeakLoc + round(durationInFrame / 2);
                if spStart > 0 && spEnd < size(spikeWaves, 2)
                    
                    plot(app.UIAxes2, spikeWaves(spikeTimeSeries, spStart:spEnd), 'Color', [0 0 0] + 1 - alpha);
                    peakAlignedSpikeMatrix = [peakAlignedSpikeMatrix; ...
                        spikeWaves(spikeTimeSeries, spStart:spEnd)];
                end
                hold(app.UIAxes2, 'on');
            end
            
            aveSpikeWaveForm = median(peakAlignedSpikeMatrix);
            
            [pks,locs] = findpeaks(-aveSpikeWaveForm);
            spikePeakLoc = locs(abs(pks) == max(abs(pks)));
            spStart = spikePeakLoc - round(durationInFrame / 2);
            spEnd = spikePeakLoc + round(durationInFrame / 2);
            if spStart > 0 && spEnd < size(spikeWaves, 2)
                plot(app.UIAxes2, aveSpikeWaveForm(spStart:spEnd), 'Color', [1 1 1], 'LineWidth',1.7);
                hold(app.UIAxes2, 'on');
                plot(app.UIAxes2, aveSpikeWaveForm(spStart:spEnd), 'Color', [0 0 0], 'LineWidth',1);
            end
            xlim(app.UIAxes2, [1 length(aveSpikeWaveForm(spStart:spEnd))]);
            
            app.SpikeSlider.Limits = [1 app.spikeCount];
            app.spike = 0;
            
            
            spikeWaveforms = app.waveforms{app.channel};
            
           
            for i = 1:length(spikeWaveforms)
                app.amp(i) = min(spikeWaveforms(:,i));
            end
            app.UIAxes3.cla;
            histogram(app.UIAxes3, app.amp, 'FaceColor', [0.4940, 0.1840, 0.5560]);
            hold(app.UIAxes3)
            
            
            
            
            
            
        end

        % Button pushed function: NextButton
        function NextButtonPushed(app, event)
            app.spike = app.spike+1;
            app.SpikenoEditField.Value = num2str(app.spike);
            app.UIAxes.cla;
            app.trace = app.traces(app.channel,:);
            app.spikeVector = app.spikeMatrix(app.channel, :);
            spikeTimes = find(app.spikeVector == 1);
            
            plot(app.UIAxes, app.trace, 'k');
            hold(app.UIAxes, 'on')
            
            thr = mad(app.trace, 1)/0.6745;
            yOffset = 4*thr;
            y = repmat(yOffset - 0, length(spikeTimes), 1);
            
            scatter(app.UIAxes, (spikeTimes)', y, 'v','filled');
            
            xlim(app.UIAxes, [(spikeTimes(app.spike)- app.binLength), (spikeTimes(app.spike)+ app.binLength)]);
            ylim(app.UIAxes, [-thr*7 thr*7]);
            
            app.UIAxes2.cla;
            spikeWaveforms = app.waveforms{app.channel};
            spikeWaveform = spikeWaveforms(:, app.spike);
            
            plot(app.UIAxes2, spikeWaveform,'k','LineWidth',1.5);
            ylim(app.UIAxes2, [min(spikeWaveform)-3 max(spikeWaveform)+3]);
            xlim(app.UIAxes2, [1 51]);
        end

        % Button pushed function: PreviousButton
        function PreviousButtonPushed(app, event)
            if app.spike > 1
                app.spike = app.spike-1;
                app.SpikenoEditField.Value = num2str(app.spike);
                
                app.UIAxes.cla;
                app.trace = app.traces(app.channel,:);
                app.spikeVector = app.spikeMatrix(app.channel, :);
                spikeTimes = find(app.spikeVector == 1);
                length(spikeTimes)
                spikeTimes(1)
                
                plot(app.UIAxes, app.trace, 'k');
                hold(app.UIAxes, 'on')
                
                thr = mad(app.trace, 1)/0.6745;
                yOffset = 4*thr;
                y = repmat(yOffset - 0, length(spikeTimes), 1);
                
                scatter(app.UIAxes, (spikeTimes)', y, 'v','filled');
                
                xlim(app.UIAxes, [(spikeTimes(app.spike)- app.binLength), (spikeTimes(app.spike)+ app.binLength)]);
                ylim(app.UIAxes, [-thr*7 thr*7]);
                
                app.UIAxes2.cla;
                spikeWaveforms = app.waveforms{app.channel};
                spikeWaveform = spikeWaveforms(:, app.spike);
                
                plot(app.UIAxes2, spikeWaveform,'k','LineWidth',1.5);
                ylim(app.UIAxes2, [min(spikeWaveform)-3 max(spikeWaveform)+3]);
                xlim(app.UIAxes2, [1 51]);
            end
        end

        % Button pushed function: TPButton
        function TPButtonPushed(app, event)
            app.TP = app.TP+1;
            app.sensitivity = app.TP/(app.TP+app.FN);
            app.precision = app.TP/(app.TP+app.FP);
            app.samples = app.samples+1;
            
            app.SensitivityEditField.Value = [num2str(round(app.sensitivity*100),2) ' %'];
            app.PrecisionEditField.Value =  [num2str(round(app.precision*100),2) ' %'];
            app.samplesEditField.Value = num2str(app.samples);
        end

        % Button pushed function: FNButton
        function FNButtonPushed(app, event)
            app.FN = app.FN+1;
            app.sensitivity = app.TP/(app.TP+app.FN);
            app.precision = app.TP/(app.TP+app.FP);
            app.samples = app.samples+1;
            
            app.SensitivityEditField.Value = [num2str(round(app.sensitivity*100),2) ' %'];
            app.PrecisionEditField.Value =  [num2str(round(app.precision*100),2) ' %'];
            app.samplesEditField.Value = num2str(app.samples);
        end

        % Button pushed function: FPButton
        function FPButtonPushed(app, event)
            app.FP = app.FP+1;
            app.sensitivity = app.TP/(app.TP+app.FN);
            app.precision = app.TP/(app.TP+app.FP);
            app.samples = app.samples+1;
            
            app.SensitivityEditField.Value = [num2str(round(app.sensitivity*100),1) ' %'];
            app.PrecisionEditField.Value =  [num2str(round(app.precision*100),1) ' %'];
            app.samplesEditField.Value = num2str(app.samples);
        end

        % Value changed function: SpikenoEditField
        function SpikenoEditFieldValueChanged(app, event)
            value = app.SpikenoEditField.Value;
            app.spike = value;
        end

        % Value changed function: BinmsEditField
        function BinmsEditFieldValueChanged(app, event)
            value = app.BinmsEditField.Value;
            app.binLength = 25*(round(value)/2);
        end

        % Button pushed function: SaveButton
        function SaveButtonPushed(app, event)
            firingRate = app.FiringrateEditField.Value;
            Precision = app.precision;
            Sensitivity = app.sensitivity;
            spikeCount = app.spikeCount;
            save([app.fname(1:end-4) '_stats.mat'], 'Precision',...
                'Sensitivity', 'firingRate','spikeCount')
        end

        % Callback function
        function SaveplotButtonPushed(app, event)
            
        end

        % Callback function
        function CheckBoxValueChanged(app, event)
            value = str2num(app.CheckBox.Text);
        end

        % Value changed function: ThresholdmethodDropDown
        function ThresholdmethodDropDownValueChanged(app, event)
            value = app.ThresholdmethodDropDown.Value;
            app.thrMode = value;
            
            app.UIAxes3.cla;
            histogram(app.UIAxes3, app.amp, 'FaceColor', [0.4940, 0.1840, 0.5560]);
            hold(app.UIAxes3)
            
            if strcmp(app.thrMode, 'MAD')
                thr = mad(app.trace, 1)/0.6745;
            else
                thr = std(app.trace);
            end
            xline(app.UIAxes3, -app.ThresholdvalueEditField.Value*thr,...
                'r--','Linewidth',1.5);
            app.equalField.Value = [num2str(-app.ThresholdvalueEditField.Value*thr)];
        end

        % Value changed function: ThresholdvalueEditField
        function ThresholdvalueEditFieldValueChanged(app, event)
            value = app.ThresholdvalueEditField.Value;
            app.UIAxes3.cla;
            histogram(app.UIAxes3, app.amp, 'FaceColor', [0.4940, 0.1840, 0.5560]);
            hold(app.UIAxes3)
           if strcmp(app.thrMode, 'MAD')
                thr = mad(app.trace, 1)/0.6745;
            else
                thr = std(app.trace);
            end
            xline(app.UIAxes3, -app.ThresholdvalueEditField.Value*thr,...
                'r--','Linewidth',1.5);
                       app.equalField.Value = [num2str(-app.ThresholdvalueEditField.Value*thr)];
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {531, 531};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {594, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
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
            app.UIFigure.Position = [200 200 930 531];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {594, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create LoadfileButton
            app.LoadfileButton = uibutton(app.LeftPanel, 'push');
            app.LoadfileButton.ButtonPushedFcn = createCallbackFcn(app, @LoadfileButtonPushed, true);
            app.LoadfileButton.Position = [251 460 100 40];
            app.LoadfileButton.Text = 'Load file';

            % Create ChannelIDEditFieldLabel
            app.ChannelIDEditFieldLabel = uilabel(app.LeftPanel);
            app.ChannelIDEditFieldLabel.HorizontalAlignment = 'right';
            app.ChannelIDEditFieldLabel.Position = [55 483 100 22];
            app.ChannelIDEditFieldLabel.Text = 'Channel ID:';

            % Create ChannelIDEditField
            app.ChannelIDEditField = uieditfield(app.LeftPanel, 'numeric');
            app.ChannelIDEditField.ValueChangedFcn = createCallbackFcn(app, @ChannelIDEditFieldValueChanged, true);
            app.ChannelIDEditField.Position = [164 483 35 22];

            % Create UIAxes
            app.UIAxes = uiaxes(app.LeftPanel);
            title(app.UIAxes, 'Filtered trace')
            xlabel(app.UIAxes, 'Bin')
            ylabel(app.UIAxes, 'Voltage [\muV]')
            app.UIAxes.PlotBoxAspectRatio = [2.32044198895028 1 1];
            app.UIAxes.Position = [4 210 584 237];

            % Create SpikeSliderLabel
            app.SpikeSliderLabel = uilabel(app.LeftPanel);
            app.SpikeSliderLabel.HorizontalAlignment = 'right';
            app.SpikeSliderLabel.Position = [31 168 46 22];
            app.SpikeSliderLabel.Text = {'Spike #'; ''};

            % Create SpikeSlider
            app.SpikeSlider = uislider(app.LeftPanel);
            app.SpikeSlider.Limits = [1 1000];
            app.SpikeSlider.ValueChangedFcn = createCallbackFcn(app, @SpikeSliderValueChanged, true);
            app.SpikeSlider.Position = [98 177 412 3];
            app.SpikeSlider.Value = 1;

            % Create PlotButton
            app.PlotButton = uibutton(app.LeftPanel, 'push');
            app.PlotButton.ButtonPushedFcn = createCallbackFcn(app, @PlotButtonPushed, true);
            app.PlotButton.Position = [415 475 100 20];
            app.PlotButton.Text = 'Plot';

            % Create NextButton
            app.NextButton = uibutton(app.LeftPanel, 'push');
            app.NextButton.ButtonPushedFcn = createCallbackFcn(app, @NextButtonPushed, true);
            app.NextButton.Position = [331 90 100 40];
            app.NextButton.Text = 'Next';

            % Create PreviousButton
            app.PreviousButton = uibutton(app.LeftPanel, 'push');
            app.PreviousButton.ButtonPushedFcn = createCallbackFcn(app, @PreviousButtonPushed, true);
            app.PreviousButton.Position = [181 90 100 40];
            app.PreviousButton.Text = 'Previous';

            % Create Lamp
            app.Lamp = uilamp(app.LeftPanel);
            app.Lamp.Position = [358 474 15 15];
            app.Lamp.Color = [1 0 0];

            % Create BinmsEditFieldLabel
            app.BinmsEditFieldLabel = uilabel(app.LeftPanel);
            app.BinmsEditFieldLabel.HorizontalAlignment = 'right';
            app.BinmsEditFieldLabel.Position = [89 453 67 22];
            app.BinmsEditFieldLabel.Text = 'Bin [ms]';

            % Create BinmsEditField
            app.BinmsEditField = uieditfield(app.LeftPanel, 'numeric');
            app.BinmsEditField.ValueChangedFcn = createCallbackFcn(app, @BinmsEditFieldValueChanged, true);
            app.BinmsEditField.Position = [165 453 34 22];

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create TabGroup
            app.TabGroup = uitabgroup(app.RightPanel);
            app.TabGroup.Position = [6 6 326 519];

            % Create SpikeTab
            app.SpikeTab = uitab(app.TabGroup);
            app.SpikeTab.Title = 'Spike';

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.SpikeTab);
            title(app.UIAxes2, 'Spike waveform')
            xlabel(app.UIAxes2, 'X')
            ylabel(app.UIAxes2, 'Voltage [\muV]')
            app.UIAxes2.PlotBoxAspectRatio = [1 1.76897689768977 1];
            app.UIAxes2.XColor = [0.9412 0.9412 0.9412];
            app.UIAxes2.Position = [48 76 230 372];

            % Create TPButton
            app.TPButton = uibutton(app.SpikeTab, 'push');
            app.TPButton.ButtonPushedFcn = createCallbackFcn(app, @TPButtonPushed, true);
            app.TPButton.Position = [48 41 70 22];
            app.TPButton.Text = 'TP';

            % Create FNButton
            app.FNButton = uibutton(app.SpikeTab, 'push');
            app.FNButton.ButtonPushedFcn = createCallbackFcn(app, @FNButtonPushed, true);
            app.FNButton.Position = [128 41 70 22];
            app.FNButton.Text = 'FN';

            % Create FPButton
            app.FPButton = uibutton(app.SpikeTab, 'push');
            app.FPButton.ButtonPushedFcn = createCallbackFcn(app, @FPButtonPushed, true);
            app.FPButton.Position = [208 41 70 22];
            app.FPButton.Text = 'FP';

            % Create SpikenoEditFieldLabel
            app.SpikenoEditFieldLabel = uilabel(app.SpikeTab);
            app.SpikenoEditFieldLabel.HorizontalAlignment = 'right';
            app.SpikenoEditFieldLabel.Position = [79 451 56 22];
            app.SpikenoEditFieldLabel.Text = 'Spike no.';

            % Create SpikenoEditField
            app.SpikenoEditField = uieditfield(app.SpikeTab, 'text');
            app.SpikenoEditField.ValueChangedFcn = createCallbackFcn(app, @SpikenoEditFieldValueChanged, true);
            app.SpikenoEditField.Position = [150 451 49 22];

            % Create HistogramTab
            app.HistogramTab = uitab(app.TabGroup);
            app.HistogramTab.Title = 'Histogram';

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.HistogramTab);
            title(app.UIAxes3, 'Amplitude histogram')
            xlabel(app.UIAxes3, 'Amplitude [\muV]')
            ylabel(app.UIAxes3, 'No. of entries')
            app.UIAxes3.PlotBoxAspectRatio = [1.20555555555556 1 1];
            app.UIAxes3.Position = [4 182 321 237];

            % Create ThresholdmethodDropDownLabel
            app.ThresholdmethodDropDownLabel = uilabel(app.HistogramTab);
            app.ThresholdmethodDropDownLabel.HorizontalAlignment = 'right';
            app.ThresholdmethodDropDownLabel.Position = [35 140 103 22];
            app.ThresholdmethodDropDownLabel.Text = 'Threshold method';

            % Create ThresholdmethodDropDown
            app.ThresholdmethodDropDown = uidropdown(app.HistogramTab);
            app.ThresholdmethodDropDown.Items = {'MAD', 'STD'};
            app.ThresholdmethodDropDown.ValueChangedFcn = createCallbackFcn(app, @ThresholdmethodDropDownValueChanged, true);
            app.ThresholdmethodDropDown.Position = [153 140 125 22];
            app.ThresholdmethodDropDown.Value = 'MAD';

            % Create ThresholdvalueEditFieldLabel
            app.ThresholdvalueEditFieldLabel = uilabel(app.HistogramTab);
            app.ThresholdvalueEditFieldLabel.HorizontalAlignment = 'right';
            app.ThresholdvalueEditFieldLabel.Position = [35 107 90 22];
            app.ThresholdvalueEditFieldLabel.Text = 'Threshold value';

            % Create ThresholdvalueEditField
            app.ThresholdvalueEditField = uieditfield(app.HistogramTab, 'numeric');
            app.ThresholdvalueEditField.ValueChangedFcn = createCallbackFcn(app, @ThresholdvalueEditFieldValueChanged, true);
            app.ThresholdvalueEditField.Position = [153 107 30 22];

            % Create equalField
            app.equalField = uieditfield(app.HistogramTab, 'text');
            app.equalField.Position = [208 107 58 22];

            % Create Label
            app.Label = uilabel(app.HistogramTab);
            app.Label.Position = [182 107 25 22];
            app.Label.Text = '   =';

            % Create lbbLabel
            app.lbbLabel = uilabel(app.HistogramTab);
            app.lbbLabel.Position = [277 107 25 22];
            app.lbbLabel.Text = 'lbb';

            % Create StatsTab
            app.StatsTab = uitab(app.TabGroup);
            app.StatsTab.Title = 'Stats';

            % Create FiringrateEditFieldLabel
            app.FiringrateEditFieldLabel = uilabel(app.StatsTab);
            app.FiringrateEditFieldLabel.HorizontalAlignment = 'right';
            app.FiringrateEditFieldLabel.Position = [57 364 60 22];
            app.FiringrateEditFieldLabel.Text = 'Firing rate';

            % Create FiringrateEditField
            app.FiringrateEditField = uieditfield(app.StatsTab, 'text');
            app.FiringrateEditField.Position = [128 364 100 22];

            % Create SensitivityEditFieldLabel
            app.SensitivityEditFieldLabel = uilabel(app.StatsTab);
            app.SensitivityEditFieldLabel.HorizontalAlignment = 'right';
            app.SensitivityEditFieldLabel.Position = [49 322 60 22];
            app.SensitivityEditFieldLabel.Text = 'Sensitivity';

            % Create SensitivityEditField
            app.SensitivityEditField = uieditfield(app.StatsTab, 'text');
            app.SensitivityEditField.Position = [128 320 100 22];

            % Create samplesEditFieldLabel
            app.samplesEditFieldLabel = uilabel(app.StatsTab);
            app.samplesEditFieldLabel.HorizontalAlignment = 'right';
            app.samplesEditFieldLabel.Position = [51 236 60 22];
            app.samplesEditFieldLabel.Text = '# samples';

            % Create samplesEditField
            app.samplesEditField = uieditfield(app.StatsTab, 'text');
            app.samplesEditField.Position = [128 236 100 22];

            % Create PrecisionEditFieldLabel
            app.PrecisionEditFieldLabel = uilabel(app.StatsTab);
            app.PrecisionEditFieldLabel.HorizontalAlignment = 'right';
            app.PrecisionEditFieldLabel.Position = [60 278 55 22];
            app.PrecisionEditFieldLabel.Text = 'Precision';

            % Create PrecisionEditField
            app.PrecisionEditField = uieditfield(app.StatsTab, 'text');
            app.PrecisionEditField.Position = [128 278 100 22];

            % Create CostparameterEditFieldLabel
            app.CostparameterEditFieldLabel = uilabel(app.StatsTab);
            app.CostparameterEditFieldLabel.HorizontalAlignment = 'right';
            app.CostparameterEditFieldLabel.Position = [26 448 89 22];
            app.CostparameterEditFieldLabel.Text = 'Cost parameter';

            % Create CostparameterEditField
            app.CostparameterEditField = uieditfield(app.StatsTab, 'text');
            app.CostparameterEditField.Position = [129 448 100 22];

            % Create spikesEditFieldLabel
            app.spikesEditFieldLabel = uilabel(app.StatsTab);
            app.spikesEditFieldLabel.HorizontalAlignment = 'right';
            app.spikesEditFieldLabel.Position = [63 406 50 22];
            app.spikesEditFieldLabel.Text = '# spikes';

            % Create spikesEditField
            app.spikesEditField = uieditfield(app.StatsTab, 'text');
            app.spikesEditField.Position = [128 406 100 22];

            % Create SaveButton
            app.SaveButton = uibutton(app.StatsTab, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.Position = [128 194 100 22];
            app.SaveButton.Text = 'Save';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = spikeBrowser

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