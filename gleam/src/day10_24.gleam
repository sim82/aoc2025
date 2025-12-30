import gleam/dict.{type Dict}
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
  let assert Ok(f) = simplifile.read("../input/24_10.txt")
  let f = f |> string.trim

  let fields =
    {
      use line, y <- list.index_map(string.split(f, "\n"))
      use c, x <- list.index_map(string.to_graphemes(string.trim(line)))
      let assert Ok(i) = int.parse(c)
      #(Vec2(x, y), i)
    }
    |> list.flatten
    |> dict.from_list
    |> echo
  let trailheads =
    fields |> dict.filter(fn(_pos, i) { i == 0 }) |> dict.keys |> echo

  trailheads
  |> list.map(collect_reachable(_, fields))
  |> echo
  |> list.map(fn(l) { l |> list.unique |> list.length })
  |> int.sum
  |> echo

  let s1 =
    trailheads
    |> list.map(fn(t) {
      collect_reachable_fold(t, fields, set.new()) |> set.size
    })
    |> int.sum

  s1
  |> echo

  // lol, actually had implemented solution 2 first since I didn't read the instructions properly...
  let s2 = trailheads |> list.map(num_paths(_, fields)) |> int.sum
  s2 |> echo

  Nil
}

fn num_paths(start: Vec2, fields: Dict(Vec2, Int)) -> Int {
  case dict.get(fields, start) {
    Error(_) -> 0
    Ok(9) -> 1
    Ok(i) -> {
      [
        Vec2(start.x - 1, start.y),
        Vec2(start.x + 1, start.y),
        Vec2(start.x, start.y - 1),
        Vec2(start.x, start.y + 1),
      ]
      |> list.filter(fn(n) {
        case dict.get(fields, n) {
          Error(_) -> False
          Ok(j) -> j == i + 1
        }
        // dict.has_key(fields, n) || dict.get(fil)
      })
      |> list.map(num_paths(_, fields))
      |> int.sum
    }
  }
}

fn collect_reachable(start: Vec2, fields: Dict(Vec2, Int)) -> List(Vec2) {
  case dict.get(fields, start) {
    Error(_) -> []
    Ok(9) -> [start]
    Ok(i) -> {
      [
        Vec2(start.x - 1, start.y),
        Vec2(start.x + 1, start.y),
        Vec2(start.x, start.y - 1),
        Vec2(start.x, start.y + 1),
      ]
      |> list.filter(fn(n) {
        case dict.get(fields, n) {
          Error(_) -> False
          Ok(j) -> j == i + 1
        }
      })
      |> list.map(collect_reachable(_, fields))
      |> list.flatten
    }
  }
}

fn collect_reachable_fold(
  start: Vec2,
  fields: Dict(Vec2, Int),
  acc: Set(Vec2),
) -> Set(Vec2) {
  case dict.get(fields, start) {
    Error(_) -> acc
    Ok(9) -> set.insert(acc, start)
    Ok(i) -> {
      let ns = [
        Vec2(start.x - 1, start.y),
        Vec2(start.x + 1, start.y),
        Vec2(start.x, start.y - 1),
        Vec2(start.x, start.y + 1),
      ]
      use acc, n <- list.fold(ns, acc)
      case dict.get(fields, n) {
        Error(_) -> acc
        Ok(j) ->
          case j == i + 1 {
            True -> collect_reachable_fold(n, fields, acc)
            False -> acc
          }
      }
    }
  }
}
