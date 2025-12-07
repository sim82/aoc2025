use std::collections::HashSet;

type Result<T> = anyhow::Result<T>;

fn main() -> Result<()> {
    let s = std::fs::read_to_string("input/day07.txt")?;

    let splitter_lines: Vec<HashSet<_>> = s
        .lines()
        .map(|line| {
            line.chars()
                .enumerate()
                .filter_map(|(i, c)| if c == '^' { Some(i) } else { None })
                .collect::<HashSet<_>>()
        })
        .skip(1)
        .collect();

    let beams_init: HashSet<_> = s
        .lines()
        .next()
        .unwrap()
        .char_indices()
        .filter_map(|(i, c)| if c == 'S' { Some(i) } else { None })
        .collect();

    {
        let mut beams = beams_init.clone();
        let mut num_splits = 0;
        for splitters in &splitter_lines {
            let hit_splitters: HashSet<_> = beams.intersection(splitters).collect();
            num_splits += hit_splitters.len();
            let new_beams = hit_splitters
                .iter()
                .flat_map(|i| [*i - 1, *i + 1])
                .collect::<HashSet<_>>();
            let non_shaded: HashSet<_> = beams.difference(splitters).cloned().collect();
            beams = new_beams.union(&non_shaded).cloned().collect();
            // max_beams = beams.len().max(max_beams);
        }
        println!("splits: {num_splits}");
    }

    {
        let mut timelines: Vec<_> = s
            .lines()
            .next()
            .unwrap()
            .chars()
            .map(|c| if c == 'S' { 1u64 } else { 0u64 })
            .collect();
        for splitters in s.lines().skip(1) {
            let splitters: Vec<_> = splitters.chars().collect();
            let mut new_timelines = vec![0u64; timelines.len()];
            for i in 0..timelines.len() {
                if splitters[i] == '^' {
                    new_timelines[i - 1] += timelines[i];
                    new_timelines[i + 1] += timelines[i];
                } else {
                    new_timelines[i] += timelines[i];
                }
            }
            // println!("timelines: {:?}", timelines);
            timelines = new_timelines;
        }
        println!("timelines: {}", timelines.iter().sum::<u64>());
    }
    Ok(())
}
