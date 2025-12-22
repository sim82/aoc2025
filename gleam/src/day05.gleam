import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

type Range {
  Inc(start: Int, end: Int)
}

pub fn main() -> Nil {
  let assert Ok(f) = simplifile.read("input/day05.txt")

  let assert Ok(#(ranges, ingredients)) = string.split_once(f, on: "\n\n")
  let ranges =
    ranges
    |> string.trim
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert Ok(#(start, end)) = string.split_once(line, on: "-")
      Inc(
        start |> int.parse() |> result.unwrap(0),
        end |> int.parse() |> result.unwrap(0),
      )
    })

  let ingredients =
    ingredients
    |> string.trim
    |> string.split("\n")
    |> list.map(int.parse)
    |> list.map(fn(i) { i |> result.unwrap(0) })

  let s1 =
    ingredients
    |> list.count(fn(i) {
      ranges
      |> list.any(fn(r) { r |> range_contains(i) })
    })
  echo s1

  let sorted_ranges =
    ranges |> list.sort(fn(r1, r2) { int.compare(r1.start, r2.start) })

  let assert [first, ..rest] = sorted_ranges

  let s2 =
    rest
    |> list.fold([first], fn(acc, next) {
      let assert [current, ..others] = acc
      case range_overlap(current, next) {
        Ok(combined) -> [combined, ..others]
        Error(_) -> [next, ..acc]
      }
    })
    |> list.fold(0, fn(acc, range) { acc + range_size(range) })
  echo s2
  Nil
}

fn range_contains(range: Range, i: Int) {
  range.start <= i && range.end >= i
}

fn range_size(range: Range) {
  range.end - range.start + 1
}

fn range_overlap(range1: Range, range2: Range) {
  case range1.end < range2.start || range2.end < range1.start {
    True -> Error("")
    False ->
      Ok(Inc(
        int.min(range1.start, range2.start),
        int.max(range1.end, range2.end),
      ))
  }
}
