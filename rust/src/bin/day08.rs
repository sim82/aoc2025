use std::collections::HashSet;

type Result<T> = anyhow::Result<T>;

// type Vec3 = nalgebra::Vector3<f32>;

fn main() -> Result<()> {
    let s = std::fs::read_to_string("../input/day08.txt")?;

    let vs: Vec<(i32, i32, i32)> = s
        .lines()
        .map(|line| {
            let mut cs = line.split(',');
            let x = cs.next().unwrap();
            let y = cs.next().unwrap();
            let z = cs.next().unwrap();
            // Vec3::new
            (x.parse().unwrap(), y.parse().unwrap(), z.parse().unwrap())
        })
        .collect();

    let mut dists = Vec::new();
    for i in 0..vs.len() {
        for j in 0..i {
            // dists.push((vs[i].metric_distance(&vs[j]) as i32, i, j));
            let (xi, yi, zi) = vs[i];
            let (xj, yj, zj) = vs[j];
            let dx = (xi - xj) as f32;
            let dy = (yi - yj) as f32;
            let dz = (zi - zj) as f32;
            let d = (dx * dx) + (dy * dy) + (dz * dz);
            dists.push((d.sqrt() as i32, i, j));
        }
    }

    dists.sort_by_key(|(d, _, _)| *d);
    let mut graphs: Vec<HashSet<usize>> = Default::default();
    let mut iter = 0;
    let mut res2_done = false;
    for (_, i, j) in dists.iter() {
        let gi = graphs
            .iter()
            .enumerate()
            .find_map(|(idx, g)| g.get(i).map(|_| idx));
        let gj = graphs
            .iter()
            .enumerate()
            .find_map(|(idx, g)| g.get(j).map(|_| idx));

        match (gi, gj) {
            (None, None) => {
                graphs.push([*i, *j].iter().cloned().collect());
            }
            (None, Some(gj)) => {
                graphs[gj].insert(*i);
            }
            (Some(gi), None) => {
                graphs[gi].insert(*j);
            }
            (Some(gi), Some(gj)) => {
                if gi != gj {
                    graphs[gi] = graphs[gi].union(&graphs[gj]).cloned().collect();
                    graphs.remove(gj);
                }
            }
        }
        iter += 1;
        if iter == 1000 {
            let mut sizes: Vec<_> = graphs.iter().map(|g| g.len()).collect();
            sizes.sort();
            let res = sizes[sizes.len() - 1] * sizes[sizes.len() - 2] * sizes[sizes.len() - 3];
            println!("res1: {res}");
        }
        if graphs.len() == 1 && graphs[0].len() == vs.len() && !res2_done {
            let res2 = vs[*i].0 * vs[*j].0;
            res2_done = true;
            println!("res2: {res2}");
        }
    }
    Ok(())
}
