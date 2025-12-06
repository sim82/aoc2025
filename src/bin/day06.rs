type Result<T> = anyhow::Result<T>;

fn main() -> Result<()> {
    let s = std::fs::read_to_string("input/day06.txt")?;
    let lines = s.lines().collect::<Vec<_>>();
    let number_lines = &lines[..(lines.len() - 1)];
    let symbols = lines[lines.len() - 1];
    let numbers = number_lines
        .iter()
        .map(|line| {
            line.split_whitespace()
                .map(|n| u64::from_str_radix(n.trim(), 10).unwrap())
                .collect::<Vec<_>>()
        })
        .collect::<Vec<_>>();
    let mut sum = 0;
    for (i, sym) in symbols.split_whitespace().enumerate() {
        let res = match sym.trim() {
            "+" => numbers.iter().map(|ns| ns[i]).sum::<u64>(),
            _ => numbers.iter().map(|ns| ns[i]).product::<u64>(),
        };
        println!("{res}");
        sum += res;
    }
    println!("sum: {sum}");

    let mut x = 0;
    let symbols = symbols.chars().collect::<Vec<_>>();
    let numbers = number_lines
        .iter()
        .map(|line| line.chars().collect::<Vec<_>>())
        .collect::<Vec<_>>();
    let mut sum = 0;
    while x < symbols.len() {
        let sym = symbols[x];
        if sym == ' ' {
            x += 1;
            continue;
        }

        let mut nums = Vec::new();
        while x < symbols.len() {
            let mut cur = Vec::new();
            for line in numbers.iter() {
                cur.push(line[x]);
            }
            let num = &cur.iter().collect::<String>();
            println!("'{num}'");
            x += 1;
            if let Ok(num) = u64::from_str_radix(num.trim(), 10) {
                nums.push(num);
            } else {
                break;
            }
        }
        let res = match sym {
            '+' => nums.iter().sum::<u64>(),
            _ => nums.iter().product::<u64>(),
        };
        sum += res;
    }
    println!("{sum}");

    Ok(())
}
