async function main(): Promise<void> {
    let selectedDay: number | undefined;
    if (Deno.args.length >= 1) {
        selectedDay = parseInt(Deno.args[0] || "1");
    } else {
        const cmd = new Deno.Command("ls", { args: ["src"] });
        const output = await cmd.output();
        if (!output.success) {
            console.log("no days yet!");
            Deno.exit(0);
        }
        const raw = new TextDecoder().decode(output.stdout);
        const days = raw.trim().split("\n").filter((e) => /day/.test(e));
        selectedDay = days.map((e) => {
            return parseInt(e.replaceAll(/[a-zA-Z_\.]/g, ""))
        }).sort().at(-1);
    }

    if (!selectedDay) {
        console.log("invalid day", selectedDay);
        return;
    }

    console.log("day", selectedDay);
    const dayString = selectedDay.toString().padStart(2, "0");
    const { main } = await import(`../src/day${dayString}.ts`);
    return main();
}

if (import.meta.main) await main();
