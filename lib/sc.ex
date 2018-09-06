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
  def hello do
    :world
  end

  def run_program() do
    SubGenerator.start_link(1000000, 4 ,100)
    Accumulator.Supervisor.start_link()
    Calculator.Supervisor.start_link(1)
    #Accumulator.get_result()
  end

  def run_program(n, k, times, num_calc) do
    SubGenerator.start_link(n, k ,times)
    Accumulator.Supervisor.start_link()
    Calculator.Supervisor.start_link(num_calc)
    #Accumulator.get_result()
  end
end
