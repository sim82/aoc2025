import gleam/bool
import gleam/int
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import gleam/yielder
import simplifile

pub fn main() -> Nil {
  let assert Ok(f) = simplifile.read("input/day04.txt")

  let input =
    f
    |> string.trim
    |> string.split(on: "\n")
    |> list.index_map(fn(line, y) {
      line
      |> string.to_graphemes
      |> list.index_map(fn(c, x) { #(c, x, y) })
      |> list.filter_map(fn(c) {
        case c {
          #("@", x, y) -> Ok(#(x, y))
          #(_, _, _) -> Error("")
        }
      })
    })
    |> list.flatten
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
