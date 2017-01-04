function [activity_template, activity_color]= blue_red_stimulus_template(recording_time,stimulus,time_axis)
% activity_template= [blue_on,red_on,both_on,both_off,blue_off];
% b r m g c
activity_color = 'brmgy';

temp_axis = linspace(0,recording_time,60*recording_time);

%% blue on template, blue, square shape
blue_on = stimulus =='b';
blue_on = [blue_on;zeros(size(blue_on))];
blue_on = blue_on(:);
blue_on = [0 blue_on'];
x = repmat(blue_on,60,1);
blue_on = x(:);
blue_on = interp1(temp_axis,blue_on,time_axis);

%% red on template, red, square shape
red_on = stimulus =='r';
red_on = [red_on;zeros(size(red_on))];
red_on = red_on(:);
red_on = [0 red_on'];
x = repmat(red_on,60,1);
red_on = x(:);
red_on = interp1(temp_axis,red_on,time_axis);

%% on template, magenta, 
both_on = blue_on + red_on;

%% off template, green, sawtooth
x = stimulus=='b' | stimulus == 'r';
both_off = [zeros(size(x));x];
both_off = both_off(:);
both_off = [0 both_off'];
x = repmat(both_off,60,1);
y = linspace(1,0,60);
x = x .* repmat(y',1,recording_time);
both_off = x(:);
both_off = interp1(temp_axis,both_off,time_axis);

%% blue off/or blue inhibition, cyan, sawtooth
x = stimulus=='b';
blue_off = [zeros(size(x));x];
blue_off = blue_off(:);
blue_off = [0 blue_off'];
x = repmat(blue_off,60,1);
y = linspace(1,0,60);
x = x .* repmat(y',1,recording_time);
blue_off = x(:);
blue_off = interp1(temp_axis,blue_off,time_axis);
activity_template= [blue_on;red_on;both_on;both_off;blue_off];


% figure, 
% subplot(5,1,1);plot(blue_on,'b');
% subplot(5,1,2);plot(red_on,'r');
% subplot(5,1,3);plot(both_on,'m');
% subplot(5,1,4);plot(both_off,'g');
% subplot(5,1,5);plot(blue_off,'c');