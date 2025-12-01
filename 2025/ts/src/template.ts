import * as adlib from "./adlib.ts";

function partOne(input: string): number {
    return 0;
}

function partTwo(input: string): number {
    return 0;
}

export async function main() {
    const input = await Bun.stdin.text();

    const res = partOne(input);
    const res2 = partTwo(input);

    console.log(`part one: ${res}\npart two: ${res2}\n`);
}

if (import.meta.main) await main();
