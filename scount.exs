defmodule SquareCount do
	@moduledoc """
	Documentation for SquareCount.
	"""

	@doc """
	Hello world.

	## Examples

			iex> SquareCount.hello()
			:world

	"""
	def run_program() do
		SubGenerator.start_link(100000000, 24, 100, self())
		Accumulator.Supervisor.start_link()
		Calculator.Supervisor.start_link(16)
		receive do
			{:finished} -> IO.inspect Accumulator.get_result()
		end
	end

	def run_program(n, k) do
		SubGenerator.start_link(n, k, Kernel.trunc(:math.sqrt(n)/2), self())
		Accumulator.Supervisor.start_link()
		Calculator.Supervisor.start_link(16)
		receive do
			{:finished} -> IO.inspect Accumulator.get_result()
		end
	end

	def run_program(n, k, times, num_calc) do
		SubGenerator.start_link(n, k ,times, self())
		Accumulator.Supervisor.start_link()
		Calculator.Supervisor.start_link(num_calc)
		receive do
			{:finished} -> IO.inspect Accumulator.get_result()
		end
	end
end

[s1, s2] = System.argv
SquareCount.run_program(String.to_integer(s1), String.to_integer(s2))