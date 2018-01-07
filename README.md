# Perfect-Posture
Program notifies user when they have poor posture-matlab R2017a
%Posture_Analysis.m measures the user's posture while sitting and using their
%computer and alerts the user when their posture is sub optimal
%Program uses laptops/computers webcam to take an initial snapshot and use
%rudimentary motion tracking programming to follow changes in pixel
%distance ratios between the head and shoulders
%Program takes an initial snapshot for later compariosn, so user must start
%in ideal posture for later comparison

%User must have entire head and curvature of shoulders within view of the
%webcam for optimal use

%Visible and audible indication for user if poor posture
%occurs

%Program requires monochromatic,homogenous background behind user for
%accurate tracking of user's posture

%Requires MATLAB R2017a or better and MATLAB Support Package for USB Webcams
