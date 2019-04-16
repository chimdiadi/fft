-- dynamic butterfly for FFT operation
-- Implements the Dynamic Butterfly needed for R2SDF pipelined FFT
--
-- connect FIFO on upper in and lower out
-- connect rotator on lower in and upper out
--
-- butterfly has two modes:
-- 1) input-passthrough - passes input to memory and memory (results) to output
-- 2) butterfly - does the addition/subtraction part
--
-- input samples are iowidth bits wide
-- output samples are iowidth+1 bits wide (bit growth due to addition)
-- input samples from the delay line are also one bit wider,
--  because we want to store 9 bit results.
-- when letting samples pass, they are sign extended to 9 bits
--
-- Author: Stefan Biereigel

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity butterfly is
    generic (
        -- input bit width
        iowidth     : positive := 8
    );

    port (
        clk     : in std_logic;
        ctl     : in std_logic;
        iu_re       : in std_logic_vector(iowidth downto 0);
        iu_im       : in std_logic_vector(iowidth downto 0);
        il_re       : in std_logic_vector(iowidth-1 downto 0);
        il_im       : in std_logic_vector(iowidth-1 downto 0);
        ou_re       : out std_logic_vector(iowidth downto 0);
        ou_im       : out std_logic_vector(iowidth downto 0);
        ol_re       : out std_logic_vector(iowidth downto 0);
        ol_im       : out std_logic_vector(iowidth downto 0)
    );
end butterfly;

architecture rtl of butterfly is
begin
    process (ctl, iu_re, iu_im, il_re, il_im)
    begin
        if ctl = '0' then
            -- upper = upper
            ou_re <= iu_re;
            ou_im <= iu_im;

            -- lower = lower)
            ol_re <= std_logic_vector(resize(signed(il_re), iowidth+1));
            ol_im <= std_logic_vector(resize(signed(il_im), iowidth+1));
        else
            -- upper = (upper + lower)
            ou_re <= std_logic_vector(
                signed(iu_re) + resize(signed(il_re),iowidth+1)
            );
            ou_im <= std_logic_vector(
                signed(iu_im) + resize(signed(il_im),iowidth+1)
            );
            -- lower = (upper - lower)
            ol_re <= std_logic_vector(
                signed(iu_re) - resize(signed(il_re),iowidth+1)
            );
            ol_im <= std_logic_vector(
                signed(iu_im) - resize(signed(il_im),iowidth+1)
            );
        end if;

    end process;
end rtl;

