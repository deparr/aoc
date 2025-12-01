#!/usr/bin/env bun

const year = "2024";
const maxDays = 12;

async function main(): Promise<number> {
    const day = process.argv[2];
    if (!day) {
        console.error("Expected day number argument");
        return 1;
    }

    const dayNum = 0 | parseInt(day);

    if (dayNum < 0) {
        console.log(`invalid day: ${dayNum}`);
        return 1;
    }

    if (dayNum > maxDays) {
        console.log("Advent of Code is over, Mery Chirstmas 🎄!");
        return 0;
    }

    let cookie = process.env["AOC_COOKIE"];
    if (!cookie) {
        const file = Bun.file("aoc-cookie");
        cookie = await file.text();
    }
    cookie = cookie.trim();

    const res = await fetch(`https://adventofcode.com/${year}/day/${dayNum}/input`, {
        method: "GET",
        headers: {
            Cookie: `session=${cookie}`,
        },
    }).catch(() => null);
    if (!res || !res.ok) {
        console.log(`res error: ${res?.status} ${res?.statusText}`);
        return 1;
    }

    if (!res.body) {
        console.log("res has no body");
        return 1;
    }

    const input = await res.body.text();

    await Bun.write(`input/${dayNum}`, input);

    const dayFile = `src/day${day.padStart(2, "0")}.ts`
    const template = await Bun.file("src/template.ts").bytes();
    await Bun.write(dayFile, template);

    console.log("created " + dayFile);
    return 0;
}

if (import.meta.main) process.exit(await main());
