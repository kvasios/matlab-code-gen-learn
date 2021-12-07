fprintf('---Initializing Posix RTW-Target\n');


ver = version('-release');
setenv('MATLAB_VERSION', ver);
setenv('POSIX_ROOT', fullfile(pwd));
addpath(fullfile(getenv('POSIX_ROOT'), 'posix'));
sl_refresh_customizations;