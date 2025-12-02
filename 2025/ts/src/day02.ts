import * as adlib from "./adlib.ts";

function partOne(input: string): number {
    let sum = 0;
    for (const range of input.split(",")) {
        const [lo, hi] = range.split("-").map((v) => parseInt(v) ?? 0);

        for (let id = lo; id <= hi; id++) {
            const idStr = id.toString();
            if (idStr.length % 2 != 0) continue;
            if (idStr.slice(0, idStr.length / 2) === idStr.slice(idStr.length / 2))
                sum += id;
        }
    }

    return sum;
}

function partTwo(input: string): number {
    let sum = 0;
    for (const range of input.split(",")) {
        const [lo, hi] = range.split("-").map((v) => parseInt(v) ?? 0);

        for (let id = lo; id <= hi; id++) {
            const idStr = id.toString();

            for (let pat_len = 1; pat_len < 7; pat_len++) {
                if (pat_len >= idStr.length) break;
                if (idStr.length % pat_len != 0) continue;

                if (idStr == idStr.slice(0, pat_len).repeat(idStr.length / pat_len)) {
                    sum += id;
                    break;
                }
            }
        }
    }

    return sum;
}

export async function main() {
    const input = (await Bun.stdin.text()).trim();

    const res = partOne(input);
    const res2 = partTwo(input);

    console.log(`part one: ${res}\npart two: ${res2}\n`);
}

if (import.meta.main) await main();
