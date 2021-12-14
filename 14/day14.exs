defmodule Day14 do
  def part1(input) do
    steps(input, 10)
    |> compute_result()
  end

  def compute_result(result) do
    {{_, min}, {_, max}} =
      result
      |> Enum.frequencies()
      |> Enum.min_max_by(&elem(&1, 1))

    max - min
  end

  def steps({template, rules}, 0), do: template

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

Day14.read_string("example.txt")
|> Day14.part1()
|> IO.inspect(label: "part1")

Day14.read_string("input.txt")
|> Day14.part1()
|> IO.inspect(label: "part1")
