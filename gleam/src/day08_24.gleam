import gleam/dict
import gleam/function
import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

type Dir {
  Up
  Down
  Right
  Left
}

type Guard {
  Guard(pos: #(Int, Int), dir: Dir)
}

pub fn main() -> Nil {
  let assert Ok(f) = simplifile.read("../input/24_08_ex.txt")
  let f = f |> string.trim

  let fields =
    {
      use line, y <- list.index_map(string.split(f, "\n"))
      use c, x <- list.index_map(string.to_graphemes(string.trim(line)))
      case c {
        "." -> Error("")
        c -> Ok(#(x, y, c))
      }
    }
    |> list.flatten
    |> list.filter_map(function.identity)
  // |> echo
  let assert Ok(w) =
    fields
    |> list.map(fn(f) { f.0 })
    |> list.max(int.compare)
    |> result.map(int.add(_, 1))
  let assert Ok(h) =
    fields
    |> list.map(fn(f) { f.1 })
    |> list.max(int.compare)
    |> result.map(int.add(_, 1))
  echo #(w, h)

  fields
  |> list.group(fn(field) { field.2 })
  |> dict.map_values(fn(_key, value) {
    value
    |> list.map(fn(v) { #(v.0, v.1) })
  })
  |> echo

  Nil
}
