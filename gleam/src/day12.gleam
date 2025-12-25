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
  let assert Ok(f) = simplifile.read("../input/day12.txt")

  let blocks = f |> string.trim |> string.split("\n\n") |> list.reverse

  let assert [last_block, ..packages] = blocks

  // let package_sizes = {
  //   use block <- list.map(packages)
  //   use block <- string.to_graphemes
  //   todo
  // }
  let package_sizes =
    packages
    |> list.reverse
    // |> list.map(fn(block) { string.split(block, "\n") })
    |> list.index_map(fn(block, i) {
      #(i, block |> string.to_graphemes |> list.count(fn(s) { s == "#" }))
    })
    |> dict.from_list
  // |> echo

  let spaces =
    last_block
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert Ok(#(size, reqs)) = line |> string.split_once(":")
      let assert Ok(req) =
        reqs
        |> string.trim
        |> string.split(" ")
        |> list.try_map(int.parse)
      // |> result.map(int.sum)

      let assert Ok([x, y]) =
        size |> string.split("x") |> list.try_map(int.parse)
      #(x * y, req)
    })

  let s1 = spaces |> list.filter(check_space(_, package_sizes)) |> list.length
  echo s1

  // |> echo
  Nil
}

fn check_space(space: #(Int, List(Int)), sizes: Dict(Int, Int)) {
  let #(size, reqs) = space

  let req_size =
    reqs
    |> list.index_map(fn(req, i) {
      let assert Ok(size) = dict.get(sizes, i)
      size * req
    })
    |> int.sum

  size >= req_size
}
