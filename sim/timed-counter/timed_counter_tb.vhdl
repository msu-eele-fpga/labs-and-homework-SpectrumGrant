 
 library ieee;
 use ieee.std_logic_1164.all;
 use work.print_pkg.all;
 use work.assert_pkg.all;
 use work.tb_pkg.all;
 
 entity timed_counter_tb is
 end entity timed_counter_tb;
 
 architecture testbench of timed_counter_tb is 
	component timed_counter is
	generic (
		clk_period : time;
		count_time : time
	);
	port (
		clk		: in 	std_ulogic;
		enable	: in	boolean;
		done		: out boolean
	);
	end component timed_counter;
	
	procedure predict_counter_done (
		constant count_time	: in time;
		signal enable			: in boolean;
		signal done				: in boolean;
		constant count_iter	: in natural
	) is
	begin
		if (enable) then
			-- counter_iter is the number of clock cycles that have elapsed since the counter was enabled
			if (count_iter < (count_time / CLK_PERIOD)) then
				-- done should be false
				assert_false(done, "counter not done");
			else
				-- count_time has been reached; done should be true
				assert_true(done, "counter is done");
			end if;
		else
			-- counter isn't enabled; done should be false
			assert_false(done, "counter not enabled");
		end if;
	end procedure predict_counter_done;
	
	
	signal clk_tb : std_ulogic := '0';
	
	signal enable_100ns_tb	: boolean := false;
	signal done_100ns_tb		: boolean;
	
	constant HUNDRED_NS		: time := 100 ns;
	
 begin
 
	dut_100ns_counter : component timed_counter
		generic map (
			clk_period => CLK_PERIOD,
			count_time => HUNDRED_NS
		)
		port map (
			clk		=> clk_tb,
			enable	=> enable_100ns_tb,
			done		=> done_100ns_tb
		);
	
	clk_tb <= not clk_tb after CLK_PERIOD / 2;
	
	stimuli_and_checker : process is
	begin
	
		-- test 100ns timer when it's enabled
		print("testing 100 ns timer: enabled");
		wait_for_clock_edge(clk_tb);
		enable_100ns_tb <= true;

		-- loop for the number of clock cycles that is equal to the timer's period
		for i in 0 to (HUNDRED_NS / CLK_PERIOD) loop
			wait_for_clock_edge(clk_tb);
			-- test whether the counter's done output is correct or not
			predict_counter_done(HUNDRED_NS, enable_100ns_tb, done_100ns_tb, i);
		end loop;
		
		print("testing 100 ns timer: disabled");
		wait_for_clock_edge(clk_tb);
		enable_100ns_tb <= false;

		-- loop for the number of clock cycles that is equal to the timer's period
		for i in 0 to (HUNDRED_NS / CLK_PERIOD * 2) loop
			wait_for_clock_edge(clk_tb);
			-- test whether the counter's done output is correct or not
			predict_counter_done(HUNDRED_NS, enable_100ns_tb, done_100ns_tb, i);
		end loop;

		print("testing 100 ns timer multiple: enabled");
		wait_for_clock_edge(clk_tb);
		enable_100ns_tb <= true;

		-- loop for the number of clock cycles that is equal to the timer's period
		for j in 0 to 3 loop
			for i in 0 to (HUNDRED_NS / CLK_PERIOD) loop
				wait_for_clock_edge(clk_tb);
				-- test whether the counter's done output is correct or not
				predict_counter_done(HUNDRED_NS, enable_100ns_tb, done_100ns_tb, i);
			end loop;
		end loop;
		
		-- add other test cases here
		
		-- testbench is done :)
		std.env.finish;
	end process stimuli_and_checker;
 end architecture testbench;