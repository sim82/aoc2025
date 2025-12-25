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

type Vec3 {
  Vec3(x: Int, y: Int, z: Int)
}

pub fn main() -> Nil {
  let assert Ok(f) = simplifile.read("../input/24_01.txt")

  let #(list1, list2) =
    f
    |> string.trim
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert [n1, n2] =
        line
        |> string.split(" ")
        |> list.map(string.trim)
        |> list.filter(fn(s) { !string.is_empty(s) })
      let assert Ok(n1) = int.parse(n1)
      let assert Ok(n2) = int.parse(n2)
      #(n1, n2)
    })
    |> list.unzip()

  let s1 =
    {
      use #(n1, n2) <- list.map(list.zip(
        list.sort(list1, int.compare),
        list.sort(list2, int.compare),
      ))
      int.absolute_value(n1 - n2)
    }
    |> int.sum
  echo s1

  let freq =
    list2
    |> list.group(function.identity)
    |> dict.map_values(fn(_, v) { list.length(v) })

  let s2 =
    list1
    |> list.map(fn(i) { { dict.get(freq, i) |> result.unwrap(0) } * i })
    |> int.sum

  echo s2
  Nil
}
