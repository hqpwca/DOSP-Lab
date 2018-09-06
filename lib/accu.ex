defmodule Accumulator do
	use GenServer

	def start_link do
		GenServer.start_link(__MODULE__, {0, [], MapSet.new}, name: {:global, :wc_accumulator})
	end

	def deliver_counts(ref, {counts, start_pos}) do
		GenServer.cast({:global, :wc_accumulator}, {:deliver_counts, ref, counts, start_pos})
	end

	def get_result() do
		GenServer.call({:global, :wc_accumulator}, {:get_results})
	end

	def init(args) do
		{:ok, args}
	end

	def handle_cast({:deliver_counts, ref, counts, start_pos}, {ans, all_pos, processed_subproblems}) do
		if MapSet.member?(processed_subproblems, ref) do
			{:noreply, {ans, all_pos, processed_subproblems}}
		else
			new_ans = ans + counts
			new_pos = all_pos ++ start_pos
			new_processed_subproblems = MapSet.put(processed_subproblems, ref)
			SubGenerator.processed(ref)
			{:noreply, {new_ans, new_pos, new_processed_subproblems}}
		end
	end

	def handle_call({:get_results}, _, {ans, all_pos, processed_subproblems}) do
		{:reply, {ans, all_pos}, {ans, all_pos, processed_subproblems}}
	end
end

defmodule Accumulator.Supervisor do
	use Supervisor

	def start_link do
		Supervisor.start_link(__MODULE__, []) 
	end

	def init(_args) do
		workers = [worker(Accumulator, [])]
		supervise(workers, strategy: :one_for_one)
	end
end