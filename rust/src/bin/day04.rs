use std::collections::HashSet;

type Result<T> = anyhow::Result<T>;
fn main() -> Result<()> {
    let s = std::fs::read_to_string("input/day04.txt")?;
    let mut crates = s
        .lines()
        .enumerate()
        .flat_map(|(y, line)| {
            line.chars().enumerate().filter_map(move |(x, c)| {
                if c == '@' {
                    Some((x as i32 + 1, y as i32 + 1))
                } else {
                    None
                }
            })
        })
        .collect::<HashSet<_>>();

    let ns: [(i32, i32); 8] = [
        (-1, -1),
        (-1, 0),
        (-1, 1),
        (0, -1),
        (0, 1),
        (1, -1),
        (1, 0),
        (1, 1),
    ];
    let num = crates
        .iter()
        .filter(|(x, y)| {
            ns.iter()
                .map(|(nx, ny)| (x + nx, y + ny))
                .filter(|c| crates.contains(c))
                .count()
                < 4
        })
        .count();
    println!("{num}");

    let num_initial = crates.len();
    loop {
        println!("{}", crates.len());
        let new_crates = crates
            .iter()
            .filter(|(x, y)| {
                ns.iter()
                    .map(|(nx, ny)| (x + nx, y + ny))
                    .filter(|c| crates.contains(c))
                    .count()
                    >= 4
            })
            .cloned()
            .collect::<HashSet<_>>();
        if crates.len() == new_crates.len() {
            break;
        }
        crates = new_crates;
    }
    println!("{}", num_initial - crates.len());
    Ok(())
}
