
################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2014.3
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl

# If you do not already have a project created,
# you can create a project using the following command:
#    create_project project_1 myproj -part xc7z020clg484-1
#    set_property BOARD_PART xilinx.com:zc702:part0:1.1 [current_project]


# CHANGE DESIGN NAME HERE
set design_name design_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}


# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "ERROR: Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      puts "INFO: Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   puts "INFO: Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   puts "INFO: Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   puts "INFO: Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

puts "INFO: Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   puts $errMsg
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]
  set input_ram [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:bram_rtl:1.0 input_ram ]
  set_property -dict [ list CONFIG.MASTER_TYPE {BRAM_CTRL}  ] $input_ram
  set leds_4bits [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 leds_4bits ]
  set inst_ram [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:bram_rtl:1.0 inst_ram ]
  set_property -dict [ list CONFIG.MASTER_TYPE {BRAM_CTRL}  ] $inst_ram
  set weight_ram [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:bram_rtl:1.0 weight_ram ]
  set_property -dict [ list CONFIG.MASTER_TYPE {BRAM_CTRL}  ] $weight_ram

  # Create ports
  set nnclk [ create_bd_port -dir O -type clk nnclk ]
  set nnend [ create_bd_port -dir I nnend ]
  set nnreset_n [ create_bd_port -dir O -type rst nnreset_n ]
  set nnstart [ create_bd_port -dir O nnstart ]
  set num_of_input [ create_bd_port -dir O -from 31 -to 0 num_of_input ]
  set num_of_output [ create_bd_port -dir O -from 31 -to 0 num_of_output ]

  # Create instance: axi_bram_ctrl_0, and set properties
  set axi_bram_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 axi_bram_ctrl_0 ]

  # Create instance: axi_bram_ctrl_0_bram, and set properties
  set axi_bram_ctrl_0_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.2 axi_bram_ctrl_0_bram ]
  set_property -dict [ list CONFIG.Memory_Type {True_Dual_Port_RAM}  ] $axi_bram_ctrl_0_bram

  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0 ]
  set_property -dict [ list CONFIG.GPIO_BOARD_INTERFACE {leds_4bits} CONFIG.USE_BOARD_FLOW {true}  ] $axi_gpio_0

  # Create instance: blk_mem_gen_0, and set properties
  set blk_mem_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.2 blk_mem_gen_0 ]
  set_property -dict [ list CONFIG.Enable_B {Use_ENB_Pin} CONFIG.Memory_Type {True_Dual_Port_RAM} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Enable_Rate {100} CONFIG.Port_B_Write_Rate {50} CONFIG.Use_RSTB_Pin {true}  ] $blk_mem_gen_0

  # Create instance: clk_wiz, and set properties
  set clk_wiz [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:5.1 clk_wiz ]
  set_property -dict [ list CONFIG.CLKOUT1_JITTER {349.768} CONFIG.CLKOUT1_PHASE_ERROR {246.739} CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {25} CONFIG.USE_RESET {false}  ] $clk_wiz

  # Create instance: input_ram, and set properties
  set input_ram [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 input_ram ]
  set_property -dict [ list CONFIG.SINGLE_PORT_BRAM {1}  ] $input_ram

  # Create instance: nnend, and set properties
  set nnend [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 nnend ]
  set_property -dict [ list CONFIG.C_ALL_INPUTS {1} CONFIG.C_GPIO_WIDTH {1}  ] $nnend

  # Create instance: nnstart, and set properties
  set nnstart [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 nnstart ]
  set_property -dict [ list CONFIG.C_ALL_OUTPUTS {1} CONFIG.C_GPIO_WIDTH {1}  ] $nnstart

  # Create instance: num_of_input, and set properties
  set num_of_input [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 num_of_input ]
  set_property -dict [ list CONFIG.C_ALL_OUTPUTS {1} CONFIG.C_GPIO_WIDTH {32}  ] $num_of_input

  # Create instance: num_of_output, and set properties
  set num_of_output [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 num_of_output ]
  set_property -dict [ list CONFIG.C_ALL_OUTPUTS {1} CONFIG.C_GPIO_WIDTH {32}  ] $num_of_output

  # Create instance: inst_ram, and set properties
  set inst_ram [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 inst_ram ]
  set_property -dict [ list CONFIG.SINGLE_PORT_BRAM {1}  ] $inst_ram

  # Create instance: inst_ram_bram, and set properties
  set inst_ram_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.2 inst_ram_bram ]
  set_property -dict [ list CONFIG.Enable_B {Use_ENB_Pin} CONFIG.Memory_Type {True_Dual_Port_RAM} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Enable_Rate {100} CONFIG.Port_B_Write_Rate {50} CONFIG.Use_RSTB_Pin {true}  ] $inst_ram_bram

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
  set_property -dict [ list CONFIG.preset {ZC702*}  ] $processing_system7_0

  # Create instance: processing_system7_0_axi_periph, and set properties
  set processing_system7_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 processing_system7_0_axi_periph ]
  set_property -dict [ list CONFIG.NUM_MI {9}  ] $processing_system7_0_axi_periph

  # Create instance: rst_clk_wiz_100M, and set properties
  set rst_clk_wiz_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_clk_wiz_100M ]

  # Create instance: rst_processing_system7_0_50M, and set properties
  set rst_processing_system7_0_50M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_processing_system7_0_50M ]

  # Create instance: weight_ram, and set properties
  set weight_ram [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 weight_ram ]
  set_property -dict [ list CONFIG.SINGLE_PORT_BRAM {1}  ] $weight_ram

  # Create instance: weight_ram_bram, and set properties
  set weight_ram_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.2 weight_ram_bram ]
  set_property -dict [ list CONFIG.Enable_B {Use_ENB_Pin} CONFIG.Memory_Type {True_Dual_Port_RAM} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Enable_Rate {100} CONFIG.Port_B_Write_Rate {50} CONFIG.Use_RSTB_Pin {true}  ] $weight_ram_bram

  # Create interface connections
  connect_bd_intf_net -intf_net BRAM_PORTB_1 [get_bd_intf_ports input_ram] [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTB]
  connect_bd_intf_net -intf_net BRAM_PORTB_2 [get_bd_intf_ports weight_ram] [get_bd_intf_pins weight_ram_bram/BRAM_PORTB]
  connect_bd_intf_net -intf_net BRAM_PORTB_3 [get_bd_intf_ports inst_ram] [get_bd_intf_pins inst_ram_bram/BRAM_PORTB]
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins axi_bram_ctrl_0_bram/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTB [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTB] [get_bd_intf_pins axi_bram_ctrl_0_bram/BRAM_PORTB]
  connect_bd_intf_net -intf_net axi_gpio_0_GPIO [get_bd_intf_ports leds_4bits] [get_bd_intf_pins axi_gpio_0/GPIO]
  connect_bd_intf_net -intf_net input_ram_BRAM_PORTA [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTA] [get_bd_intf_pins input_ram/BRAM_PORTA]
  connect_bd_intf_net -intf_net inst_ram_BRAM_PORTA [get_bd_intf_pins inst_ram/BRAM_PORTA] [get_bd_intf_pins inst_ram_bram/BRAM_PORTA]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins processing_system7_0/M_AXI_GP0] [get_bd_intf_pins processing_system7_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M00_AXI [get_bd_intf_pins axi_gpio_0/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M01_AXI [get_bd_intf_pins axi_bram_ctrl_0/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M02_AXI [get_bd_intf_pins nnend/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M02_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M03_AXI [get_bd_intf_pins num_of_input/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M03_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M04_AXI [get_bd_intf_pins num_of_output/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M04_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M05_AXI [get_bd_intf_pins nnstart/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M05_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M06_AXI [get_bd_intf_pins input_ram/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M06_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M07_AXI [get_bd_intf_pins processing_system7_0_axi_periph/M07_AXI] [get_bd_intf_pins weight_ram/S_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M08_AXI [get_bd_intf_pins inst_ram/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M08_AXI]
  connect_bd_intf_net -intf_net weight_ram_BRAM_PORTA [get_bd_intf_pins weight_ram/BRAM_PORTA] [get_bd_intf_pins weight_ram_bram/BRAM_PORTA]

  # Create port connections
  connect_bd_net -net clk_wiz_locked [get_bd_pins clk_wiz/locked] [get_bd_pins rst_clk_wiz_100M/dcm_locked]
  connect_bd_net -net gpio_io_i_1 [get_bd_ports nnend] [get_bd_pins nnend/gpio_io_i]
  connect_bd_net -net nnclk [get_bd_ports nnclk] [get_bd_pins clk_wiz/clk_out1] [get_bd_pins nnend/s_axi_aclk] [get_bd_pins nnstart/s_axi_aclk] [get_bd_pins num_of_input/s_axi_aclk] [get_bd_pins num_of_output/s_axi_aclk] [get_bd_pins processing_system7_0_axi_periph/M02_ACLK] [get_bd_pins processing_system7_0_axi_periph/M03_ACLK] [get_bd_pins processing_system7_0_axi_periph/M04_ACLK] [get_bd_pins processing_system7_0_axi_periph/M05_ACLK] [get_bd_pins rst_clk_wiz_100M/slowest_sync_clk]
  connect_bd_net -net nnstart [get_bd_ports nnstart] [get_bd_pins nnstart/gpio_io_o]
  connect_bd_net -net num_of_input_gpio_io_o [get_bd_ports num_of_input] [get_bd_pins num_of_input/gpio_io_o]
  connect_bd_net -net num_of_output_gpio_io_o [get_bd_ports num_of_output] [get_bd_pins num_of_output/gpio_io_o]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] [get_bd_pins axi_gpio_0/s_axi_aclk] [get_bd_pins clk_wiz/clk_in1] [get_bd_pins input_ram/s_axi_aclk] [get_bd_pins inst_ram/s_axi_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0_axi_periph/ACLK] [get_bd_pins processing_system7_0_axi_periph/M00_ACLK] [get_bd_pins processing_system7_0_axi_periph/M01_ACLK] [get_bd_pins processing_system7_0_axi_periph/M06_ACLK] [get_bd_pins processing_system7_0_axi_periph/M07_ACLK] [get_bd_pins processing_system7_0_axi_periph/M08_ACLK] [get_bd_pins processing_system7_0_axi_periph/S00_ACLK] [get_bd_pins rst_processing_system7_0_50M/slowest_sync_clk] [get_bd_pins weight_ram/s_axi_aclk]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rst_clk_wiz_100M/ext_reset_in] [get_bd_pins rst_processing_system7_0_50M/ext_reset_in]
  connect_bd_net -net rst_clk_wiz_100M_peripheral_aresetn [get_bd_ports nnreset_n] [get_bd_pins nnend/s_axi_aresetn] [get_bd_pins nnstart/s_axi_aresetn] [get_bd_pins num_of_input/s_axi_aresetn] [get_bd_pins num_of_output/s_axi_aresetn] [get_bd_pins processing_system7_0_axi_periph/M02_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M03_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M04_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M05_ARESETN] [get_bd_pins rst_clk_wiz_100M/peripheral_aresetn]
  connect_bd_net -net rst_processing_system7_0_50M_interconnect_aresetn [get_bd_pins processing_system7_0_axi_periph/ARESETN] [get_bd_pins rst_processing_system7_0_50M/interconnect_aresetn]
  connect_bd_net -net rst_processing_system7_0_50M_peripheral_aresetn [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn] [get_bd_pins axi_gpio_0/s_axi_aresetn] [get_bd_pins input_ram/s_axi_aresetn] [get_bd_pins inst_ram/s_axi_aresetn] [get_bd_pins processing_system7_0_axi_periph/M00_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M01_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M06_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M07_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M08_ARESETN] [get_bd_pins processing_system7_0_axi_periph/S00_ARESETN] [get_bd_pins rst_processing_system7_0_50M/peripheral_aresetn] [get_bd_pins weight_ram/s_axi_aresetn]

  # Create address segments
  create_bd_addr_seg -range 0x10000 -offset 0x40000000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem0
  create_bd_addr_seg -range 0x10000 -offset 0x41200000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] SEG_axi_gpio_0_Reg
  create_bd_addr_seg -range 0x2000 -offset 0x40010000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs input_ram/S_AXI/Mem0] SEG_input_ram_Mem0
  create_bd_addr_seg -range 0x10000 -offset 0x41210000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs nnend/S_AXI/Reg] SEG_nnend_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41240000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs nnstart/S_AXI/Reg] SEG_nnstart_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41220000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs num_of_input/S_AXI/Reg] SEG_num_of_input_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41230000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs num_of_output/S_AXI/Reg] SEG_num_of_output_Reg
  create_bd_addr_seg -range 0x2000 -offset 0x40012000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs inst_ram/S_AXI/Mem0] SEG_inst_ram_Mem0
  create_bd_addr_seg -range 0x8000 -offset 0x40020000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs weight_ram/S_AXI/Mem0] SEG_weight_ram_Mem0
  

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


