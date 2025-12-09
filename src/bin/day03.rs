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
fn main() -> Result<()> {
    let s = std::fs::read_to_string("input/day03.txt")?;
    let res = s
        .lines()
        .map(|line| {
            let digits = line
                .chars()
                .map(|c| c.to_digit(10).unwrap())
                .collect::<Vec<_>>();
            let mut max1 = u32::MIN;
            let mut i1 = 0;

            for (i, v) in digits[0..(digits.len() - 1)].iter().enumerate() {
                if *v > max1 {
                    max1 = *v;
                    i1 = i
                }
            }
            let mut max2 = u32::MIN;
            for v in &digits[(i1 + 1)..] {
                if *v > max2 {
                    max2 = *v;
                }
            }
            // format!("{}{}", max1, max2)
            max1 * 10 + max2
        })
        .sum::<u32>();
    println!("{}", res);
    let res = s
        .lines()
        .map(|line| {
            let digits = line
                .chars()
                .map(|c| c.to_digit(10).unwrap())
                .collect::<Vec<_>>();

            let mut digits = &digits[..];
            let mut num = 0u64;
            for i in 1..=12 {
                let mut max = u32::MIN;
                let mut imax = 0;
                for (i, v) in digits[..(digits.len() - (12 - i))].iter().enumerate() {
                    if *v > max {
                        max = *v;
                        imax = i;
                    }
                }
                num *= 10;
                num += max as u64;
                digits = &digits[(imax + 1)..];
            }
            num
        })
        .sum::<u64>();
    println!("{}", res);
    Ok(())
}
