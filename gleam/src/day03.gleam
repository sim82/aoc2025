import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn main() -> Nil {
  let assert Ok(f) = simplifile.read("input/day03.txt")

  let input =
    f
    |> string.trim
    |> string.split(on: "\n")
    |> list.map(fn(s) {
      string.to_graphemes(s)
      |> list.map(fn(c) {
        int.parse(c)
        |> result.unwrap(0)
      })
    })

  let s1 =
    input
    |> list.map(fn(l) {
      let assert [head, ..rest] = l

      let stop_at = list.length(rest) - 1
      let #(first, ifirst) =
        rest
        |> list.index_fold(#(head, 0), fn(acc, c, i) {
          let #(best, ibest) = acc
          case i < stop_at && c > best {
            True -> #(c, i + 1)
            False -> #(best, ibest)
          }
        })

      // echo ifirst
      let second =
        rest
        |> list.drop(ifirst)
        |> list.max(int.compare)
        |> result.unwrap(0)

      // echo #(first, second)
      first * 10 + second
    })
    |> list.fold(0, fn(i, acc) { i + acc })

  echo s1

  let s2 =
    input
    |> list.map(fn(l) {
      list.range(12, 1)
      |> list.scan(#(l, 0), fn(acc, end) {
        let #(l, _) = acc
        let end = list.length(l) - end
        let assert [head, ..rest] = l
        let #(best, ibest) =
          rest
          |> list.index_fold(#(head, 0), fn(acc, c, i) {
            let #(best, ibest) = acc
            case i < end && c > best {
              True -> #(c, i + 1)
              False -> #(best, ibest)
            }
          })
        #(rest |> list.drop(ibest), best)
      })
      |> list.map(fn(x) {
        let #(_, best) = x
        best
      })
      |> list.fold(0, fn(acc, i) { acc * 10 + i })
    })
    |> list.fold(0, fn(i, acc) { i + acc })
  echo s2
  Nil
}
