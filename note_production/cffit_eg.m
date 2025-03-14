function [fitresult, gof] = createFit(note_ons, delta_ts)
%CREATEFIT(NOTE_ONS,DELTA_TS)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input: note_ons
%      Y Output: delta_ts
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 18-Feb-2025 13:33:07


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( note_ons, delta_ts );

% Set up fittype and options.
ft = fittype( '(a-x)-sqrt((a-x)^2+c)', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0.69656868951164 0.747661582378364];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
figure( 'Name', 'untitled fit 1' );
h = plot( fitresult, xData, yData );
legend( h, 'delta_ts vs. note_ons', 'untitled fit 1', 'Location', 'NorthEast', 'Interpreter', 'none' );
% Label axes
xlabel( 'note_ons', 'Interpreter', 'none' );
ylabel( 'delta_ts', 'Interpreter', 'none' );
grid on


