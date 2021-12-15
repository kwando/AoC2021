defmodule Day5 do
  def vertical_line?({{x1, _}, {x2, _}}), do: x1 == x2
  def horizontal_line?({{_, y1}, {_, y2}}), do: y1 == y2

  def part1(lines) do
    lines
    |> Enum.filter(fn line -> vertical_line?(line) || horizontal_line?(line) end)
    |> draw_lines()
    |> Enum.count(fn {_pos, v} -> v >= 2 end)
  end

  def part2(lines) do
    lines
    |> draw_lines()
    |> print_map()
    |> Enum.count(fn {_pos, v} -> v >= 2 end)
  end

  def draw_lines(lines) do
    for line <- lines, reduce: %{} do
      map ->
        draw_line(map, line)
    end
  end

  def draw_line(map, {{sx, sy}, {ex, ey}}) do
    for x <- sx..ex, y <- sy..ey, reduce: map do
      map ->
        Map.update(map, {x, y}, 1, &(&1 + 1))
    end
  end

  def print_map(map) do
    {min, max} =
      bounds(map)
      |> IO.inspect(label: "bounds")

    for y <- elem(min, 1)..elem(max, 1) do
      [
        for x <- elem(min, 0)..elem(max, 0) do
          Map.get(map, {x, y}, ".") |> to_string()
        end,
        ?\n
      ]
    end
    |> IO.puts()

    map
  end

  defp bounds(map) when is_map(map) do
    for {pos, _} <- map, reduce: {{0, 0}, {0, 0}} do
      {low, high} ->
        {min_point(low, pos), max_point(high, pos)}
    end
  end

  defp max_point({x1, y1}, {x2, y2}), do: {max(x1, x2), max(y1, y2)}
  defp min_point({x1, y1}, {x2, y2}), do: {min(x1, x2), min(y1, y2)}

  def read_data(file) do
    file
    |> Path.expand(__DIR__)
    |> File.stream!()
    |> Stream.map(&parse_line/1)
    |> Enum.to_list()
  end

  defp parse_line(line) do
    line
    |> String.trim()
    |> String.split(" -> ", trim: true)
    |> Enum.map(&parse_position/1)
    |> List.to_tuple()
  end

  defp parse_position(pos) do
    String.split(pos, ",", parts: 2)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end
end

Day5.read_data("example.txt")
|> Day5.part1()
|> IO.inspect(label: "part1 example")

Day5.read_data("input.txt")
|> Day5.part1()
|> IO.inspect(label: "part1 input")

Day5.read_data("example.txt")
|> Day5.part2()
|> IO.inspect(label: "part2 example")
