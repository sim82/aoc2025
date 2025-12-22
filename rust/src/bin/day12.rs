use std::{fmt::Debug, iter::Sum};

type Result<T> = anyhow::Result<T>;

#[derive(Clone)]
struct Shape([[u8; 3]; 3]);
fn shapes_ex() -> [Shape; 6] {
    let shapes = [
        // 0
        // ###
        // ##.
        // ##.
        Shape([[1, 1, 1], [1, 1, 0], [1, 1, 0]]),
        //1
        // ###
        // ##.
        // .##
        Shape([[1, 1, 1], [1, 1, 0], [0, 1, 1]]),
        // 2
        // .##
        // ###
        // ##.
        Shape([[0, 1, 1], [1, 1, 1], [1, 1, 0]]),
        // 3
        // ##.
        // ###
        // ##.
        Shape([[1, 1, 0], [1, 1, 1], [1, 1, 0]]),
        // 4
        // ###
        // #..
        // ###
        Shape([[1, 1, 1], [1, 0, 0], [1, 1, 1]]),
        // 5
        // ###
        // .#.
        // ###
        Shape([[1, 1, 1], [0, 1, 0], [1, 1, 1]]),
    ];
    return shapes;
}

trait Transform {
    fn flip_h(&self) -> Self;
    fn flip_v(&self) -> Self;
    fn flip_d1(&self) -> Self;
    fn flip_d2(&self) -> Self;
    fn rot_90(&self) -> Self;
    fn rot_180(&self) -> Self;
    fn rot_270(&self) -> Self;
}
impl Transform for Shape {
    fn flip_h(&self) -> Self {
        let mut s = self.clone();
        for row in &mut s.0 {
            row.reverse();
        }
        s
    }
    fn flip_v(&self) -> Self {
        let mut s = self.clone();
        s.0.reverse();
        s
    }

    fn flip_d1(&self) -> Self {
        let s = self.0;
        Shape([
            [s[0][0], s[1][0], s[2][0]],
            [s[0][1], s[1][1], s[2][1]],
            [s[0][2], s[1][2], s[2][2]],
        ])
    }
    fn flip_d2(&self) -> Self {
        let s = self.0;
        Shape([
            [s[2][2], s[1][2], s[0][2]],
            [s[2][1], s[1][1], s[0][0]],
            [s[2][0], s[1][0], s[2][0]],
        ])
    }
    fn rot_90(&self) -> Self {
        let s = self.0;
        Shape([
            [s[2][0], s[1][0], s[0][0]],
            [s[2][1], s[1][1], s[0][1]],
            [s[2][2], s[1][2], s[0][2]],
        ])
    }
    fn rot_180(&self) -> Self {
        self.rot_90().rot_90()
    }
    fn rot_270(&self) -> Self {
        self.rot_90().rot_90().rot_90()
    }
}
impl Debug for Shape {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        for row in self.0 {
            // row.iter().map(|i| i != 0 { '#' } else {'.'})
            for c in row {
                if c != 0 {
                    write!(f, "#");
                } else {
                    write!(f, ".");
                }
            }
            writeln!(f);
        }
        Ok(())
    }
}

fn main() -> Result<()> {
    let s = std::fs::read_to_string("input/day10.txt")?;

    let shapes = shapes_ex();

    for shape in &shapes {
        // println!(
        //     "{shape:?}\n{:?}\n{:?}\n{:?}\n{:?}\n{:?}\n{:?}\n{:?}\n{:?}\n{:?}\n{:?}{:?}",
        //     shape.rot_90(),
        //     shape.rot_180(),
        //     shape.rot_270(),
        //     shape.flip_h(),
        //     shape.flip_h().rot_90(),
        //     shape.flip_h().rot_180(),
        //     shape.flip_h().rot_270(),
        //     shape.flip_v(),
        //     shape.flip_v().rot_90(),
        //     shape.flip_v().rot_180(),
        //     shape.flip_v().rot_270()
        // );
        println!(
            "------\n{:?}\n{:?}\n{:?}\n{:?}\n{:?}\n{:?}\n{:?}\n{:?}",
            shape,
            shape.rot_90(),
            shape.rot_180(),
            shape.rot_270(),
            shape.flip_h(),
            shape.flip_v(),
            shape.flip_d1(),
            shape.flip_d2(),
        );
    }
    Ok(())
}
