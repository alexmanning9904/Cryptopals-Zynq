Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Library std;
use std.env.finish;

-- AXI4 Stream FIFO Testbench
-- This testbench uses all of the assumptions of the axi stream fifo

entity axi_stream_fifo_tb is
end entity axi_stream_fifo_tb;

architecture arch of axi_stream_fifo_tb is

    -- UUT Component
    component axi_stream_fifo is
        generic(
            n : integer := 1 -- AXI4 Stream Data Width in Bytes
        );
        port(
            -- General Signals
            ACLK_i : in std_logic;
            ARESETn_i : in std_logic;

            -- AXI4 Stream Inputs
            TVALID_i : in std_logic;
            TREADY_o : out std_logic;
            TDATA_i : in std_logic_vector(8*n-1 downto 0);

            -- AXI4 Stream Outputs
            TVALID_o : out std_logic;
            TREADY_i : in std_logic;
            TDATA_o : out std_logic_vector(8*n-1 downto 0)
        );
    end component;

    -- Parameters
    constant n : integer := 1; -- Bus width in bytes

    -- Stimulus
    signal TB_ACLK_o, TB_ARESETn_o : std_logic;
    signal TB_TVALID_o, TB_TVALID_i, TB_TREADY_o, TB_TREADY_i : std_logic;
    signal TB_TDATA_o, TB_TDATA_i : std_logic_vector(8*n-1 downto 0);

begin
    -- UUT Instance
    uut : axi_stream_fifo
    generic map(
        n => n
    )
    port map(
        ACLK_i => TB_ACLK_o,
        ARESETn_i => TB_ARESETn_o,
        TVALID_i => TB_TVALID_o,
        TREADY_o => TB_TREADY_i,
        TVALID_o => TB_TVALID_i,
        TREADY_i => TB_TREADY_o,
        TDATA_o => TB_TDATA_i,
        TDATA_i => TB_TDATA_o
    );

    -- Clock Process
    process begin
        TB_ACLK_o <= '0';
        wait for 5ns;
        TB_ACLK_o <= '1';
        wait for 5ns;
    end process;
    
    -- Test Process
    process begin
        -- Reset
        TB_ARESETn_o <= '0';
        TB_TVALID_o <= '0';
        TB_TREADY_o <= '0';
        TB_TDATA_o <= (others => '0');

        wait for 10ns;

        -- Fifo should be empty
        assert(TB_TREADY_i = '1') report "FIFO was Reset but reported Not Ready" severity error;
        assert(TB_TVALID_i = '0') report "FIFO was Reset but reported Valid Data" severity error;

        -- Try to Read Data
        TB_ARESETn_o <= '1';
        TB_TVALID_o <= '0';
        TB_TREADY_o <= '1';
        TB_TDATA_o <= (others => '0');

        wait for 10ns;

        -- Fifo should be empty
        assert(TB_TREADY_i = '1') report "FIFO was empty but reported Not Ready" severity error;
        assert(TB_TVALID_i = '0') report "FIFO was empty but reported Valid Data" severity error;

        -- Write a Byte
        TB_ARESETn_o <= '1';
        TB_TVALID_o <= '1';
        TB_TREADY_o <= '0';
        TB_TDATA_o <= X"23";

        wait for 10ns;

        -- Fifo has 1 byte
        assert(TB_TREADY_i = '1') report "FIFO not full but reported Not Ready" severity error;
        assert(TB_TVALID_i = '1') report "FIFO was not empty but reported No Valid Data" severity error;

        -- Write a Byte and Read a Byte
        TB_ARESETn_o <= '1';
        TB_TVALID_o <= '1';
        TB_TREADY_o <= '1';
        TB_TDATA_o <= X"45";

        wait for 10ns;

        -- Fifo has 1 new byte
        assert(TB_TREADY_i = '1') report "FIFO not full but reported Not Ready" severity error;
        assert(TB_TVALID_i = '1') report "FIFO was not empty but reported No Valid Data" severity error;
        assert(TB_TDATA_i = X"23") report "FIFO Gave Incorrect Data";

        -- Write a Byte
        TB_ARESETn_o <= '1';
        TB_TVALID_o <= '1';
        TB_TREADY_o <= '0';
        TB_TDATA_o <= X"67";

        wait for 10ns;

        -- Fifo has 2 bytes
        assert(TB_TREADY_i = '0') report "FIFO was full but reported Ready" severity error;
        assert(TB_TVALID_i = '1') report "FIFO was not empty but reported No Valid Data" severity error;

        -- Try to write another byte
        TB_ARESETn_o <= '1';
        TB_TVALID_o <= '1';
        TB_TREADY_o <= '0';
        TB_TDATA_o <= X"89";

        wait for 10ns;

        -- Fifo has 2 bytes
        assert(TB_TREADY_i = '0') report "FIFO was full but reported Ready" severity error;
        assert(TB_TVALID_i = '1') report "FIFO was not empty but reported No Valid Data" severity error;

        -- Try to Write and Read
        TB_ARESETn_o <= '1';
        TB_TVALID_o <= '1';
        TB_TREADY_o <= '1';
        TB_TDATA_o <= X"AB";

        wait for 10ns;

        -- Fifo has 1 byte; the read should have been successful but not the write
        assert(TB_TREADY_i = '1') report "FIFO not full but reported Not Ready" severity error;
        assert(TB_TVALID_i = '1') report "FIFO was not empty but reported No Valid Data" severity error;
        assert(TB_TDATA_i = X"45") report "FIFO Gave Incorrect Data";

        -- Try to read the last byte
        TB_ARESETn_o <= '1';
        TB_TVALID_o <= '0';
        TB_TREADY_o <= '1';
        TB_TDATA_o <= (others => '0');

        wait for 10ns;

        -- Fifo should be empty
        assert(TB_TREADY_i = '1') report "FIFO empty but reported Not Ready" severity error;
        assert(TB_TVALID_i = '0') report "FIFO was not empty but reported No Valid Data" severity error;
        assert(TB_TDATA_i = X"67") report "FIFO Gave Incorrect Data";

        finish;

    end process;

end architecture;