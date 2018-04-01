---------------------------------------------------------------------
-- Simple WISHBONE interconnect
--
-- Generated by wigen at Sun Jul 16 19:53:03 2017
--
-- Configuration:
--     Number of masters:     1
--     Number of slaves:      3
--     Master address width:  30
--     Slave address width:   8
--     Port size:             8
--     Port granularity:      8
--     Entity name:           wb_io
--     Pipelined arbiter:     no
--     Registered feedback:   no
--     Unsafe slave decoder:  no
--
-- Command line:
--     wigen -e wb_io 1 3 30 8 8 8
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity wb_io is
	port(
		clk_i: in std_logic;
		rst_i: in std_logic;

		s0_cyc_i: in std_logic;
		s0_stb_i: in std_logic;
		s0_we_i: in std_logic;
		s0_ack_o: out std_logic;
		s0_adr_i: in std_logic_vector(29 downto 0);
		s0_dat_i: in std_logic_vector(7 downto 0);
		s0_dat_o: out std_logic_vector(7 downto 0);

		m0_cyc_o: out std_logic;
		m0_stb_o: out std_logic;
		m0_we_o: out std_logic;
		m0_ack_i: in std_logic;
		m0_adr_o: out std_logic_vector(7 downto 0);
		m0_dat_o: out std_logic_vector(7 downto 0);
		m0_dat_i: in std_logic_vector(7 downto 0);

		m1_cyc_o: out std_logic;
		m1_stb_o: out std_logic;
		m1_we_o: out std_logic;
		m1_ack_i: in std_logic;
		m1_adr_o: out std_logic_vector(7 downto 0);
		m1_dat_o: out std_logic_vector(7 downto 0);
		m1_dat_i: in std_logic_vector(7 downto 0);

		m2_cyc_o: out std_logic;
		m2_stb_o: out std_logic;
		m2_we_o: out std_logic;
		m2_ack_i: in std_logic;
		m2_adr_o: out std_logic_vector(7 downto 0);
		m2_dat_o: out std_logic_vector(7 downto 0);
		m2_dat_i: in std_logic_vector(7 downto 0)
	);
end entity;

architecture rtl of wb_io is

signal select_slave: std_logic_vector(3 downto 0);

signal cyc_mux: std_logic;
signal stb_mux: std_logic;
signal we_mux: std_logic;
signal adr_mux: std_logic_vector(29 downto 0);
signal wdata_mux: std_logic_vector(7 downto 0);

signal ack_mux: std_logic;
signal rdata_mux: std_logic_vector(7 downto 0);

begin

-- MASTER->SLAVE MUX

cyc_mux<=s0_cyc_i;
stb_mux<=s0_stb_i;
we_mux<=s0_we_i;
adr_mux<=s0_adr_i;
wdata_mux<=s0_dat_i;

-- MASTER->SLAVE DEMUX

select_slave<="0001" when adr_mux(29 downto 8)="0000000000000000000000" else
	"0010" when adr_mux(29 downto 8)="0000000000000000000001" else
	"0100" when adr_mux(29 downto 8)="0000000000000000000010" else
	"1000"; -- fallback slave

m0_cyc_o<=cyc_mux and select_slave(0);
m0_stb_o<=stb_mux and select_slave(0);
m0_we_o<=we_mux;
m0_adr_o<=adr_mux(m0_adr_o'range);
m0_dat_o<=wdata_mux;

m1_cyc_o<=cyc_mux and select_slave(1);
m1_stb_o<=stb_mux and select_slave(1);
m1_we_o<=we_mux;
m1_adr_o<=adr_mux(m1_adr_o'range);
m1_dat_o<=wdata_mux;

m2_cyc_o<=cyc_mux and select_slave(2);
m2_stb_o<=stb_mux and select_slave(2);
m2_we_o<=we_mux;
m2_adr_o<=adr_mux(m2_adr_o'range);
m2_dat_o<=wdata_mux;

-- SLAVE->MASTER MUX

ack_mux<=(m0_ack_i and select_slave(0)) or
	(m1_ack_i and select_slave(1)) or
	(m2_ack_i and select_slave(2)) or
	(cyc_mux and stb_mux and select_slave(3)); -- fallback slave

rdata_mux_gen: for i in rdata_mux'range generate
	rdata_mux(i)<=(m0_dat_i(i) and select_slave(0)) or
		(m1_dat_i(i) and select_slave(1)) or
		(m2_dat_i(i) and select_slave(2));
end generate;

-- SLAVE->MASTER DEMUX

s0_ack_o<=ack_mux;
s0_dat_o<=rdata_mux;

end architecture;
