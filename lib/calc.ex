defmodule Calculator do
	use GenServer

	def start_link do
		GenServer.start_link(__MODULE__, nil)
	end

	def deliver_sub_problems(pid, ref, st, k, times) do
		GenServer.cast(pid, {:calc, ref, st, k, times})
	end

	def init(_args) do
		SubGenerator.request_problems(self())
		{:ok, nil}
	end

	defp sum2(x) do div(x * (x + 1) * (2 * x + 1), 6) end

	defp calc_loop(st, k, remain_times) do
		#IO.puts(st)
		if remain_times == 0 do
			{0, []}
		else
			{counts, start_pos} = calc_loop(st + 1, k, remain_times - 1)
			sum = sum2(st + k - 1) - sum2(st - 1)
			t = Kernel.trunc(:math.sqrt(sum) + 1.0e-8)
			if t * t == sum do
				{counts + 1, [st] ++ start_pos}
			else
				{counts, start_pos}
			end
		end
	end

	def handle_cast({:calc, ref, st, k, times}, state) do
		with {:error, _} <- SubGenerator.request_problems(self()) do
			exit(:normal)
		end
		Accumulator.deliver_counts(ref, calc_loop(st, k, times))
		{:noreply, state}
	end
end

defmodule Calculator.Supervisor do
	use Supervisor

	def start_link(num_calculators) do
		Supervisor.start_link(__MODULE__, num_calculators)
	end

	def init(num_calculators) do
		workers = Enum.map(1..num_calculators, fn(n) ->
			worker(Calculator, [], id: "calculator#{n}")
		end)
		supervise(workers, strategy: :one_for_one)
	end
end

