%% Function Extract Data
%
% Denis Štogl 2012 IIROB group IPR/KIT
% http://rob.ipr.kit.edu/english/303.php
%
% Definiton: extractedValue = extractData(data, nameOfVariable, arrayIndex)
%
% This function extract values from cell with name in first and values
% second column.
%
% Input:
%       data - input data
%       name - name of data to extract value
%       arrayIndex - index of value to be extracted from array (optional)
%
% Output:
%       extractedValue - Extracted value/values respectively to
%                        nameOfVariable

function extractedValue = extractData(data, name, arrayIndex)

    % find data respectively to name
    for i = 1:size(data, 1)
        if strcmp(data{i, 1}, name)
            value = data{i, 2};
            break;
        end
    end
    
    % check if should be extracted one value from array
    if nargin == 3
        extractedValue = value(arrayIndex);
    else    
       extractedValue = value;
    end
end