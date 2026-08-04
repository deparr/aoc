import * as adlib from "./adlib.ts";

function boxAt(grid: string[][], row: number, col: number): 1|0 {
    return grid[row][col] === "." ? 0 : 1;
}

function countAccessibleBoxes(grid: string[][]): number {
    let accessible_boxes = 0;
    for (let i = 0; i < grid.length; i++) {
        const line = grid[i];
        for (let j = 0; j < line.length; j++) {
            if (!boxAt(grid, i, j)) continue;
            let box_count = 0;
            const space_left = j > 0;
            const space_right = j < line.length - 1;
            const space_up = i > 0;
            const space_down = i < grid.length - 1;

            if (space_left) {
                box_count += boxAt(grid, i, j - 1);
                if (space_down) box_count += boxAt(grid, i + 1, j - 1);
                if (space_up) box_count += boxAt(grid, i - 1, j - 1);
            }
            if (space_right) {
                box_count += boxAt(grid, i, j + 1)
                if (space_down) box_count += boxAt(grid, i + 1, j + 1);
                if (space_up) box_count += boxAt(grid, i - 1, j + 1);
            }
            if (space_down) box_count += boxAt(grid, i + 1, j);
            if (space_up) box_count += boxAt(grid, i - 1, j);
            if (box_count < 4) {
                accessible_boxes += 1;
                grid[i][j] = "x";
            }

        }
    }

    return accessible_boxes;
}

function partOne(input: string): number {
    const grid = input.trim().split("\n").map((s) => s.split(""));
    return countAccessibleBoxes(grid);
}

function partTwo(input: string): number {
    const grid = input.trim().split("\n").map((s) => s.split(""));
    let total_accessible = 0;
    while (true) {
        const newly_accessible = countAccessibleBoxes(grid);
        if (newly_accessible == 0) break;
        total_accessible += newly_accessible;

        for (let i = 0; i < grid.length; i++) {
            const row = grid[i];
            for (let j = 0; j < row.length; j++) {
                if (row[j] === "x") row[j] = ".";
            }
        }
    }
    return total_accessible;
}

export async function main() {
    const input = await new Response(Deno.stdin.readable).text();

    const res = partOne(input);
    const res2 = partTwo(input);

    console.log(`part one: ${res}\npart two: ${res2}\n`);
}

if (import.meta.main) await main();
