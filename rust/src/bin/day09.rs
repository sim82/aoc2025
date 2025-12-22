use std::iter::once;

type Result<T> = anyhow::Result<T>;

fn vmin(v0: &(i64, i64), v1: &(i64, i64)) -> (i64, i64) {
    (v0.0.min(v1.0), v0.1.min(v1.1))
}

fn vmax(v0: &(i64, i64), v1: &(i64, i64)) -> (i64, i64) {
    (v0.0.max(v1.0), v0.1.max(v1.1))
}

#[derive(Debug)]
enum Wall {
    H(i64, i64, i64),
    V(i64, i64, i64),
}
impl Wall {
    fn intersects(&self, vmin: &(i64, i64), vmax: &(i64, i64)) -> bool {
        // let vmin = vmin(v0, v1);
        // let vmax = vmax(v0, v1);
        match self {
            Wall::H(y, xmin, xmax) => {
                *xmax > vmin.0 && *xmin < vmax.0 && *y > vmin.1 && *y < vmax.1
            }
            Wall::V(x, ymin, ymax) => {
                *ymax > vmin.1 && *ymin < vmax.1 && *x > vmin.0 && *x < vmax.0
            }
        }
    }
}
fn main() -> Result<()> {
    let s = std::fs::read_to_string("input/day09.txt")?;

    let vs: Vec<(i64, i64)> = s
        .lines()
        .map(|line| {
            let mut cs = line.split(',');
            let x = cs.next().unwrap();
            let y = cs.next().unwrap();
            (x.parse().unwrap(), y.parse().unwrap())
        })
        .collect();
    let max_area = vs
        .iter()
        .enumerate()
        .flat_map(|(i, v0)| {
            vs[0..i]
                .iter()
                .map(|v1| (v0.0.abs_diff(v1.0) + 1) * (v0.1.abs_diff(v1.1) + 1))
        })
        .max()
        .unwrap();

    println!("res: {max_area}");

    let iter2 = vs.iter().skip(1).cloned().chain(once(vs[0]));
    let walls: Vec<_> = vs
        .iter()
        .zip(iter2)
        .map(|(v0, v1)| {
            let vmin = vmin(v0, &v1);
            let vmax = vmax(v0, &v1);
            if v0.0 == v1.0 {
                Wall::V(v0.0, vmin.1, vmax.1)
            } else if v0.1 == v1.1 {
                Wall::H(v0.1, vmin.0, vmax.0)
            } else {
                panic!("bad wall")
            }
        })
        .collect();

    let max_area = vs
        .iter()
        .enumerate()
        .flat_map(|(i, v0)| {
            vs[0..i].iter().filter_map(|v1| {
                if walls
                    .iter()
                    .any(|wall| wall.intersects(&vmin(v0, v1), &vmax(v0, v1)))
                {
                    None
                } else {
                    Some((v0.0.abs_diff(v1.0) + 1) * (v0.1.abs_diff(v1.1) + 1))
                }
            })
        })
        .max()
        .unwrap();

    println!("res2: {max_area}");
    Ok(())
}
