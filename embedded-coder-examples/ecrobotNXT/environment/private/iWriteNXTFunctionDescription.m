% iWriteNXTFunctionDescription
%   write generated C functions list comment

%   Copyright 2010 The MathWorks, Inc.

function iWriteNXTFunctionDescription(fid, model, sys, fcn_name, fcn_source)

fprintf(fid, '/*');
for i=1:76
    fprintf(fid, '=');
end
fprintf(fid, '\n');

fprintf(fid, ' * RTW-EC generated functions for Function-Call Subsystems:\n');
for i=1:length(fcn_source)
    fprintf(fid, '*   %s', fcn_name{i});
    switch fcn_source(i)
        case -1 % External trigger not supported for target implementation
            disp([fcn_name{i} ...
                ' was specified as an external triggered Function-Call, but not supported for target implementation.']);
        case 0 % Initialize
            fprintf(fid, ': exectuted at initialization\n');
        otherwise
            if fcn_source(i)>0 % Periodical
                fprintf(fid, ': executed at every %s[sec]\n', ...
                    num2str(fcn_source(i)*simget(model, 'FixedStep')));
            else
                error(['NXTBuild:execution timing of ' fcn_name{i} ' could not be set properly.']);
            end
    end
end
fprintf(fid, ' *\n');
fprintf(fid, ' * RTW-EC generated model initialize function:\n');
fprintf(fid, ' *   %s_initialize\n', sys);

fprintf(fid, ' *');
for i=1:75
    fprintf(fid, '=');
end
fprintf(fid, '*/\n');
% End of function
