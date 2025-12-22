import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn main() -> Nil {
  let assert Ok(f) = simplifile.read("input/day02.txt")

  let input =
    f
    |> string.trim
    |> string.split(on: ",")
    |> list.filter_map(fn(r) {
      string.split_once(r, on: "-")
      |> result.map(fn(x) {
        let #(a, b) = x
        #(int.parse(a) |> result.unwrap(0), int.parse(b) |> result.unwrap(0))
      })
    })
    |> list.flat_map(fn(r) {
      let #(start, end) = r
      list.range(start, end)
    })
    |> list.map(int.to_string)

  let s1 =
    input
    |> list.filter(fn(s) { string.length(s) % 2 == 0 })
    |> list.filter(fn(s) {
      let l = string.length(s) / 2
      string.starts_with(s, string.drop_start(s, l))
    })
    |> list.fold(0, fn(acc, s) { acc + { int.parse(s) |> result.unwrap(0) } })

  echo s1
  let s2 =
    input
    |> list.filter(fn(s) {
      let l = string.length(s)
      l > 1
      && {
        let l2 = string.length(s) / 2
        list.range(1, l2)
        |> list.any(fn(i) {
          let r = {
            s |> string.slice(0, i) |> string.repeat(l / i)
          }
          r == s
        })
      }
    })
    |> list.fold(0, fn(acc, s) { acc + { int.parse(s) |> result.unwrap(0) } })

  echo s2
  Nil
}
