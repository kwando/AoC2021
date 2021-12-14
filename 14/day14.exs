defmodule Day14 do
  def part1(input) do
    steps(input, 10)
    |> compute_result()
  end

  defp new_counters() do
    :ets.new(__MODULE__, [])
  end

  defp inc_counter(counters, key) do
    # Map.update(counters, key, 1, &(&1 + 1))
    :ets.update_counter(counters, key, {2, 1})
    counters
  rescue
    _ ->
      :ets.insert(counters, {key, 1})
      counters
  end

  defp list_counts(table) do
    :ets.tab2list(table)
  end

  def part2({template, rules}) do
    counts =
      for x <- template, reduce: new_counters() do
        counts -> inc_counter(counts, x)
      end

    part2(template, counts, rules, 40)
    |> format_result()
  end

  defp format_result(counts) do
    {{_, min}, {_, max}} = Enum.min_max_by(list_counts(counts), fn {_, count} -> count end)
    max - min
  end

  defp part2([_], counts, _rules, _), do: counts

  defp part2([l, r | rest], counts, rules, levels) do
    part2([r | rest], apply_rules(l, r, rules, counts, levels), rules, levels)
  end

  def apply_rules(_left, _right, _rules, counts, 0) do
    counts
  end

  def apply_rules(left, right, rules, counts, level) do
    case Map.fetch(rules, {left, right}) do
      {:ok, insertion} ->
        updated_counts = inc_counter(counts, insertion)
        updated_counts = apply_rules(left, insertion, rules, updated_counts, level - 1)
        apply_rules(insertion, right, rules, updated_counts, level - 1)

      :error ->
        counts
    end
  end

  def compute_result(result) do
    {{_, min}, {_, max}} =
      result
      |> Enum.frequencies()
      |> Enum.min_max_by(&elem(&1, 1))

    max - min
  end

  def steps({template, _rules}, 0), do: template

  def steps({template, rules}, n) do
    steps({apply_rules(template, rules), rules}, n - 1)
  end

  def apply_rules([l], _rules), do: [l]

  def apply_rules([l, r | rest], rules) do
    case Map.fetch(rules, {l, r}) do
      {:ok, insertion} ->
        [l, insertion | apply_rules([r | rest], rules)]

      :error ->
        apply_rules([r | rest], rules)
    end
  end

  def read_string(path) do
    stream =
      path
      |> Path.expand(__DIR__)
      |> File.stream!()

    template =
      stream
      |> Enum.take(1)
      |> hd()
      |> String.trim()
      |> to_charlist()

    rules =
      stream
      |> Stream.drop(2)
      |> Enum.map(&parse_rule/1)

    {template, Map.new(rules)}
  end

  def parse_rule(line) do
    [l, r, _, ?-, ?>, _, t] =
      line
      |> String.trim()
      |> String.to_charlist()

    {{l, r}, t}
  end
end

Day14.read_string("input.txt")
|> Day14.part2()
|> IO.inspect(label: "part2")
