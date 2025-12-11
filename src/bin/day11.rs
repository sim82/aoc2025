use nalgebra::{DMatrix, DVector};
use pathfinding::directed::count_paths::count_paths;
use std::collections::{HashMap, HashSet};

type Result<T> = anyhow::Result<T>;
fn main() -> Result<()> {
    let s = std::fs::read_to_string("input/day11.txt")?;

    let adj = s
        .lines()
        .map(|line| {
            let (head, tail) = line.split_once(':').unwrap();
            let succ = tail.split_whitespace().collect::<Vec<_>>();
            (head, succ)
        })
        .collect::<HashMap<_, _>>();

    println!("adj: {adj:?}");

    let res = count_paths(
        "you",
        |state| adj.get(state).unwrap().clone(),
        |state| *state == "out",
    );
    println!("res: {res}");

    // adj.insert("out", Vec::new());
    let s2f = count_paths(
        "svr",
        |state| {
            if *state == "out" {
                Vec::new()
            } else {
                adj.get(state).unwrap().clone()
            }
        },
        |state| *state == "fft",
    );
    let f2d = count_paths(
        "fft",
        |state| {
            if *state == "out" {
                Vec::new()
            } else {
                adj.get(state).unwrap().clone()
            }
        },
        |state| *state == "dac",
    );
    let d2f = count_paths(
        "dac",
        // |state| adj.get(state).unwrap().clone(),
        |state| {
            if *state == "out" {
                Vec::new()
            } else {
                adj.get(state).unwrap().clone()
            }
        },
        |state| *state == "fft",
    );

    let d2o = count_paths(
        "dac",
        // |state| adj.get(state).unwrap().clone(),
        |state| adj.get(state).unwrap().clone(),
        |state| *state == "out",
    );

    println!("s2f: {s2f} f2d: {f2d}, d2o: {d2o}");
    let res = s2f * f2d * d2o;
    println!("res: {res}");
    Ok(())
}
