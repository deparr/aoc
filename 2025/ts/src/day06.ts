function partOne(input: string): number {
    const [str1, str2, str3, str4, op] = input.trim().split("\n").map((s) => s.trim().split(/ +/g));
    const num1 = str1.map((s) => parseInt(s));
    const num2 = str2.map((s) => parseInt(s));
    const num3 = str3.map((s) => parseInt(s));
    const num4 = str4.map((s) => parseInt(s));
    let grand_total = 0;
    for (let i = 0; i < num1.length; i++) {
        let res = 0;
        if (op[i] == "+") {
            res = num1[i] + num2[i] + num3[i] + num4[i];
        } else {
            res = num1[i] * num2[i] * num3[i] * num4[i];
        }
        grand_total += res;
    }
    return grand_total;
}

function partTwo(input: string): number {
    return 0;
}

export async function main() {
    const input = await new Response(Deno.stdin.readable).text();

    const res = partOne(input);
    const res2 = partTwo(input);

    console.log(`part one: ${res}\npart two: ${res2}\n`);
}

if (import.meta.main) await main();
