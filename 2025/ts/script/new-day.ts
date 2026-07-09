const year = "2025";
const maxDays = 12;

async function main(): Promise<number> {
    const day = Deno.args[0];
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

    let cookie = Deno.env.get("AOC_COOKIE");
    if (!cookie) {
        cookie = Deno.readTextFileSync("aoc-cookie").trim();
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

    const input = await res.text();
    Deno.writeTextFileSync(`input/${dayNum}`, input);

    const dayFile = `src/day${day.padStart(2, "0")}.ts`
    Deno.copyFileSync("src/template.ts", dayFile);

    console.log("created " + dayFile, "and its input");
    return 0;
}

if (import.meta.main) Deno.exit(await main());
