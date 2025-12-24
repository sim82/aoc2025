import gleam/dict
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
  let assert Ok(f) = simplifile.read("../input/day12.txt")

  let assert Ok(last_block) =
    f |> string.trim |> string.split("\n\n") |> list.last
  let sizes =
    last_block
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert Ok(#(size, reqs)) = line |> string.split_once(":")
      let assert Ok(req) =
        reqs
        |> string.trim
        |> string.split(" ")
        |> list.try_map(int.parse)
        |> echo
        |> result.map(int.sum)

      let assert Ok([x, y]) =
        line |> string.split("x") |> list.try_map(int.parse)
      #(x * y, req)
    })
    |> echo
  Nil
}
