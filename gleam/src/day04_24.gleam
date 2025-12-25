import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/regexp
import gleam/string
import simplifile

pub fn main() -> Nil {
  let assert Ok(f) = simplifile.read("../input/24_04.txt")

  let lines = f |> string.trim |> string.split("\n")

  let transposed =
    lines
    |> list.map(string.to_graphemes)
    |> list.transpose
    |> list.map(string.concat)

  let diag = to_diag(lines)
  let diag2 = to_diag2(lines)

  let all = [lines, transposed, diag, diag2] |> list.flatten
  // all |> string.join("\n") |> io.println

  // let assert Ok(re) = regexp.from_string("(XMAS)|(SAMX)")
  let assert Ok(re) = regexp.from_string("XMAS")
  let assert Ok(re2) = regexp.from_string("SAMX")
  let s1 =
    {
      use line <- list.map(all)
      { regexp.scan(re, line) |> list.length }
      + { regexp.scan(re2, line) |> list.length }
    }
    |> int.sum
  echo s1

  // let s = ["M.S.A.M.S", "M M A S S"]
  let graphemes = lines |> list.map(string.to_graphemes)
  let s2 =
    graphemes
    |> list.window(3)
    |> list.map(fn(w) {
      let assert [l1, l2, l3] = w
      list.zip(
        list.zip(list.window(l1, 3), list.window(l2, 3)),
        list.window(l3, 3),
      )
      |> list.map(fn(x) {
        let #(#(a, b), c) = x
        string.concat(a) <> string.concat(b) <> string.concat(c)
      })
    })
    |> list.flatten
    |> list.map(fn(x) {
      x |> string.to_graphemes |> list_remove_2nd |> string.concat
    })
    |> list.filter(fn(s) {
      case s {
        "MSAMS" | "SMASM" | "MMASS" | "SSAMM" -> True
        _ -> False
      }
    })
    |> list.length
  echo s2
  Nil
}

fn list_remove_2nd(l) {
  case l {
    [first, _second, ..rest] -> [first, ..list_remove_2nd(rest)]
    [first] -> [first]
    [] -> []
  }
}

fn to_diag(lines: List(String)) {
  let num_lines = list.length(lines)
  lines
  |> list.map(string.to_graphemes)
  |> list.index_map(fn(line, i) {
    list.append(
      list.append(list.repeat(".", i), line),
      list.repeat(".", num_lines - i - 1),
    )
  })
  |> list.transpose
  |> list.map(string.concat)
}

fn to_diag2(lines: List(String)) {
  let num_lines = list.length(lines)
  lines
  |> list.map(string.to_graphemes)
  |> list.index_map(fn(line, i) {
    list.append(
      list.append(list.repeat(".", num_lines - i - 1), line),
      list.repeat(".", i),
    )
  })
  |> list.transpose
  |> list.map(string.concat)
}
