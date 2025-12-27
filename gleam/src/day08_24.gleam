import gleam/dict
import gleam/function
import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

type Vec2 {
  Vec2(x: Int, y: Int)
}

pub fn main() -> Nil {
  let assert Ok(f) = simplifile.read("../input/24_08_ex.txt")
  let f = f |> string.trim

  let fields =
    {
      use line, y <- list.index_map(string.split(f, "\n"))
      use c, x <- list.index_map(string.to_graphemes(string.trim(line)))
      case c {
        // "." -> Error("")
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

  let nodes =
    fields
    |> list.filter(fn(f) { f.2 != "." })
    |> list.group(fn(field) { field.2 })
    |> dict.map_values(fn(_key, value) {
      value
      |> list.map(fn(v) { Vec2(v.0, v.1) })
    })
    |> echo

  nodes
  |> dict.map_values(fn(node_type, nodes) {
    nodes
    |> list.combination_pairs
    |> list.flat_map(fn(node_pairs) {
      calc_antinodes(node_pairs.0, node_pairs.1)
    })
    |> list.filter(fn(n) { n.x >= 0 && n.x < w && n.y >= 0 && n.y < h })
  })
  |> echo

  Nil
}

fn vec2_sub(a: Vec2, b: Vec2) -> Vec2 {
  Vec2(a.x - b.x, a.y - b.y)
}

fn vec2_add(a: Vec2, b: Vec2) -> Vec2 {
  Vec2(a.x + b.x, a.y + b.y)
}

fn calc_antinodes(n1: Vec2, n2: Vec2) -> List(Vec2) {
  let d1 = vec2_sub(n1, n2)
  [vec2_add(n1, d1), vec2_sub(n2, d1)]
}
