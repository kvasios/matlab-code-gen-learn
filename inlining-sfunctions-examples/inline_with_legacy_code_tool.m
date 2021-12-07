def = legacy_code('initialize');
def.Options.language = 'C++';
% 
%                   SFunctionName: ''
%     InitializeConditionsFcnSpec: ''
%                   OutputFcnSpec: ''
%                    StartFcnSpec: ''
%                TerminateFcnSpec: ''
%                     HeaderFiles: {}
%                     SourceFiles: {}
%                    HostLibFiles: {}
%                  TargetLibFiles: {}
%                        IncPaths: {}
%                        SrcPaths: {}
%                        LibPaths: {}
%                      SampleTime: 'inherited'
%                         Options: [1x1 struct]

def.SFunctionName = 'robot_world_distances_sfun';

% def.InitializeConditionsFcnSpec = 'void robot_world_distances_init(double u1[1], double u2[1], double u3[208], double u4[30], double u5[9], double u6[30],  double u7[9], double u8[30],  double u9[9], double u10[30], double u11[9], double u12[10], double u13[3], double u14[18], double u15[18], double u16[96], double u17[6], double y1[78], double y2[78], double y3[234], double y4[234], double y5[234], double y6[1], double y7[1], double y8[1], int32 work1[1], void work2[1], void work3[1], void work4[1], int32 work5[1], int32 work6[1], int32 work7[1])';

%                               
def.OutputFcnSpec = 'void robot_world_distances_out(double u1[1], double u2[1], double u3[208], double u4[30], double u5[9], double u6[30],  double u7[9], double u8[30],  double u9[9], double u10[30], double u11[9], double u12[10], double u13[3], double u14[18], double u15[18], double u16[96], double u17[6], double y1[78], double y2[78], double y3[234], double y4[234], double y5[234], double y6[1], double y7[1], double y8[1], int32 work1[1], void work2[1], void work3[1], void work4[1], int32 work5[1], int32 work6[1], int32 work7[1])';
% 
% def.TerminateFcnSpec = 'void robot_world_distances_terminate(work2[1], void work3[1], void work4[1])';

def.HeaderFiles   = {'robot_world_distances.h', 'collision_api.h','math_geometry.h'};
def.SourceFiles   = {'robot_world_distances.cpp', 'collision.cpp','collision_api.cpp','math_geometry.cpp'};

def.IncPaths      = {'controllers/src/collision', 'controllers/build'}; 
def.SrcPaths      = {'controllers/src/collision'}; 
% def.LibPaths      = {'controllers/src/collision'};

%%
legacy_code('generate_for_sim', def);

%%
legacy_code('rtwmakecfg_generate', def);

%% 
legacy_code('sfcn_tlc_generate', def)

%%
legacy_code('slblock_generate', def);
