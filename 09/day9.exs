defmodule Day9 do
  def part1(map) do
    find_lowpoints(map)
    |> Map.values()
    |> Enum.map(&(&1 + 1))
    |> Enum.sum()
  end

  def find_lowpoints(map) do
    Map.filter(map, fn {k, v} -> low_point?(map, {k, v}) end)
  end

  @kernel for(x <- -1..1, y <- -1..1, do: {x, y}) -- [{0, 0}]

  def low_point?(map, {{x, y}, value}) do
    Enum.all?(@kernel, fn {dx, dy} ->
      case Map.fetch(map, {x + dx, y + dy}) do
        :error -> true
        {:ok, v} -> v > value
      end
    end)
  end

  def read_map(file) do
    Path.expand(file, __DIR__)
    |> File.stream!()
    |> Stream.map(&parse_line/1)
    |> Stream.with_index()
    |> Stream.flat_map(fn {line, row} ->
      Enum.map(line, fn {value, col} -> {{row, col}, value} end)
    end)
    |> Map.new()
  end

  defp parse_line(line) do
    line
    |> String.trim()
    |> String.split("", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
  end
end

Day9.read_map("input.txt")
|> Day9.part1()
|> IO.inspect(label: "part1")
