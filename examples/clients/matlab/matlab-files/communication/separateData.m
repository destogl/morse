%% Function Separate Data
%
% Denis Štogl 2012 IIROB group IPR/KIT
% http://rob.ipr.kit.edu/english/303.php
%
% Defintion: separatedData = separateData(data)
%
% This funciton separate string of data from MORSE. String length is not
% limited. Function if currently impleneted of numeric data.
% String of data has pattern:
% {"distance": 0.0, "velocity": [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]}
%
% Input:
%       data - String of data to separate 
%
% Output:
%       separatedData - Cell of data with name in first and data in second
%                       column

function separatedData = separateData(data)

    % separate data on name-value pairs
    data = data(3:size(data, 2)-2);
    str = regexp(data, '\, \"', 'split');

    separatedData = cell(size(str, 2), 2);    
    
    for i = 1:size(str, 2)
        
        % split name-value pair and store name
        str1 = regexp(str{i}, '\:\ ', 'split');
        separatedData{i, 1} = str1{1}(1:size(str1{1}, 2)-1);
        
        % check if value is array and convert value
        if str1{2}(1) == '['
            
            str1{2} = str1{2}(2:size(str1{2}, 2)-1);
            str2 = regexp(str1{2}(), '\, ', 'split');
            separatedData{i, 2} = str2double(str2);            
        else
            separatedData{i, 2} = str2double(str1{2});
        end     
    
    end
end