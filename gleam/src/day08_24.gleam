import gleam/dict
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

type Vec2 {
  Vec2(x: Int, y: Int)
}

pub fn main() -> Nil {
  let assert Ok(f) = simplifile.read("../input/24_08.txt")
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
  let bounds = Vec2(w, h)

  let nodes =
    fields
    |> list.filter(fn(f) { f.2 != "." })
    |> list.group(fn(field) { field.2 })
    |> dict.map_values(fn(_key, value) {
      value
      |> list.map(fn(v) { Vec2(v.0, v.1) })
    })
    |> echo

  let s1 =
    nodes
    |> dict.map_values(fn(_node_type, nodes) {
      nodes
      |> list.combination_pairs
      |> list.flat_map(fn(node_pairs) {
        calc_antinodes(node_pairs.0, node_pairs.1)
      })
      |> list.filter(vec2_in_bounds(_, bounds))
    })
    |> dict.to_list
    |> list.flat_map(fn(p) { p.1 })
    |> list.unique
    |> list.length
    |> echo

  let s2_nodes =
    nodes
    |> dict.map_values(fn(_node_type, nodes) {
      nodes
      |> list.combination_pairs
      |> list.flat_map(fn(node_pairs) {
        calc_resonant_antinodes(node_pairs.0, node_pairs.1, bounds)
      })
      |> list.filter(vec2_in_bounds(_, bounds))
    })
    |> dict.to_list
    |> list.flat_map(fn(p) { p.1 })
    |> list.append(nodes |> dict.values |> list.flatten)
    |> list.unique

  let s2 =
    s2_nodes
    |> list.length

  echo s2

  let s2_nodes = s2_nodes |> set.from_list
  list.range(0, h - 1)
  |> list.map(fn(y) {
    list.range(0, w - 1)
    |> list.map(fn(x) {
      case set.contains(s2_nodes, Vec2(x, y)) {
        True -> "#"
        False -> "."
      }
    })
    |> string.concat
  })
  |> string.join("\n")
  |> io.println
  Nil
}

fn perms(c: List(String), num: Int) {
  case num {
    0 -> []
    1 -> c
    _ -> {
      perms(c, num - 1)
      |> list.flat_map(fn(l) { c |> list.map(fn(c) { c <> l }) })
      // |> list.flatten
    }
  }
}

// ##....#....#
// .#.#....0...
// ..#.#0....#.
// ..##...0....
// ....0....#..
// .#...#A....#
// ...#..#.....
// #....#.#....
// ..#.....A...
// ....#....A..
// .#........#.
// ...#......##
fn vec2_sub(a: Vec2, b: Vec2) -> Vec2 {
  Vec2(a.x - b.x, a.y - b.y)
}

fn vec2_add(a: Vec2, b: Vec2) -> Vec2 {
  Vec2(a.x + b.x, a.y + b.y)
}

fn vec2_in_bounds(v: Vec2, bounds: Vec2) -> Bool {
  v.x >= 0 && v.y >= 0 && v.x < bounds.x && v.y < bounds.y
}

fn calc_antinodes(n1: Vec2, n2: Vec2) -> List(Vec2) {
  let d1 = vec2_sub(n1, n2)
  [vec2_add(n1, d1), vec2_sub(n2, d1)]
}

fn collect_resonant_antinodes_dir(
  acc: List(Vec2),
  n1: Vec2,
  d: Vec2,
  bounds,
) -> List(Vec2) {
  let an = vec2_add(n1, d)
  case vec2_in_bounds(an, bounds) {
    True -> [an, ..collect_resonant_antinodes_dir(acc, an, d, bounds)]
    False -> acc
  }
}

fn calc_resonant_antinodes(n1: Vec2, n2: Vec2, bounds: Vec2) -> List(Vec2) {
  let nodes = collect_resonant_antinodes_dir([], n1, vec2_sub(n1, n2), bounds)
  collect_resonant_antinodes_dir(nodes, n2, vec2_sub(n2, n1), bounds)
}
