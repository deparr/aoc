#!/usr/bin/env bun

const day = process.argv[2];
if (!day) {
    console.error("Expected day number argument");
    process.exit(1);
}

const dayNum = 0 | parseInt(day);

if (dayNum < 0) {
    console.log(`invalid day: ${dayNum}`);
    process.exit(1);
}

if (dayNum > 12) {
    console.log("Advent of Code is over, Mery Chirstmas 🎄!");
    process.exit(0);
}

let cookie = process.env["AOC_COOKIE"];
if (!cookie) {
    const file = Bun.file("aoc-cookie");
    cookie = await file.text();
}
cookie = cookie.trim();

const res = await fetch(`https://adventofcode.com/2024/day/${dayNum}/input`, {
    method: "GET",
    headers: {
        Cookie: `session=${cookie}`,
    },
}).catch(() => null);
if (!res || !res.ok) {
    console.log("res error: ", res?.status, res?.statusText);
    process.exit(1);
}

if (!res.body) {
    console.log("res has no body");
    process.exit(1);
}

const input = await res.body.text();

Bun.write(`input/${dayNum}`, input);


const dayFile = `src/day${day.padStart(2, "0")}.ts`
const template = await Bun.file("src/template.ts").bytes();
Bun.write(dayFile, template);

console.log("created", dayFile);
