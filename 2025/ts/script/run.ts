import { $ } from "bun";

let selectedDay: number | undefined;
if (process.argv.length >= 3) {
    selectedDay = parseInt(process.argv[2] || "1");
} else {
    const raw = await $`ls src | rg day`.text().catch(() => {
        console.log("no days yet!");
        process.exit(0);
    });

    selectedDay = raw.trim().split("\n").map((e) => {
        return parseInt(e.replaceAll(/[a-zA-Z_\.]/g, ""))
    }).sort().at(-1);
}

if (!selectedDay) {
    console.log("invalid day", selectedDay);
} else {
    let dayString = selectedDay.toString().padStart(2, "0");
    await $`bun src/day${dayString}.ts < input/${selectedDay}`;
}
