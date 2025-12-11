use std::{fmt::Debug, iter::Sum};

use good_lp::{
    Expression, ProblemVariables, Solution, SolverModel, constraint, variable, variables,
};
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

    let res = machines
        .iter()
        .map(
            |Machine {
                 lights,
                 transitions,
                 ..
             }| {
                dijkstra(
                    &0,
                    |state| {
                        let state = *state;
                        transitions
                            .iter()
                            .map(move |transition| (state ^ transition, 1))
                    },
                    |state| *state == *lights,
                )
                .unwrap()
                .1
            },
        )
        .sum::<usize>();

    println!("res: {res}");

    let res = machines
        .iter()
        .map(
            |Machine {
                 transitions2, reqs, ..
             }| {
                let mut vars = ProblemVariables::new();
                let a = vars.add_vector(variable().integer().min(0), transitions2.len());
                let solution = vars
                    .minimise(a.iter().sum::<Expression>())
                    .using(good_lp::default_solver)
                    .with_all(reqs.iter().enumerate().map(|(i, b)| {
                        let sel_a = transitions2
                            .iter()
                            .zip(a.iter())
                            .filter_map(|(tr, a)| if tr.contains(&i) { Some(a) } else { None });
                        constraint!(sel_a.sum::<Expression>() == *b)
                    }))
                    .solve();

                match solution {
                    Ok(sol) => {
                        let sum = sol.eval(a.iter().sum::<Expression>());
                        sum
                    }

                    Err(e) => panic!("Solving failed: {:?}", e),
                }
            },
        )
        .sum::<f64>();
    println!("res2: {res}");
    Ok(())
}
