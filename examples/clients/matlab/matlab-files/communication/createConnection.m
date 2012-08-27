%% Function Create Connection
%
% Denis Štogl 2012 IIROB group IPR/KIT
% http://rob.ipr.kit.edu/english/303.php
%
% Definition: connection = createConnection(host, startPort, numberOfDevices)
%
% Create TCPIP connection on host starting from startPort for
% numberOfDevices devices.
%
% Input:
%       host - name of host
%       startPort - starting port for communication (other Ports are
%       startPort + i)
%       numberOfDevices - number of devices to communicate (optional)
%       bufferSize - size of the Buffer for writer (optional)
% Output:
%       connection - list with Reader for every port (size is
%       numberOfDevices)

function connection = createConnection(host, startPort, numberOfDevices, bufferSize)

    if nargin == 2
        numberOfDevices = 1;
    end

    for i = 1:numberOfDevices
        
        connection(i) = tcpip(host, startPort+i-1);
        if nargin == 4
        	set(connection(i), 'InputBufferSize', bufferSize);
        end            
        fopen(connection(i));        
    end
end