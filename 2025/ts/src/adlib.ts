export class Queue<T> {
    front: number = 0;
    back: number = 0;
    buffer: Array<T> = [];

    constructor(capacity: number) {
        this.buffer = new Array(capacity);
    }

    pop(): T | undefined {
        if (this.isEmpty()) return undefined;
        const value = this.buffer[this.mask(this.front)];
        this.front = this.mask2(this.front + 1);
        return value;
    }

    push(value: T): void {
        if (this.isFull()) {
            this.resize();
        }
        this.buffer[this.mask(this.back)] = value;
        this.back = this.mask2(this.back + 1);
    }

    len(): number {
        const wrap_offset = 2 * this.buffer.length * Number(this.back < this.front);
        const adjusted_back = this.back + wrap_offset;
        return adjusted_back - this.front;
    }

    isFull(): boolean {
        return this.mask2(this.back + this.buffer.length) == this.front;
    }

    isEmpty(): boolean {
        return this.front == this.back;
    }

    resize(): void {
        const new_len = (this.buffer.length * 9 / 5) | 0;
        const new_buffer = new Array<T>(new_len);
        const front = this.front;
        const back = this.back % (this.buffer.length + 1);
        const first = back < front ? this.buffer.slice(front) : this.buffer.slice(front, back);
        const second = back < front ? this.buffer.slice(0, back) : [];
        // const new_buffer = first.concat(second);
        // new_buffer.length = new_len;
        new_buffer.splice(0, first.length, ...first);
        new_buffer.splice(first.length, second.length, ...second);
        this.front = 0;
        this.back = first.length + second.length;
        this.buffer = new_buffer;
    }

    clear(): void {
        this.front = 0;
        this.back = 0;
    }

    private mask(index: number): number {
        return index % this.buffer.length;
    }

    private mask2(index: number): number {
        return index % (2 * this.buffer.length);
    }
}
