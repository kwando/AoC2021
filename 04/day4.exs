defmodule Day4 do
  def part1(input) do
    input
    |> play()
    |> case do
      {:bingo, {number, [{numbers_left, _}]}, game} ->
        Enum.sum(numbers_left) * number
    end
  end

  def play({[], boards}) do
    {:no_bingo, {[], boards}}
  end

  def play({[number | sequence], boards}) do
    case play_round(number, boards) do
      {:continue, updated_boards} ->
        play({sequence, updated_boards})

      {:bingo, bingo_boards, updated_boards} ->
        {:bingo, {number, bingo_boards}, {sequence, updated_boards}}
    end
  end

  def play_round(number, boards) do
    updated_boards = mark_boards(boards, number)

    bingo_boards = updated_boards |> Enum.filter(&bingo?/1)

    if bingo_boards == [] do
      {:continue, updated_boards}
    else
      {:bingo, bingo_boards, updated_boards}
    end
  end

  def mark_boards(boards, number) do
    for {numbers, sets} <- boards do
      if MapSet.member?(numbers, number) do
        {
          MapSet.delete(numbers, number),
          for set <- sets do
            set -- [number]
          end
        }
      else
        {numbers, sets}
      end
    end
  end

  def mark_board({numbers, sets}, number) do
    if MapSet.member?(numbers, number) do
      {
        MapSet.new(numbers, number),
        for set <- sets do
          set -- [number]
        end
      }
    else
      {numbers, sets}
    end
  end

  def bingo?({_, sets}) do
    Enum.any?(sets, &(&1 == []))
  end

  def read_input(path) do
    content =
      path
      |> Path.expand(__DIR__)
      |> File.read!()

    [sequence, boards] = String.split(content, "\n\n", parts: 2)

    sequence =
      sequence
      |> String.trim()
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    boards =
      boards
      |> String.split("\n\n")
      |> Enum.map(&parse_board/1)

    {sequence, boards}
  end

  defp parse_board(board) do
    board
    |> String.split(~r/\s+/, trim: true)
    |> Enum.map(&String.to_integer/1)
    |> build_board(5)
  end

  def build_board(board, x) do
    sets =
      for n <- 0..(x - 1) do
        board
        |> Enum.drop(n)
        |> Enum.take_every(5)
      end ++
        Enum.chunk_every(board, x)

    {MapSet.new(board), sets}
  end
end

example = Day4.read_input("example.txt")
input = Day4.read_input("input.txt")

Day4.part1(example)
|> IO.inspect(label: "part1 example")

Day4.part1(input)
|> IO.inspect(label: "part1 input")
