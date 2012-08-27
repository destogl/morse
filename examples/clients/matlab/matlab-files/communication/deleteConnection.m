%% Function Delete Connection
%
% Denis Štogl 2012 IIROB group IPR/KIT
% http://rob.ipr.kit.edu/english/303.php
%
% Definiton: deleteConnection(connections)
%
% This function closes and deletes TCP/IP connections.
%
% Input:
%       connections - list with connections to be closed.


function deleteConnection(connections)

    for i = 1:max(size(connections))
        
        fclose(connections(i));
        delete(connections(i));      
    end
end