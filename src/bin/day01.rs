use std::iter;

type Result<T> = anyhow::Result<T>;
// use nom::{
//     IResult,
//     branch::alt,
//     character::complete::{char, tag, take_while_m_n},
//     character::one_of,
//     combinator::{map_res, recognize},
//     multi::{many0, many1},
//     sequence::{preceded, terminated},
// };

// fn decimal(input: &str) -> IResult<&str, &str> {
//     recognize(many1(terminated(one_of("0123456789"), many0(char('_'))))).parse(input)
// }
// fn lr_number(input: &str) -> IResult<&str, i64> {
//     alt((preceded(tag("L"), decimal), preceded(tag("R"), decimal)))
// }
//
fn line_to_num(line: &str) -> Result<i64> {
    // let line = line.as_bytes();

    let n = if line[0..1] == *"R" {
        i64::from_str_radix(&line[1..], 10)?
    } else {
        -i64::from_str_radix(&line[1..], 10)?
    };

    Ok(n)
}
fn main() -> Result<()> {
    let s = std::fs::read_to_string("input/day01_1.txt")?;
    let zeros = s
        .lines()
        .filter_map(|line| line_to_num(line).ok())
        .scan(50, |acc, i| {
            *acc += i;
            let wrap_click = if (*acc % 100) == 0 { 1 } else { 0 };

            Some(wrap_click)
        })
        .sum::<i64>();
    println!("password 1: {}", zeros);
    let zeros = s
        .lines()
        .filter_map(|line| line_to_num(line).ok())
        .flat_map(|i| iter::repeat_n(i.signum(), i.unsigned_abs() as usize))
        .scan(50, |acc, i| {
            *acc += i;
            let wrap_click = if (*acc % 100) == 0 { 1 } else { 0 };

            Some(wrap_click)
        })
        .sum::<i64>();
    println!("password 2: {}", zeros);
    Ok(())
}
