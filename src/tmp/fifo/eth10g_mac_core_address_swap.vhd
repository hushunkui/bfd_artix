------------------------------------------------------------------------
-- Title      : Address swap block
-- Project    : 10 Gigabit Ethernet MAC Core
------------------------------------------------------------------------
-- File       : eth10g_mac_core_address_swap.vhd  
-- Author     : Xilinx Inc.
------------------------------------------------------------------------
-- Description: This is the address swap block for the Ten Gig Mac core.
--              It swaps the Destination and source address for the 
--              frames that pass through.           
------------------------------------------------------------------------
-- (c) Copyright 2001-2012 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;                                                                                                  
use work.XGMAC_FIFO_PACK.all;

------------------------------------------------------------------------
-- The entity declaration for the client side loopback design example.
------------------------------------------------------------------------

entity eth10g_mac_core_address_swap is
   port (
      --Local Link signals
      rx_clk         : in  std_logic;
      reset          : in  std_logic;
      rx_axis_tdata        : in  std_logic_vector(63 downto 0);
      rx_axis_tkeep         : in  std_logic_vector(7 downto 0);
      rx_axis_tlast       : in  std_logic;
      rx_axis_tvalid   : in  std_logic;
      rx_axis_tready   : out std_logic;

      tx_axis_tdata        : out std_logic_vector(63 downto 0);
      tx_axis_tkeep         : out std_logic_vector(7 downto 0);
      tx_axis_tlast       : out std_logic;
      tx_axis_tvalid   : out std_logic;
      tx_axis_tready   : in  std_logic   


      );
end eth10g_mac_core_address_swap;


architecture rtl of eth10g_mac_core_address_swap is   


  -- create a synchronous reset in the receiver clock domain
  signal rx_reset                     : std_logic;
  signal rx_reset2                     : std_logic;
  signal rx_reset3                     : std_logic;
  signal rx_reset4                     : std_logic;
  signal rx_reset5                     : std_logic;

  -- two state fifo state machine
  signal data_stored_n                : std_logic;

  -- single register in Local Link data path
  signal rx_axis_tdata_out_reg              :  std_logic_vector(63 downto 0);
  signal rx_axis_tdata_out_reg_reg          :  std_logic_vector(31 downto 0);
  signal rx_axis_tkeep_reg                   :  std_logic_vector(7 downto 0);
  signal rx_sof_n_reg                 :  std_logic;
  signal rx_sof_n_reg_reg             :  std_logic;
  signal rx_axis_tlast_reg                 :  std_logic;
  signal rx_axis_tvalid_reg                 :  std_logic;
  
begin

  ----------------------------------------------------------------------
  -- Create synchronous reset signals for use in the Address swapping
  -- logic.  A synchronous reset signal is created in the rx_clk
  -- clock domain.
  ----------------------------------------------------------------------



  -- Create synchronous reset in the receiver clock domain.
  gen_rx_reset : process (rx_clk, reset)
  begin
    if reset = '1' then
      rx_reset5     <= '1';
      rx_reset4     <= '1';
      rx_reset3     <= '1';
      rx_reset2     <= '1';
      rx_reset      <= '1';
    elsif rx_clk'event and rx_clk = '1' then
      rx_reset5     <= '0';
      rx_reset4     <= rx_reset5;
      rx_reset3     <= rx_reset4;
      rx_reset2     <= rx_reset3;
      rx_reset      <= rx_reset2;
   end if;
  end process gen_rx_reset;

  ----------------------------------------------------------------------
  -- Buffer one and a half words to allow address swap
  ----------------------------------------------------------------------

  p_rx_reg : process (rx_clk, rx_reset)
  begin
    if rx_clk'event and rx_clk = '1' then
      if rx_reset = '1' then
        rx_axis_tdata_out_reg     <= (others => '0');
        rx_axis_tkeep_reg          <= (others => '0');
        rx_sof_n_reg        <= '1';
        rx_sof_n_reg_reg    <= '1';
        rx_axis_tlast_reg        <= '1';
        rx_axis_tdata_out_reg_reg <= (others => '0');
        data_stored_n       <= '0';
        rx_axis_tvalid_reg <= '0';
        else
          rx_axis_tvalid_reg <= rx_axis_tvalid;
          rx_axis_tlast_reg <= '0';
         if rx_axis_tvalid = '1' and tx_axis_tready = '1' then
        data_stored_n       <= '1';
        rx_axis_tdata_out_reg     <= rx_axis_tdata;
        rx_axis_tkeep_reg          <= rx_axis_tkeep;
        if( rx_axis_tvalid_reg = '0' and rx_axis_tvalid = '1') then
        rx_sof_n_reg        <= '1';
        else
          rx_sof_n_reg        <= '0';
          end if;
        rx_sof_n_reg_reg    <= rx_sof_n_reg;
        rx_axis_tlast_reg        <= rx_axis_tlast;
        rx_axis_tdata_out_reg_reg <= rx_axis_tdata_out_reg(47 downto 16);
      elsif rx_axis_tvalid = '0' and tx_axis_tready = '1' then
        data_stored_n       <= '0';
      end if;
    end if;
    end if;
  end process p_rx_reg;


  ----------------------------------------------------------------------
  -- Output to Tx
  ----------------------------------------------------------------------

  -- address swap following new SOF
  p_tx_data : process (rx_sof_n_reg, rx_axis_tdata_out_reg, rx_axis_tdata, rx_sof_n_reg_reg, rx_axis_tdata_out_reg_reg)
  begin
    if rx_sof_n_reg = '1' then
      tx_axis_tdata <= rx_axis_tdata_out_reg(15 downto 0) & rx_axis_tdata(31 downto 0) & rx_axis_tdata_out_reg(63 downto 48);
    elsif rx_sof_n_reg_reg = '1' then
      tx_axis_tdata <= rx_axis_tdata_out_reg(63 downto 32) & rx_axis_tdata_out_reg_reg;
    else
      tx_axis_tdata <= rx_axis_tdata_out_reg;
    end if;
  end process p_tx_data;

  tx_axis_tkeep       <= rx_axis_tkeep_reg;
  tx_axis_tvalid <= data_stored_n;
  --tx_axis_tlast     <= rx_eof_n_reg or data_stored_n;
  tx_axis_tlast     <= rx_axis_tlast_reg;
  rx_axis_tready <= tx_axis_tready;

end rtl;
