defmodule Day8 do
  def part1(input) do
    unique_outputs(input)
  end

  @unique [2, 4, 3, 7]
  def unique_outputs(examples) do
    for {_, outputs} <- examples, reduce: 0 do
      sum ->
        sum + Enum.count(outputs, fn output -> Enum.member?(@unique, String.length(output)) end)
    end
  end

  @segments [
    {0, ~w(a b c e f g)},
    {1, ~w(c f)},
    {2, ~w(a c d e g)},
    {3, ~w(a c d f g)},
    {4, ~w(b c d f)},
    {5, ~w(a b d f g)},
    {6, ~w(a b d e f g)},
    {7, ~w(a c f)},
    {8, ~w(a b c d e f g)},
    {8, ~w(a b c d f g)}
  ]

  def read_input(file) do
    file
    |> Path.expand(__DIR__)
    |> File.stream!()
    |> Stream.map(&parse_line/1)
  end

  def parse_line(line) do
    [input, output] =
      line
      |> String.trim()
      |> String.split("|", parts: 2)

    {String.split(input), String.split(output)}
  end
end

Day8.read_input("example2.txt")
|> Day8.part1()
|> IO.inspect(label: "part1 example")

Day8.read_input("input.txt")
|> Day8.part1()
|> IO.inspect(label: "part1")
