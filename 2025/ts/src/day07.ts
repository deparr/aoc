function solve(grid: string[][]): { splits: number, pathways: number } {
    const beams = new Array<number>(grid[0].length);
    beams.fill(0);
    beams[grid[0].indexOf("S")] = 1;
    let splits = 0;
    for (const row of grid.slice(1)) {
        for (let i = 0; i < beams.length; i++) {
            if (beams[i] > 0 && row[i] === "^") {
                splits += 1;
                if (i > 0) beams[i - 1] += beams[i];
                if (i < beams.length - 1) beams[i + 1] += beams[i];
                beams[i] = 0;
            }
        }
    }
    const pathways = beams.reduce((acc, x) => acc + x, 0);
    return { splits, pathways };
}

export async function main() {
    const input = await new Response(Deno.stdin.readable).text();
    const grid = input.trim().split("\n").map((s) => s.split(""));
    const { splits, pathways } = solve(grid);

    console.log(`part one: ${splits}\npart two: ${pathways}\n`);
}

if (import.meta.main) await main();
