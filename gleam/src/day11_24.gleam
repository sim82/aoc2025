import gleam/int
import gleam/list
import gleam/order
import gleam/string
import rememo/memo
import simplifile

pub fn main() -> Nil {
  // let assert Ok(f) = simplifile.read("../input/24_09_ex.txt")
  let assert Ok(f) = simplifile.read("../input/24_11.txt")
  // let f = "125 17"
  let assert Ok(stones) =
    f |> string.trim |> string.split(" ") |> list.try_map(int.parse) |> echo

  let s1 =
    list.range(1, 25)
    |> list.fold(stones, fn(acc, i) {
      echo i
      acc |> list_evolve
    })
    |> list.length

  s1
  |> echo

  stones |> list.map(count_steps(_, 25)) |> int.sum |> echo
  let s2 = {
    use cache <- memo.create()
    stones |> list.map(count_steps_memo(_, 75, cache)) |> int.sum
  }
  echo s2
  // stones |> list.map(fn(s) { count_steps(s, 75) |> echo }) |> int.sum |> echo
  Nil
}

fn list_evolve(list: List(Int)) -> List(Int) {
  case list {
    [] -> []
    [head, ..tail] -> {
      case head {
        0 -> [1, ..list_evolve(tail)]

        _ -> {
          let is = int.to_string(head)

          case int.is_even(string.length(is)) {
            True -> {
              list.append(split(is), list_evolve(tail))
            }
            False -> [head * 2024, ..list_evolve(tail)]
          }
        }
      }
    }
  }
}

fn split(stone: String) -> List(Int) {
  let len2 = string.length(stone) / 2
  let assert Ok(i1) = string.slice(stone, 0, len2) |> int.parse
  let assert Ok(i2) = string.slice(stone, len2, len2) |> int.parse
  [i1, i2]
}

fn count_steps(i: Int, s: Int) -> Int {
  case s {
    0 -> 1
    _ -> {
      case i {
        0 -> count_steps(1, s - 1)
        _ -> {
          let is = int.to_string(i)
          let len = string.length(is)
          case int.is_even(len) {
            True -> {
              let len2 = len / 2
              let assert Ok(i1) = string.slice(is, 0, len2) |> int.parse
              let assert Ok(i2) = string.slice(is, len2, len2) |> int.parse
              count_steps(i1, s - 1) + count_steps(i2, s - 1)
            }
            False -> count_steps(i * 2024, s - 1)
          }
        }
      }
    }
  }
}

fn count_steps_memo(i: Int, s: Int, cache) -> Int {
  use <- memo.memoize(cache, #(i, s))
  case s {
    0 -> 1
    _ -> {
      case i {
        0 -> count_steps_memo(1, s - 1, cache)
        _ -> {
          let is = int.to_string(i)
          let len = string.length(is)
          case int.is_even(len) {
            True -> {
              let len2 = len / 2
              let assert Ok(i1) = string.slice(is, 0, len2) |> int.parse
              let assert Ok(i2) = string.slice(is, len2, len2) |> int.parse
              count_steps_memo(i1, s - 1, cache)
              + count_steps_memo(i2, s - 1, cache)
            }
            False -> count_steps_memo(i * 2024, s - 1, cache)
          }
        }
      }
    }
  }
}
