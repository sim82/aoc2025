import gleam/dict
import gleam/float
import gleam/function
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

type Vec3 {
  Vec3(x: Int, y: Int, z: Int)
}

pub fn main() -> Nil {
  let assert Ok(f) = simplifile.read("../input/day08.txt")
  let lines = f |> string.trim |> string.split("\n")

  let vs = {
    use line <- list.map(lines)
    let assert Ok([x, y, z]) =
      string.split(line, ",") |> list.try_map(int.parse)
    Vec3(x, y, z)
  }

  vs
  |> list.combination_pairs
  |> list.sort(fn(p1, p2) {
    let d1 = v3dist(p1.0, p1.1)
    let d2 = v3dist(p2.0, p2.1)
    float.compare(d1, d2)
  })
  |> list.take(1000)
  |> list.fold([], fn(acc, p) { acc |> add_pair(p) })
  |> list.map(set.size)
  |> list.sort(int.compare)
  |> list.reverse
  |> list.take(3)
  |> int.product
  |> echo
  Nil
}

fn find_and_remove(v: Vec3, graphs: List(Set(Vec3))) {
  case graphs {
    [] -> #(Error(""), [])
    [first, ..rest] -> {
      case set.contains(first, v) {
        True -> #(Ok(first), rest)
        False -> {
          let #(found, remaining) = find_and_remove(v, rest)
          #(found, [first, ..remaining])
        }
      }
    }
  }
}

fn add_pair(graphs: List(Set(Vec3)), pair: #(Vec3, Vec3)) {
  let #(p1, p2) = pair
  let #(graph1, rest1) = find_and_remove(p1, graphs)
  let #(graph2, rest2) = find_and_remove(p2, rest1)
  case graph1, graph2 {
    Error(_), Error(_) -> [set.from_list([p1, p2]), ..rest2]
    Ok(c), Error(_) -> [set.insert(c, p2), ..rest2]
    Error(_), Ok(c) -> [set.insert(c, p1), ..rest2]
    Ok(c1), Ok(c2) -> [set.union(c1, c2), ..rest2]
  }
}

fn v3dist(v1, v2) {
  let Vec3(x1, y1, z1) = v1
  let Vec3(x2, y2, z2) = v2

  let dx = x1 - x2
  let dy = y1 - y2
  let dz = z1 - z2
  let d = dx * dx + dy * dy + dz * dz
  let assert Ok(d) = int.square_root(d)
  d
}
