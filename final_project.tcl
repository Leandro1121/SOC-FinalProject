
################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2025.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   if { [string compare $scripts_vivado_version $current_vivado_version] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2042 -severity "ERROR" " This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Sourcing the script failed since it was created with a future version of Vivado."}

   } else {
     catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   }

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7s50csga324-1
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name design_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
NEORV32:user:neorv32_vivado_ip:1.0\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:ip:smartconnect:1.0\
xilinx.com:ip:mig_7series:4.2\
xilinx.com:inline_hdl:ilvector_logic:1.0\
xilinx.com:inline_hdl:ilconcat:1.0\
xilinx.com:ip:axi_gpio:2.0\
user.org:user:P1_BD_S2026:1.0\
xilinx.com:ip:util_vector_logic:2.0\
xilinx.com:inline_hdl:ilslice:1.0\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}


##################################################################
# MIG PRJ FILE TCL PROCs
##################################################################

proc write_mig_file_design_1_mig_7series_0_0 { str_mig_prj_filepath } {

   file mkdir [ file dirname "$str_mig_prj_filepath" ]
   set mig_prj_file [open $str_mig_prj_filepath  w+]

   puts $mig_prj_file {﻿<?xml version="1.0" encoding="UTF-8" standalone="no" ?>}
   puts $mig_prj_file {<Project NoOfControllers="1">}
   puts $mig_prj_file {  }
   puts $mig_prj_file {<!-- IMPORTANT: This is an internal file that has been generated by the MIG software. Any direct editing or changes made to this file may result in unpredictable behavior or data corruption. It is strongly advised that users do not edit the contents of this file. Re-run the MIG GUI with the required settings if any of the options provided below need to be altered. -->}
   puts $mig_prj_file {  <ModuleName>design_1_mig_7series_0_1</ModuleName>}
   puts $mig_prj_file {  <dci_inouts_inputs>1</dci_inouts_inputs>}
   puts $mig_prj_file {  <dci_inputs>1</dci_inputs>}
   puts $mig_prj_file {  <Debug_En>OFF</Debug_En>}
   puts $mig_prj_file {  <DataDepth_En>1024</DataDepth_En>}
   puts $mig_prj_file {  <LowPower_En>ON</LowPower_En>}
   puts $mig_prj_file {  <XADC_En>Enabled</XADC_En>}
   puts $mig_prj_file {  <TargetFPGA>xc7s50-csga324/-1</TargetFPGA>}
   puts $mig_prj_file {  <Version>4.2</Version>}
   puts $mig_prj_file {  <SystemClock>No Buffer</SystemClock>}
   puts $mig_prj_file {  <ReferenceClock>No Buffer</ReferenceClock>}
   puts $mig_prj_file {  <SysResetPolarity>ACTIVE HIGH</SysResetPolarity>}
   puts $mig_prj_file {  <BankSelectionFlag>FALSE</BankSelectionFlag>}
   puts $mig_prj_file {  <InternalVref>1</InternalVref>}
   puts $mig_prj_file {  <dci_hr_inouts_inputs>50 Ohms</dci_hr_inouts_inputs>}
   puts $mig_prj_file {  <dci_cascade>0</dci_cascade>}
   puts $mig_prj_file {  <FPGADevice>}
   puts $mig_prj_file {    <selected>7s/xc7s25-csga324</selected>}
   puts $mig_prj_file {  </FPGADevice>}
   puts $mig_prj_file {  <Controller number="0">}
   puts $mig_prj_file {    <MemoryDevice>DDR3_SDRAM/Components/MT41K64M16XX-125</MemoryDevice>}
   puts $mig_prj_file {    <TimePeriod>3000</TimePeriod>}
   puts $mig_prj_file {    <VccAuxIO>1.8V</VccAuxIO>}
   puts $mig_prj_file {    <PHYRatio>4:1</PHYRatio>}
   puts $mig_prj_file {    <InputClkFreq>333.333</InputClkFreq>}
   puts $mig_prj_file {    <UIExtraClocks>0</UIExtraClocks>}
   puts $mig_prj_file {    <MMCM_VCO>666</MMCM_VCO>}
   puts $mig_prj_file {    <MMCMClkOut0> 1.000</MMCMClkOut0>}
   puts $mig_prj_file {    <MMCMClkOut1>1</MMCMClkOut1>}
   puts $mig_prj_file {    <MMCMClkOut2>1</MMCMClkOut2>}
   puts $mig_prj_file {    <MMCMClkOut3>1</MMCMClkOut3>}
   puts $mig_prj_file {    <MMCMClkOut4>1</MMCMClkOut4>}
   puts $mig_prj_file {    <DataWidth>16</DataWidth>}
   puts $mig_prj_file {    <DeepMemory>1</DeepMemory>}
   puts $mig_prj_file {    <DataMask>1</DataMask>}
   puts $mig_prj_file {    <ECC>Disabled</ECC>}
   puts $mig_prj_file {    <Ordering>Strict</Ordering>}
   puts $mig_prj_file {    <BankMachineCnt>4</BankMachineCnt>}
   puts $mig_prj_file {    <CustomPart>FALSE</CustomPart>}
   puts $mig_prj_file {    <NewPartName/>}
   puts $mig_prj_file {    <RowAddress>13</RowAddress>}
   puts $mig_prj_file {    <ColAddress>10</ColAddress>}
   puts $mig_prj_file {    <BankAddress>3</BankAddress>}
   puts $mig_prj_file {    <MemoryVoltage>1.35V</MemoryVoltage>}
   puts $mig_prj_file {    <C0_MEM_SIZE>134217728</C0_MEM_SIZE>}
   puts $mig_prj_file {    <UserMemoryAddressMap>BANK_ROW_COLUMN</UserMemoryAddressMap>}
   puts $mig_prj_file {    <PinSelection>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="V3" SLEW="FAST" VCCAUX_IO="" name="ddr3_addr[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="U3" SLEW="FAST" VCCAUX_IO="" name="ddr3_addr[10]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="P5" SLEW="FAST" VCCAUX_IO="" name="ddr3_addr[11]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="V6" SLEW="FAST" VCCAUX_IO="" name="ddr3_addr[12]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="V7" SLEW="FAST" VCCAUX_IO="" name="ddr3_addr[13]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="R6" SLEW="FAST" VCCAUX_IO="" name="ddr3_addr[14]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="R4" SLEW="FAST" VCCAUX_IO="" name="ddr3_addr[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="P6" SLEW="FAST" VCCAUX_IO="" name="ddr3_addr[2]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="T3" SLEW="FAST" VCCAUX_IO="" name="ddr3_addr[3]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="T6" SLEW="FAST" VCCAUX_IO="" name="ddr3_addr[4]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="T1" SLEW="FAST" VCCAUX_IO="" name="ddr3_addr[5]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="V5" SLEW="FAST" VCCAUX_IO="" name="ddr3_addr[6]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="U7" SLEW="FAST" VCCAUX_IO="" name="ddr3_addr[7]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="R7" SLEW="FAST" VCCAUX_IO="" name="ddr3_addr[8]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="U6" SLEW="FAST" VCCAUX_IO="" name="ddr3_addr[9]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="V2" SLEW="FAST" VCCAUX_IO="" name="ddr3_ba[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="V4" SLEW="FAST" VCCAUX_IO="" name="ddr3_ba[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="R3" SLEW="FAST" VCCAUX_IO="" name="ddr3_ba[2]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="U1" SLEW="FAST" VCCAUX_IO="" name="ddr3_cas_n"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL135" PADName="T4" SLEW="FAST" VCCAUX_IO="" name="ddr3_ck_n[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL135" PADName="R5" SLEW="FAST" VCCAUX_IO="" name="ddr3_ck_p[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="T5" SLEW="FAST" VCCAUX_IO="" name="ddr3_cke[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="K4" SLEW="FAST" VCCAUX_IO="" name="ddr3_dm[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="M3" SLEW="FAST" VCCAUX_IO="" name="ddr3_dm[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="UNTUNED_SPLIT_50" IOSTANDARD="SSTL135" PADName="K2" SLEW="FAST" VCCAUX_IO="" name="ddr3_dq[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="UNTUNED_SPLIT_50" IOSTANDARD="SSTL135" PADName="P1" SLEW="FAST" VCCAUX_IO="" name="ddr3_dq[10]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="UNTUNED_SPLIT_50" IOSTANDARD="SSTL135" PADName="N1" SLEW="FAST" VCCAUX_IO="" name="ddr3_dq[11]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="UNTUNED_SPLIT_50" IOSTANDARD="SSTL135" PADName="R2" SLEW="FAST" VCCAUX_IO="" name="ddr3_dq[12]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="UNTUNED_SPLIT_50" IOSTANDARD="SSTL135" PADName="N4" SLEW="FAST" VCCAUX_IO="" name="ddr3_dq[13]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="UNTUNED_SPLIT_50" IOSTANDARD="SSTL135" PADName="P2" SLEW="FAST" VCCAUX_IO="" name="ddr3_dq[14]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="UNTUNED_SPLIT_50" IOSTANDARD="SSTL135" PADName="M2" SLEW="FAST" VCCAUX_IO="" name="ddr3_dq[15]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="UNTUNED_SPLIT_50" IOSTANDARD="SSTL135" PADName="M4" SLEW="FAST" VCCAUX_IO="" name="ddr3_dq[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="UNTUNED_SPLIT_50" IOSTANDARD="SSTL135" PADName="K3" SLEW="FAST" VCCAUX_IO="" name="ddr3_dq[2]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="UNTUNED_SPLIT_50" IOSTANDARD="SSTL135" PADName="L5" SLEW="FAST" VCCAUX_IO="" name="ddr3_dq[3]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="UNTUNED_SPLIT_50" IOSTANDARD="SSTL135" PADName="L6" SLEW="FAST" VCCAUX_IO="" name="ddr3_dq[4]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="UNTUNED_SPLIT_50" IOSTANDARD="SSTL135" PADName="M6" SLEW="FAST" VCCAUX_IO="" name="ddr3_dq[5]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="UNTUNED_SPLIT_50" IOSTANDARD="SSTL135" PADName="L4" SLEW="FAST" VCCAUX_IO="" name="ddr3_dq[6]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="UNTUNED_SPLIT_50" IOSTANDARD="SSTL135" PADName="K6" SLEW="FAST" VCCAUX_IO="" name="ddr3_dq[7]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="UNTUNED_SPLIT_50" IOSTANDARD="SSTL135" PADName="N5" SLEW="FAST" VCCAUX_IO="" name="ddr3_dq[8]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="UNTUNED_SPLIT_50" IOSTANDARD="SSTL135" PADName="M1" SLEW="FAST" VCCAUX_IO="" name="ddr3_dq[9]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="UNTUNED_SPLIT_50" IOSTANDARD="DIFF_SSTL135" PADName="L1" SLEW="FAST" VCCAUX_IO="" name="ddr3_dqs_n[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="UNTUNED_SPLIT_50" IOSTANDARD="DIFF_SSTL135" PADName="N2" SLEW="FAST" VCCAUX_IO="" name="ddr3_dqs_n[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="UNTUNED_SPLIT_50" IOSTANDARD="DIFF_SSTL135" PADName="K1" SLEW="FAST" VCCAUX_IO="" name="ddr3_dqs_p[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="UNTUNED_SPLIT_50" IOSTANDARD="DIFF_SSTL135" PADName="N3" SLEW="FAST" VCCAUX_IO="" name="ddr3_dqs_p[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="P7" SLEW="FAST" VCCAUX_IO="" name="ddr3_odt[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="U2" SLEW="FAST" VCCAUX_IO="" name="ddr3_ras_n"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="M5" SLEW="FAST" VCCAUX_IO="" name="ddr3_reset_n"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="T2" SLEW="FAST" VCCAUX_IO="" name="ddr3_we_n"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="LVDS_25" PADName="B1" SLEW="" VCCAUX_IO="" name="sys_clk_n"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="LVDS_25" PADName="C1" SLEW="" VCCAUX_IO="" name="sys_clk_p"/>}
   puts $mig_prj_file {    </PinSelection>}
   puts $mig_prj_file {    <System_Control>}
   puts $mig_prj_file {      <Pin Bank="Select Bank" PADName="No connect" name="sys_rst"/>}
   puts $mig_prj_file {      <Pin Bank="Select Bank" PADName="No connect" name="init_calib_complete"/>}
   puts $mig_prj_file {      <Pin Bank="15" PADName="C13" name="tg_compare_error"/>}
   puts $mig_prj_file {    </System_Control>}
   puts $mig_prj_file {    <TimingParameters>}
   puts $mig_prj_file {      <Parameters tcke="5" tfaw="40" tras="35" trcd="13.75" trefi="7.8" trfc="110" trp="13.75" trrd="7.5" trtp="7.5" twtr="7.5"/>}
   puts $mig_prj_file {    </TimingParameters>}
   puts $mig_prj_file {    <mrBurstLength name="Burst Length">8 - Fixed</mrBurstLength>}
   puts $mig_prj_file {    <mrBurstType name="Read Burst Type and Length">Sequential</mrBurstType>}
   puts $mig_prj_file {    <mrCasLatency name="CAS Latency">5</mrCasLatency>}
   puts $mig_prj_file {    <mrMode name="Mode">Normal</mrMode>}
   puts $mig_prj_file {    <mrDllReset name="DLL Reset">No</mrDllReset>}
   puts $mig_prj_file {    <mrPdMode name="DLL control for precharge PD">Slow Exit</mrPdMode>}
   puts $mig_prj_file {    <emrDllEnable name="DLL Enable">Enable</emrDllEnable>}
   puts $mig_prj_file {    <emrOutputDriveStrength name="Output Driver Impedance Control">RZQ/7</emrOutputDriveStrength>}
   puts $mig_prj_file {    <emrMirrorSelection name="Address Mirroring">Disable</emrMirrorSelection>}
   puts $mig_prj_file {    <emrCSSelection name="Controller Chip Select Pin">Disable</emrCSSelection>}
   puts $mig_prj_file {    <emrRTT name="RTT (nominal) - On Die Termination (ODT)">RZQ/4</emrRTT>}
   puts $mig_prj_file {    <emrPosted name="Additive Latency (AL)">0</emrPosted>}
   puts $mig_prj_file {    <emrOCD name="Write Leveling Enable">Disabled</emrOCD>}
   puts $mig_prj_file {    <emrDQS name="TDQS enable">Enabled</emrDQS>}
   puts $mig_prj_file {    <emrRDQS name="Qoff">Output Buffer Enabled</emrRDQS>}
   puts $mig_prj_file {    <mr2PartialArraySelfRefresh name="Partial-Array Self Refresh">Full Array</mr2PartialArraySelfRefresh>}
   puts $mig_prj_file {    <mr2CasWriteLatency name="CAS write latency">5</mr2CasWriteLatency>}
   puts $mig_prj_file {    <mr2AutoSelfRefresh name="Auto Self Refresh">Enabled</mr2AutoSelfRefresh>}
   puts $mig_prj_file {    <mr2SelfRefreshTempRange name="High Temparature Self Refresh Rate">Normal</mr2SelfRefreshTempRange>}
   puts $mig_prj_file {    <mr2RTTWR name="RTT_WR - Dynamic On Die Termination (ODT)">Dynamic ODT off</mr2RTTWR>}
   puts $mig_prj_file {    <PortInterface>AXI</PortInterface>}
   puts $mig_prj_file {    <AXIParameters>}
   puts $mig_prj_file {      <C0_C_RD_WR_ARB_ALGORITHM>RD_PRI_REG</C0_C_RD_WR_ARB_ALGORITHM>}
   puts $mig_prj_file {      <C0_S_AXI_ADDR_WIDTH>27</C0_S_AXI_ADDR_WIDTH>}
   puts $mig_prj_file {      <C0_S_AXI_DATA_WIDTH>64</C0_S_AXI_DATA_WIDTH>}
   puts $mig_prj_file {      <C0_S_AXI_ID_WIDTH>4</C0_S_AXI_ID_WIDTH>}
   puts $mig_prj_file {      <C0_S_AXI_SUPPORTS_NARROW_BURST>0</C0_S_AXI_SUPPORTS_NARROW_BURST>}
   puts $mig_prj_file {    </AXIParameters>}
   puts $mig_prj_file {  </Controller>}
   puts $mig_prj_file {</Project>}

   close $mig_prj_file
}
# End of write_mig_file_design_1_mig_7series_0_0()



##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: slice_0
proc create_hier_cell_slice_0 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_slice_0() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir O -from 0 -to 0 Dout
  create_bd_pin -dir O -from 0 -to 0 Dout1
  create_bd_pin -dir O -from 0 -to 0 Dout2
  create_bd_pin -dir O -from 0 -to 0 Dout3
  create_bd_pin -dir O -from 0 -to 0 Dout4
  create_bd_pin -dir I -from 4 -to 0 Din

  # Create instance: ilslice_3, and set properties
  set ilslice_3 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_3 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {3} \
    CONFIG.DIN_TO {3} \
    CONFIG.DIN_WIDTH {5} \
  ] $ilslice_3


  # Create instance: ilslice_0, and set properties
  set ilslice_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_0 ]
  set_property CONFIG.DIN_WIDTH {5} $ilslice_0


  # Create instance: ilslice_1, and set properties
  set ilslice_1 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_1 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {1} \
    CONFIG.DIN_TO {1} \
    CONFIG.DIN_WIDTH {5} \
  ] $ilslice_1


  # Create instance: ilslice_2, and set properties
  set ilslice_2 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_2 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {2} \
    CONFIG.DIN_TO {2} \
    CONFIG.DIN_WIDTH {5} \
  ] $ilslice_2


  # Create instance: ilslice_4, and set properties
  set ilslice_4 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_4 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {4} \
    CONFIG.DIN_TO {4} \
    CONFIG.DIN_WIDTH {5} \
  ] $ilslice_4


  # Create port connections
  connect_bd_net -net Din_1  [get_bd_pins Din] \
  [get_bd_pins ilslice_0/Din] \
  [get_bd_pins ilslice_1/Din] \
  [get_bd_pins ilslice_2/Din] \
  [get_bd_pins ilslice_3/Din] \
  [get_bd_pins ilslice_4/Din]
  connect_bd_net -net ilslice_0_Dout  [get_bd_pins ilslice_0/Dout] \
  [get_bd_pins Dout]
  connect_bd_net -net ilslice_1_Dout  [get_bd_pins ilslice_1/Dout] \
  [get_bd_pins Dout1]
  connect_bd_net -net ilslice_2_Dout  [get_bd_pins ilslice_2/Dout] \
  [get_bd_pins Dout2]
  connect_bd_net -net ilslice_3_Dout  [get_bd_pins ilslice_3/Dout] \
  [get_bd_pins Dout3]
  connect_bd_net -net ilslice_4_Dout  [get_bd_pins ilslice_4/Dout] \
  [get_bd_pins Dout4]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: Pong_base_0
proc create_hier_cell_Pong_base_0 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_Pong_base_0() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:hdmi_rtl:2.0 hdmi_tx_0_0

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:hdmi_rtl:2.0 hdmi_tx_0_1


  # Create pins
  create_bd_pin -dir I -type clk clk_100MHz_0
  create_bd_pin -dir I -type rst clk_rst_0
  create_bd_pin -dir O -from 3 -to 0 D0_an_0_0
  create_bd_pin -dir O -from 3 -to 0 D1_an_0_0
  create_bd_pin -dir O -from 6 -to 0 o_sev_seg_P1_0_0
  create_bd_pin -dir O -from 6 -to 0 o_sev_seg_P2_0_0
  create_bd_pin -dir I -type rst rst_0_1
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type rst s_axi_aresetn

  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0 ]
  set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_GPIO_WIDTH {5} \
  ] $axi_gpio_0


  # Create instance: P1_BD_S2026_0, and set properties
  set P1_BD_S2026_0 [ create_bd_cell -type ip -vlnv user.org:user:P1_BD_S2026:1.0 P1_BD_S2026_0 ]

  # Create instance: slice_0
  create_hier_cell_slice_0 $hier_obj slice_0

  # Create instance: util_vector_logic_0, and set properties
  set util_vector_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_0 ]
  set_property -dict [list \
    CONFIG.C_OPERATION {not} \
    CONFIG.C_SIZE {1} \
  ] $util_vector_logic_0


  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins P1_BD_S2026_0/hdmi_tx_0] [get_bd_intf_pins hdmi_tx_0_1]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins axi_gpio_0/S_AXI] [get_bd_intf_pins S_AXI]

  # Create port connections
  connect_bd_net -net P1_BD_S2026_0_D0_an_0  [get_bd_pins P1_BD_S2026_0/D0_an_0] \
  [get_bd_pins D0_an_0_0]
  connect_bd_net -net P1_BD_S2026_0_D1_an_0  [get_bd_pins P1_BD_S2026_0/D1_an_0] \
  [get_bd_pins D1_an_0_0]
  connect_bd_net -net P1_BD_S2026_0_o_sev_seg_P1_0  [get_bd_pins P1_BD_S2026_0/o_sev_seg_P1_0] \
  [get_bd_pins o_sev_seg_P1_0_0]
  connect_bd_net -net P1_BD_S2026_0_o_sev_seg_P2_0  [get_bd_pins P1_BD_S2026_0/o_sev_seg_P2_0] \
  [get_bd_pins o_sev_seg_P2_0_0]
  connect_bd_net -net axi_gpio_0_gpio_io_o  [get_bd_pins axi_gpio_0/gpio_io_o] \
  [get_bd_pins slice_0/Din]
  connect_bd_net -net clk_100MHz_0_1  [get_bd_pins clk_100MHz_0] \
  [get_bd_pins P1_BD_S2026_0/clk_100MHz]
  connect_bd_net -net clk_rst_0_1  [get_bd_pins clk_rst_0] \
  [get_bd_pins util_vector_logic_0/Op1]
  connect_bd_net -net rst_0_1_1  [get_bd_pins rst_0_1] \
  [get_bd_pins P1_BD_S2026_0/rst_0]
  connect_bd_net -net s_axi_aclk_1  [get_bd_pins s_axi_aclk] \
  [get_bd_pins axi_gpio_0/s_axi_aclk]
  connect_bd_net -net s_axi_aresetn_1  [get_bd_pins s_axi_aresetn] \
  [get_bd_pins axi_gpio_0/s_axi_aresetn]
  connect_bd_net -net slice_0_Dout  [get_bd_pins slice_0/Dout] \
  [get_bd_pins P1_BD_S2026_0/i_Switch_0]
  connect_bd_net -net slice_0_Dout1  [get_bd_pins slice_0/Dout1] \
  [get_bd_pins P1_BD_S2026_0/i_Switch_1]
  connect_bd_net -net slice_0_Dout2  [get_bd_pins slice_0/Dout2] \
  [get_bd_pins P1_BD_S2026_0/i_Switch_2]
  connect_bd_net -net slice_0_Dout3  [get_bd_pins slice_0/Dout3] \
  [get_bd_pins P1_BD_S2026_0/i_Switch_3]
  connect_bd_net -net slice_0_Dout4  [get_bd_pins slice_0/Dout4] \
  [get_bd_pins P1_BD_S2026_0/i_Switch_4]
  connect_bd_net -net util_vector_logic_0_Res  [get_bd_pins util_vector_logic_0/Res] \
  [get_bd_pins P1_BD_S2026_0/clk_rst]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set ddr3 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 ddr3 ]

  set hdmi_tx_0_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:hdmi_rtl:2.0 hdmi_tx_0_0 ]


  # Create ports
  set resetn_0 [ create_bd_port -dir I resetn_0 ]
  set clk_100MHz [ create_bd_port -dir I clk_100MHz ]
  set gpio_i_0 [ create_bd_port -dir I -from 6 -to 0 gpio_i_0 ]
  set uart0_rxd_i_0 [ create_bd_port -dir I uart0_rxd_i_0 ]
  set uart0_txd_o_0 [ create_bd_port -dir O uart0_txd_o_0 ]
  set gpio_o_0 [ create_bd_port -dir O -from 7 -to 0 gpio_o_0 ]
  set init_calib_complete_0 [ create_bd_port -dir O init_calib_complete_0 ]
  set rst_0_0 [ create_bd_port -dir I -type rst rst_0_0 ]
  set D0_an_0_0 [ create_bd_port -dir O -from 3 -to 0 D0_an_0_0 ]
  set D1_an_0_0 [ create_bd_port -dir O -from 3 -to 0 D1_an_0_0 ]
  set o_sev_seg_P1_0_0 [ create_bd_port -dir O -from 6 -to 0 o_sev_seg_P1_0_0 ]
  set o_sev_seg_P2_0_0 [ create_bd_port -dir O -from 6 -to 0 o_sev_seg_P2_0_0 ]

  # Create instance: neorv32_vivado_ip_0, and set properties
  set neorv32_vivado_ip_0 [ create_bd_cell -type ip -vlnv NEORV32:user:neorv32_vivado_ip:1.0 neorv32_vivado_ip_0 ]
  set_property -dict [list \
    CONFIG.BOOT_MODE_SELECT {2} \
    CONFIG.CACHE_BURSTS_EN {false} \
    CONFIG.DCACHE_EN {true} \
    CONFIG.DCACHE_NUM_BLOCKS {64} \
    CONFIG.DMEM_EN {true} \
    CONFIG.DUAL_CORE_EN {true} \
    CONFIG.ICACHE_EN {true} \
    CONFIG.ICACHE_NUM_BLOCKS {256} \
    CONFIG.IMEM_EN {true} \
    CONFIG.IMEM_SIZE {32768} \
    CONFIG.IO_CFS_EN {false} \
    CONFIG.IO_CLINT_EN {true} \
    CONFIG.IO_DMA_EN {false} \
    CONFIG.IO_GPIO_DIR_EN {false} \
    CONFIG.IO_GPIO_EN {true} \
    CONFIG.IO_GPIO_IN_NUM {8} \
    CONFIG.IO_GPIO_OUT_NUM {8} \
    CONFIG.IO_GPTMR_EN {true} \
    CONFIG.IO_NEOLED_EN {false} \
    CONFIG.IO_SPI_EN {false} \
    CONFIG.IO_TRNG_EN {true} \
    CONFIG.IO_UART0_EN {true} \
    CONFIG.IO_UART0_RX_FIFO {1024} \
    CONFIG.IO_UART0_TX_FIFO {256} \
    CONFIG.IO_WDT_EN {true} \
    CONFIG.OCD_EN {false} \
    CONFIG.RISCV_ISA_C {false} \
    CONFIG.RISCV_ISA_Zaamo {true} \
    CONFIG.RISCV_ISA_Zbkb {true} \
    CONFIG.RISCV_ISA_Zbkx {true} \
    CONFIG.RISCV_ISA_Zknd {true} \
    CONFIG.RISCV_ISA_Zkne {true} \
    CONFIG.XBUS_EN {true} \
  ] $neorv32_vivado_ip_0


  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0 ]
  set_property -dict [list \
    CONFIG.CLKOUT1_JITTER {130.958} \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {100.000} \
    CONFIG.CLKOUT2_JITTER {114.829} \
    CONFIG.CLKOUT2_PHASE_ERROR {98.575} \
    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {200.000} \
    CONFIG.CLKOUT2_USED {true} \
    CONFIG.CLKOUT3_JITTER {104.542} \
    CONFIG.CLKOUT3_PHASE_ERROR {98.575} \
    CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {333.33333} \
    CONFIG.CLKOUT3_USED {true} \
    CONFIG.CLKOUT4_JITTER {175.402} \
    CONFIG.CLKOUT4_PHASE_ERROR {98.575} \
    CONFIG.CLKOUT4_REQUESTED_OUT_FREQ {100.000} \
    CONFIG.CLKOUT4_USED {false} \
    CONFIG.CLKOUT5_JITTER {125.247} \
    CONFIG.CLKOUT5_PHASE_ERROR {98.575} \
    CONFIG.CLKOUT5_REQUESTED_OUT_FREQ {100.000} \
    CONFIG.CLKOUT5_USED {false} \
    CONFIG.CLK_OUT1_PORT {clk_100} \
    CONFIG.CLK_OUT2_PORT {clk_200} \
    CONFIG.CLK_OUT3_PORT {clk_333} \
    CONFIG.CLK_OUT4_PORT {clk_out4} \
    CONFIG.CLK_OUT5_PORT {clk_out5} \
    CONFIG.MMCM_CLKOUT0_DIVIDE_F {10.000} \
    CONFIG.MMCM_CLKOUT1_DIVIDE {5} \
    CONFIG.MMCM_CLKOUT2_DIVIDE {3} \
    CONFIG.MMCM_CLKOUT3_DIVIDE {1} \
    CONFIG.MMCM_CLKOUT4_DIVIDE {1} \
    CONFIG.NUM_OUT_CLKS {3} \
    CONFIG.RESET_PORT {resetn} \
    CONFIG.RESET_TYPE {ACTIVE_LOW} \
  ] $clk_wiz_0


  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0 ]
  set_property -dict [list \
    CONFIG.NUM_CLKS {2} \
    CONFIG.NUM_MI {2} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_0


  # Create instance: mig_7series_0, and set properties
  set mig_7series_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mig_7series:4.2 mig_7series_0 ]

  # Generate the PRJ File for MIG
  set str_mig_folder [get_property IP_DIR [ get_ips [ get_property CONFIG.Component_Name $mig_7series_0 ] ] ]
  set str_mig_file_name mig_a.prj
  set str_mig_file_path ${str_mig_folder}/${str_mig_file_name}
  write_mig_file_design_1_mig_7series_0_0 $str_mig_file_path

  set_property -dict [list \
    CONFIG.BOARD_MIG_PARAM {Custom} \
    CONFIG.MIG_DONT_TOUCH_PARAM {Custom} \
    CONFIG.RESET_BOARD_INTERFACE {Custom} \
    CONFIG.XML_INPUT_FILE {mig_a.prj} \
  ] $mig_7series_0


  # Create instance: proc_sys_reset_1, and set properties
  set proc_sys_reset_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_1 ]

  # Create instance: ilvector_logic_0, and set properties
  set ilvector_logic_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilvector_logic:1.0 ilvector_logic_0 ]
  set_property -dict [list \
    CONFIG.C_OPERATION {not} \
    CONFIG.C_SIZE {1} \
  ] $ilvector_logic_0


  # Create instance: ilconcat_0, and set properties
  set ilconcat_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat:1.0 ilconcat_0 ]
  set_property -dict [list \
    CONFIG.IN0_WIDTH {7} \
    CONFIG.IN1_WIDTH {1} \
  ] $ilconcat_0


  # Create instance: Pong_base_0
  create_hier_cell_Pong_base_0 [current_bd_instance .] Pong_base_0

  # Create interface connections
  connect_bd_intf_net -intf_net Pong_base_0_hdmi_tx_0_1 [get_bd_intf_ports hdmi_tx_0_0] [get_bd_intf_pins Pong_base_0/hdmi_tx_0_1]
  connect_bd_intf_net -intf_net mig_7series_0_DDR3 [get_bd_intf_ports ddr3] [get_bd_intf_pins mig_7series_0/DDR3]
  connect_bd_intf_net -intf_net neorv32_vivado_ip_0_m_axi [get_bd_intf_pins neorv32_vivado_ip_0/m_axi] [get_bd_intf_pins smartconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins mig_7series_0/S_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins smartconnect_0/M01_AXI] [get_bd_intf_pins Pong_base_0/S_AXI]

  # Create port connections
  connect_bd_net -net Pong_base_0_D0_an_0_0  [get_bd_pins Pong_base_0/D0_an_0_0] \
  [get_bd_ports D0_an_0_0]
  connect_bd_net -net Pong_base_0_D1_an_0_0  [get_bd_pins Pong_base_0/D1_an_0_0] \
  [get_bd_ports D1_an_0_0]
  connect_bd_net -net Pong_base_0_o_sev_seg_P1_0_0  [get_bd_pins Pong_base_0/o_sev_seg_P1_0_0] \
  [get_bd_ports o_sev_seg_P1_0_0]
  connect_bd_net -net Pong_base_0_o_sev_seg_P2_0_0  [get_bd_pins Pong_base_0/o_sev_seg_P2_0_0] \
  [get_bd_ports o_sev_seg_P2_0_0]
  connect_bd_net -net clk_in1_0_1  [get_bd_ports clk_100MHz] \
  [get_bd_pins clk_wiz_0/clk_in1]
  connect_bd_net -net clk_wiz_0_clk_200  [get_bd_pins clk_wiz_0/clk_200] \
  [get_bd_pins mig_7series_0/clk_ref_i]
  connect_bd_net -net clk_wiz_0_clk_333  [get_bd_pins clk_wiz_0/clk_333] \
  [get_bd_pins mig_7series_0/sys_clk_i]
  connect_bd_net -net clk_wiz_0_clk_out1  [get_bd_pins clk_wiz_0/clk_100] \
  [get_bd_pins smartconnect_0/aclk] \
  [get_bd_pins proc_sys_reset_0/slowest_sync_clk] \
  [get_bd_pins Pong_base_0/clk_100MHz_0] \
  [get_bd_pins Pong_base_0/s_axi_aclk] \
  [get_bd_pins neorv32_vivado_ip_0/clk]
  connect_bd_net -net clk_wiz_0_locked  [get_bd_pins clk_wiz_0/locked] \
  [get_bd_pins proc_sys_reset_0/dcm_locked] \
  [get_bd_pins ilvector_logic_0/Op1]
  connect_bd_net -net gpio_i_0_1  [get_bd_ports gpio_i_0] \
  [get_bd_pins ilconcat_0/In0]
  connect_bd_net -net ilconcat_0_dout  [get_bd_pins ilconcat_0/dout] \
  [get_bd_pins neorv32_vivado_ip_0/gpio_i]
  connect_bd_net -net ilvector_logic_0_Res  [get_bd_pins ilvector_logic_0/Res] \
  [get_bd_pins mig_7series_0/sys_rst]
  connect_bd_net -net mig_7series_0_init_calib_complete  [get_bd_pins mig_7series_0/init_calib_complete] \
  [get_bd_ports init_calib_complete_0] \
  [get_bd_pins ilconcat_0/In1]
  connect_bd_net -net mig_7series_0_mmcm_locked  [get_bd_pins mig_7series_0/mmcm_locked] \
  [get_bd_pins proc_sys_reset_1/dcm_locked]
  connect_bd_net -net mig_7series_0_ui_clk  [get_bd_pins mig_7series_0/ui_clk] \
  [get_bd_pins proc_sys_reset_1/slowest_sync_clk] \
  [get_bd_pins smartconnect_0/aclk1]
  connect_bd_net -net mig_7series_0_ui_clk_sync_rst  [get_bd_pins mig_7series_0/ui_clk_sync_rst] \
  [get_bd_pins proc_sys_reset_1/ext_reset_in]
  connect_bd_net -net neorv32_vivado_ip_0_gpio_o  [get_bd_pins neorv32_vivado_ip_0/gpio_o] \
  [get_bd_ports gpio_o_0]
  connect_bd_net -net neorv32_vivado_ip_0_uart0_txd_o  [get_bd_pins neorv32_vivado_ip_0/uart0_txd_o] \
  [get_bd_ports uart0_txd_o_0]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn  [get_bd_pins proc_sys_reset_0/peripheral_aresetn] \
  [get_bd_pins smartconnect_0/aresetn] \
  [get_bd_pins Pong_base_0/s_axi_aresetn] \
  [get_bd_pins neorv32_vivado_ip_0/resetn]
  connect_bd_net -net proc_sys_reset_1_peripheral_aresetn  [get_bd_pins proc_sys_reset_1/peripheral_aresetn] \
  [get_bd_pins mig_7series_0/aresetn]
  connect_bd_net -net resetn_0_1  [get_bd_ports resetn_0] \
  [get_bd_pins proc_sys_reset_0/ext_reset_in] \
  [get_bd_pins clk_wiz_0/resetn] \
  [get_bd_pins Pong_base_0/clk_rst_0]
  connect_bd_net -net rst_0_1_0_1  [get_bd_ports rst_0_0] \
  [get_bd_pins Pong_base_0/rst_0_1]
  connect_bd_net -net uart0_rxd_i_0_1  [get_bd_ports uart0_rxd_i_0] \
  [get_bd_pins neorv32_vivado_ip_0/uart0_rxd_i]

  # Create address segments
  assign_bd_address -offset 0x40000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces neorv32_vivado_ip_0/m_axi] [get_bd_addr_segs Pong_base_0/axi_gpio_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x88000000 -range 0x08000000 -target_address_space [get_bd_addr_spaces neorv32_vivado_ip_0/m_axi] [get_bd_addr_segs mig_7series_0/memmap/memaddr] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


