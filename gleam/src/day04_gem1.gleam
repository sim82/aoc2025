import gleam/bool
import gleam/int
import gleam/list
import gleam/order
import gleam/result
import gleam/set
import gleam/string
import simplifile

pub fn main() -> Nil {
  let assert Ok(f) = simplifile.read("input/day04.txt")
  let input =
    f
    |> string.trim
    |> string.split("\n")
    |> list.index_fold([], fn(acc, line, y) {
      line
      |> string.to_graphemes
      |> list.index_fold(acc, fn(inner_acc, char, x) {
        case char {
          "@" -> [#(x, y), ..inner_acc]
          _ -> inner_acc
        }
      })
    })
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

const ns = [
  #(-1, -1),
  #(0, -1),
  #(1, -1),
  #(-1, 0),
  #(1, 0),
  #(-1, 1),
  #(0, 1),
  #(1, 1),
]

fn reachable(rolls, roll) {
  let #(x, y) = roll
  ns
  |> list.count(fn(n) {
    let #(nx, ny) = n
    set.contains(rolls, #(x + nx, y + ny))
  })
  |> int.compare(4)
  |> fn(res) { res == order.Lt }
}

fn remove_reachable(rolls) {
  let reduced = rolls |> set.filter(fn(roll) { !reachable(rolls, roll) })
  case set.size(reduced) == set.size(rolls) {
    True -> rolls
    False -> remove_reachable(reduced)
  }
}
