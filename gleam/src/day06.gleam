import gleam/function
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn main() -> Nil {
  let assert Ok(f) = simplifile.read("input/day06.txt")
  let lines = f |> string.trim |> string.split("\n")

  let assert [ops, ..nums] = lines |> list.reverse
  {
    let ops = ops |> split_space
    let num_cols =
      {
        use line <- list.map(nums)
        use num <- list.map(split_space(line))
        let assert Ok(i) = num |> int.parse
        i
      }
      |> list.transpose

    let s1 =
      {
        use #(op, nums) <- list.map(list.zip(ops, num_cols))
        case op {
          "+" -> nums |> int.sum
          _ -> nums |> int.product
        }
      }
      |> int.sum
    echo s1
  }

  let hblocks =
    ops
    |> string.to_graphemes
    |> list.index_map(fn(c, i) {
      case c {
        " " -> Error("")
        _ -> Ok(i)
      }
    })
    |> list.filter_map(function.identity)
    |> list.append([string.length(ops) + 1])
    |> list.window_by_2
  // |> echo

  let blocks =
    {
      use line <- list.map(nums)
      use #(start, end) <- list.map(hblocks)
      let len = end - start
      line |> string.slice(start, len)
    }
    |> list.transpose
  // |> echo

  let ops = ops |> split_space
  let s2 =
    {
      use #(op, nums) <- list.map(list.zip(ops, blocks))

      let nums =
        nums
        |> list.map(string.to_graphemes)
        |> list.reverse
        |> list.transpose
        |> list.map(string.concat)
        |> list.filter_map(fn(num) { string.trim(num) |> int.parse })

      case op {
        "+" -> nums |> int.sum
        _ -> nums |> int.product
      }
    }
    |> int.sum

  echo s2
  Nil
}

fn split_space(s) {
  s |> string.split(" ") |> list.filter(fn(s) { !string.is_empty(s) })
}
