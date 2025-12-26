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
  let assert Ok(f) = simplifile.read("../input/24_06.txt")
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

  let blocks =
    fields
    |> list.filter_map(fn(t) {
      case t {
        #(x, y, "#") -> Ok(#(x, y))
        _ -> Error("")
      }
    })
    |> set.from_list
    |> echo

  let assert [guard_start] =
    fields
    |> list.filter_map(fn(t) {
      case t {
        #(x, y, "^") -> Ok(#(x, y))
        _ -> Error("")
      }
    })
    |> echo

  let bounds = #(w, h)
  let trace = run_while_in_bounds(Guard(guard_start, Up), [], blocks, bounds)

  let s1 =
    trace
    |> list.map(fn(guard) { guard.pos })
    |> list.unique
    |> list.length

  echo list.length(trace)

  echo s1

  let s2 =
    trace
    |> list.filter_map(fn(guard) {
      case guard.pos == guard_start {
        True -> Error("")
        False -> {
          let blocks = set.insert(blocks, guard.pos)
          case
            run_until_cycle(Guard(guard_start, Up), set.new(), blocks, bounds)
          {
            True -> Ok(guard.pos)
            False -> Error("")
          }
        }
      }
    })
    |> list.unique
    |> list.length

  echo s2
  Nil
}

fn run_while_in_bounds(
  guard: Guard,
  acc: List(Guard),
  blocks: Set(#(Int, Int)),
  bounds: #(Int, Int),
) -> List(Guard) {
  case in_bounds(guard.pos, bounds) {
    False -> acc
    True ->
      run_while_in_bounds(step(guard, blocks), [guard, ..acc], blocks, bounds)
  }
}

fn run_until_cycle(
  guard: Guard,
  acc: Set(Guard),
  blocks: Set(#(Int, Int)),
  bounds: #(Int, Int),
) {
  case in_bounds(guard.pos, bounds) {
    False -> False
    True ->
      case set.contains(acc, guard) {
        True -> {
          // echo acc
          True
        }
        False ->
          run_until_cycle(
            step(guard, blocks),
            set.insert(acc, guard),
            // [guard, ..acc],
            blocks,
            bounds,
          )
      }
  }
}

fn in_bounds(guard: #(Int, Int), bounds: #(Int, Int)) -> Bool {
  let #(x, y) = guard
  let #(w, h) = bounds
  x >= 0 && x < w && y >= 0 && y < h
}

fn next_pos(guard: Guard) -> #(Int, Int) {
  let #(x, y) = guard.pos
  let new_pos = case guard.dir {
    Up -> #(x, y - 1)
    Down -> #(x, y + 1)
    Right -> #(x + 1, y)
    Left -> #(x - 1, y)
  }
  new_pos
}

fn rot(dir: Dir) -> Dir {
  case dir {
    Up -> Right
    Right -> Down
    Down -> Left
    Left -> Up
  }
}

fn step(guard: Guard, blocks: Set(#(Int, Int))) -> Guard {
  let next = next_pos(guard)
  case set.contains(blocks, next) {
    True -> Guard(guard.pos, rot(guard.dir))
    False -> Guard(next, guard.dir)
  }
}
