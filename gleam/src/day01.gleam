import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn main() -> Nil {
  let assert Ok(f) = simplifile.read("input/day01.txt")

  let input =
    f
    |> string.split(on: "\n")
    |> list.filter_map(fn(s) {
      case s {
        "R" <> num -> int.parse(num)
        "L" <> num -> int.parse(num) |> result.map(fn(i) { -i })
        _ -> Error(Nil)
      }
    })

  let s1 =
    input
    |> list.scan(50, fn(acc, i) { acc + i })
    |> list.filter(fn(i) { { i % 100 } == 0 })
    |> list.length
  echo s1

  let s2 =
    input
    |> list.flat_map(fn(i) {
      case i >= 0 {
        True -> list.repeat(1, i)
        False -> list.repeat(-1, int.absolute_value(i))
      }
    })
    |> list.scan(50, fn(acc, i) { acc + i })
    |> list.filter(fn(i) { { i % 100 } == 0 })
    |> list.length
  echo s2
  Nil
}
