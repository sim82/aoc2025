import gleam/dict
import gleam/function
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/set
import gleam/string
import simplifile

pub fn main() -> Nil {
  let assert Ok(f) = simplifile.read("../input/day07.txt")
  let lines = f |> string.trim |> string.split("\n")

  let assert [start, ..splitters] = lines

  {
    let beams =
      start
      |> non_empty
      |> echo
      |> set.from_list

    let splitters =
      {
        use line <- list.map(splitters)
        line
        |> non_empty
        |> set.from_list
      }
      |> list.filter(fn(line) { !set.is_empty(line) })
    // |> echo

    let #(_, s1) = {
      use #(beams, num), splitters <- list.fold(
        from: #(beams, 0),
        over: splitters,
      )

      let hits = set.intersection(beams, splitters)

      let new = {
        use acc, hit <- set.fold(
          from: set.difference(beams, splitters),
          over: hits,
        )

        acc
        |> set.insert(hit - 1)
        |> set.insert(hit + 1)
      }

      #(new, num + set.size(hits))
    }

    echo s1
  }
  // let num_columns = string.length(start)

  let beam_count =
    {
      use c, i <- list.index_map(string.to_graphemes(start))

      case c {
        "." -> #(i, 0)
        _ -> #(i, 1)
      }
    }
    |> dict.from_list
  // |> echo
  let splitters =
    splitters
    |> list.map(fn(line) {
      line
      |> string.to_graphemes
      |> list.index_map(fn(c, i) { #(i, c) })
      |> dict.from_list
    })

  let s2 =
    splitters
    |> list.fold(beam_count, fn(acc, splitters) {
      use new_acc, i, count <- dict.fold(acc, dict.new())
      case dict.get(splitters, i) {
        Ok("^") ->
          new_acc
          |> dict.upsert(i - 1, fn(x) { option.unwrap(x, 0) + count })
          |> dict.upsert(i + 1, fn(x) { option.unwrap(x, 0) + count })
        _ -> new_acc |> dict.upsert(i, fn(x) { option.unwrap(x, 0) + count })
      }
    })
    |> dict.values
    |> int.sum

  s2
  |> echo

  // splitters
  // |> list.fold(beam_count, fn(splitters) { todo })
  // splitters
  // |> list.fold(beam_count, fn(beam_count, splitters) {
  //   let new_count =
  //     list.zip(beam_count, string.to_graphemes(splitters))
  //     |> list.window(by: 3)
  //     // |> echo
  //     |> list.map(fn(c) {
  //       let assert [#(count_l, _), #(count_c, splitter), #(count_r, _)] = c
  //       case splitter {
  //         "^" -> [count_l + count_c, 0, count_r + count_c]
  //         _ -> [0, count_c, 0]
  //       }
  //     })
  //   // |> echo

  //   let assert [head, ..rest] = new_count

  //   let x =
  //     rest
  //     |> list.fold(list.reverse(head), fn(acc, triple) {
  //       let assert [r, c, l] = list.reverse(triple)
  //       let assert [lr, lc, ..rest] = acc
  //       [r, c + lr, l + lc, ..rest]
  //     })
  //   x |> echo

  //   x
  // })
  // |> int.sum
  // |> echo
  // |> echo

  // start |> string.to_graphemes |> 
  Nil
}

fn non_empty(s) {
  s
  |> string.to_graphemes
  |> list.index_map(fn(c, i) {
    case c {
      "." -> Error("")
      _ -> Ok(i)
    }
  })
  |> list.filter_map(function.identity)
}
