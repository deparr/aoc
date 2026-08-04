import { Queue } from "./adlib.ts";
interface ButtonState {
    state: number;
    presses: number;
}

function partOne(input: string): number {
    const lines = input.trim().split("\n");
    let total_min_presses = 0;
    const processed = new Set<number>();
    const queue = new Queue<ButtonState>(100);
    for (const line of lines) {
        if (line[0] != "[") {
            console.log("bad line");
            continue;
        }
        const target_str = line.slice(1, line.indexOf("]"));
        let target_state = 0;
        const button_len = target_str.length;
        for (let i = 0; i < target_str.length; i++) {
            if (target_str[i] == "#") {
                target_state |= 1 << (button_len - 1 - i);
            }
        }

        const buttons = line.matchAll(/\(([\d,]+)\)/g).toArray().map((match) =>
            match[1].split(",").map((x) => parseInt(x)).reduce(
                (acc, n) => acc | (1 << (button_len - n - 1)),
                0,
            )
        );

        // console.log(buttons.map((x) => x.toString(2).padStart(button_len, "0")), target_state.toString(2));

        queue.push({ state: 0, presses: 0 });
        processed.add(0);
        let current_min_presses = 1 << 22;

        while (!queue.isEmpty()) {
            const next = queue.pop();
            if (!next) {
                console.log("bad item from queue");
                break;
            }
            if (next.state === target_state) {
                current_min_presses = next.presses < current_min_presses
                    ? next.presses
                    : current_min_presses;
                continue;
            }
            if (next.presses >= current_min_presses) continue;
            for (const button of buttons) {
                const new_state = next.state ^ button;
                if (!processed.has(new_state)) {
                    processed.add(new_state);
                    // console.log("++:", next.state.toString(2).padStart(button_len, "0"), "^", button.toString(2).padStart(button_len, "0"), "->", new_state.toString(2).padStart(button_len, "0"));
                    queue.push({ state: new_state, presses: next.presses + 1 });
                }
            }
        }
        if (current_min_presses != 1 << 22) {
            total_min_presses += current_min_presses;
        }
        queue.clear();
        processed.clear();
    }

    return total_min_presses;
}

function partTwo(_input: string): number {
    return 0;
}

export async function main() {
    const input = await new Response(Deno.stdin.readable).text();

    const start = Temporal.Now.instant().epochMilliseconds;
    const res = partOne(input);
    console.log(Temporal.Now.instant().epochMilliseconds - start);
    const res2 = partTwo(input);

    console.log(`part one: ${res}\npart two: ${res2}\n`);
}

if (import.meta.main) await main();
