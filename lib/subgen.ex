defmodule SubGenerator do
	use GenServer

	def start_link(n, k, times) do
		GenServer.start_link(__MODULE__, {n, k, times}, name: {:global, :wc_subgenerator})
	end

	def request_problems(pid) do
		GenServer.cast({:global, :wc_subgenerator}, {:request_problems, pid})
	end

	def processed(ref) do
		GenServer.cast({:global, :wc_subgenerator}, {:processed, ref})
	end

	def init({n, k, times}) do
		{:ok, {Map.new, 1, n - k + 1, k, times}}
	end

	def handle_cast({:request_problems, pid}, {pending, pos, n, k, times}) do
		#IO.inspect({pos, n, k, times})
		sub_length = min(n - pos + 1, times)
		new_pending = deliver_subproblem(pid, pending, pos, k, sub_length)
		if sub_length == 0 && Enum.empty?(pending) do
			IO.inspect("Finished")
			IO.inspect(Accumulator.get_result())
			exit(:normal)
		end
		{:noreply, {new_pending, pos + sub_length, n, k, times}}
	end

	def handle_cast({:processed, ref}, {pending, pos, n, k, times}) do
		new_pending = Map.delete(pending, ref)
		{:noreply, {new_pending, pos, n, k, times}}
	end

	defp deliver_subproblem(pid, pending, pos, k, sub_length) when sub_length > 0 do
		ref = make_ref()
		Calculator.deliver_sub_problems(pid, ref, pos, k, sub_length)
		Map.put(pending, ref, {pos, sub_length})
	end

	defp deliver_subproblem(pid, pending, pos, k, sub_length) when sub_length == 0 do
		if Enum.empty?(pending) do
			pending
		else
			{ref, {last_pos, last_sub_length}} = Enum.random(pending)
			Calculator.deliver_sub_problems(pid, ref, last_pos, k, last_sub_length)
			Map.put(Map.delete(pending, ref), ref, {last_pos, last_sub_length})
		end
	end
end