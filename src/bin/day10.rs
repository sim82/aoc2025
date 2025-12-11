use std::iter::Sum;

use good_lp::{Expression, Solution, SolverModel, constraint, variable, variables};
use pathfinding::directed::dijkstra::dijkstra;

type Result<T> = anyhow::Result<T>;

// type Vec3 = nalgebra::Vector3<f32>;

#[derive(Debug)]
struct Machine {
    lights: u32,
    transitions: Vec<u32>,
    transitions2: Vec<Vec<usize>>,
    reqs: Vec<u32>,
}

impl Machine {
    fn read(input: &[&str]) -> Machine {
        let lightsc = input
            .iter()
            .find(|s| s.starts_with('['))
            .unwrap()
            .trim_matches(|x| x == '[' || x == ']')
            .chars();

        let num_lights = lightsc.clone().count();

        let lights = lightsc.fold(0, |acc, c| (acc << 1) | if c == '#' { 1 } else { 0 });

        let transitions = input
            .iter()
            .filter_map(|s| {
                if s.starts_with('(') {
                    Some(s.trim_matches(|c| c == ')' || c == '('))
                } else {
                    None
                }
            })
            .map(|l| {
                l.split(',')
                    .map(|i| 1 << (num_lights - i.parse::<usize>().unwrap() - 1))
                    .sum::<u32>()
            })
            .collect::<Vec<_>>();

        let transitions2 = input
            .iter()
            .filter_map(|s| {
                if s.starts_with('(') {
                    Some(s.trim_matches(|c| c == ')' || c == '('))
                } else {
                    None
                }
            })
            .map(|l| {
                l.split(',')
                    .map(|s| s.parse::<usize>().unwrap())
                    .collect::<Vec<_>>()
            })
            .collect::<Vec<_>>();
        let reqs = input
            .iter()
            .find(|s| s.starts_with('{'))
            .unwrap()
            .trim_matches(|c| c == '{' || c == '}')
            .split(',')
            .map(|s| s.parse::<u32>().unwrap())
            .collect::<Vec<_>>();

        Machine {
            lights,
            transitions,
            transitions2,
            reqs,
        }
    }
}
fn main() -> Result<()> {
    let s = std::fs::read_to_string("input/day10.txt")?;

    let split_lines = s
        .lines()
        .map(|line| line.split(' ').collect::<Vec<_>>())
        .collect::<Vec<_>>();

    let machines = split_lines
        .iter()
        .map(|input| Machine::read(input))
        .collect::<Vec<_>>();
    println!("{machines:?}");

    let res = machines
        .iter()
        .map(|machine| {
            dijkstra(
                &0,
                |state| {
                    machine
                        .transitions
                        .iter()
                        .map(|transition| (state ^ transition, 1))
                        .collect::<Vec<_>>()
                },
                |state| *state == machine.lights,
            )
            .unwrap()
            .0
            .len()
                - 1
        })
        .sum::<usize>();
    // .collect::<Vec<_>>();

    println!("res: {res}");

    let mut res = 0f64;
    for machine in &machines {
        let mut vars = variables!();
        let a = machine
            .transitions2
            .iter()
            .map(|_tr| vars.add(variable().integer().min(0)))
            .collect::<Vec<_>>();
        // println!("a len: {}", a.len());
        // println!("reqs: {:?}", machine.reqs);
        let mut model = vars
            .minimise(Expression::sum(a.iter()))
            .using(good_lp::default_solver);
        for (i, b) in machine.reqs.iter().enumerate() {
            let sel_a = machine
                .transitions2
                .iter()
                .zip(a.iter())
                .filter_map(|(tr, a)| {
                    // println!("tr: {tr:?} i: {i}");
                    if tr.contains(&i) { Some(a) } else { None }
                });
            // println!("a_sel: {:?}", a);
            model = model.with(constraint::eq(Expression::sum(sel_a), *b))
        }
        let solution = model.solve();
        match solution {
            Ok(sol) => {
                let sum = sol.eval(Expression::sum(a.iter()));
                res += sum;
                println!("Minimal Sum: {sum}");
            }

            Err(e) => println!("Solving failed: {:?}", e),
        }
    }
    println!("res2: {res}");
    Ok(())
}
