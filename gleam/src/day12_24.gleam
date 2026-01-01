import gleam/dict.{type Dict}
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

type Vec2 {
  Vec2(x: Int, y: Int)
}

pub fn main() -> Nil {
  let assert Ok(f) = simplifile.read("../input/24_12.txt")
  let f = f |> string.trim

  let starts =
    {
      use line, y <- list.index_map(string.split(f, "\n"))
      use c, x <- list.index_map(string.to_graphemes(string.trim(line)))
      #(Vec2(x, y), c)
    }
    |> list.flatten

  let fields =
    starts
    |> dict.from_list

  let cont = {
    use acc, head <- list.fold(dict.keys(fields), dict.new())
    collect_reachable(head, head, fields, acc)
  }
  let groups =
    cont
    |> dict.to_list
    |> list.group(fn(p) { p.1 })
    |> dict.map_values(fn(_, b) { b |> list.map(fn(x) { x.0 }) })
    |> dict.values
    |> echo

  {
    use group <- list.map(groups)

    let circumfence = calc_circumfence(group, fields)
    circumfence * list.length(group)
  }
  |> int.sum
  |> echo

  Nil
}

fn calc_circumfence(group: List(Vec2), fields: Dict(Vec2, String)) -> Int {
  group
  |> list.map(fn(f) {
    let assert Ok(t) = dict.get(fields, f)

    get_neighbors(f)
    |> list.count(fn(n) { dict.get(fields, n) != Ok(t) })
  })
  |> int.sum
}

fn get_neighbors(f: Vec2) -> List(Vec2) {
  [
    Vec2(f.x - 1, f.y),
    Vec2(f.x + 1, f.y),
    Vec2(f.x, f.y - 1),
    Vec2(f.x, f.y + 1),
  ]
}

fn collect_reachable(
  start: Vec2,
  from,
  fields: Dict(Vec2, String),
  acc: Dict(Vec2, Vec2),
) {
  let assert Ok(me) = dict.get(fields, start)
  let acc = case dict.has_key(acc, start) {
    False -> dict.insert(acc, start, from)
    True -> acc
  }
  get_neighbors(start)
  |> list.filter(fn(n) {
    case dict.get(fields, n) {
      Error(_) -> False
      Ok(c) -> c == me
    }
  })
  |> list.filter(fn(n) { !dict.has_key(acc, n) })
  |> list.fold(acc, fn(acc, n) {
    collect_reachable(n, from, fields, dict.insert(acc, n, from))
  })
}
