import gleam/int
import gleam/list
import gleam/option
import gleam/regexp
import simplifile

pub fn main() -> Nil {
  let assert Ok(f) = simplifile.read("../input/24_03.txt")

  let assert Ok(re) = regexp.from_string("mul\\((\\d+),(\\d+)\\)")
  let s1 =
    {
      use match <- list.map(regexp.scan(re, f))
      let assert Ok(l) =
        match.submatches |> list.try_map(option.to_result(_, ""))
      let assert Ok([a, b]) = l |> list.try_map(int.parse)
      a * b
    }
    |> int.sum
  echo s1

  let assert Ok(re) =
    regexp.from_string("(mul|don\\'t|do)\\(((\\d+),(\\d+))?\\)")

  let s2 =
    {
      use match <- list.map(regexp.scan(re, f))
      // let matches = match.submatches |> list.try_map(fn(m) {option.to_result})
      //
      let assert Ok(matches) =
        match.submatches |> list.try_map(option.to_result(_, ""))
      matches
    }
    |> list.fold(#(True, 0), fn(acc, cmd) {
      case cmd, acc {
        ["mul", _, a, b], #(True, acc) -> {
          let assert #(Ok(a), Ok(b)) = #(int.parse(a), int.parse(b))
          #(True, acc + { a * b })
        }
        ["do"], #(_, acc) -> #(True, acc)
        ["don't"], #(_, acc) -> #(False, acc)
        _, acc -> acc
      }
    })
  echo s2.1
  Nil
}
