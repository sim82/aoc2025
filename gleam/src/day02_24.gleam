import gleam/dict.{type Dict}
import gleam/float
import gleam/function
import gleam/int
import gleam/list
import gleam/option
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

pub fn main() -> Nil {
  let assert Ok(f) = simplifile.read("../input/24_02.txt")
  let assert Ok(reports) =
    f
    |> string.trim
    |> string.split("\n")
    |> list.map(string.split(_, " "))
    |> list.try_map(fn(report) { report |> list.try_map(int.parse) })

  let s1 =
    reports
    |> list.map(report_diff)
    |> list.filter(report_valid)
    |> list.length
  echo s1

  let s2 =
    reports
    |> list.filter(fn(report) {
      report_valid(report_diff(report))
      || remove_one(report) |> list.map(report_diff) |> list.any(report_valid)
    })
    |> list.length
  echo s2
  Nil
}

fn report_diff(report: List(Int)) {
  use #(n1, n2) <- list.map(list.window_by_2(report))
  n2 - n1
}

fn remove_one(list) {
  case list {
    [] -> []
    [_] -> [[]]
    [head, ..tail] -> {
      let rest = remove_one(tail)
      let rest = rest |> list.map(list.prepend(_, head))
      [tail, ..rest]
    }
  }
}

fn report_valid(report: List(Int)) {
  report
  |> list.map(int.absolute_value)
  |> list.all(fn(x) { x >= 1 && x <= 3 })
  && report
  |> list.map(fn(x) { x > 0 })
  |> list.unique
  |> list.length
  == 1
}
