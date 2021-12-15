defmodule Day13 do
  def part1({positions, folds}) do
    fold = hd(folds)

    fold_map(positions, fold)
    |> MapSet.size()
  end

  def part2({positions, folds}) do
    for fold <- folds, reduce: positions do
      positions ->
        fold_map(positions, fold)
    end
    |> print_map()

    nil
  end

  def fold_map(positions, {:y, line}) do
    for {x, y} <- positions, reduce: MapSet.new() do
      folded_positions ->
        if y > line do
          MapSet.put(folded_positions, {x, line - abs(y - line)})
        else
          MapSet.put(folded_positions, {x, y})
        end
    end
  end

  def fold_map(positions, {:x, line}) do
    for {x, y} <- positions, reduce: MapSet.new() do
      folded_positions ->
        if x > line do
          MapSet.put(folded_positions, {line - abs(x - line), y})
        else
          MapSet.put(folded_positions, {x, y})
        end
    end
  end

  def print_map(positions) do
    bottom_right =
      for {x, y} <- positions, reduce: {0, 0} do
        {max_x, max_y} ->
          {max(x, max_x), max(y, max_y)}
      end

    print_map(positions, bottom_right)
  end

  def print_map(positions, {width, height}) do
    for y <- 0..height do
      [
        for x <- 0..width do
          if MapSet.member?(positions, {x, y}) do
            ?#
          else
            ?\s
          end
        end,
        ?\n
      ]
    end
    |> IO.puts()

    positions
  end

  def read_input(file) do
    lines =
      file
      |> Path.expand(__DIR__)
      |> File.read!()
      |> String.split("\n", trim: true)

    {pos, folds} = Enum.split_while(lines, &(!String.starts_with?(&1, "fold")))

    positions =
      for p <- pos do
        [x, y] =
          p
          |> String.split(",", parts: 2)
          |> Enum.map(&String.to_integer/1)

        {x, y}
      end

    folds =
      for "fold along " <> f <- folds do
        [direction, value] = String.split(f, "=", parts: 2)
        {String.to_existing_atom(direction), String.to_integer(value)}
      end

    {MapSet.new(positions), folds}
  end
end

example = Day13.read_input("example.txt")
input = Day13.read_input("input.txt")

example
|> Day13.part1()
|> IO.inspect(label: "part1")

input
|> Day13.part1()
|> IO.inspect(label: "part1")

example
|> Day13.part2()
|> IO.inspect(label: "part2")

input
|> Day13.part2()
|> IO.inspect(label: "part2")
