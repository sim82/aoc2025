import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/pair
import gleam/regexp
import gleam/string
import simplifile

pub fn main() -> Nil {
  let assert Ok(f) = simplifile.read("../input/24_05.txt")

  let assert [rules, updates] = string.split(f, "\n\n")
  let rules =
    rules
    |> string.trim
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert Ok([i1, i2]) =
        line |> string.split("|") |> list.try_map(int.parse)

      #(i1, i2)
    })

  let assert Ok(updates) =
    updates
    |> string.trim
    |> string.split("\n")
    |> list.try_map(fn(line) {
      line |> string.split(",") |> list.try_map(int.parse)
    })

  let #(valid_updates, invalid_updates) =
    updates |> list.partition(rules_valid(_, rules))
  let s1 =
    valid_updates
    |> list.map(middle)
    |> int.sum

  echo s1

  invalid_updates
  |> list.map(fix_rules(_, rules))
  |> list.map(middle)
  |> int.sum
  |> echo

  Nil
}

fn middle(update: List(Int)) -> Int {
  let middle = list.length(update) / 2
  update
  |> list.index_fold(0, fn(acc, u, i) {
    case i == middle {
      True -> u
      False -> acc
    }
  })
}

fn rules_valid(update: List(Int), rules: List(#(Int, Int))) {
  !{
    update
    |> list.combination_pairs
    |> list.any(fn(p) { rules |> list.contains(pair.swap(p)) })
  }
}

fn fix_rules(update: List(Int), rules: List(#(Int, Int))) {
  let new_update = fix_rules_once(update, rules)
  case new_update == update {
    True -> new_update
    False -> fix_rules(new_update, rules)
  }
}

fn fix_rules_once(update: List(Int), rules: List(#(Int, Int))) {
  case update {
    [] -> []
    [a] -> [a]
    [a, b, ..rest] ->
      case list.contains(rules, pair.swap(#(b, a))) {
        True -> [a, ..fix_rules([b, ..rest], rules)]
        False -> [b, ..fix_rules([a, ..rest], rules)]
      }
  }
}
