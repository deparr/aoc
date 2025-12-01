import * as adlib from "./adlib.ts";

function partOne(input: string): number {
    let password = 0;
    let dial = 50;
    for (const line of input.split("\n")) {
        const sign = line[0] === "L" ? -1 : 1;
        const turns = parseInt(line.substring(1));

        dial = (((dial + turns * sign) % 100) + 100) % 100;

        if (dial == 0)
            password += 1;
    }

    return password;
}

function partTwo(input: string): number {
    let password = 0;
    let dial = 50;
    for (const line of input.split("\n")) {
        const sign = line[0] === "L" ? -1 : 1;
        const turns = parseInt(line.substring(1));
        const mod_turns = turns % 100;

        if ((sign < 0 && dial !== 0 && mod_turns > dial) || (sign > 0 && dial + mod_turns > 100))
            password += 1;

        dial = (((dial + turns * sign) % 100) + 100) % 100;

        if (dial === 0)
            password += 1;

        password += (turns / 100) | 0;
    }

    return password;
}

export async function main() {
    const input = (await Bun.stdin.text()).trim();

    const res = partOne(input);
    const res2 = partTwo(input);

    console.log(`part one: ${res}\npart two: ${res2}\n`);
}

if (import.meta.main) await main();
