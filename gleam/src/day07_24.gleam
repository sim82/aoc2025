import gleam/function
import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
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
  let assert Ok(res) = res |> list.try_map(int.parse) |> echo

  let assert Ok(operands) =
    operands
    |> list.try_map(fn(line) {
      line |> string.trim |> string.split(" ") |> list.try_map(int.parse)
    })
    |> echo

  let s1 =
    {
      use #(res, operands) <- list.filter_map(list.zip(res, operands))
      let assert [first, ..rest] = operands
      let perms = perm_operators(list.length(rest))
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
      echo operands
      let assert [first, ..rest] = operands
      let perms = perm_operators2(list.length(rest))
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

fn perm_operators(num: Int) -> List(String) {
  case num {
    0 -> []
    1 -> ["+", "*"]
    _ -> {
      let x = perm_operators(num - 1)
      x |> list.map(fn(l) { ["+" <> l, "*" <> l] }) |> list.flatten
    }
  }
}

fn perm_operators2(num: Int) -> List(String) {
  case num {
    0 -> []
    1 -> ["+", "*", "|"]
    _ -> {
      let x = perm_operators2(num - 1)
      x |> list.map(fn(l) { ["+" <> l, "*" <> l, "|" <> l] }) |> list.flatten
    }
  }
}
