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

  f
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert [n1, n2] = line.split(" ") |> list.map(string.trim)
    #(n1, n2)
  })
  |> echo

  Nil
}
