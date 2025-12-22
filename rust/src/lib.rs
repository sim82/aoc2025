use anyhow::Result;
use anyhow::anyhow;
use std::ops::RangeInclusive;

pub fn range_union<T: Copy + Ord>(
    r1: &RangeInclusive<T>,
    r2: &RangeInclusive<T>,
) -> Option<RangeInclusive<T>> {
    if r1.start() > r2.end() || r2.start() > r1.end() {
        return None;
    }

    Some((*r1.start().min(r2.start()))..=(*r1.end().max(r2.end())))
}

pub fn parse_range(s: &str) -> Result<RangeInclusive<u64>> {
    let (start, end) = s
        .trim()
        .split_once('-')
        .ok_or(anyhow!("failed to split range"))?;
    Ok(start.parse()?..=end.parse()?)
}
