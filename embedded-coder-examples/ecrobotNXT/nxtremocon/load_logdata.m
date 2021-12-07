%   Copyright 2010 The MathWorks, Inc.

data = dlmread('logging_data.csv', ',',1,0);
logging_data = [data(:,1)/1000, data(:,2), data(:,3), data(:,4)];
clear data;