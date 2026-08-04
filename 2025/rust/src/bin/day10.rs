use std::collections::{HashSet, VecDeque};

#[derive(Debug)]
struct ButtonState {
    state: u16,
    presses: u32,
}

fn part_one(input: &String) -> u64 {
    let mut total_min_presses = 0;
    let mut processed: HashSet<u16> = HashSet::new();
    let mut queue = VecDeque::new();

    for line in input.lines() {
        let close_bracket = line.find(']').unwrap();
        let target_len = close_bracket - 1;
        let mut target_state = 0;
        let line_bytes = line.as_bytes();
        for i in 1..close_bracket {
            if line_bytes[i] == b'#' {
                target_state |= 1 << (target_len - i);
            }
        }
        let mut buttons: Vec<u16> = vec![];

        let brack_end = line.find(']').unwrap();
        let brace_start = line.find('{').unwrap();
        for button_str in line[brack_end + 1..brace_start].split(' ') {
            if button_str.len() == 0 {
                continue;
            }
            let mut button = 0;
            for digit_str in button_str.matches(char::is_numeric) {
                let num: usize = digit_str.parse().unwrap();
                button |= 1 << (target_len - 1 - num);
            }
            buttons.push(button);
        }

        let mut min_presses = u64::MAX;
        queue.push_back(ButtonState {
            state: 0,
            presses: 0,
        });
        processed.insert(0);

        while !queue.is_empty() {
            let next = queue.pop_front().unwrap();
            if next.state == target_state {
                min_presses = min_presses.min(next.presses as u64);
                continue;
            }
            if (next.presses as u64) >= min_presses {
                continue;
            }

            for button in buttons.iter() {
                let new_state = next.state ^ button;
                if !processed.contains(&new_state) {
                    processed.insert(new_state);
                    queue.push_back(ButtonState {
                        state: new_state,
                        presses: next.presses + 1,
                    });
                }
            }
        }

        if min_presses != u64::MAX {
            total_min_presses += min_presses;
        }
        queue.clear();
        processed.clear();
    }

    return total_min_presses;
}

pub fn main() -> Result<(), std::io::Error> {
    let input = std::fs::read_to_string("input/10")?;
    let res_1 = part_one(&input);
    println!("part_one: {}", res_1);
    Ok(())
}
