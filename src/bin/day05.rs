use std::{collections::HashSet, iter, ops::RangeInclusive};

use anyhow::anyhow;
type Result<T> = anyhow::Result<T>;

type MyRange = RangeInclusive<u64>;
fn intersect(r1: &MyRange, r2: &MyRange) -> Option<MyRange> {
    if r1.start() > r2.end() || r2.start() > r1.end() {
        return None;
    }

    Some((*r1.start().min(r2.start()))..=(*r1.end().max(r2.end())))
}
fn main() -> Result<()> {
    let s = std::fs::read_to_string("input/day05.txt")?;
    let (part1, part2) = s.split_once("\n\n").unwrap();
    // println!("'{part1}'\n'{part2}'");
    let mut ranges = part1
        .lines()
        .map(|line| {
            let (start, end) = line.split_once('-').unwrap();
            u64::from_str_radix(start, 10).unwrap()..=u64::from_str_radix(end, 10).unwrap()
        })
        .collect::<Vec<_>>();
    let ids = part2
        .lines()
        .map(|line| u64::from_str_radix(line.trim(), 10).unwrap())
        .collect::<Vec<_>>();
    let num = ids
        .iter()
        .filter(|id| ranges.iter().any(|range| range.contains(id)))
        .count();
    println!("{num}");

    let min_ranges = loop {
        println!("merge loop");
        let mut min_ranges = Vec::new();
        for r in &ranges {
            if let Some((i, ir)) = min_ranges
                .iter()
                .enumerate()
                .find_map(|(i, mr)| intersect(&r, mr).map(|ir| (i, ir)))
            {
                println!("merge: {:?} {:?} -> {:?}", r, min_ranges[i], ir);
                min_ranges[i] = ir;
            } else {
                min_ranges.push(r.clone());
            }
        }
        if ranges == min_ranges {
            break min_ranges;
        }
        ranges = min_ranges;
    };

    println!("ranges: {min_ranges:?}");
    let num_fresh = min_ranges
        .iter()
        .map(|r| r.end() - r.start() + 1)
        .sum::<u64>();
    println!("{num_fresh}");
    Ok(())
}
