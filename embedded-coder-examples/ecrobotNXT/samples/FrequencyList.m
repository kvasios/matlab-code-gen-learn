%   Copyright 2010 The MathWorks, Inc.

% Sound  1   2   3   4   5   6    7    8    9
% B      62 123 247 494 988 1976 3951 7902
% A#     58 117 233 466 932 1865 3729 7458
% A      55 110 220 440 880 1760 3520 7040 14080
% G#     52 104 208 415 831 1661 3322 6644 13288
% G      49  98 196 392 784 1568 3136 6272 12544
% F#     46  92 185 370 740 1480 2960 5920 11840
% F      44  87 175 349 698 1397 2794 5588 11176
% E      41  82 165 330 659 1319 2637 5274 10548
% D#     39  78 156 311 622 1245 2489 4978 9956
% D      37  73 147 294 587 1175 2349 4699 9398
% C#     35  69 139 277 554 1109 2217 4435 8870
% C      33  65 131 262 523 1047 2093 4186 8372
% Note: Frequency is audible from about 31 to 2100 Hertz.
frequency = ...
    uint16([33   35   37   39   41   44   46   49   52   55   58   62 ...
            65   69   73   78   82   87   92   98  104  110  117  123 ...
           131  139  147  156  165  175  185  196  208  220  233  247 ...
           262  277  294  311  330  349  370  392  415  440  466  494 ...
           523  554  587  622  659  698  740  784  831  880  932  988 ...
          1047 1109 1175 1245 1319 1397 1480 1568 1661 1760 1976 2093]);
          
% Blues scale: these notes are often used in blues and heavy metal rock music. 
% The notes in this scale are: A, C, D, D#, E, G, G#, A 
%           C    D    D#   E    G    G#   A
% frequency = ...
%     uint16([33   37   39   41   49   52   55 ... 
%             65   73   78   82   98  104  110 ...
%            131  147  156  165  196  208  220 ...
%            262  294  311  330  392  415  440 ...
%            523  587  622  659  784  831  880 ...
%           1047 1175 1245 1319 1568 1661 1760 ...
%           2093]);

% Okinawa scale: these notes are often used in Okinawa(Ryukyu) traditional
% music. The notes in this scale are: C, E, F, G, B, C
%            C    E    F    G    B
% frequency = ...
%     uint16([33   41   44   49   62 ...
%             65   82   87   98  123 ...
%            131  165  175  196  247 ...
%            262  330  349  392  494 ...
%            523  659  698  784  988 ...
%           1047 1319 1397 1568 1976 ...
%           2093]);
