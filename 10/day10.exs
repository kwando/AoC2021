defmodule Day10 do
  def part1(input) do
    for {:corrupted, {actual, _expected, _offset}} <- input, reduce: 0 do
      sum -> sum + corruption_score(actual)
    end
  end

  def part2(input) do
    for row = {:incomplete, stack} <- input do
      incomplete_score(stack)
    end
    |> median()
  end

  defp median(list), do: middle(Enum.sort(list))
  defp middle(list), do: Enum.at(list, div(length(list), 2))

  def parse(row), do: parse(row, [], 0)

  def parse("", [], _), do: :ok
  def parse("", stack, _), do: {:incomplete, stack}
  def parse(<<?(, r::binary>>, stack, n), do: parse(r, [?) | stack], n + 1)
  def parse(<<?[, r::binary>>, stack, n), do: parse(r, [?] | stack], n + 1)
  def parse(<<?{, r::binary>>, stack, n), do: parse(r, [?} | stack], n + 1)
  def parse(<<?<, r::binary>>, stack, n), do: parse(r, [?> | stack], n + 1)

  def parse(<<x, r::binary>>, [x | rest], n), do: parse(r, rest, n + 1)
  def parse(<<a, _::binary>>, [e | _], n), do: {:corrupted, {a, e, n}}

  def corruption_score(?)), do: 3
  def corruption_score(?]), do: 57
  def corruption_score(?}), do: 1197
  def corruption_score(?>), do: 25137

  def incomplete_bracket_score(?)), do: 1
  def incomplete_bracket_score(?]), do: 2
  def incomplete_bracket_score(?}), do: 3
  def incomplete_bracket_score(?>), do: 4

  def incomplete_score(list) do
    for bracket <- list, reduce: 0 do
      total ->
        total * 5 + incomplete_bracket_score(bracket)
    end
  end

  def stream_input(file) do
    file
    |> Path.expand(__DIR__)
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse/1)
  end
end

example = Day10.stream_input("example.txt")
input = Day10.stream_input("input.txt")

example
|> Day10.part1()
|> IO.inspect(label: "part1")

input
|> Day10.part1()
|> IO.inspect(label: "part1")

example
|> Day10.part2()
|> IO.inspect(label: "part2")

input
|> Day10.part2()
|> IO.inspect(label: "part2")
