import gleam/dict.{type Dict}
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/order
import gleam/regexp
import gleam/set.{type Set}
import gleam/string
import simplifile

type Vec2 {
  Vec2(x: Int, y: Int)
}

pub fn main() -> Nil {
  let assert Ok(f) = simplifile.read("../input/24_14.txt")

  let assert Ok(re) =
    regexp.compile(
      "^p=(\\d+),(\\d+) v=(-?\\d+),(-?\\d+)$",
      regexp.Options(case_insensitive: False, multi_line: True),
    )
  let f =
    f
    |> regexp.scan(re, _)
    |> list.map(fn(match) {
      let assert Ok([px, py, vx, vy]) =
        match.submatches |> option.values |> list.try_map(int.parse)
      #(Vec2(px, py), Vec2(vx, vy))
    })
    |> echo

  let s1 =
    f
    |> list.map(apply_steps(_, 100))
    |> echo
    |> list.map(fn(p) {
      let x = case p.x < 0 {
        True -> w + p.x
        False -> p.x
      }
      let y = case p.y < 0 {
        True -> h + p.y
        False -> p.y
      }
      Vec2(x, y)
    })
    |> echo
    |> list.map(to_quadrant)
    |> list.filter(fn(q) { q != 0 })
    |> list.group(function.identity)
    |> dict.values
    |> list.map(list.length)
    |> echo
    |> int.product

  echo s1
  search_tree(f, 10_000)
  //  string.split("\n") |> list.map(fn(line) {
  //   let Ok(match) = regexp.(re, line)
  // })

  Nil
}

fn search_tree(f, n: Int) {
  case n {
    0 -> Nil
    _ -> {
      let p =
        f
        |> list.map(apply_steps(_, 1))
        |> list.map(fn(p) {
          let x = case p.x < 0 {
            True -> w + p.x
            False -> p.x
          }
          let y = case p.y < 0 {
            True -> h + p.y
            False -> p.y
          }
          Vec2(x, y)
        })

      case list.length(p) == set.size(set.from_list(p)) {
        True -> {
          echo 10_000 - n + 1
          Nil
        }
        False -> Nil
      }
      // { 10_000 - n } |> int.to_string |> io.println
      // draw(p |> set.from_list)
      search_tree(
        list.zip(f, p)
          |> list.map(fn(x) {
            let #(f, p) = x
            #(p, f.1)
          }),
        n - 1,
      )
    }
  }
}

const w = 101

const h = 103

fn apply_steps(p: #(Vec2, Vec2), n) {
  let #(p, v) = p
  Vec2({ p.x + v.x * n } % w, { p.y + v.y * n } % h)
}

fn to_quadrant(p: Vec2) -> Int {
  case int.compare(p.x, { w / 2 } + 0), int.compare(p.y, { h / 2 } + 0) {
    order.Lt, order.Lt -> 1
    order.Gt, order.Lt -> 2
    order.Lt, order.Gt -> 3
    order.Gt, order.Gt -> 4
    _, _ -> 0
  }
}

fn draw(s: Set(Vec2)) {
  list.range(0, h - 1)
  |> list.map(fn(y) {
    list.range(0, w - 1)
    |> list.map(fn(x) {
      case set.contains(s, Vec2(x, y)) {
        True -> "X"
        False -> "."
      }
    })
    |> string.concat
    |> io.println
  })
}
