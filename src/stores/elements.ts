import { writable } from "svelte/store";

export const astroWrapper = writable<HTMLDivElement>();
export const astroEditor = writable<HTMLDivElement>();
export const app = writable<HTMLDivElement>();
export const lineNumbers = writable<HTMLDivElement>();
export const astroWrapperInner = writable<HTMLDivElement>();