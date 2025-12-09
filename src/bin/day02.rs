use std::collections::HashSet;

type Result<T> = anyhow::Result<T>;
fn is_invalid(s: &str) -> bool {
    if !s.len().is_multiple_of(2) {
        return false;
    }
    s[..(s.len() / 2)] == s[(s.len() / 2)..]
}
fn is_invalid2(s: &str) -> bool {
    // println!("s: {s}");
    let chars = s.chars().collect::<Vec<_>>();
    for i in 1..=(chars.len() / 2) {
        if chars.chunks(i).collect::<HashSet<_>>().len() == 1 {
            // println!("{s}");
            return true;
        }
    }
    false
}
fn main() -> Result<()> {
    let s = std::fs::read_to_string("input/day02.txt")?;
    let ranges = s
        .trim()
        .split(',')
        .map(|s| {
            let (start, end) = s.split_once('-').unwrap();
            start.parse::<u64>().unwrap()..=end.parse::<u64>().unwrap()
        })
        .collect::<Vec<_>>();

    let sum = ranges
        .iter()
        .flat_map(|range| range.clone().filter(|id| is_invalid(&format!("{id}"))))
        .sum::<u64>();
    println!("{sum}");

    let sum = ranges
        .iter()
        .flat_map(|range| range.clone().filter(|id| is_invalid2(&format!("{id}"))))
        .sum::<u64>();
    println!("{sum}");
    Ok(())
}
