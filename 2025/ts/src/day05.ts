
function partOne(ranges: Range[], subjects: number[]): number {
    let valid_count = 0;
    for (const s of subjects) {
        for (const r of ranges) {
            if (rangeContains(r, s)) {
                valid_count += 1;
                break;
            }
        }
    }

    return valid_count;
}

function partTwo(ranges: Range[]): number {
    ranges.sort(rangeLessThan);
    let valid_count = 0;
    for (let i = 0; i < ranges.length;) {
        let range = ranges[i];
        let j = i + 1;
        while (j < ranges.length && rangeOverlaps(range, ranges[j])) {
            range = rangeMerge(range, ranges[j]);
            j += 1;
        }
        i = j;
        valid_count += range.hi + 1 - range.lo;
    }
    return valid_count;
}


interface Range {
    lo: number,
    hi: number
};

function rangeContains(range: Range, n: number): boolean {
    return n >= range.lo && n <= range.hi;
}

function rangeOverlaps(a: Range, b: Range): boolean {
    return a.hi >= b.lo || b.hi <= a.lo;
}

function rangeMerge(a: Range, b: Range): Range {
    return { lo: Math.min(a.lo, b.lo), hi: Math.max(a.hi, b.hi) };
}

function rangeLessThan(a: Range, b: Range): number {
    if (a.lo === b.lo)
        return a.hi - b.hi;
    return a.lo - b.lo;
}

export async function main() {
    const input = await new Response(Deno.stdin.readable).text();

    const ranges: Range[] = []
    const subjects: number[] = []
    const lines = input.trim().split("\n");
    let subject_start = -1;
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        if (line.length == 0) {
            subject_start = i + 1;
            break;
        }

        const [lo, hi] = line.split("-").map((s) => parseInt(s));
        ranges.push({lo, hi});
    }

    for (const subject of lines.slice(subject_start)) subjects.push(parseInt(subject));

    const res = partOne(ranges, subjects);
    const res2 = partTwo(ranges, subjects);

    console.log(`part one: ${res}\npart two: ${res2}\n`);
}

if (import.meta.main) await main();
