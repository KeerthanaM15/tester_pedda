#! /bin/csh -f 
#============================================================================
#  CONFIDENTIAL and Copyright (C) 2010 Test and Verification Solutions Ltd
#============================================================================
#  Contents:
#  run_test_reg.csh 
#
#  Brief description:
#  This is the run_test_reg.csh script, which is used to run the regression 
#  suite, i.e. all the test cases at a time either in the cadence or questa
#  sim. For further details run,

#  ./run_test_reg.csh -help
#
#  Known exceptions to rules:
#    
#============================================================================
#  Author        : 
#  Created on    : 
#  File Id       : $Id: run_test_reg_tvs_1149_10.csh,v 1.1.1.1 2012/12/24 08:20:22 naru Exp $
#============================================================================


setenv UVM_HOME /tools/questa10_3d/questasim/verilog_src/uvm-1.1d

if ($?UVM_HOME == 0) then
echo "#####################################################"
echo  Exiting Simulation
echo  UVM_HOME Not Set
echo  Please set the UVM_HOME to your uvm src directory
echo "#####################################################"
endif

set tool = "-questa"
set func_cov = 0
set pass_count = 0
set fail_count = 0
set testcase_count = 0
set ET = "Error_Test.inf"
set PT = "Pass_Test.inf"
set dump_option = ""
set verbosity = "UVM_NONE"
set dump_cadence = ""
set dump_questa = ""
set user_define = "VC_DUMMY"
set top_module_name = "top"
set cmd_option = ""
set boot_option = " "
# =============================================================================
# Get args
# =============================================================================
while ($#argv )
  if( "$1" == "-t") then
	shift 
	set testcase_name = "$1"
  else if( "$1" == "-cadence") then
        set tool = "$1"
  else if( "$1" == "-questa") then
        set tool = "$1"  
  else if( "$1" == "-func_cov") then
        set func_cov = 1
  else if( "$1" == "-dump_cadence") then
        set dump_option = "$1"
  else if( "$1" == "-dump_questa") then
        set dump_option = "$1"  
else if( "$1" == "-boot1") then
        set boot_option = "+boot1"
 else if( "$1" == "-boot2") then
        set boot_option = "+boot2"   
  else if( "$1" == "-v") then
        shift
        set verbosity = "$1"   
  else if( "$1" == "-define" )then
       shift
       set user_define = $1;
       echo $user_define;
       finish; 
  else if( "$1" == "-h" || "$1" == "-help") then
        goto SHOW_OPTIONS
  else if( "$1" == "-clean" || "$1" == "-cl") then
        goto CLEANUP_DATABASE
  endif
  shift
end


# =============================================================================
# Execute
# =============================================================================

if(-f $ET ) then
 rm -rf $ET 
endif


if(-f $PT ) then
 rm -rf $PT 
endif


if ("$tool" == "-cadence" ) then

  if ("$dump_option" == "-dump_cadence") then
   set dump_cadence="+define+CADENCE_DUMP  +access+rw"
  endif
  
  if ($func_cov == 1) then
      if ! (-e ./coverage_1149_10) then
          mkdir ./coverage_1149_10
      endif
  
      if ! (-e ./coverage_1149_10/reports) then
          mkdir -p ./coverage_1149_10/reports
      endif
  
      if  (-e ./coverage_1149_10/cov_work) then
          rm -r ./coverage_1149_10/cov_work
      endif
  
      if  (-e ./cov_work) then
          rm -r ./cov_work
      endif
  
      if ! (-e ./coverage_1149_10/cov_dump) then
          mkdir ./coverage_1149_10/cov_dump
      endif
  endif

  if ! (-e ./logs_1149_10) then
     mkdir ./logs_1149_10
  endif 

endif


if ("$tool" == "-questa" ) then

  if ( -e ./work) then
     rm -rf ./work
  endif

  if ("$dump_option" == "-dump_questa") then
    set dump_questa="add wave -r /*;"
  endif

  if ($func_cov == 1) then
   if ! (-e ./coverage_1149_10/testcase_ucdb/reports) then
     mkdir -p ./coverage_1149_10/testcase_ucdb/reports
   endif
  endif

  if ($func_cov == 1) then
   if ! (-e ./coverage_1149_10/merged_ucdb/reports) then
     mkdir -p ./coverage_1149_10/merged_ucdb/reports
   endif
  endif

  if ! (-e ./logs_1149_10) then
     mkdir ./logs_1149_10
  endif

endif


set FILENAME = ./ieee_1149_10_test_list

foreach testcase_name ( `cat $FILENAME` )
 echo " "
 echo "###################################### "
 echo "TESTCASE:" $testcase_name
 echo "###################################### "

 set testcase_count = `expr $testcase_count + 1`

 if ("$tool" == "-cadence" ) then
 endif 
  
 if ("$tool" == "-questa" ) then
  if ( -e ./work) then
  	rm -r ./work
  endif
 endif


 if ("$tool" == "-cadence" ) then
    if($func_cov == 1) then
          irun -TIMESCALE 1ps/1ps -v93 -messages -linedebug -licqueue -covfile covfile.cf +define+GDA_SPI -svseed random\
          -f ../compile/rtl_comp_list.fl \
          -f ../compile/tb_comp_list.fl \
          +UVM_TESTNAME=$testcase_name \
          +UVM_VERBOSITY=$verbosity  \
          -uvmhome $UVM_HOME \
          +nccoverage+u \
          +tcl+run.tcl \
      	  $dump_cadence | tee -a $testcase_name.log 

          if ( -e ./coverage_1149_10/cov_dump/$testcase_name) then
           rm -rf ./coverage_1149_10/cov_dump/$testcase_name
           rm -rf ./coverage_1149_10/reports/$testcase_name
          else 
           mkdir -p ./coverage_1149_10/cov_dump/$testcase_name
           mkdir -p ./coverage_1149_10/reports/$testcase_name
          endif 
 
         # cp -rf ./cov_work/tvs_sio_tb_top/*  ./coverage_1149_10/cov_dump/
        #  iccr  iccr_single_test_cov.cmd
          #iccr  iccr_regression_cov.cmd
          #mv ./coverage_1149_10/cov_dump/test/*.ucd ./coverage_1149_10/cov_dump/$testcase_name
          #mv ./coverage_1149_10/cov_dump/*.ucm      ./coverage_1149_10/cov_dump/$testcase_name
          #mv ./coverage_1149_10/reports/report.rpt  ./coverage_1149_10/reports/$testcase_name/$testcase_name\_func_cov.rpt
          #rm -rf ./cov_work  ./coverage_1149_10/cov_dump/test
     else if("$cmd_option" == "-cmdp") then
        irun -TIMESCALE 1ns/1ns -v93 -messages -linedebug +define+GDA_SPI +define+$user_define -svseed random \
        #irun -v93 -messages -linedebug +define+GDA_SPI \
        -f ../compile/rtl_comp_list.fl \
        -f ../compile/rtl_comp_list_new.fl \
        -f ../compile/tb_comp_list.fl \
	    +UVM_TESTNAME=$testcase_name \
	    +UVM_VERBOSITY=$verbosity  \
	    -uvmhome $UVM_HOME \
	    $dump_cadence | tee -a $testcase_name.log 
  else 
      echo $user_define 
          irun -TIMESCALE 1ns/1ps -v93 -messages -linedebug  +define+GDA_SPI \
          -f ../compile/rtl_comp_list.fl \
          -f ../compile/tb_comp_list.fl \
          +UVM_TESTNAME=$testcase_name \
          +UVM_VERBOSITY=$verbosity  \
          -uvmhome $UVM_HOME \
          $dump_cadence | tee -a $testcase_name.log
    endif
 endif # if ("$tool" == "-cadence" )


 if ("$tool" == "-questa" ) then
    if($func_cov == 1) then

      qverilog -sv -novopt +cover=bcfst  +define+QUESTA  \
          -f ../compile/comp_list.fl \
          -R -coverage +UVM_TESTNAME=$testcase_name +UVM_VERBOSITY=$verbosity  \
	-coverage -assertcover \
	-voptargs="+cover=bcfst" \
          -cvg63 \
 	  -do "$dump_questa; coverage save -cvg -assert -codeAll -onexit $testcase_name.ucdb; run -all; exit" | tee -a $testcase_name.log
#          -do "$dump_questa;  run -a; quit -f"  \
#         | tee  $testcase_name.log
#      vlib work
#      vlog -sv +define+QUESTA_SIM \
#          -f ../compile/comp_list.fl \
#          +cover=bcefst | tee $testcase_name.log
#     vsim -novopt  \
#          +UVM_TESTNAME=$testcase_name \
#          +UVM_VERBOSITY=$verbosity  \
#   	  -coverage -sv_seed random \
#          -voptargs="+cover=bcfst" \
#          -cvg63 \
#      vlog -sv  -novopt +cover   \
#	  +define+QUESTA   \
#         -f ../compile/comp_list.fl | tee $testcase_name.log
#    vsim -novopt -coverage $top_module_name  +UVM_TESTNAME=$testcase_name \
#       +UVM_VERBOSITY=$verbosity  \
#      -do "$dump_questa;coverage save -codeAll -cvg -onexit $testcase_name.ucdb;  run -all; exit" \
#          | tee -a $testcase_name.log 
      
      if ( -d ./coverage_1149_10/testcase_ucdb/$testcase_name.ucdb ) then
        rm -rf ./coverage_1149_10/testcase_ucdb/$testcase_name.ucdb
      endif

      mv $testcase_name.ucdb ./coverage_1149_10/testcase_ucdb
      vcover report -details ./coverage_1149_10/testcase_ucdb/$testcase_name.ucdb > ./coverage_1149_10/testcase_ucdb/reports/$testcase_name.rpt

    else

      qverilog -sv -novopt   +define+QUESTA  \
          -f ../compile/comp_list.fl \
          -R  +UVM_TESTNAME=$testcase_name +UVM_VERBOSITY=$verbosity  \
          -do "$dump_questa;  run -a; quit -f"  \
         | tee  $testcase_name.log
    endif 
 endif # if ("$tool" == "-questa" )


 if ! (-e ./logs_1149_10/$testcase_name) then
    mkdir ./logs_1149_10/$testcase_name
 endif


 if ("$tool" == "-cadence" ) then
    if  (-d ./logs_1149_10/$testcase_name/$testcase_name.trn) then
     rm -rf ./logs_1149_10/$testcase_name/$testcase_name.trn
    endif

    if  (-d ./logs_1149_10/$testcase_name/$testcase_name.dsn) then
     rm -rf ./logs_1149_10/$testcase_name/$testcase_name.dsn
    endif 
 endif 


 if ("$tool" == "-questa" ) then
    if  (-d ./logs_1149_10/$testcase_name/$testcase_name.wlf) then
      rm -rf ./logs_1149_10/$testcase_name/$testcase_name.wlf
    endif
 endif

 mv $testcase_name.log ./logs_1149_10/$testcase_name/$testcase_name.log
 mv app_log ./logs_1149_10/$testcase_name/app_log

 if ("$dump_option" == "-dump_cadence") then
   mv tvs_sio_dump.trn  ./logs_1149_10/$testcase_name/$testcase_name.trn
   mv tvs_sio_dump.dsn  ./logs_1149_10/$testcase_name/$testcase_name.dsn
 endif

 if ("$dump_option" == "-dump_questa") then
   mv *.wlf   ./logs_1149_10/$testcase_name/$testcase_name.wlf
 endif

 
 if (`grep -c "\<Fatal\>" ./logs_1149_10/$testcase_name/$testcase_name.log`) then
       set result_status  = "TEST FAILED DURING COMPILATION/SIMULATION"
       set result = "TEST_FAILED"
       if(-f $ET ) then
         echo $testcase_name >>$ET 
       else
         echo $testcase_name >$ET
       endif
      
   else if (`grep -c "\<Error\>" ./logs_1149_10/$testcase_name/$testcase_name.log`) then
       set result_status  = "TEST FAILED DURING COMPILATION/SIMULATION"
       set result = "TEST_FAILED"
       if(-f $ET ) then
         echo $testcase_name >>$ET 
       else
         echo $testcase_name >$ET
       endif

   else if (`grep -c "ncvlog: \*E" ./logs_1149_10/$testcase_name/$testcase_name.log`) then
       set result_status  = "TEST FAILED DUE TO COMPILATION ERRORS"
       set result = "TEST_FAILED" 
       if(-f $ET ) then
         echo $testcase_name >>$ET 
       else
         echo $testcase_name >$ET
       endif

   else if (`grep -c "ncelab: \*E" ./logs_1149_10/$testcase_name/$testcase_name.log`) then
       set result_status  = "TEST FAILED DUE TO ELABORATION ERRORS"
       set result = "TEST_FAILED"
       if(-f $ET ) then
         echo $testcase_name >>$ET 
       else
         echo $testcase_name >$ET
       endif

   else if (`grep -c "UVM_FATAL \@" ./logs_1149_10/$testcase_name/$testcase_name.log`) then
       set result_status  = "TEST FAILED DUE TO UVM_FATAL"
       set result  = "TEST_FAILED"
       if(-f $ET ) then
         echo $testcase_name >>$ET 
       else
         echo $testcase_name >$ET
       endif
   else if (`grep -c "FAIL" ./logs_1149_10/$testcase_name/app_log`) then
       set result_status  = "TEST FAILED DUE TO FAIL FROM APP_LOG"
       set result = "TEST_FAILED"
       if(-f $ET ) then
         echo $testcase_name >>$ET 
       else
         echo $testcase_name >$ET
       endif

   else if (`grep -c "UVM_ERROR \@" ./logs_1149_10/$testcase_name/$testcase_name.log`) then
       set result_status  = "TEST FAILED DUE TO UVM_ERROR"
       set result = "TEST_FAILED"
       if(-f $ET ) then
         echo $testcase_name >>$ET 
       else
         echo $testcase_name >$ET
       endif
 
   else if (`grep -c "UVM_WARNING \@" ./logs_1149_10/$testcase_name/$testcase_name.log`) then
       set result_status  = "TEST FAILED DUE TO UVM_WARNING"
       set result = "TEST_PASSED"
       if(-f $ET ) then
         echo $testcase_name >>$PT 
       else
         echo $testcase_name >$PT
       endif

   else
       set result_status  = " "
       set result = "TEST_PASSED"
       if(-f $PT ) then
         echo $testcase_name >>$PT 
       else
         echo $testcase_name >$PT
       endif
 endif


 echo " " | tee -a ./logs_1149_10/$testcase_name/$testcase_name.log 
 echo " =============================================== " | tee -a ./logs_1149_10/$testcase_name/$testcase_name.log
 echo " ----------------- TEST_RESULT------------------ " | tee -a ./logs_1149_10/$testcase_name/$testcase_name.log
 echo " =============================================== " | tee -a ./logs_1149_10/$testcase_name/$testcase_name.log
 echo " TEST-NAME: $testcase_name " | tee -a ./logs_1149_10/$testcase_name/$testcase_name.log
 if ($result == "TEST_FAILED") then
   echo " RESULT_STATUS: $result_status " | tee -a ./logs_1149_10/$testcase_name/$testcase_name.log
   echo " RESULT: $result " | tee -a ./logs_1149_10/$testcase_name/$testcase_name.log
 else
   echo " RESULT: $result " | tee -a ./logs_1149_10/$testcase_name/$testcase_name.log
 endif
 echo " ############################################### " | tee -a ./logs_1149_10/$testcase_name/$testcase_name.log
 
 
 if ($result == "TEST_PASSED") then
 	set pass_count = `expr $pass_count + 1`
 else if ($result == "TEST_FAILED") then
 	set fail_count = `expr $fail_count + 1`
 endif

end  # End of Foreach Loop


  if ("$tool" == "-questa" ) then
   if($func_cov == 1) then
      vcover merge ./coverage_1149_10/merged_ucdb/merged_ucdb.ucdb  ./coverage_1149_10/testcase_ucdb/*.ucdb 
      vcover report -details ./coverage_1149_10/merged_ucdb/merged_ucdb.ucdb > ./coverage_1149_10/merged_ucdb/reports/merged_ucdb.rpt_det
    vcover report -cvg -assert -code bcefst -details ./coverage_1149_10/merged_ucdb/merged_ucdb.ucdb > ./coverage_1149_10/merged_ucdb/reports/merged_ucdb.fun_det
vcover report -cvg -assert -code bcefst -details -code bcfst -html -htmldir ./coverage_1149_10/merged_ucdb/report_html ./coverage_1149_10/merged_ucdb/merged_ucdb.ucdb
 
    endif
  endif 
  
  if ("$tool" == "-cadence" ) then
   if($func_cov == 1) then
     rm -rf ./coverage_1149_10/cov_dump 
     mkdir -p ./coverage_1149_10/reports/merged_coverage
     iccr iccr_regression_cov.cmd
     mv ./coverage_1149_10/cov_dump ./coverage_1149_10 
   endif
  endif 


  echo " " | tee -a ./tvs_sio_regression_statistics.info
  echo " =============================================== " | tee -a ./tvs_sio_regression_statistics.info
  echo " 	      REGRESSION STATISTICS  		 " | tee -a ./tvs_sio_regression_statistics.info
  echo " =============================================== " | tee -a ./tvs_sio_regression_statistics.info
  echo " TESTCASES RUN    :" $testcase_count | tee -a ./tvs_sio_regression_statistics.info
  echo " TESTCASES PASSED :" $pass_count | tee -a ./tvs_sio_regression_statistics.info
  echo " TESTCASES FAILED :" $fail_count | tee -a ./tvs_sio_regression_statistics.info
  echo " =============================================== " | tee -a ./tvs_sio_regression_statistics.info
  
  echo " =============================================== " | tee -a ./tvs_sio_regression_statistics.info
  echo " 		    PASS TEST 			 " | tee -a ./tvs_sio_regression_statistics.info
  echo " =============================================== " | tee -a ./tvs_sio_regression_statistics.info
  if (-f $PT) then
  cat $PT 	     | tee -a ./tvs_sio_regression_statistics.info	
  else 
  echo " No Test Passed in Regression" | tee -a ./tvs_sio_regression_statistics.info
  endif
  echo " =============================================== " | tee -a ./tvs_sio_regression_statistics.info

  echo " =============================================== " | tee -a ./tvs_sio_regression_statistics.info
  echo " 		    FAIL TEST 			 " | tee -a ./tvs_sio_regression_statistics.info
  echo " =============================================== " | tee -a ./tvs_sio_regression_statistics.info
  if (-f $ET) then
  cat $ET 	     | tee -a ./tvs_sio_regression_statistics.info	
  else
  echo " No Test Failed in Regression" | tee -a ./tvs_sio_regression_statistics.info
  endif
  echo " =============================================== " | tee -a ./tvs_sio_regression_statistics.info

exit(0)

SHOW_OPTIONS:

echo ""
echo "Usage: run_test_reg.csh [-cadence       : Enables Running in Cadence Simulator  ]"
echo "                        [-questa        : Enables Running in Questa  Simulator  ]"
echo "                        [-func_cov      : Enable  Functional Coverage ]"
echo "                        [-dump_cadence  : Enables Dumping for waveform viewing in Cadence Simulator  ]"
echo "                        [-dump_questa   : Enables Dumping for waveform viewing in Questa  Simulator  ]"
echo "                        [-v <verbosity> : Enables the Reporting Mechanism ]"
echo "                             | UVM_NONE : Prints only the UVM_WARNING Informations - For Error Checking"
echo "                             | UVM_LOW  : Prints only the UVM_WARNING and UVM_INFO Informations - For Error Checking"
echo "                             | UVM_HIGH : Prints the UVM_INFO, UVM_WARNING, UVM_ERROR, UVM_FATAL Informations - For Debugging"
echo ""
echo "        run_test_reg.csh -h[elp]"
echo ""

exit(0)

CLEANUP_DATABASE:

echo ""
echo "Cleaning up the Database.......";
rm -rf  ./coverage_1149_10 ./logs_1149_10 ./work ./transcript ./INCA_libs 
find . -name "*.log"  -exec rm -rf {} \; 
find . -name "*.inf"  -exec rm -rf {} \; 
find . -name "*.info" -exec rm -rf {} \; 
find . -name "*.wlf"  -exec rm -rf {} \; 
find . -name "*.vcd"  -exec rm -rf {} \; 
find . -name "*.vpd"  -exec rm -rf {} \; 
find . -name "*.ucdb" -exec rm -rf {} \; 
find . -name "*.do"   -exec rm -rf {} \; 
find . -name "*.vstf" -exec rm -rf {} \;
find . -name "*.trn"  -exec rm -rf {} \;
find . -name "*.dsn"  -exec rm -rf {} \;
find . -name "*.key"  -exec rm -rf {} \;

exit(0)

#============================================================================
# Modification History:
# $Log: run_test_reg_tvs.csh,v $
# Revision 1.1.1.1  2012/12/24 08:20:22  naru
# My initial project message
#
# Revision 1.8  2012/02/28 13:23:10  siva
# lic_queue added
#
# Revision 1.7  2012/01/12 05:22:29  babu
# added cross coverage uncoverd bin generation support
#
# Revision 1.6  2011/12/21 14:14:58  siva
# svseed in reg added
#
# Revision 1.5  2011/12/14 13:52:56  sugi
# *** empty log message ***
#
# Revision 1.4  2011/12/14 10:37:47  sugi
# updated
#
# Revision 1.3  2011/12/14 10:28:29  sugi
# updated
#
# Revision 1.2  2011/12/08 05:57:14  sugi
# changes made
#
# Revision 1.1.1.1  2011/10/21 13:39:19  babu
# Initial check in
#
# Revision 1.6  2011/08/09 13:33:02  babu
# functional coverage update
#
# Revision 1.5  2011/03/16 06:09:13  bharathkumar
# UVM HOME path changed
#
# Revision 1.4  2011/03/15 07:34:56  bharathkumar
# uvm_HOME  path is changed
#
# Revision 1.3  2011/02/28 06:46:30  bharathkumar
# changed script
#
# Revision 1.1.1.1  2011/02/11 06:48:11  bharathkumar
# data
#
#
#============================================================================
