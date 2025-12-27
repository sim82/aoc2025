import gleam/int
import gleam/list
import gleam/string
import simplifile

pub fn main() -> Nil {
  let assert Ok(f) = simplifile.read("../input/24_07.txt")
  let assert Ok(s) =
    f
    |> string.trim
    |> string.split("\n")
    |> list.try_map(string.split_once(_, ":"))
  let #(res, operands) = s |> list.unzip
  let assert Ok(res) = res |> list.try_map(int.parse)
  let assert Ok(operands) =
    operands
    |> list.try_map(fn(line) {
      line |> string.trim |> string.split(" ") |> list.try_map(int.parse)
    })

  variations(["a", "b", "c"], 4) |> echo
  let s1 =
    {
      use #(res, operands) <- list.filter_map(list.zip(res, operands))
      let assert [first, ..rest] = operands
      let perms = perms(["+", "*"], list.length(rest))
      case
        perms
        |> list.any(fn(perm) {
          res
          == list.fold(
            list.zip(perm |> string.to_graphemes, rest),
            first,
            fn(acc, p) {
              let #(operator, operand) = p
              case operator {
                "+" -> acc + operand
                "*" -> acc * operand
                _ -> panic
              }
            },
          )
        })
      {
        True -> Ok(res)
        False -> Error("")
      }
    }
    |> int.sum
  echo s1

  let s2 =
    {
      use #(res, operands) <- list.filter_map(list.zip(res, operands))
      // echo operands
      let assert [first, ..rest] = operands
      let perms = perms(["+", "*", "|"], list.length(rest))
      case
        perms
        |> list.any(fn(perm) {
          res
          == list.fold(
            list.zip(perm |> string.to_graphemes, rest),
            first,
            fn(acc, p) {
              let #(operator, operand) = p
              case operator {
                "+" -> acc + operand
                "*" -> acc * operand
                "|" -> {
                  let assert Ok(x) =
                    int.parse(int.to_string(acc) <> int.to_string(operand))
                  x
                }
                _ -> panic
              }
            },
          )
        })
      {
        True -> Ok(res)
        False -> Error("")
      }
    }
    |> int.sum
  echo s2

  Nil
}

// AI suggestion...
pub fn variations(chars: List(String), length: Int) -> List(String) {
  case length {
    0 -> []
    1 -> chars
    _ -> {
      list.range(1, length - 1)
      |> list.fold(from: chars, with: fn(acc, _) {
        list.flat_map(acc, fn(stem) {
          list.map(chars, fn(char) { stem <> char })
        })
      })
    }
  }
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
