import gleam/int
import gleam/list
import gleam/order
import gleam/string
import simplifile

pub fn main() -> Nil {
  // let assert Ok(f) = simplifile.read("../input/24_09_ex.txt")
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

  let s1 = checksum(res)
  echo s1

  // echo blocks
  let extents =
    blocks
    |> list.fold([], fn(acc, b) {
      case acc {
        [] -> [#(1, b)]
        [#(len, head), ..tail] -> {
          case head == b {
            True -> [#(len + 1, head), ..tail]
            False -> [#(1, b), #(len, head), ..tail]
          }
        }
      }
    })
    |> list.reverse

  // echo extents
  let full_extents_rev =
    extents |> list.reverse |> list.filter(fn(e) { e.1 != -1 })
  // echo full_extents_rev

  // let extents_opt = fill_extents(extents, full_extents_rev)
  let extents_opt = stuff_extents(extents, full_extents_rev)
  // echo debug_str(blocks)
  // echo extents_opt
  // echo debug_str(to_blocks(extents_opt))
  let s2 = checksum(to_blocks(extents_opt))
  echo s2
  Nil
}

fn to_blocks(extents: List(#(Int, Int))) -> List(Int) {
  case extents {
    [] -> []
    [head, ..tail] -> list.append(list.repeat(head.1, head.0), to_blocks(tail))
  }
}

// try to stuff one extent list into empty extents of another list
fn stuff_extents(extents: List(#(Int, Int)), full: List(#(Int, Int))) {
  case full {
    [] -> extents
    [head, ..tail] -> stuff_extents(stuff_extent(extents, head), tail)
  }
}

// try to stuff extent to_stuff into empty extent (before itself)
fn stuff_extent(
  extents: List(#(Int, Int)),
  to_stuff: #(Int, Int),
) -> List(#(Int, Int)) {
  case extents {
    [] -> []
    [head, ..tail] -> {
      case head.1, int.compare(head.0, to_stuff.0) {
        // case 1: found empty extent to stuff it into. Recursively remove extent from tail
        -1, order.Eq -> [to_stuff, ..remove_extent(tail, to_stuff.1)]
        -1, order.Gt -> [
          to_stuff,
          #(head.0 - to_stuff.0, -1),
          ..remove_extent(tail, to_stuff.1)
        ]
        // case 2: extent not empty or too small
        c, _ -> {
          case c == to_stuff.1 {
            // it the 'stuffed' extent meets 'itself' in the extent list,
            // stop recursion, since this would mean moving it _backwards_
            True -> [head, ..tail]
            // otherwise continue stuffing...
            False -> [head, ..stuff_extent(tail, to_stuff)]
          }
        }
      }
    }
  }
}

fn remove_extent(
  extents: List(#(Int, Int)),
  to_remove: Int,
) -> List(#(Int, Int)) {
  case extents {
    [] -> []
    [head, ..tail] -> {
      case head.1 == to_remove {
        True -> {
          [#(head.0, -1), ..tail]
        }
        False -> [head, ..remove_extent(tail, to_remove)]
      }
    }
  }
}

// fn remove_extent(extents, _) {
//   extents
// }

// fn remove_duplicates(
//   extents: List(#(Int, Int)),
//   acc: Set(Int),
// ) -> List(#(Int, Int)) {
//   case extents {
//     [] -> []
//     [head, ..tail] -> {
//       case set.contains(acc, head.1) {
//         True -> [
//           #(head.0, -1),
//           ..remove_duplicates(tail, set.insert(acc, head.1))
//         ]
//         False -> [head, ..remove_duplicates(tail, set.insert(acc, head.1))]
//       }
//     }
//   }
// }

fn checksum(res: List(Int)) -> Int {
  let s1 = res |> list.index_fold(0, fn(acc, c, i) { acc + i * int.max(c, 0) })
  s1
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
