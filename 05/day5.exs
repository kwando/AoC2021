defmodule Day5 do
  @moduledoc """
  --- Day 5: Hydrothermal Venture ---

  You come across a field of hydrothermal vents on the ocean floor! These vents constantly produce large, opaque clouds, so it would be best to avoid them if possible.

  They tend to form in lines; the submarine helpfully produces a list of nearby lines of vents (your puzzle input) for you to review. For example:

  0,9 -> 5,9
  8,0 -> 0,8
  9,4 -> 3,4
  2,2 -> 2,1
  7,0 -> 7,4
  6,4 -> 2,0
  0,9 -> 2,9
  3,4 -> 1,4
  0,0 -> 8,8
  5,5 -> 8,2
  Each line of vents is given as a line segment in the format x1,y1 -> x2,y2 where x1,y1 are the coordinates of one end the line segment and x2,y2 are the coordinates of the other end. These line segments include the points at both ends. In other words:

  An entry like 1,1 -> 1,3 covers points 1,1, 1,2, and 1,3.
  An entry like 9,7 -> 7,7 covers points 9,7, 8,7, and 7,7.
  For now, only consider horizontal and vertical lines: lines where either x1 = x2 or y1 = y2.

  So, the horizontal and vertical lines from the above list would produce the following diagram:

  .......1..
  ..1....1..
  ..1....1..
  .......1..
  .112111211
  ..........
  ..........
  ..........
  ..........
  222111....
  In this diagram, the top left corner is 0,0 and the bottom right corner is 9,9. Each position is shown as the number of lines which cover that point or . if no line covers that point. The top-left pair of 1s, for example, comes from 2,2 -> 2,1; the very bottom row is formed by the overlapping lines 0,9 -> 5,9 and 0,9 -> 2,9.

  To avoid the most dangerous areas, you need to determine the number of points where at least two lines overlap. In the above example, this is anywhere in the diagram with a 2 or larger - a total of 5 points.

  Consider only horizontal and vertical lines. At how many points do at least two lines overlap?

  Your puzzle answer was 5576.

  --- Part Two ---

  Unfortunately, considering only horizontal and vertical lines doesn't give you the full picture; you need to also consider diagonal lines.

  Because of the limits of the hydrothermal vent mapping system, the lines in your list will only ever be horizontal, vertical, or a diagonal line at exactly 45 degrees. In other words:

  An entry like 1,1 -> 3,3 covers points 1,1, 2,2, and 3,3.
  An entry like 9,7 -> 7,9 covers points 9,7, 8,8, and 7,9.
  Considering all lines from the above example would now produce the following diagram:

  1.1....11.
  .111...2..
  ..2.1.111.
  ...1.2.2..
  .112313211
  ...1.2....
  ..1...1...
  .1.....1..
  1.......1.
  222111....
  You still need to determine the number of points where at least two lines overlap. In the above example, this is still anywhere in the diagram with a 2 or larger - now a total of 12 points.

  Consider all of the lines. At how many points do at least two lines overlap?

  Your puzzle answer was 18144.
  """
  def part1(lines) do
    lines
    |> Enum.filter(fn line -> vertical?(line) || horizontal?(line) end)
    |> draw_lines()
    |> Enum.count(fn {_pos, v} -> v >= 2 end)
  end

  defp vertical?({_, {_, 0}, _}), do: true
  defp vertical?(_), do: false
  defp horizontal?({_, {0, _}, _}), do: true
  defp horizontal?(_), do: false

  def part2(lines) do
    lines
    |> draw_lines()
    |> Enum.count(fn {_pos, v} -> v >= 2 end)
  end

  def draw_lines(lines) do
    for line <- lines, reduce: %{} do
      map ->
        draw_line(map, line)
    end
  end

  def draw_line(map, {start, delta, len}) when is_tuple(delta) do
    for n <- 0..len, reduce: map do
      map ->
        pos = delta |> scale(n) |> add(start)
        Map.update(map, pos, 1, &(&1 + 1))
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
    |> to_vector()
  end

  defp parse_position(pos) do
    String.split(pos, ",", parts: 2)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  defp add({x1, y1}, {x2, y2}), do: {x1 + x2, y1 + y2}
  defp scale({x, y}, s) when is_number(s), do: {x * s, y * s}

  defp to_vector({{x1, y1}, {x2, y2}}) do
    dx = x2 - x1
    dy = y2 - y1

    {dir, len} = vectorize({dx, dy})
    {{x1, y1}, dir, len}
  end

  defp vectorize({0, y}), do: {{0, sign(y)}, abs(y)}
  defp vectorize({x, 0}), do: {{sign(x), 0}, abs(x)}
  defp vectorize({x, y}) when abs(x) == abs(y), do: {{sign(x), sign(y)}, abs(x)}
  defp sign(x) when x > 0, do: 1
  defp sign(_), do: -1
end

example = Day5.read_data("example.txt")
input = Day5.read_data("input.txt")

example
|> Day5.part1()
|> IO.inspect(label: "part1 example")

input
|> Day5.part1()
|> IO.inspect(label: "part1 input")

example
|> Day5.part2()
|> IO.inspect(label: "part2 example")

input
|> Day5.part2()
|> IO.inspect(label: "part2 input")
