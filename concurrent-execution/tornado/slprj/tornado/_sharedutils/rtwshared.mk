# Copyright 1994-2020 The MathWorks, Inc.
#
# File    : tornado.tmf   
#
# Abstract:
#   Template makefile for building a PC or UNIX hosted Tornado/VxWorks real-time 
#   version of Simulink model using generated C code.
#
#   This makefile attempts to conform to the guidelines specified in the
#   IEEE Std 1003.2-1992 (POSIX) standard.
#
#   Note that this template is automatically customized by the build procedure 
#   to create "<model>.mk".
#
#   The following defines can be used to modify the behavior of the
#   build:
#
#   OPT_OPTS       - Optimization options. Default is -O. To enable
#                    debugging specify as OPT_OPTS=-g.
#   OPTS           - User specific compile options.
#   USER_SRCS      - Additional user sources, such as files needed by
#                    S-functions.
#   USER_INCLUDES  - Additional include paths 
#                    (i.e. USER_INCLUDES="-Iwhere-ever -Iwhere-ever2")
#
#   The following define is used to set the option string that is passed
#   to rt_main when invoking the target program:
#
#   PROGRAM_OPTS   - This is a string passed to rt_main of the form:
#
#                       -opt1 val1 -opt2 val2 -opt3
#
#                    The options currently available are:
#                       -tf 20 => sets stop time to 20
#                       -w     => starts target program, but waits for message
#                                 from Simulink (host) before starting the
#                                 "simulation" (this option applies to external
#                                 mode only).
#
#                     For example:
#
#                       PROGRAM_OPTS="-tf inf -w" sets the stop time to infinity
#                       and waits to start the sim until receiving a message
#                       from the host.
#
#
#   This template makefile is designed to be used with a system target
#   file that contains 'rtwgensettings.BuildDirSuffix' see tornado.tlc

#------------------------ Macros read by make_rtw ------------------------------
#
# The following macros are read by the build procedure:
#
#  MAKECMD         - This is the command used to invoke the make utility
#                    Change path as appropriate for your Torando installation
#  HOST            - What platform this template makefile is targeted for 
#                    (i.e. PC,UNIX or ANY)
#  BUILD           - Invoke make from the build procedure (yes/no)? 
#                     Setting to 'no' will create model source code and
#                     makefile only without executing the actual make command.
#  DOWNLOAD        - Setting to 'no' will create executable object file but it
#		     will not be loaded and run on the VxWorks target.
#  SYS_TARGET_FILE - Name of system target file.
#
#
MAKECMD          = make
#MAKECMD          = o:/Tornado_vxWorks/host/x86-win32/bin/make
#MAKECMD         = /home/username/wind/host/sun4-solaris2/bin/make
HOST             = ANY
BUILD            = yes
DOWNLOAD_SUCCESS = task spawned
DOWNLOAD         = no
SYS_TARGET_FILE  = tornado.tlc
MAKEFILE_FILESEP = /

#---------------------- Tokens expanded by make_rtw ----------------------------
#
# The following tokens, when wrapped with "|>" and "<|" are expanded by the 
# procedure.
#   
#  MODEL               - Name of the Simulink block diagram
#  MODULES             - Any additional generated source modules
#  MAKEFILE            - Name of makefile created from template makefile <model>.mk
#  MATLAB_ROOT         - Path to where MATLAB is installed. 
#  MATLAB_BIN          - Path to MATLAB executable.
#  S_FUNCTIONS_LIB     - List of S-functions libraries to link.
#  SOLVER              - Solver source file name
#  NUMST               - Number of sample times
#  TID01EQ             - yes (1) or no (0): Are sampling rates of continuous task 
#                        (tid=0) and 1st discrete task equal.
#  NCSTATES            - Number of continuous states
#  COMPUTER            - Computer type. See the MATLAB computer command.
#  BUILDARGS           - Options passed in at the command line.
#  MULTITASKING        - yes (1) or no (0): Is solver mode multitasking
#  MODELREFS           - List of referenced models
#  EXT_MODE            - yes (1) or no (0): Build for external mode
#  EXTMODE_TRANSPORT   - Name of transport mechanism (e.g. tcpip, serial) for extmode
#  EXTMODE_STATIC      - yes (1) or no (0): Use static instead of dynamic mem alloc.
#  EXTMODE_STATIC_SIZE - Size of static memory allocation buffer.
#  MAT_FILE            - yes (1) or no (0): generate a model.mat file?
#  STETHOSCOPE         - yes (1) or no (0): Build for use with StethoScope

MODEL               = rtwshared
MODULES             = rtGetInf.c rtGetNaN.c rt_nonfinite.c
MAKEFILE            = 
MATLAB_ROOT         = /usr/local/MATLAB/R2021a
ALT_MATLAB_ROOT     = /usr/local/MATLAB/R2021a
MATLAB_BIN          = /usr/local/MATLAB/R2021a/bin
ALT_MATLAB_BIN      = /usr/local/MATLAB/R2021a/bin
START_DIR           = /home/kvasios/simulink-concurrent-execution
S_FUNCTIONS_LIB     = 
SOLVER              = 
NUMST               = 
TID01EQ             = 0
NCSTATES            = 0
MEM_ALLOC           = 
COMPUTER            = GLNXA64
BUILDARGS           =  RTWCAPIPARAMS=0 RTWCAPISIGNALS=0
MULTITASKING        = 0
EXT_MODE            = 0
EXTMODE_TRANSPORT   = 0
EXTMODE_STATIC      = 0
EXTMODE_STATIC_SIZE = 1000000
MAT_FILE            = 0
STETHOSCOPE         = 0
DOWNLOAD            = 0
BASE_PRIORITY       = 30
STACK_SIZE          = 16384
MODELREFS           = 
TARGET_LANG_EXT     = 
DEFINES_OTHER        = -DNRT -DUSE_RTMODEL
COMPILE_FLAGS_OTHER  = 

MODELLIB                  = rtwshared.a
MODELREF_LINK_LIBS        = 
RELATIVE_PATH_TO_ANCHOR   = ../../..
# NONE: standalone, SIM: modelref sim, RTW: modelref coder target
MODELREF_TARGET_TYPE      = 

#-- In the case when directory name contains space ---
ifneq ($(MATLAB_ROOT),$(ALT_MATLAB_ROOT))
MATLAB_ROOT := $(ALT_MATLAB_ROOT)
endif
ifneq ($(MATLAB_BIN),$(ALT_MATLAB_BIN))
MATLAB_BIN := $(ALT_MATLAB_BIN)
endif

#------------------------------ Tool Locations ---------------------------------
#
# Modify the following macros to reflect where you have installed these 
# packages.  They can be commented in/out depending on whether or not 
# you have included them in your environment.  If you are using 
# StethoScope but it was not installed in the default Tornado directory,
# add its include path to USER_INCLUDES below.
#
ifeq ($(COMPUTER),PCWIN)
  # Tornado Setup on WIN32, assumed macros are in environment.
  #WIND_BASE      = o:/Tornado_vxWorks
  #WIND_REGISTRY  = max
  #WIND_HOST_TYPE = x86-win32
else
  # Tornado Setup on UNIX, assumed macros are in environment.
  #WIND_BASE = /usr/wind
  #WIND_REGISTRY = $(HOST)
  #WIND_HOST_TYPE = sun4-solaris2
endif

#------------------------- VxWorks  Configuration ------------------------------
#
# Set the following variables to reflect the target processor that you are
# using.  Refer to the VxWorks Programmer's Guide for information on
# appropriate values.
#
#VX_TARGET_TYPE = ppc
#CPU_TYPE       = PPC604
VX_TARGET_TYPE = 68k
CPU_TYPE       = MC68040

#-------------------- Macros for Downloading to Target -------------------------
# Specify the name of your VxWorks system and the name of the host system that 
# will run the target server.
# NOTES: 1) The tgtsvr needs the core file(VxWorks image) to be specified on the
#        command line, use VX_CORE_LOC to point to the image.
#        2) On unix host platforms, the automatic invoking of tgtsvr via
#        downld.sh is commented out as it causes Matlab command prompt to block.
#        Invoke the tgtsvr once by hand on unix hosted platforms.
TARGET         = tower-20
TGTSVR_HOST    = max
VX_CORE_LOC    = $(WIND_BASE)/target/config/mv167/vxWorks
#VX_CORE_LOC    = $(WIND_BASE)/target/config/mv2604/vxWorks

PROGRAM_OPTS   = 

#-------------------------------- StethoScope Locations -------------------------
# Modify the follwoing macros to reflect where StethoScope was installed and
# what target processor and OS is being used.  The "TarGeT PRocessor OS" must 
# match the directory name under the "lib" directory.
# SCOPE_ROOT assumes the default StethoScope install directory is the Tornado
# directory.  If your installation of StethoScope was into its
# own directory, replace "/tornado/target" with the install directory and
# modify SCOPE_INCLUDES below.

# Use forward slashes in SCOPE_ROOT
SCOPE_ROOT  = $(WIND_BASE)/rti
#SCOPE_ROOT = /home/username/rti
#SCOPE_ROOT = d:/rti
RTI_LIB     = $(SCOPE_ROOT)/rtilib.4.2b
SCOPE_TOOLS = $(SCOPE_ROOT)/scopetools.4.0c
#TGT_PR_OS  = ppcVx5.4
TGT_PR_OS  = m68kVx5.4

ifeq ($(STETHOSCOPE),1)
  # SCOPE_INCLUDES assumes the default StethoScope install directory which is
  # the Tornado directory.  If your installation of StethScope was into its
  # own directory, modify SCOPE_INCLUDES accordingly.
  # Also not that the download script(downld.pl on Win32 and downld.sh on Unix)
  # may need to be modified if the path to the 3 StethoScope libraries is not 
  # the same, see the downld script.
  #SCOPE_INCLUDES = -I$(SCOPE_ROOT)/h -I$(SCOPE_ROOT)/../host/include/share
  SCOPE_INCLUDES = -I$(RTI_LIB)/include/share \
	 -I$(SCOPE_TOOLS)/include/share

  SCOPE_OPTS = -DSTETHOSCOPE -DRTI_VXWORKS
endif

#-------------------------------- GNU Tools ------------------------------------
#
# You may need to modify the following variables if you have installed the GNU
# Tools in a different location.
#
GNUROOT = $(WIND_BASE)/host/$(WIND_HOST_TYPE)
GCC_EXEC_PREFIX = $(GNUROOT)/lib/gcc-lib/
export GCC_EXEC_PREFIX = $(GNUROOT)/lib/gcc-lib/

CC   = $(GNUROOT)/bin/cc$(VX_TARGET_TYPE)
LD   = $(GNUROOT)/bin/ld$(VX_TARGET_TYPE)
AR   = $(GNUROOT)/bin/ar$(VX_TARGET_TYPE)

#------------------------ Code Generation page Options -------------------------------------
#
# External Mode
# Uncomment -DVERBOSE to have information printed to stdout
# To add a new transport layer, see the comments in
#   <matlabroot>/toolbox/simulink/simulink/extmode_transports.m
ifeq ($(EXT_MODE),1)
  EXT_CC_OPTS = -DEXT_MODE #-DVERBOSE
  ifeq ($(EXTMODE_TRANSPORT),0) #tcpip
    EXT_SRC = ext_svr.c updown.c ext_work.c rtiostream_interface.c rtiostream_tcpip.c
  endif
  ifeq ($(EXTMODE_STATIC),1)
    EXT_SRC     += mem_mgr.c
    EXT_CC_OPTS += -DEXTMODE_STATIC -DEXTMODE_STATIC_SIZE=$(EXTMODE_STATIC_SIZE)
  endif
endif
#
# .mat File Logging
#NOTE: by default, the .mat file is created in the root directory of the
#      host file system that VxWorks was booted from.
ifeq ($(MAT_FILE),1)
  LOG_OPTS  = -DMAT_FILE
endif
#

#------------------------------ Include Path -----------------------------------
#

# Additional includes 

ADD_INCLUDES = \
	-I$(START_DIR) \
	-I$(START_DIR)/slprj/tornado/_sharedutils \
	-I$(MATLAB_ROOT)/extern/include \
	-I$(MATLAB_ROOT)/simulink/include \
	-I$(MATLAB_ROOT)/rtw/c/src \
	-I$(MATLAB_ROOT)/rtw/c/src/ext_mode/common \


# Tornado includes

#------------------------- Tornado target compiler includes Configuration -----
TORNADO_INCLUDES = \
	-I$(WIND_BASE)/target/h \
	-I$(WIND_BASE)/host/include/share \
	-I$(GNUROOT)/lib/gcc-lib/m68k-wrs-vxworks/gcc-2.96/include

USER_INCLUDES = 

INCLUDES = -I. -I.. -I$(RELATIVE_PATH_TO_ANCHOR) $(ADD_INCLUDES) $(TORNADO_INCLUDES) \
	       $(SCOPE_INCLUDES) $(USER_INCLUDES)

#----------------------------- RTModel Flags -----------------------------------
RTM_CC_OPTS = -DUSE_RTMODEL

#-------------------------------- C Flags --------------------------------------
# General User Options 
OPTS      = 
OPT_OPTS  = -O

# Required Options
GCC_FLAGS = -W -nostdinc -fno-builtin -B$(GCC_EXEC_PREFIX)
REQ_OPTS  = -DCPU=$(CPU_TYPE) -DVXWORKS $(GCC_FLAGS) 

CC_OPTS   = $(REQ_OPTS) $(OPTS) $(SCOPE_OPTS) $(EXT_CC_OPTS) $(LOG_OPTS) \
            $(RTM_CC_OPTS) $(COMPILE_FLAGS_OTHER)

CPP_REQ_DEFINES = -DMODEL=$(MODEL) -DRT -DNUMST=$(NUMST) \
                  -DTID01EQ=$(TID01EQ) -DNCSTATES=$(NCSTATES) -D$(MEM_ALLOC) \
                  -DMULTITASKING=$(MULTITASKING)
DEFINES = $(CPP_REQ_DEFINES) $(DEFINES_OTHER)

RT_MAIN_DEFINES = -DBASE_PRIORITY=$(BASE_PRIORITY) -DSTACK_SIZE=$(STACK_SIZE)

CFLAGS   = -c $(CC_OPTS) $(DEFINES) $(INCLUDES) $(OPT_OPTS)
CPPFLAGS = $(CFLAGS) $(CPP_OPTS)
LDFLAGS  = -r

LIBS =


LIBS += $(S_FUNCTIONS_LIB)

#----------------------------- Source Files ------------------------------------
#
USER_SRCS =
SRCS      = $(MODULES) $(USER_SRCS)
OBJS      = $(addsuffix .o, $(basename $(SRCS)))


ifeq ($(MODELREF_TARGET_TYPE), NONE)
    PROGRAM            = $(RELATIVE_PATH_TO_ANCHOR)/$(MODEL).lo
    BIN_SETTING        = $(LD) $(LDFLAGS) $(ADDITIONAL_LDFLAGS) -o $(PROGRAM)
    BUILD_PRODUCT_TYPE = "executable"
    SRCS               += $(MODEL).$(TARGET_LANG_EXT) rt_main.c rt_sim.c $(EXT_SRC) $(SOLVER)
else
    # Model reference coder target
    PRODUCT            = $(MODELLIB)
    BUILD_PRODUCT_TYPE = "library"
endif

#--------------------------------- Rules ---------------------------------------
ifeq ($(MODELREF_TARGET_TYPE),NONE)
$(PROGRAM) : $(OBJS) $(LIBS) $(MODELREF_LINK_LIBS)
	$(BIN_SETTING) $(OBJS) $(MODELREF_LINK_LIBS) $(LIBS) 
	@echo "### Created $(BUILD_PRODUCT_TYPE): $@"
else
$(PRODUCT) : $(OBJS)
	@rm -f $(MODELLIB)
	$(AR) ruvs $(MODELLIB) $(OBJS)
	@echo "### Created $(MODELLIB)"
	@echo "### Created $(BUILD_PRODUCT_TYPE): $@"
endif

%.o : %.c
	$(CC) $(CFLAGS) $<

%.o : ../%.c
	$(CC) $(CFLAGS) $<

%.o : %.cpp
	$(CC) $(CPPFLAGS) $<

%.o : ../%.cpp
	$(CC) $(CPPFLAGS) $<

%.o : $(RELATIVE_PATH_TO_ANCHOR)/%.c
	$(CC) -c $(CFLAGS) $<

%.o : $(RELATIVE_PATH_TO_ANCHOR)/%.cpp
	$(CC) -c $(CPPFLAGS) $<

%.o : $(MATLAB_ROOT)/rtw/c/tornado/%.c
	$(CC) $(CFLAGS) $(RT_MAIN_DEFINES) $<

%.o : $(MATLAB_ROOT)/rtw/c/tornado/devices/%.c
	$(CC) $(CFLAGS) $<

%.o : $(MATLAB_ROOT)/rtw/c/src/%.c
	$(CC) $(CFLAGS) $<

%.o : $(MATLAB_ROOT)/rtw/c/src/ext_mode/custom/%.c
	$(CC) $(CFLAGS) $<





# Libraries:






#----------------------------- Dependencies ------------------------------------

$(OBJS) : $(MAKEFILE) rtw_proj.tmw
