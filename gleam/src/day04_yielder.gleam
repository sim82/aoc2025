import file_streams/file_stream
import gleam/bool
import gleam/int
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import gleam/yielder
import simplifile

pub fn main() -> Nil {
  let path = "input/day04.txt"
  let assert Ok(stream) = file_stream.open_read(path)

  let line_yielder =
    yielder.unfold(from: stream, with: fn(s) {
      case file_stream.read_line(s) {
        Ok(line) -> yielder.Next(element: line, accumulator: s)
        Error(_) -> {
          let _ = file_stream.close(stream)
          yielder.Done
        }
      }
    })

  let input =
    line_yielder
    |> yielder.index
    |> yielder.map(fn(c) {
      let #(line, y) = c
      line
      |> string.to_graphemes
      |> yielder.from_list
      |> yielder.index
      |> yielder.filter_map(fn(c) {
        let #(char, x) = c
        case char {
          "@" -> Ok(#(x, y))
          _ -> Error(Nil)
        }
      })
    })
    |> yielder.flatten
    |> yielder.to_list
    |> set.from_list

  let s1 =
    input
    |> set.filter(reachable(input, _))
    |> set.size
  echo s1

  let start = set.size(input)
  let end = input |> remove_reachable |> set.size
  let s2 = start - end
  echo s2

  Nil
}

fn reachable(rolls, roll) {
  let ns = [
    #(-1, -1),
    #(0, -1),
    #(1, -1),
    #(-1, 0),
    #(1, 0),
    #(-1, 1),
    #(0, 1),
    #(1, 1),
  ]

  let #(x, y) = roll
  let count =
    ns
    |> list.count(fn(n) {
      let #(nx, ny) = n
      set.contains(rolls, #(x + nx, y + ny))
    })
  count < 4
}

fn remove_reachable(rolls) {
  let reduced = rolls |> set.filter(fn(roll) { !reachable(rolls, roll) })
  case reduced == rolls {
    True -> rolls
    False -> remove_reachable(reduced)
  }
}
