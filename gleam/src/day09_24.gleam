import gleam/dict
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

pub fn main() -> Nil {
  let assert Ok(f) = simplifile.read("../input/24_09.txt")

  let blocks =
    f
    |> string.trim
    |> string.to_graphemes
    |> list.index_map(fn(c, i) {
      let assert Ok(len) = int.parse(c)
      let block_num = i / 2
      case i % 2 == 0 {
        True -> {
          list.repeat(block_num, len)
        }
        False -> {
          list.repeat(-1, len)
        }
      }
    })
    |> list.flatten

  let num_empty = blocks |> list.count(fn(b) { b == -1 }) |> echo

  // 'src blocks' non-empty block from the that will be filled into empty spots
  let src =
    blocks
    |> list.reverse
    |> list.fold_until(#(num_empty, []), fn(acc, b) {
      let #(num_empty, src) = acc
      case list.length(src) >= num_empty {
        True -> list.Stop(acc)
        False -> {
          list.Continue(case b {
            -1 -> #(num_empty - 1, src)
            _ -> {
              #(num_empty, [b, ..src])
            }
          })
        }
      }
    })

  let #(_, res) =
    list.map_fold(blocks, #(src.1 |> list.reverse, 0), fn(acc, i) {
      case acc {
        #([head, ..tail], l) -> {
          case i {
            // while we still have src blocks left, fill them in on empty spots
            -1 -> {
              #(#(tail, l + 1), head)
            }
            // just take over filled blocks
            _ -> #(#([head, ..tail], l + 1), i)
          }
        }
        #(src, l) -> {
          // no src blocks left -> copy input up to the first block that was put into src list. Fill up the rest
          // with empty blocks.
          case l < list.length(blocks) - num_empty {
            True -> #(#(src, l + 1), i)
            False -> #(#(src, l + 1), -1)
          }
        }
      }
    })

  // res
  // |> debug_str
  // |> echo

  let s1 = res |> list.index_fold(0, fn(acc, c, i) { acc + i * int.max(c, 0) })
  echo s1
  Nil
}

fn debug_str(l) {
  l
  |> list.map(fn(i) {
    case i {
      -1 -> "."
      _ -> int.to_string(i)
    }
  })
  |> string.concat
}
