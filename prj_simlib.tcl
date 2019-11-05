#
#author: Golovachenko Viktor
#

set simpath C:/modelsim64_10.6d/win64
set usrdir ./sim/compile_simlib/

compile_simlib -simulator modelsim -simulator_exec_path {$simpath} -family artix7 -language all -library all -directory {$usrdir}
# -ip_compile

exit
