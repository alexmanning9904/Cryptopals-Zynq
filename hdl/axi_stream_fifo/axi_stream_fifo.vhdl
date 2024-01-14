Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- AXI4 Stream FIFO
-- I'm using this configurable-width 2-entry FIFO to allow naive combinatorial logic
-- for the first chunk of cryptopals challenges, which are mostly simple stream manipulations.
-- There may be reasons for configurable depth later, but I'm not even going to think about that for now.
-- I could actually forego this for now and just run straight combinatorial chains, but I know I'll need this
-- at some point, so I might as well start correctly now.

-- TID is _not_ supported
-- TDEST is _not_ supported
-- TUSER is _not_ supported
-- TSTRB is _not_ supported
-- TKEEP is _not_ supported
-- TLAST is _not_ supported

entity axi_stream_fifo is
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
end entity;

architecture arch of axi_stream_fifo is
    type FIFO_t is array(0 to 1) of std_logic_vector(8*n-1 downto 0);
    signal FIFO : FIFO_t;
    signal FIFO_WRITE_POINTER : unsigned(0 downto 0);
    signal FIFO_READ_POINTER : unsigned(0 downto 0);
    signal FIFO_SIZE : unsigned(1 downto 0); -- How much of FIFO is full?

begin

    -- Ready and Valid Signals inferred from size
    TREADY_o <= '0' when FIFO_SIZE = 2 else '1';
    TVALID_o <= '0' when FIFO_SIZE = 0 else '1';

    process(ACLK_i, ARESETn_i) is
    begin
        if (ARESETn_i = '0') then
            -- Reset
            TDATA_o <= (others => '0');
            FIFO <= (others => (others => '0'));
            FIFO_WRITE_POINTER <= (others => '0');
            FIFO_READ_POINTER <= (others => '0');
            FIFO_SIZE <= (others => '0');
        
        elsif (rising_edge(ACLK_i)) then
            if (TVALID_i = '1' and FIFO_SIZE /= 2) then
                -- Write to FIFO
                FIFO(to_integer(FIFO_WRITE_POINTER)) <= TDATA_i; -- Write Data
                FIFO_WRITE_POINTER <= FIFO_WRITE_POINTER + 1; -- Increment the Write Pointer
                FIFO_SIZE <= FIFO_SIZE + 1; -- Increment Size
            end if;

            if (TREADY_i = '1' and FIFO_SIZE /= 0) then
                -- Read from FIFO
                TDATA_o <= FIFO(to_integer(FIFO_READ_POINTER)); -- Write the Data
                FIFO_READ_POINTER <= FIFO_READ_POINTER + 1; -- Increment the Read Pointer
                FIFO_SIZE <= FIFO_SIZE - 1; -- Decrement Size
            end if;

            if (TVALID_i = '1' and TREADY_i = '1' and FIFO_SIZE = 1) then
                -- FIFO is both read and written - don't touch size
                FIFO_SIZE <= FIFO_SIZE;
            end if;
        end if;

    end process;

end architecture;