import gleam/int
import gleam/io
import gleam/string
import simplifile

pub fn main() -> Nil {
  let a = 2

  io.println("Hello from test_gleam!" |> string.drop_start(1))
  // call(a)
}

fn call(a) {
  io.println("a: " <> int.to_string(a))
  call(square(a))
}

fn square(a: Int) -> Int {
  2 * a
}
